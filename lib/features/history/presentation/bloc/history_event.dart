part of 'history_bloc.dart';

abstract class HistoryEvent extends Equatable {
  const HistoryEvent();
  @override
  List<Object?> get props => [];
}

class LoadHistory extends HistoryEvent {
  // --- CAMBIO: Ahora pedimos el ID explícitamente ---
  final String? vehicleId;
  const LoadHistory({this.vehicleId});
  
  @override
  List<Object?> get props => [vehicleId];
}

class AddMaintenanceRecord extends HistoryEvent {
  final Maintenance record;
  const AddMaintenanceRecord(this.record);
  @override
  List<Object> get props => [record];
}