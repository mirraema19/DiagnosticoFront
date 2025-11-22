import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:proyecto/core/services/service_locator.dart';
import 'package:proyecto/features/appointments/data/models/reminder_model.dart';
import 'package:proyecto/features/appointments/data/repositories/reminder_repository.dart';

part 'reminders_event.dart';
part 'reminders_state.dart';

class RemindersBloc extends Bloc<RemindersEvent, RemindersState> {
  final ReminderRepository _repository = sl<ReminderRepository>();

  RemindersBloc() : super(RemindersLoading()) {
    on<LoadReminders>(_onLoadReminders);
    on<AddReminder>(_onAddReminder);
  }

  Future<void> _onLoadReminders(LoadReminders event, Emitter<RemindersState> emit) async {
    emit(RemindersLoading());
    try {
      final reminders = await _repository.getReminders();
      emit(RemindersLoaded(reminders));
    } catch (e) {
      emit(RemindersError("Error al cargar recordatorios: ${e.toString()}"));
    }
  }

  Future<void> _onAddReminder(AddReminder event, Emitter<RemindersState> emit) async {
    try {
      // --- MEJORA AQUÍ ---
      // Pasamos explícitamente el ID del vehículo para evitar errores de asignación
      await _repository.addReminder(
        event.reminder, 
        vehicleId: event.reminder.vehicleId
      );
      
      add(LoadReminders());
    } catch (e) {
      emit(RemindersError("Error al crear recordatorio: ${e.toString()}"));
    }
  }
}