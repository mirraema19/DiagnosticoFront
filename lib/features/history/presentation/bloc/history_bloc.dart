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
      // Usamos el ID que viene en el evento. Si es nulo, el repo intentará buscar el primario.
      final records = await _repository.getHistory(vehicleId: event.vehicleId);
      
      // Ordenamos por fecha descendente
      records.sort((a, b) => b.serviceDate.compareTo(a.serviceDate));
      
      emit(HistoryLoaded(records));
    } catch (e) {
      emit(HistoryError(e.toString()));
    }
  }

  Future<void> _onAddMaintenanceRecord(AddMaintenanceRecord event, Emitter<HistoryState> emit) async {
    try {
      await _repository.addRecord(event.record, vehicleId: event.record.vehicleId);
      // Recargamos usando el mismo ID
      add(LoadHistory(vehicleId: event.record.vehicleId)); 
    } catch (e) {
      emit(HistoryError("Error al agregar registro: ${e.toString()}"));
    }
  }
}