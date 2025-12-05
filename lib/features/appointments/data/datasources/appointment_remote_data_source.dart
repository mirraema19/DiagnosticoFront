import 'package:dio/dio.dart';
import 'package:proyecto/core/api/api_client.dart';
import 'package:proyecto/features/appointments/data/models/appointment_model.dart';
import 'package:proyecto/features/appointments/data/models/progress_model.dart';
import 'package:proyecto/features/appointments/data/models/chat_message_model.dart';
import 'package:proyecto/features/appointments/data/models/notification_model.dart';

class AppointmentRemoteDataSource {
  final ApiClient _apiClient;

  AppointmentRemoteDataSource({required ApiClient apiClient})
      : _apiClient = apiClient;

  // =============================================
  // APPOINTMENT ENDPOINTS
  // =============================================

  /// 1. POST /appointments - Crear Cita
  Future<AppointmentModel> createAppointment(CreateAppointmentDto dto) async {
    try {
      final jsonData = dto.toJson();
      print('🚀 Creando cita con datos:');
      print('   URL: ${_apiClient.dio.options.baseUrl}/appointments');
      print('   Body: $jsonData');

      final response = await _apiClient.dio.post(
        '/appointments',
        data: jsonData,
      );

      print('✅ Respuesta exitosa: ${response.statusCode}');
      print('📦 Tipo de response.data: ${response.data.runtimeType}');
      print('📦 Contenido de response.data: ${response.data}');

      // Asegurarse de que response.data sea Map<String, dynamic>
      final Map<String, dynamic> appointmentData;
      if (response.data is Map<String, dynamic>) {
        appointmentData = response.data as Map<String, dynamic>;
      } else {
        throw Exception('La respuesta del servidor no tiene el formato esperado');
      }

      return AppointmentModel.fromJson(appointmentData);
    } on DioException catch (e) {
      print('❌ Error al crear cita:');
      print('   Status: ${e.response?.statusCode}');
      print('   Data: ${e.response?.data}');
      print('   Message: ${e.message}');
      throw _handleError(e);
    }
  }

  /// 2. GET /appointments - Listar Citas del Usuario o Taller
  Future<List<AppointmentModel>> getAppointments({
    String? status,
    int? limit,
    String? workshopId,
  }) async {
    try {
      final queryParams = <String, dynamic>{};
      if (status != null) queryParams['status'] = status;
      if (limit != null) queryParams['limit'] = limit;
      if (workshopId != null) queryParams['workshopId'] = workshopId;

      print('🔍 Obteniendo citas con parámetros: $queryParams');

      final response = await _apiClient.dio.get(
        '/appointments',
        queryParameters: queryParams,
      );

      print('✅ Citas obtenidas: ${(response.data as List).length}');

      return (response.data as List)
          .map((json) => AppointmentModel.fromJson(json))
          .toList();
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// 3. GET /appointments/:id - Obtener Cita por ID
  Future<AppointmentModel> getAppointmentById(String id) async {
    try {
      print('🔍 Obteniendo cita con ID: $id');
      final response = await _apiClient.dio.get('/appointments/$id');
      print('✅ Respuesta recibida: ${response.statusCode}');
      print('📦 Tipo de data: ${response.data.runtimeType}');
      print('📦 Contenido: ${response.data}');

      return AppointmentModel.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      print('❌ Error DioException al obtener cita:');
      print('   Status: ${e.response?.statusCode}');
      print('   Data: ${e.response?.data}');
      print('   Message: ${e.message}');
      throw _handleError(e);
    } catch (e, stackTrace) {
      print('❌ Error inesperado al obtener cita:');
      print('   Error: $e');
      print('   StackTrace: $stackTrace');
      throw Exception('Error al parsear la cita: $e');
    }
  }

  /// 4. PATCH /appointments/:id - Actualizar Cita
  Future<AppointmentModel> updateAppointment(
    String id,
    UpdateAppointmentDto dto,
  ) async {
    try {
      final response = await _apiClient.dio.patch(
        '/appointments/$id',
        data: dto.toJson(),
      );
      return AppointmentModel.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// 5. POST /appointments/:id/cancel - Cancelar Cita
  Future<AppointmentModel> cancelAppointment(String id, String reason) async {
    try {
      final response = await _apiClient.dio.post(
        '/appointments/$id/cancel',
        data: {'reason': reason},
      );
      return AppointmentModel.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// 6. POST /appointments/:id/complete - Completar Cita (Taller)
  Future<AppointmentModel> completeAppointment(
    String id, {
    required double finalCost,
    String? notes,
  }) async {
    try {
      final response = await _apiClient.dio.post(
        '/appointments/$id/complete',
        data: {
          'finalCost': finalCost,
          'notes': notes,
        },
      );
      return AppointmentModel.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // =============================================
  // PROGRESS ENDPOINTS
  // =============================================

  /// 7. POST /appointments/:id/progress - Agregar Progreso
  Future<ProgressModel> addProgress(
    String appointmentId,
    CreateProgressDto dto,
  ) async {
    try {
      final jsonData = dto.toJson();
      print('🚀 Agregando progreso a cita:');
      print('   Appointment ID: $appointmentId');
      print('   URL: ${_apiClient.dio.options.baseUrl}/appointments/$appointmentId/progress');
      print('   Body: $jsonData');

      final response = await _apiClient.dio.post(
        '/appointments/$appointmentId/progress',
        data: jsonData,
      );

      print('✅ Respuesta exitosa: ${response.statusCode}');
      print('📦 Datos de respuesta: ${response.data}');

      return ProgressModel.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      print('❌ Error al agregar progreso:');
      print('   Status: ${e.response?.statusCode}');
      print('   Data: ${e.response?.data}');
      print('   Message: ${e.message}');
      throw _handleError(e);
    }
  }

  /// 8. GET /appointments/:id/progress - Ver Progreso
  Future<List<ProgressModel>> getProgress(String appointmentId) async {
    try {
      print('🔍 Obteniendo progreso de cita: $appointmentId');
      final response = await _apiClient.dio.get(
        '/appointments/$appointmentId/progress',
      );
      print('✅ Progreso obtenido: ${(response.data as List).length} items');
      print('📦 Datos: ${response.data}');
      return (response.data as List)
          .map((json) => ProgressModel.fromJson(json))
          .toList();
    } on DioException catch (e) {
      print('❌ Error al obtener progreso:');
      print('   Status: ${e.response?.statusCode}');
      print('   Data: ${e.response?.data}');
      throw _handleError(e);
    }
  }

  // =============================================
  // CHAT ENDPOINTS
  // =============================================

  /// 9. POST /appointments/:id/chat - Enviar Mensaje
  Future<ChatMessageModel> sendMessage(
    String appointmentId,
    SendMessageDto dto,
  ) async {
    try {
      final response = await _apiClient.dio.post(
        '/appointments/$appointmentId/chat',
        data: dto.toJson(),
      );
      return ChatMessageModel.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// 10. GET /appointments/:id/chat - Ver Mensajes
  Future<List<ChatMessageModel>> getChatMessages(
    String appointmentId, {
    int? limit,
  }) async {
    try {
      final queryParams = <String, dynamic>{};
      if (limit != null) queryParams['limit'] = limit;

      final response = await _apiClient.dio.get(
        '/appointments/$appointmentId/chat',
        queryParameters: queryParams,
      );
      return (response.data as List)
          .map((json) => ChatMessageModel.fromJson(json))
          .toList();
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // =============================================
  // NOTIFICATION ENDPOINTS
  // =============================================

  /// 11. GET /notifications - Listar Notificaciones
  Future<List<NotificationModel>> getNotifications({int? limit}) async {
    try {
      final queryParams = <String, dynamic>{};
      if (limit != null) queryParams['limit'] = limit;

      final response = await _apiClient.dio.get(
        '/notifications',
        queryParameters: queryParams,
      );
      return (response.data as List)
          .map((json) => NotificationModel.fromJson(json))
          .toList();
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// 12. POST /notifications/:id/read - Marcar como Leída
  Future<NotificationModel> markNotificationAsRead(String id) async {
    try {
      final response = await _apiClient.dio.post('/notifications/$id/read');
      return NotificationModel.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // =============================================
  // ERROR HANDLER
  // =============================================

  Exception _handleError(DioException error) {
    if (error.response != null) {
      final statusCode = error.response!.statusCode;
      final data = error.response!.data;
      final message = (data is Map<String, dynamic> && data['message'] != null)
          ? data['message'].toString()
          : 'Error desconocido';

      switch (statusCode) {
        case 400:
          return Exception('Solicitud inválida: $message');
        case 401:
          return Exception('No autorizado. Por favor inicia sesión.');
        case 403:
          return Exception('No tienes permisos para realizar esta acción.');
        case 404:
          return Exception('Recurso no encontrado: $message');
        case 500:
          return Exception('Error del servidor. Intenta más tarde.');
        default:
          return Exception('Error: $message');
      }
    } else {
      return Exception('Error de conexión: ${error.message}');
    }
  }
}
