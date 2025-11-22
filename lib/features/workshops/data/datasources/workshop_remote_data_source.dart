import 'package:dio/dio.dart';
import 'package:proyecto/core/api/api_client.dart';
import 'package:proyecto/features/workshops/data/models/workshop_model.dart';

class WorkshopRemoteDataSource {
  final ApiClient _apiClient;

  WorkshopRemoteDataSource({required ApiClient apiClient}) : _apiClient = apiClient;

  Future<List<Workshop>> getWorkshops() async {
    try {
      const double latitude = 16.7516;
      const double longitude = -93.1134;
      const double radiusKm = 10.0;

      // --- CORRECCIÓN CLAVE AQUÍ ---
      // Ahora la ruta es solo '/nearby', ya que '/workshops' está en la baseUrl
      final response = await _apiClient.dio.get(
        '/nearby',
        queryParameters: {
          'latitude': latitude,
          'longitude': longitude,
          'radiusKm': radiusKm,
        },
      );
      
      final List<dynamic> workshopListJson = response.data;
      return workshopListJson.map((json) => Workshop.fromJson(json)).toList();
    } on DioException catch (e) {
      final errorMessage = e.response?.data?['message'] ?? e.message;
      throw Exception('Error al obtener los talleres: $errorMessage');
    }
  }

  Future<Workshop> getWorkshopById(String id) async {
    try {
      // --- CORRECCIÓN CLAVE AQUÍ ---
      // La ruta ahora es solo el ID, ya que '/workshops' está en la baseUrl
      final response = await _apiClient.dio.get('/$id');
      return Workshop.fromJson(response.data);
    } on DioException catch (e) {
      final errorMessage = e.response?.data?['message'] ?? e.message;
      throw Exception('Error al obtener el detalle del taller: $errorMessage');
    }
  }
}