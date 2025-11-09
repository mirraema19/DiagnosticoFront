part of 'appointments_bloc.dart';

abstract class AppointmentsState extends Equatable {
  const AppointmentsState();
  @override
  List<Object> get props => [];
}

class AppointmentsLoading extends AppointmentsState {}

class AppointmentsLoaded extends AppointmentsState {
  final List<Appointment> appointments;
  const AppointmentsLoaded(this.appointments);
  @override
  List<Object> get props => [appointments];
}

class AppointmentsError extends AppointmentsState {
  final String message;
  const AppointmentsError(this.message);
  @override
  List<Object> get props => [message];
}