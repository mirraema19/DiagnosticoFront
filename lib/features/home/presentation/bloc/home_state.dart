part of 'home_bloc.dart';

abstract class HomeState extends Equatable {
  const HomeState();
  @override
  List<Object?> get props => []; // Permitimos props nulos
}

class HomeLoading extends HomeState {}

class HomeLoaded extends HomeState {
  // --- CORRECCIÓN: El vehículo ahora puede ser nulo ---
  final Vehicle? primaryVehicle;
  const HomeLoaded(this.primaryVehicle);
  @override
  List<Object?> get props => [primaryVehicle];
}

class HomeError extends HomeState {
  final String message;
  const HomeError(this.message);
  @override
  List<Object> get props => [message];
}