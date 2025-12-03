import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart'; // Para debugPrint
import 'package:proyecto/core/api/api_client.dart';
import 'package:proyecto/features/history/data/models/maintenance_model.dart';

class MaintenanceRemoteDataSource {
  final ApiClient _apiClient;

  MaintenanceRemoteDataSource({required ApiClient apiClient}) : _apiClient = apiClient;

  // GET /vehicles/:vehicleId/maintenance
  Future<List<Maintenance>> getMaintenanceHistory(String vehicleId) async {
    try {
      debugPrint('🔍 Buscando historial para vehículo ID: $vehicleId'); // DEBUG
      
      final response = await _apiClient.dio.get('/vehicles/$vehicleId/maintenance');
      
      debugPrint('✅ Respuesta del backend: ${response.data}'); // DEBUG

      if (response.data is List) {
        final List<dynamic> list = response.data;
        return list.map((json) {
          try {
            return Maintenance.fromJson(json);
          } catch (e) {
            debugPrint('❌ Error al leer un registro individual: $e \n JSON: $json');
            throw Exception('Error de formato en datos: $e');
          }
        }).toList();
      } else {
        return [];
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        debugPrint('ℹ️ No se encontró historial (404). Esto es normal si es nuevo.');
        return [];
      }
      final errorMessage = e.response?.data?['message'] ?? e.message;
      throw Exception('Error API: $errorMessage');
    } catch (e) {
      // Ya no devolvemos [] aquí, lanzamos el error para verlo en pantalla
      throw Exception('Error desconocido al leer historial: $e');
    }
  }

  // POST /vehicles/:vehicleId/maintenance
  Future<void> createMaintenance(Maintenance maintenance, String vehicleId) async {
    try {
      final data = maintenance.toJson();
      await _apiClient.dio.post('/vehicles/$vehicleId/maintenance', data: data);
    } on DioException catch (e) {
      final errorMessage = _extractErrorMessage(e);
      throw Exception('Error al crear registro: $errorMessage');
    }
  }

  // PATCH
  Future<void> updateMaintenance(String vehicleId, String maintenanceId, Map<String, dynamic> updates) async {
    try {
      await _apiClient.dio.patch('/vehicles/$vehicleId/maintenance/$maintenanceId', data: updates);
    } on DioException catch (e) {
      final errorMessage = _extractErrorMessage(e);
      throw Exception('Error al actualizar: $errorMessage');
    }
  }

  String _extractErrorMessage(DioException e) {
    try {
      if (e.response?.data != null && e.response!.data['message'] != null) {
        final message = e.response!.data['message'];
        if (message is List) return message.join('\n');
        return message.toString();
      }
    } catch (_) {}
    return e.message ?? 'Error desconocido';
  }
}