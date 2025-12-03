import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:proyecto/features/diagnosis/data/repositories/diagnosis_repository.dart';
import 'package:proyecto/features/diagnosis/data/models/diagnosis_session_model.dart';
import 'package:proyecto/features/diagnosis/data/models/diagnosis_message_model.dart';
import 'package:proyecto/features/diagnosis/data/models/chat_response_model.dart';
import 'package:proyecto/features/diagnosis/data/models/classification_model.dart';
import 'package:proyecto/features/diagnosis/data/models/urgency_model.dart';
import 'package:proyecto/features/diagnosis/data/models/cost_estimate_model.dart';
import 'package:proyecto/features/workshops/data/repositories/workshop_repository.dart';
import 'package:proyecto/features/diagnosis/utils/category_specialty_mapper.dart';
import 'package:proyecto/core/services/location_service.dart';

part 'diagnosis_event.dart';
part 'diagnosis_state.dart';

class DiagnosisBloc extends Bloc<DiagnosisEvent, DiagnosisState> {
  final DiagnosisRepository repository;
  final WorkshopRepository workshopRepository;

  DiagnosisBloc({
    required this.repository,
    required this.workshopRepository,
  }) : super(const DiagnosisInitial()) {
    on<CreateDiagnosisSession>(_onCreateSession);
    on<LoadDiagnosisSessions>(_onLoadSessions);
    on<LoadSessionDetail>(_onLoadSessionDetail);
    on<LoadSessionMessages>(_onLoadSessionMessages);
    on<SendDiagnosisMessage>(_onSendMessage);
    on<ClassifyProblem>(_onClassifyProblem);
    on<GetUrgencyLevel>(_onGetUrgencyLevel);
    on<GetCostEstimate>(_onGetCostEstimate);
    on<ClearDiagnosisState>(_onClearState);
    on<LoadRecommendedWorkshops>(_onLoadRecommendedWorkshops);
    on<LoadActiveSession>(_onLoadActiveSession);
  }

  Future<void> _onCreateSession(
    CreateDiagnosisSession event,
    Emitter<DiagnosisState> emit,
  ) async {
    emit(const DiagnosisLoading());
    try {
      final chatResponse = await repository.createSession(
        vehicleId: event.vehicleId,
        initialMessage: event.initialMessage,
      );

      print('DiagnosisBloc: Session created. ID: ${chatResponse.userMessage.sessionId}');

      final session = DiagnosisSessionModel(
        id: chatResponse.userMessage.sessionId,
        userId: '',
        vehicleId: event.vehicleId,
        status: SessionStatus.ACTIVE,
        startedAt: DateTime.now(),
        messagesCount: 2,
      );

      emit(DiagnosisSessionActive(
        session: session,
        messages: [chatResponse.userMessage, chatResponse.assistantMessage],
        suggestedQuestions: chatResponse.suggestedQuestions,
      ));
    } catch (e) {
      emit(DiagnosisError(e.toString()));
    }
  }

  Future<void> _onLoadSessions(
    LoadDiagnosisSessions event,
    Emitter<DiagnosisState> emit,
  ) async {
    emit(const DiagnosisLoading());
    try {
      final sessions = await repository.getSessions(
        vehicleId: event.vehicleId,
        limit: event.limit,
      );
      emit(DiagnosisSessionsLoaded(sessions));
    } catch (e) {
      emit(DiagnosisError(e.toString()));
    }
  }

  Future<void> _onLoadSessionDetail(
    LoadSessionDetail event,
    Emitter<DiagnosisState> emit,
  ) async {
    emit(const DiagnosisLoading());
    try {
      final session = await repository.getSessionById(event.sessionId);
      final messages = await repository.getMessages(event.sessionId);

      emit(DiagnosisSessionActive(
        session: session,
        messages: messages,
      ));
    } catch (e) {
      emit(DiagnosisError(e.toString()));
    }
  }

  Future<void> _onLoadSessionMessages(
    LoadSessionMessages event,
    Emitter<DiagnosisState> emit,
  ) async {
    try {
      final messages = await repository.getMessages(event.sessionId);

      if (state is DiagnosisSessionActive) {
        final currentState = state as DiagnosisSessionActive;
        emit(currentState.copyWith(messages: messages));
      }
    } catch (e) {
      emit(DiagnosisError(e.toString()));
    }
  }

  Future<void> _onSendMessage(
    SendDiagnosisMessage event,
    Emitter<DiagnosisState> emit,
  ) async {
    print('DiagnosisBloc: _onSendMessage called with sessionId: ${event.sessionId}, content: ${event.content}');
    print('DiagnosisBloc: Current state is: ${state.runtimeType}');

    try {
      final chatResponse = await repository.sendMessage(
        sessionId: event.sessionId,
        content: event.content,
      );

      print('DiagnosisBloc: Message sent successfully, got response');

      if (state is DiagnosisSessionActive) {
        final currentState = state as DiagnosisSessionActive;
        final updatedMessages = List<DiagnosisMessageModel>.from(currentState.messages)
          ..add(chatResponse.userMessage)
          ..add(chatResponse.assistantMessage);

        print('DiagnosisBloc: Updating state with ${updatedMessages.length} messages');
        emit(currentState.copyWith(
          messages: updatedMessages,
          suggestedQuestions: chatResponse.suggestedQuestions,
        ));

        // Automatically classify problem after enough conversation (3+ messages total)
        if (updatedMessages.length >= 3 && currentState.classification == null) {
          print('DiagnosisBloc: Auto-triggering problem classification after conversation');
          add(ClassifyProblem(event.sessionId));
        }
      } else {
        print('DiagnosisBloc: WARNING - State is not DiagnosisSessionActive, it is ${state.runtimeType}');
      }
    } catch (e) {
      print('DiagnosisBloc: Error in _onSendMessage: $e');
      emit(DiagnosisError(e.toString()));
    }
  }

  Future<void> _onClassifyProblem(
    ClassifyProblem event,
    Emitter<DiagnosisState> emit,
  ) async {
    try {
      final classification = await repository.classifyProblem(event.sessionId);

      if (state is DiagnosisSessionActive) {
        final currentState = state as DiagnosisSessionActive;
        emit(currentState.copyWith(classification: classification));

        // Automatically load urgency level
        print('DiagnosisBloc: Classification complete, loading urgency level');
        add(GetUrgencyLevel(event.sessionId));

        // Automatically load cost estimate
        print('DiagnosisBloc: Classification complete, loading cost estimate');
        add(GetCostEstimate(event.sessionId));

        // Get user location and load recommended workshops
        _loadWorkshopsWithLocation(classification.category);

      } else {
        emit(DiagnosisClassified(classification));
      }
    } catch (e) {
      // No interrumpir la conversación si falla la clasificación
      // Solo loguear el error y mantener el estado activo
      print('DiagnosisBloc: Error al clasificar problema (no crítico): $e');

      // Mantener el estado actual sin emitir error
      if (state is! DiagnosisSessionActive) {
        // Solo emitir error si no estamos en una sesión activa
        emit(DiagnosisError(e.toString()));
      }
    }
  }

  Future<void> _onGetUrgencyLevel(
    GetUrgencyLevel event,
    Emitter<DiagnosisState> emit,
  ) async {
    try {
      final urgency = await repository.getUrgency(event.sessionId);

      if (state is DiagnosisSessionActive) {
        final currentState = state as DiagnosisSessionActive;
        emit(currentState.copyWith(urgency: urgency));
      } else {
        emit(DiagnosisUrgencyObtained(urgency));
      }
    } catch (e) {
      // No interrumpir la conversación si falla obtener la urgencia
      print('DiagnosisBloc: Error al obtener urgencia (no crítico): $e');

      if (state is! DiagnosisSessionActive) {
        emit(DiagnosisError(e.toString()));
      }
    }
  }

  Future<void> _onGetCostEstimate(
    GetCostEstimate event,
    Emitter<DiagnosisState> emit,
  ) async {
    try {
      final costEstimate = await repository.getCostEstimate(event.sessionId);

      if (state is DiagnosisSessionActive) {
        final currentState = state as DiagnosisSessionActive;
        emit(currentState.copyWith(costEstimate: costEstimate));
      } else {
        emit(DiagnosisCostEstimateObtained(costEstimate));
      }
    } catch (e) {
      // No interrumpir la conversación si falla obtener el costo estimado
      print('DiagnosisBloc: Error al obtener costo estimado (no crítico): $e');

      if (state is! DiagnosisSessionActive) {
        emit(DiagnosisError(e.toString()));
      }
    }
  }

  Future<void> _onClearState(
    ClearDiagnosisState event,
    Emitter<DiagnosisState> emit,
  ) async {
    print('DiagnosisBloc: Clearing state');
    emit(const DiagnosisInitial());
  }

  Future<void> _onLoadRecommendedWorkshops(
    LoadRecommendedWorkshops event,
    Emitter<DiagnosisState> emit,
  ) async {
    try {
      final specialty = CategorySpecialtyMapper.getWorkshopSpecialty(event.category);

      if (specialty == null) {
        print('DiagnosisBloc: No specialty mapping for ${event.category}');
        return;
      }

      print('DiagnosisBloc: Loading workshops for specialty: $specialty');
      print('DiagnosisBloc: Location: lat=${event.latitude}, lon=${event.longitude}');

      // Pasar ubicación al repository (que delega al backend)
      final workshops = await workshopRepository.fetchWorkshopsBySpecialty(
        specialty,
        latitude: event.latitude != 0.0 ? event.latitude : null,
        longitude: event.longitude != 0.0 ? event.longitude : null,
      );

      print('DiagnosisBloc: Found ${workshops.length} workshops');

      if (state is DiagnosisSessionActive) {
        final currentState = state as DiagnosisSessionActive;
        emit(currentState.copyWith(recommendedWorkshops: workshops));
      }
    } catch (e) {
      print('DiagnosisBloc: Error loading recommended workshops: $e');
      // Fail silently, don't emit error
    }
  }

  /// Helper method to get location and load workshops
  Future<void> _loadWorkshopsWithLocation(ProblemCategory category) async {
    try {
      print('DiagnosisBloc: Getting user location for workshop recommendations...');

      // Intentar obtener ubicación real del dispositivo
      final position = await LocationService.getBestAvailableLocation();

      double latitude = 0.0;
      double longitude = 0.0;

      if (position != null) {
        latitude = position.latitude;
        longitude = position.longitude;
        print('DiagnosisBloc: Using real location: lat=$latitude, lon=$longitude');
      } else {
        print('DiagnosisBloc: Could not get location, using default (workshops will use backend default)');
      }

      // Cargar talleres con ubicación real o null (backend usará default)
      add(LoadRecommendedWorkshops(
        category: category,
        latitude: latitude,
        longitude: longitude,
      ));
    } catch (e) {
      print('DiagnosisBloc: Error getting location, loading workshops with default: $e');
      // Si falla, cargar con coordenadas 0,0 (backend usará default)
      add(LoadRecommendedWorkshops(
        category: category,
        latitude: 0.0,
        longitude: 0.0,
      ));
    }
  }

  Future<void> _onLoadActiveSession(
    LoadActiveSession event,
    Emitter<DiagnosisState> emit,
  ) async {
    emit(const DiagnosisLoading());
    try {
      print('DiagnosisBloc: Loading active session for vehicle ${event.vehicleId}');
      
      final sessions = await repository.getSessions(
        vehicleId: event.vehicleId,
        limit: 1,
      );

      if (sessions.isEmpty) {
        print('DiagnosisBloc: No active sessions found');
        emit(const DiagnosisInitial());
        return;
      }

      final session = sessions.first;
      
      if (session.status != SessionStatus.ACTIVE) {
        print('DiagnosisBloc: Session is not active (${session.status})');
        emit(const DiagnosisInitial());
        return;
      }

      print('DiagnosisBloc: Found active session ${session.id}, loading messages');
      
      final messages = await repository.getMessages(session.id);

      print('DiagnosisBloc: Loaded ${messages.length} messages');

      emit(DiagnosisSessionActive(
        session: session,
        messages: messages,
      ));
    } catch (e) {
      print('DiagnosisBloc: Error loading active session: $e');
      emit(const DiagnosisInitial());
    }
  }
}