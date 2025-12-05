import 'package:dio/dio.dart';
import 'package:proyecto/features/diagnosis/data/models/diagnosis_session_model.dart';
import 'package:proyecto/features/diagnosis/data/models/diagnosis_message_model.dart';
import 'package:proyecto/features/diagnosis/data/models/chat_response_model.dart';
import 'package:proyecto/features/diagnosis/data/models/classification_model.dart';
import 'package:proyecto/features/diagnosis/data/models/urgency_model.dart';
import 'package:proyecto/features/diagnosis/data/models/cost_estimate_model.dart';

class DiagnosisRemoteDataSource {
  final Dio dio;
  static const String baseUrl = 'https://ai-diagnosis-service-autodiag.onrender.com';

  DiagnosisRemoteDataSource({required this.dio});

  /// POST /sessions - Crear nueva sesión de diagnóstico
  Future<ChatResponseModel> createSession({
    required String vehicleId,
    required String initialMessage,
  }) async {
    try {
      final response = await dio.post(
        '$baseUrl/sessions',
        data: {
          'vehicleId': vehicleId,
          'initialMessage': initialMessage,
        },
      );
      return ChatResponseModel.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw Exception('Error al crear sesión: ${e.message}');
    }
  }

  /// GET /sessions - Listar sesiones del usuario
  Future<List<DiagnosisSessionModel>> getSessions({
    String? vehicleId,
    int limit = 10,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'limit': limit,
        if (vehicleId != null) 'vehicleId': vehicleId,
      };

      final response = await dio.get(
        '$baseUrl/sessions',
        queryParameters: queryParams,
      );

      return (response.data as List)
          .map((json) => DiagnosisSessionModel.fromJson(json))
          .toList();
    } on DioException catch (e) {
      throw Exception('Error al obtener sesiones: ${e.message}');
    }
  }

  /// GET /sessions/{sessionId} - Obtener detalle de sesión
  Future<DiagnosisSessionModel> getSessionById(String sessionId) async {
    try {
      final response = await dio.get('$baseUrl/sessions/$sessionId');
      return DiagnosisSessionModel.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw Exception('Error al obtener sesión: ${e.message}');
    }
  }

  /// GET /sessions/{sessionId}/messages - Obtener mensajes de la sesión
  Future<List<DiagnosisMessageModel>> getMessages(String sessionId) async {
    try {
      final response = await dio.get('$baseUrl/sessions/$sessionId/messages');
      return (response.data as List)
          .map((json) => DiagnosisMessageModel.fromJson(json))
          .toList();
    } on DioException catch (e) {
      throw Exception('Error al obtener mensajes: ${e.message}');
    }
  }

  /// POST /sessions/{sessionId}/messages - Enviar mensaje al chatbot
  Future<ChatResponseModel> sendMessage({
    required String sessionId,
    required String content,
  }) async {
    try {
      print('DiagnosisRemoteDataSource: Sending message to session $sessionId');
      print('DiagnosisRemoteDataSource: Content: $content');

      final response = await dio.post(
        '$baseUrl/sessions/$sessionId/messages',
        data: {'content': content},
      );
      return ChatResponseModel.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      print('DiagnosisRemoteDataSource: Error sending message: ${e.response?.statusCode} - ${e.response?.data}');
      throw Exception('Error al enviar mensaje: ${e.message}');
    }
  }

  /// POST /sessions/{sessionId}/classify - Clasificar problema
  Future<ClassificationModel> classifyProblem(String sessionId) async {
    try {
      final response = await dio.post('$baseUrl/sessions/$sessionId/classify');
      return ClassificationModel.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw Exception('Error al clasificar problema: ${e.message}');
    }
  }

  /// GET /sessions/{sessionId}/urgency - Obtener nivel de urgencia
  Future<UrgencyModel> getUrgency(String sessionId) async {
    try {
      final response = await dio.get('$baseUrl/sessions/$sessionId/urgency');
      return UrgencyModel.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw Exception('Error al obtener urgencia: ${e.message}');
    }
  }

  /// GET /sessions/{sessionId}/cost-estimate - Estimación de costos
  Future<CostEstimateModel> getCostEstimate(String sessionId) async {
    try {
      final response = await dio.get('$baseUrl/sessions/$sessionId/cost-estimate');
      return CostEstimateModel.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw Exception('Error al obtener estimación de costos: ${e.message}');
    }
  }

  /// GET /health - Health check
  Future<Map<String, dynamic>> healthCheck() async {
    try {
      final response = await dio.get('$baseUrl/health');
      return response.data;
    } on DioException catch (e) {
      throw Exception('Error en health check: ${e.message}');
    }
  }
}
