import 'package:proyecto/features/appointments/data/models/appointment_model.dart';
import 'package:proyecto/features/appointments/data/repositories/appointment_repository.dart';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

part 'appointments_event.dart';
part 'appointments_state.dart';

class AppointmentsBloc extends Bloc<AppointmentsEvent, AppointmentsState> {
  final AppointmentRepository _repository = AppointmentRepository();

  AppointmentsBloc() : super(AppointmentsLoading()) {
    on<LoadAppointments>(_onLoadAppointments);
    on<AddAppointment>(_onAddAppointment);
  }

  Future<void> _onLoadAppointments(
    LoadAppointments event,
    Emitter<AppointmentsState> emit,
  ) async {
    emit(AppointmentsLoading());
    try {
      final appointments = await _repository.getAppointments();
      emit(AppointmentsLoaded(appointments));
    } catch (e) {
      emit(AppointmentsError(e.toString()));
    }
  }

  Future<void> _onAddAppointment(
    AddAppointment event,
    Emitter<AppointmentsState> emit,
  ) async {
    // Aquí podrías emitir un estado de "Añadiendo..." si quisieras
    try {
      await _repository.addAppointment(event.appointment);
      // Después de añadir, recargamos la lista para que se refleje el cambio
      add(LoadAppointments());
    } catch (e) {
      emit(AppointmentsError(e.toString()));
    }
  }
}