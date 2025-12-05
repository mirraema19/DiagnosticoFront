import 'package:dio/dio.dart';
import 'package:proyecto/core/api/api_client.dart';
import 'package:proyecto/features/garaje/presentation/data/models/vehicle_model.dart';


class VehicleRemoteDataSource {
  final ApiClient _apiClient;

  VehicleRemoteDataSource({required ApiClient apiClient}) : _apiClient = apiClient;

  Future<List<Vehicle>> getVehicles() async {
    try {
      final response = await _apiClient.dio.get('/vehicles');
      final List<dynamic> vehicleListJson = response.data;
      return vehicleListJson.map((json) => Vehicle.fromJson(json)).toList();
    } on DioException catch (e) {
      throw Exception('Error al obtener vehículos: ${e.message}');
    }
  }

  Future<Vehicle> createVehicle(Vehicle vehicle) async {
    try {
      final response = await _apiClient.dio.post(
        '/vehicles',
        data: vehicle.toJson(),
      );
      return Vehicle.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      final data = e.response?.data;
      String errorMessage = e.message ?? 'Error desconocido';
      if (data is Map<String, dynamic> && data['message'] != null) {
        final message = data['message'];
        errorMessage = (message is List) ? message.join('\n') : message.toString();
      }
      throw Exception('Error al crear: $errorMessage');
    }
  }
  
  Future<void> updateVehicle(Vehicle vehicle) async {
    try {
      await _apiClient.dio.patch(
        '/vehicles/${vehicle.id}',
        data: {
          'currentMileage': vehicle.mileage,
          if (!vehicle.imageUrl.startsWith('assets/')) 'photoUrl': vehicle.imageUrl,
        },
      );
    } on DioException catch (e) {
      throw Exception('Error al actualizar: ${e.message}');
    }
  }

  // --- NUEVO MÉTODO DELETE ---
  Future<void> deleteVehicle(String id) async {
    try {
      await _apiClient.dio.delete('/vehicles/$id');
    } on DioException catch (e) {
      throw Exception('Error al eliminar vehículo: ${e.message}');
    }
  }
}