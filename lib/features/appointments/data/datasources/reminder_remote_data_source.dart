import 'package:dio/dio.dart';
import 'package:proyecto/core/api/api_client.dart';
import 'package:proyecto/features/appointments/data/models/reminder_model.dart';

class ReminderRemoteDataSource {
  final ApiClient _apiClient;

  ReminderRemoteDataSource({required ApiClient apiClient}) : _apiClient = apiClient;

  // GET /vehicles/:vehicleId/reminders
  Future<List<Reminder>> getReminders(String vehicleId) async {
    try {
      final response = await _apiClient.dio.get('/vehicles/$vehicleId/reminders');
      
      if (response.data is List) {
        final List<dynamic> list = response.data;
        return list.map((json) => Reminder.fromJson(json)).toList();
      } else {
        return [];
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) return [];
      throw Exception('Error al obtener recordatorios: ${e.message}');
    }
  }

  // POST /vehicles/:vehicleId/reminders
  Future<void> createReminder(Reminder reminder, String vehicleId) async {
    try {
      await _apiClient.dio.post(
        '/vehicles/$vehicleId/reminders', 
        data: reminder.toJson()
      );
    } on DioException catch (e) {
      // Capturamos mensaje de error del backend si existe
      final data = e.response?.data;
      final errorMsg = (data is Map<String, dynamic> && data['message'] != null)
          ? data['message'].toString()
          : e.message;
      throw Exception('Error al crear recordatorio: $errorMsg');
    }
  }
}