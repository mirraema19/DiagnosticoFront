part of 'garage_bloc.dart';

abstract class GarageState extends Equatable {
  const GarageState();
  @override
  List<Object> get props => [];
}

class GarageLoading extends GarageState {}

class GarageLoaded extends GarageState {
  final List<Vehicle> vehicles;
  const GarageLoaded(this.vehicles);
  @override
  List<Object> get props => [vehicles];
}

class GarageError extends GarageState {
  final String message;
  const GarageError(this.message);
  @override
  List<Object> get props => [message];
}