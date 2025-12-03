part of 'appointments_bloc.dart';

abstract class AppointmentsEvent extends Equatable {
  const AppointmentsEvent();
  @override
  List<Object?> get props => [];
}

// Eventos de Appointments
class LoadAppointments extends AppointmentsEvent {
  final String? status;
  final int? limit;

  const LoadAppointments({this.status, this.limit});

  @override
  List<Object?> get props => [status, limit];
}

class LoadAppointmentById extends AppointmentsEvent {
  final String id;

  const LoadAppointmentById(this.id);

  @override
  List<Object> get props => [id];
}

class CreateAppointment extends AppointmentsEvent {
  final CreateAppointmentDto dto;

  const CreateAppointment(this.dto);

  @override
  List<Object> get props => [dto];
}

class UpdateAppointment extends AppointmentsEvent {
  final String id;
  final UpdateAppointmentDto dto;

  const UpdateAppointment(this.id, this.dto);

  @override
  List<Object> get props => [id, dto];
}

class CancelAppointment extends AppointmentsEvent {
  final String id;
  final String reason;

  const CancelAppointment(this.id, this.reason);

  @override
  List<Object> get props => [id, reason];
}

class CompleteAppointment extends AppointmentsEvent {
  final String id;
  final double finalCost;
  final String? notes;

  const CompleteAppointment(this.id, this.finalCost, {this.notes});

  @override
  List<Object?> get props => [id, finalCost, notes];
}

// Eventos de Progress
class LoadProgress extends AppointmentsEvent {
  final String appointmentId;

  const LoadProgress(this.appointmentId);

  @override
  List<Object> get props => [appointmentId];
}

class AddProgress extends AppointmentsEvent {
  final String appointmentId;
  final CreateProgressDto dto;

  const AddProgress(this.appointmentId, this.dto);

  @override
  List<Object> get props => [appointmentId, dto];
}

// Eventos de Chat
class LoadChatMessages extends AppointmentsEvent {
  final String appointmentId;
  final int? limit;

  const LoadChatMessages(this.appointmentId, {this.limit});

  @override
  List<Object?> get props => [appointmentId, limit];
}

class SendChatMessage extends AppointmentsEvent {
  final String appointmentId;
  final SendMessageDto dto;

  const SendChatMessage(this.appointmentId, this.dto);

  @override
  List<Object> get props => [appointmentId, dto];
}

// Eventos de Notifications
class LoadNotifications extends AppointmentsEvent {
  final int? limit;

  const LoadNotifications({this.limit});

  @override
  List<Object?> get props => [limit];
}

class MarkNotificationAsRead extends AppointmentsEvent {
  final String id;

  const MarkNotificationAsRead(this.id);

  @override
  List<Object> get props => [id];
}
