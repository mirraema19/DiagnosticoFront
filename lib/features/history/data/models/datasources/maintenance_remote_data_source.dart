import 'package:dio/dio.dart';
import 'package:proyecto/core/api/api_client.dart';
import 'package:proyecto/features/history/data/models/maintenance_model.dart';

class MaintenanceRemoteDataSource {
  final ApiClient _apiClient;

  MaintenanceRemoteDataSource({required ApiClient apiClient}) : _apiClient = apiClient;

  // GET /vehicles/:vehicleId/maintenance
  Future<List<Maintenance>> getMaintenanceHistory(String vehicleId) async {
    try {
      final response = await _apiClient.dio.get('/vehicles/$vehicleId/maintenance');
      
      if (response.data is List) {
        final List<dynamic> list = response.data;
        return list.map((json) => Maintenance.fromJson(json)).toList();
      } else {
        return [];
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) return [];
      
      // Extracción mejorada de errores
      final errorMessage = _extractErrorMessage(e);
      throw Exception('Error al obtener historial: $errorMessage');
    }
  }

  // POST /vehicles/:vehicleId/maintenance
  Future<void> createMaintenance(Maintenance maintenance, String vehicleId) async {
    try {
      final data = maintenance.toJson();
      await _apiClient.dio.post('/vehicles/$vehicleId/maintenance', data: data);
    } on DioException catch (e) {
      // --- CORRECCIÓN CLAVE AQUÍ ---
      // Ahora extraemos el mensaje detallado que envía NestJS
      final errorMessage = _extractErrorMessage(e);
      throw Exception('Error al crear registro: $errorMessage');
    }
  }

  // PATCH /vehicles/:vehicleId/maintenance/:maintenanceId
  Future<void> updateMaintenance(String vehicleId, String maintenanceId, Map<String, dynamic> updates) async {
    try {
      await _apiClient.dio.patch('/vehicles/$vehicleId/maintenance/$maintenanceId', data: updates);
    } on DioException catch (e) {
      final errorMessage = _extractErrorMessage(e);
      throw Exception('Error al actualizar: $errorMessage');
    }
  }

  // Método auxiliar para leer los errores de NestJS (que pueden ser arrays)
  String _extractErrorMessage(DioException e) {
    try {
      if (e.response?.data != null && e.response!.data['message'] != null) {
        final message = e.response!.data['message'];
        if (message is List) {
          // Si es una lista de errores, los unimos con saltos de línea
          return message.join('\n');
        }
        return message.toString();
      }
    } catch (_) {}
    // Si no podemos extraerlo, devolvemos el mensaje por defecto
    return e.message ?? 'Error desconocido';
  }
}