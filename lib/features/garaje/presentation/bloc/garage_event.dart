part of 'garage_bloc.dart';

abstract class GarageEvent extends Equatable {
  const GarageEvent();
  @override
  List<Object> get props => [];
}

class LoadGarageData extends GarageEvent {}