part of 'history_bloc.dart';

abstract class HistoryEvent extends Equatable {
  const HistoryEvent();
  @override
  List<Object> get props => [];
}

class LoadHistory extends HistoryEvent {}

class AddMaintenanceRecord extends HistoryEvent {
  final Maintenance record;
  const AddMaintenanceRecord(this.record);
  @override
  List<Object> get props => [record];
}