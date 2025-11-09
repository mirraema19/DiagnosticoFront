import 'package:proyecto/features/garaje/presentation/data/models/vehicle_model.dart';
import 'package:proyecto/features/garaje/presentation/data/repositories/garage_repository.dart';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

part 'garage_event.dart';
part 'garage_state.dart';

class GarageBloc extends Bloc<GarageEvent, GarageState> {
  final GarageRepository _garageRepository = GarageRepository();

  GarageBloc() : super(GarageLoading()) {
    on<LoadGarageData>(_onLoadGarageData);
    on<AddVehicle>(_onAddVehicle);
    // --- CORRECCIÓN: REGISTRAMOS EL NUEVO EVENTO DE ACTUALIZACIÓN ---
    on<UpdateVehicle>(_onUpdateVehicle);
  }

  Future<void> _onLoadGarageData(
    LoadGarageData event,
    Emitter<GarageState> emit,
  ) async {
    emit(GarageLoading());
    try {
      final vehicles = await _garageRepository.getVehicles();
      emit(GarageLoaded(vehicles));
    } catch (e) {
      emit(GarageError(e.toString()));
    }
  }

  Future<void> _onAddVehicle(
    AddVehicle event,
    Emitter<GarageState> emit,
  ) async {
    try {
      await _garageRepository.addVehicle(event.vehicle);
      add(LoadGarageData()); // Recarga la lista
    } catch (e) {
      emit(GarageError(e.toString()));
    }
  }

  // --- NUEVO MANEJADOR DE EVENTO PARA ACTUALIZAR ---
  Future<void> _onUpdateVehicle(
    UpdateVehicle event,
    Emitter<GarageState> emit,
  ) async {
    try {
      // Le decimos al repositorio que actualice el vehículo
      await _garageRepository.updateVehicle(event.updatedVehicle);
      // Recargamos la lista para que la UI refleje los cambios
      add(LoadGarageData());
    } catch (e) {
      emit(GarageError(e.toString()));
    }
  }
}