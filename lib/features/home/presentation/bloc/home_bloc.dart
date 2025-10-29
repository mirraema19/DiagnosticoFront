import 'package:proyecto/features/garaje/presentation/data/models/vehicle_model.dart';
import 'package:proyecto/features/garaje/presentation/data/repositories/garage_repository.dart';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

part 'home_event.dart';
part 'home_state.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  // El HomeBloc depende del GarageRepository para obtener el vehículo principal
  final GarageRepository _garageRepository = GarageRepository();

  HomeBloc() : super(HomeLoading()) {
    on<LoadHomeData>(_onLoadHomeData);
  }

  Future<void> _onLoadHomeData(
    LoadHomeData event,
    Emitter<HomeState> emit,
  ) async {
    emit(HomeLoading());
    try {
      // Usamos el nuevo método para obtener solo el vehículo principal
      final vehicle = await _garageRepository.getPrimaryVehicle();
      emit(HomeLoaded(vehicle));
    } catch (e) {
      emit(HomeError("No se pudo cargar el vehículo principal: ${e.toString()}"));
    }
  }
}