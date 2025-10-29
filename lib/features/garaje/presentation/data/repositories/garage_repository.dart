import 'package:proyecto/features/garaje/presentation/data/models/vehicle_model.dart';

class GarageRepository {
  final List<Vehicle> _vehicles = [
    const Vehicle(
      id: 'v1',
      make: 'Toyota',
      model: 'Corolla',
      year: 2022,
      imageUrl: 'assets/images/car.png', // Imagen principal
      mileage: 45230,
    ),
    const Vehicle(
      id: 'v2',
      make: 'Honda',
      model: 'Civic',
      year: 2020,
      imageUrl: 'assets/images/civic.jpg', // Imagen secundaria
      mileage: 15800,
    ),
  ];

  // Este método es para la pantalla 'Mi Garaje' (la lista completa)
  Future<List<Vehicle>> getVehicles() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return _vehicles;
  }

  // --- MÉTODO NUEVO AÑADIDO ---
  // Este método es para la pantalla 'Inicio' (el dashboard)
  Future<Vehicle> getPrimaryVehicle() async {
    await Future.delayed(const Duration(milliseconds: 300));
    // En una app real, aquí habría lógica para determinar el vehículo principal.
    // Para la simulación, simplemente devolvemos el primero de la lista.
    if (_vehicles.isNotEmpty) {
      return _vehicles.first;
    } else {
      throw Exception('No hay vehículos en el garaje.');
    }
  }
}