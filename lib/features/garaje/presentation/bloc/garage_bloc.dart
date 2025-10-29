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
      emit(GarageError("No se pudieron cargar los vehículos: ${e.toString()}"));
    }
  }
}