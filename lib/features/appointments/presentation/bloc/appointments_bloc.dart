import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:proyecto/features/appointments/data/models/appointment_model.dart';
import 'package:proyecto/features/appointments/data/models/progress_model.dart';
import 'package:proyecto/features/appointments/data/models/chat_message_model.dart';
import 'package:proyecto/features/appointments/data/models/notification_model.dart';
import 'package:proyecto/features/appointments/data/repositories/appointment_repository.dart';

part 'appointments_event.dart';
part 'appointments_state.dart';

class AppointmentsBloc extends Bloc<AppointmentsEvent, AppointmentsState> {
  final AppointmentRepository _repository;

  AppointmentsBloc({required AppointmentRepository repository})
      : _repository = repository,
        super(AppointmentsInitial()) {
    // Appointment handlers
    on<LoadAppointments>(_onLoadAppointments);
    on<LoadAppointmentById>(_onLoadAppointmentById);
    on<CreateAppointment>(_onCreateAppointment);
    on<UpdateAppointment>(_onUpdateAppointment);
    on<CancelAppointment>(_onCancelAppointment);
    on<CompleteAppointment>(_onCompleteAppointment);

    // Progress handlers
    on<LoadProgress>(_onLoadProgress);
    on<AddProgress>(_onAddProgress);

    // Chat handlers
    on<LoadChatMessages>(_onLoadChatMessages);
    on<SendChatMessage>(_onSendChatMessage);

    // Notification handlers
    on<LoadNotifications>(_onLoadNotifications);
    on<MarkNotificationAsRead>(_onMarkNotificationAsRead);
  }

  // =============================================
  // APPOINTMENT HANDLERS
  // =============================================

  Future<void> _onLoadAppointments(
    LoadAppointments event,
    Emitter<AppointmentsState> emit,
  ) async {
    emit(AppointmentsLoading());
    try {
      final appointments = await _repository.getAppointments(
        status: event.status,
        limit: event.limit,
      );
      emit(AppointmentsLoaded(appointments));
    } catch (e) {
      emit(AppointmentsError(e.toString()));
    }
  }

  Future<void> _onLoadAppointmentById(
    LoadAppointmentById event,
    Emitter<AppointmentsState> emit,
  ) async {
    emit(AppointmentsLoading());
    try {
      final appointment = await _repository.getAppointmentById(event.id);
      emit(AppointmentDetailLoaded(appointment));
    } catch (e) {
      emit(AppointmentsError(e.toString()));
    }
  }

  Future<void> _onCreateAppointment(
    CreateAppointment event,
    Emitter<AppointmentsState> emit,
  ) async {
    emit(AppointmentsLoading());
    try {
      final appointment = await _repository.createAppointment(event.dto);
      emit(AppointmentCreated(appointment));
    } catch (e) {
      emit(AppointmentsError(e.toString()));
    }
  }

  Future<void> _onUpdateAppointment(
    UpdateAppointment event,
    Emitter<AppointmentsState> emit,
  ) async {
    emit(AppointmentsLoading());
    try {
      final appointment = await _repository.updateAppointment(
        event.id,
        event.dto,
      );
      emit(AppointmentUpdated(appointment));
    } catch (e) {
      emit(AppointmentsError(e.toString()));
    }
  }

  Future<void> _onCancelAppointment(
    CancelAppointment event,
    Emitter<AppointmentsState> emit,
  ) async {
    emit(AppointmentsLoading());
    try {
      final appointment = await _repository.cancelAppointment(
        event.id,
        event.reason,
      );
      emit(AppointmentCancelled(appointment));
    } catch (e) {
      emit(AppointmentsError(e.toString()));
    }
  }

  Future<void> _onCompleteAppointment(
    CompleteAppointment event,
    Emitter<AppointmentsState> emit,
  ) async {
    emit(AppointmentsLoading());
    try {
      final appointment = await _repository.completeAppointment(
        event.id,
        finalCost: event.finalCost,
        notes: event.notes,
      );
      emit(AppointmentCompleted(appointment));
    } catch (e) {
      emit(AppointmentsError(e.toString()));
    }
  }

  // =============================================
  // PROGRESS HANDLERS
  // =============================================

  Future<void> _onLoadProgress(
    LoadProgress event,
    Emitter<AppointmentsState> emit,
  ) async {
    emit(AppointmentsLoading());
    try {
      final progressList = await _repository.getProgress(event.appointmentId);
      emit(ProgressLoaded(progressList));
    } catch (e) {
      emit(AppointmentsError(e.toString()));
    }
  }

  Future<void> _onAddProgress(
    AddProgress event,
    Emitter<AppointmentsState> emit,
  ) async {
    emit(AppointmentsLoading());
    try {
      final progress = await _repository.addProgress(
        event.appointmentId,
        event.dto,
      );
      emit(ProgressAdded(progress));
    } catch (e) {
      emit(AppointmentsError(e.toString()));
    }
  }

  // =============================================
  // CHAT HANDLERS
  // =============================================

  Future<void> _onLoadChatMessages(
    LoadChatMessages event,
    Emitter<AppointmentsState> emit,
  ) async {
    emit(AppointmentsLoading());
    try {
      final messages = await _repository.getChatMessages(
        event.appointmentId,
        limit: event.limit,
      );
      emit(ChatMessagesLoaded(messages));
    } catch (e) {
      emit(AppointmentsError(e.toString()));
    }
  }

  Future<void> _onSendChatMessage(
    SendChatMessage event,
    Emitter<AppointmentsState> emit,
  ) async {
    try {
      final message = await _repository.sendMessage(
        event.appointmentId,
        event.dto,
      );
      emit(ChatMessageSent(message));
      // Después de enviar, recargamos los mensajes
      add(LoadChatMessages(event.appointmentId));
    } catch (e) {
      emit(AppointmentsError(e.toString()));
    }
  }

  // =============================================
  // NOTIFICATION HANDLERS
  // =============================================

  Future<void> _onLoadNotifications(
    LoadNotifications event,
    Emitter<AppointmentsState> emit,
  ) async {
    emit(AppointmentsLoading());
    try {
      final notifications = await _repository.getNotifications(
        limit: event.limit,
      );
      emit(NotificationsLoaded(notifications));
    } catch (e) {
      emit(AppointmentsError(e.toString()));
    }
  }

  Future<void> _onMarkNotificationAsRead(
    MarkNotificationAsRead event,
    Emitter<AppointmentsState> emit,
  ) async {
    try {
      final notification = await _repository.markNotificationAsRead(event.id);
      emit(NotificationMarkedAsRead(notification));
      // Después de marcar como leída, recargamos las notificaciones
      add(const LoadNotifications());
    } catch (e) {
      emit(AppointmentsError(e.toString()));
    }
  }
}
