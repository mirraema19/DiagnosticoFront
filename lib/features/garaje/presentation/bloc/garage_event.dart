part of 'garage_bloc.dart';

abstract class GarageEvent extends Equatable {
  const GarageEvent();
  @override
  List<Object> get props => [];
}

class LoadGarageData extends GarageEvent {}

class AddVehicle extends GarageEvent {
  final Vehicle vehicle;
  const AddVehicle(this.vehicle);
  @override
  List<Object> get props => [vehicle];
}

// --- NUEVO EVENTO AÑADIDO ---
class UpdateVehicle extends GarageEvent {
  final Vehicle updatedVehicle;
  const UpdateVehicle(this.updatedVehicle);
  @override
  List<Object> get props => [updatedVehicle];
}