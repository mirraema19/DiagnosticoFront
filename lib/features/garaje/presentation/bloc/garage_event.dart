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

class UpdateVehicle extends GarageEvent {
  final Vehicle updatedVehicle;

  const UpdateVehicle(this.updatedVehicle);

  @override
  List<Object> get props => [updatedVehicle];
}

// --- ESTA ES LA CLASE QUE TE FALTA ---
class DeleteVehicle extends GarageEvent {
  final String vehicleId;

  const DeleteVehicle(this.vehicleId);

  @override
  List<Object> get props => [vehicleId];
}