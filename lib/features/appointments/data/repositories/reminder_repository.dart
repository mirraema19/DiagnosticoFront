import 'package:proyecto/features/appointments/data/datasources/reminder_remote_data_source.dart';
import 'package:proyecto/features/appointments/data/models/reminder_model.dart';
import 'package:proyecto/features/garaje/presentation/data/repositories/garage_repository.dart';

class ReminderRepository {
  final ReminderRemoteDataSource _dataSource;
  final GarageRepository _garageRepository;

  ReminderRepository({
    required ReminderRemoteDataSource dataSource,
    required GarageRepository garageRepository,
  })  : _dataSource = dataSource,
        _garageRepository = garageRepository;

  Future<String> _getTargetVehicleId(String? vehicleId) async {
    if (vehicleId != null && vehicleId.isNotEmpty) {
      return vehicleId;
    }
    final primaryVehicle = await _garageRepository.getPrimaryVehicle();
    if (primaryVehicle != null) {
      return primaryVehicle.id;
    }
    throw Exception('No se encontró ningún vehículo.');
  }

  Future<List<Reminder>> getReminders({String? vehicleId}) async {
    try {
      final targetId = await _getTargetVehicleId(vehicleId);
      return await _dataSource.getReminders(targetId);
    } catch (e) {
      return [];
    }
  }

  Future<void> addReminder(Reminder reminder, {String? vehicleId}) async {
    final targetId = await _getTargetVehicleId(vehicleId);
    await _dataSource.createReminder(reminder, targetId);
  }
}