part of 'appointments_bloc.dart';

abstract class AppointmentsState extends Equatable {
  const AppointmentsState();
  @override
  List<Object?> get props => [];
}

// Estados iniciales
class AppointmentsInitial extends AppointmentsState {}

class AppointmentsLoading extends AppointmentsState {}

// Estados de Appointments
class AppointmentsLoaded extends AppointmentsState {
  final List<AppointmentModel> appointments;

  const AppointmentsLoaded(this.appointments);

  @override
  List<Object> get props => [appointments];
}

class AppointmentDetailLoaded extends AppointmentsState {
  final AppointmentModel appointment;

  const AppointmentDetailLoaded(this.appointment);

  @override
  List<Object> get props => [appointment];
}

class AppointmentCreated extends AppointmentsState {
  final AppointmentModel appointment;

  const AppointmentCreated(this.appointment);

  @override
  List<Object> get props => [appointment];
}

class AppointmentUpdated extends AppointmentsState {
  final AppointmentModel appointment;

  const AppointmentUpdated(this.appointment);

  @override
  List<Object> get props => [appointment];
}

class AppointmentCancelled extends AppointmentsState {
  final AppointmentModel appointment;

  const AppointmentCancelled(this.appointment);

  @override
  List<Object> get props => [appointment];
}

class AppointmentCompleted extends AppointmentsState {
  final AppointmentModel appointment;

  const AppointmentCompleted(this.appointment);

  @override
  List<Object> get props => [appointment];
}

// Estados de Progress
class ProgressLoaded extends AppointmentsState {
  final List<ProgressModel> progressList;

  const ProgressLoaded(this.progressList);

  @override
  List<Object> get props => [progressList];
}

class ProgressAdded extends AppointmentsState {
  final ProgressModel progress;

  const ProgressAdded(this.progress);

  @override
  List<Object> get props => [progress];
}

// Estados de Chat
class ChatMessagesLoaded extends AppointmentsState {
  final List<ChatMessageModel> messages;

  const ChatMessagesLoaded(this.messages);

  @override
  List<Object> get props => [messages];
}

class ChatMessageSent extends AppointmentsState {
  final ChatMessageModel message;

  const ChatMessageSent(this.message);

  @override
  List<Object> get props => [message];
}

// Estados de Notifications
class NotificationsLoaded extends AppointmentsState {
  final List<NotificationModel> notifications;

  const NotificationsLoaded(this.notifications);

  @override
  List<Object> get props => [notifications];
}

class NotificationMarkedAsRead extends AppointmentsState {
  final NotificationModel notification;

  const NotificationMarkedAsRead(this.notification);

  @override
  List<Object> get props => [notification];
}

// Estado de Error
class AppointmentsError extends AppointmentsState {
  final String message;

  const AppointmentsError(this.message);

  @override
  List<Object> get props => [message];
}
