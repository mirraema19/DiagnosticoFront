import 'package:proyecto/features/history/data/models/datasources/maintenance_remote_data_source.dart';
import 'package:proyecto/features/history/data/models/maintenance_model.dart';
import 'package:proyecto/features/garaje/presentation/data/repositories/garage_repository.dart';


class MaintenanceRepository {
  final MaintenanceRemoteDataSource _dataSource;
  final GarageRepository _garageRepository;

  MaintenanceRepository({
    required MaintenanceRemoteDataSource dataSource,
    required GarageRepository garageRepository,
  })  : _dataSource = dataSource,
        _garageRepository = garageRepository;

  // Obtiene el ID del vehículo a usar (el pasado como argumento o el principal)
  Future<String> _getTargetVehicleId(String? vehicleId) async {
    if (vehicleId != null && vehicleId.isNotEmpty) {
      return vehicleId;
    }
    final primaryVehicle = await _garageRepository.getPrimaryVehicle();
    if (primaryVehicle != null) {
      return primaryVehicle.id;
    }
    throw Exception('No se encontró ningún vehículo para gestionar el mantenimiento.');
  }

  Future<List<Maintenance>> getHistory({String? vehicleId}) async {
    try {
      final targetId = await _getTargetVehicleId(vehicleId);
      return await _dataSource.getMaintenanceHistory(targetId);
    } catch (e) {
      // Si no hay vehículos, devolvemos lista vacía en lugar de error
      return [];
    }
  }

  Future<void> addRecord(Maintenance record, {String? vehicleId}) async {
    final targetId = await _getTargetVehicleId(vehicleId);
    await _dataSource.createMaintenance(record, targetId);
  }

  Future<void> updateRecord(String id, Map<String, dynamic> updates, {String? vehicleId}) async {
    final targetId = await _getTargetVehicleId(vehicleId);
    await _dataSource.updateMaintenance(targetId, id, updates);
  }
}