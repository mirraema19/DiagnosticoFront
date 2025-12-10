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
import 'package:proyecto/features/diagnosis/data/models/workshop_recommendation_model.dart';
import 'package:proyecto/features/diagnosis/data/models/workshop_recommendation_model.dart';

part 'diagnosis_event.dart';
part 'diagnosis_state.dart';

class DiagnosisBloc extends Bloc<DiagnosisEvent, DiagnosisState> {
  final DiagnosisRepository repository;

  DiagnosisBloc({
    required this.repository,
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
    on<LoadRecommendations>(_onLoadRecommendations);
    on<LoadActiveSession>(_onLoadActiveSession);
  }

  Future<void> _onCreateSession(
    CreateDiagnosisSession event,
    Emitter<DiagnosisState> emit,
  ) async {
    emit(const DiagnosisLoading());
    try {
      // Backend returns ChatResponseModel with userMessage and assistantMessage
      final chatResponse = await repository.createSession(
        vehicleId: event.vehicleId,
        initialMessage: event.initialMessage,
      );

      print('DiagnosisBloc: Session created. ID: ${chatResponse.userMessage.sessionId}');

      // Create session model from the response
      final session = DiagnosisSessionModel(
        id: chatResponse.userMessage.sessionId,
        userId: '', // Backend fills this from JWT
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


        // Automatic classification disabled by user request. 
        // Diagnosis is now triggered only manually via button.
        /*
        if (updatedMessages.length >= 3 && currentState.classification == null) {
          print('DiagnosisBloc: Auto-triggering problem classification after conversation');
          add(ClassifyProblem(event.sessionId));
        }
        */
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

        // Load recommended workshops from backend ML
        print('DiagnosisBloc: Classification complete, loading recommendations');
        add(LoadRecommendations(sessionId: event.sessionId));

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

  Future<void> _onLoadRecommendations(
    LoadRecommendations event,
    Emitter<DiagnosisState> emit,
  ) async {
    try {
      print('DiagnosisBloc: Loading recommendations from backend ML for session ${event.sessionId}');
      
      final recommendations = await repository.getRecommendations(
        sessionId: event.sessionId,
        limit: event.limit,
      );

      print('DiagnosisBloc: Found ${recommendations.length} recommended workshops');

      if (state is DiagnosisSessionActive) {
        final currentState = state as DiagnosisSessionActive;
        emit(currentState.copyWith(recommendedWorkshops: recommendations));
      } else {
        emit(DiagnosisRecommendationsLoaded(recommendations));
      }
    } catch (e) {
      print('DiagnosisBloc: Error loading recommendations (non-critical): $e');
      // Fail silently, don't interrupt the session
      if (state is! DiagnosisSessionActive) {
        emit(DiagnosisError(e.toString()));
      }
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

      // Attempt to load classification/results if they exist
      // We do this by checking if we CAN get them without error
      ClassificationModel? classification;
      UrgencyModel? urgency;
      CostEstimateModel? costEstimate;
      List<WorkshopRecommendationModel>? recommendations;

      // Only attempt to load results if there are enough messages (implying analysis might have happened)
      if (messages.length >= 3) {
        try {
          // TODO: Ideally getSessionById should return full details including these
          // For now we try to fetch them individually. If they don't exist, these might throw/fail silently
          // We can use a try-catch for each or check session status if backend supported it
          
          // Note: Since we don't have a direct "hasClassification" flag, 
          // we'll optimistically try to fetch urgency which is usually present if classified
          try {
             urgency = await repository.getUrgency(session.id);
             // If we got urgency, likely we have the rest
             costEstimate = await repository.getCostEstimate(session.id);
             recommendations = await repository.getRecommendations(sessionId: session.id);
             
             // For classification, there is no GET endpoint exposed in repo yet except inside session detail
             // We will assume if urgency exists, we can try to get session detail to extract classification
             // or add a getClassification method. 
             // For now, let's try to get full session detail which might contain it
             final sessionDetail = await repository.getSessionById(session.id);
             // If sessionDetail has classification map, we'd need to parse it. 
             // But DiagnosisSessionModel doesn't have it yet.
             
             // WORKAROUND: For now we just load what we can. 
             // If we really need classification object, we might need to add getClassification to repo
             // OR assume if we have urgency/cost/workshops, we can show them even without the Classification object
             // displayed in the UI (which is just the category name).
          } catch (e) {
            print('DiagnosisBloc: Could not load results (normal if not diagnosed yet): $e');
          }
        } catch (e) {
          print('DiagnosisBloc: Error checking for results: $e');
        }
      }

      emit(DiagnosisSessionActive(
        session: session,
        messages: messages,
        // classification: classification, // We don't have this yet
        urgency: urgency,
        costEstimate: costEstimate,
        recommendedWorkshops: recommendations,
      ));
    } catch (e) {
      print('DiagnosisBloc: Error loading active session: $e');
      emit(const DiagnosisInitial());
    }
  }
}