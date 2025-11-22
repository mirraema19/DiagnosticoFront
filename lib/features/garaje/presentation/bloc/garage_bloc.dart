import 'package:proyecto/core/services/service_locator.dart';
import 'package:proyecto/features/garaje/presentation/data/models/vehicle_model.dart';
import 'package:proyecto/features/garaje/presentation/data/repositories/garage_repository.dart';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

part 'garage_event.dart';
part 'garage_state.dart';


class GarageBloc extends Bloc<GarageEvent, GarageState> {
  final GarageRepository _garageRepository = sl<GarageRepository>();

  GarageBloc() : super(GarageLoading()) {
    on<LoadGarageData>(_onLoadGarageData);
    on<AddVehicle>(_onAddVehicle);
    on<UpdateVehicle>(_onUpdateVehicle);
    // Ahora que agregaste la clase en el archivo de eventos, este error desaparecerá:
    on<DeleteVehicle>(_onDeleteVehicle);
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
      add(LoadGarageData());
    } catch (e) {
      emit(GarageError(e.toString()));
    }
  }

  Future<void> _onUpdateVehicle(
    UpdateVehicle event,
    Emitter<GarageState> emit,
  ) async {
    try {
      await _garageRepository.updateVehicle(event.updatedVehicle);
      add(LoadGarageData());
    } catch (e) {
      emit(GarageError(e.toString()));
    }
  }

  // --- LÓGICA PARA ELIMINAR ---
  Future<void> _onDeleteVehicle(
    DeleteVehicle event,
    Emitter<GarageState> emit,
  ) async {
    try {
      await _garageRepository.deleteVehicle(event.vehicleId);
      add(LoadGarageData()); // Recargamos la lista después de borrar
    } catch (e) {
      emit(GarageError("Error al eliminar: ${e.toString()}"));
    }
  }
}