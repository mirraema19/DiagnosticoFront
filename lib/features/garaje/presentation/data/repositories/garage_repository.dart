import 'package:proyecto/features/garaje/presentation/data/datasources/vehicle_remote_data_source.dart';
import 'package:proyecto/features/garaje/presentation/data/models/vehicle_model.dart';

class GarageRepository {
  final VehicleRemoteDataSource _remoteDataSource;

  GarageRepository({required VehicleRemoteDataSource remoteDataSource})
      : _remoteDataSource = remoteDataSource;

  Future<List<Vehicle>> getVehicles() {
    return _remoteDataSource.getVehicles();
  }

  Future<Vehicle?> getPrimaryVehicle() async {
    try {
      final vehicles = await _remoteDataSource.getVehicles();
      if (vehicles.isNotEmpty) return vehicles.first;
      return null;
    } catch (e) {
      rethrow;
    }
  }

  Future<void> addVehicle(Vehicle vehicle) async {
    await _remoteDataSource.createVehicle(vehicle);
  }

  Future<void> updateVehicle(Vehicle updatedVehicle) async {
    await _remoteDataSource.updateVehicle(updatedVehicle);
  }

  // --- NUEVO MÉTODO ---
  Future<void> deleteVehicle(String id) async {
    await _remoteDataSource.deleteVehicle(id);
  }
}