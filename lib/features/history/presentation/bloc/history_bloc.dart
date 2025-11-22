import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:proyecto/core/services/service_locator.dart';
import 'package:proyecto/features/history/data/models/maintenance_model.dart';
import 'package:proyecto/features/history/data/repositories/maintenance_repository.dart';

part 'history_event.dart';
part 'history_state.dart';

class HistoryBloc extends Bloc<HistoryEvent, HistoryState> {
  final MaintenanceRepository _repository = sl<MaintenanceRepository>();

  HistoryBloc() : super(HistoryLoading()) {
    on<LoadHistory>(_onLoadHistory);
    on<AddMaintenanceRecord>(_onAddMaintenanceRecord);
  }

  Future<void> _onLoadHistory(LoadHistory event, Emitter<HistoryState> emit) async {
    emit(HistoryLoading());
    try {
      final records = await _repository.getHistory(); 
      emit(HistoryLoaded(records));
    } catch (e) {
      emit(HistoryError("Error al cargar historial: ${e.toString()}"));
    }
  }

  Future<void> _onAddMaintenanceRecord(AddMaintenanceRecord event, Emitter<HistoryState> emit) async {
    try {
      // --- CORRECCIÓN AQUÍ ---
      // Se agregó "vehicleId:" antes del valor
      await _repository.addRecord(event.record, vehicleId: event.record.vehicleId);
      
      add(LoadHistory()); // Recargar lista
    } catch (e) {
      emit(HistoryError("Error al agregar registro: ${e.toString()}"));
    }
  }
}