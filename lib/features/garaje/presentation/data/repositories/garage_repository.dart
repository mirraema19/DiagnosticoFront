import 'package:proyecto/features/garaje/presentation/data/models/vehicle_model.dart';
import 'dart:math';
class GarageRepository {
  static final GarageRepository _instance = GarageRepository._internal();
  factory GarageRepository() {
    return _instance;
  }
  GarageRepository._internal();

  final List<Vehicle> _vehicles = [
    const Vehicle(
      id: 'v1',
      make: 'Toyota',
      model: 'Corolla',
      year: 2022,
      plate: 'ABC-123',
      imageUrl: 'assets/images/car.png',
      mileage: 45230,
    ),
    const Vehicle(
      id: 'v2',
      make: 'Honda',
      model: 'Civic',
      year: 2020,
      plate: 'XYZ-789',
      imageUrl: 'assets/images/civic.jpg',
      mileage: 15800,
    ),
  ];

  Future<List<Vehicle>> getVehicles() async {
    await Future.delayed(const Duration(milliseconds: 100));
    return _vehicles;
  }

  Future<Vehicle> getPrimaryVehicle() async {
    await Future.delayed(const Duration(milliseconds: 100));
    if (_vehicles.isNotEmpty) {
      return _vehicles.first;
    } else {
      throw Exception('Añade un vehículo a tu garaje.');
    }
  }

  Future<void> addVehicle(Vehicle vehicle) async {
    await Future.delayed(const Duration(milliseconds: 300));
    _vehicles.add(vehicle);
  }

  // --- NUEVO MÉTODO PARA ACTUALIZAR VEHÍCULOS ---
  Future<void> updateVehicle(Vehicle updatedVehicle) async {
    await Future.delayed(const Duration(milliseconds: 300));
    // Encuentra el índice del vehículo que coincide con el ID
    final index = _vehicles.indexWhere((vehicle) => vehicle.id == updatedVehicle.id);

    // Si se encuentra, reemplázalo en la lista
    if (index != -1) {
      _vehicles[index] = updatedVehicle;
    } else {
      // Opcional: manejar el caso en que el vehículo no se encuentre
      throw Exception('Vehículo no encontrado para actualizar.');
    }
  }
}