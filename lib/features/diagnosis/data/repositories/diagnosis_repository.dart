import 'package:proyecto/features/diagnosis/data/datasources/diagnosis_remote_data_source.dart';
import 'package:proyecto/features/diagnosis/data/models/diagnosis_session_model.dart';
import 'package:proyecto/features/diagnosis/data/models/diagnosis_message_model.dart';
import 'package:proyecto/features/diagnosis/data/models/chat_response_model.dart';
import 'package:proyecto/features/diagnosis/data/models/classification_model.dart';
import 'package:proyecto/features/diagnosis/data/models/urgency_model.dart';
import 'package:proyecto/features/diagnosis/data/models/cost_estimate_model.dart';

class DiagnosisRepository {
  final DiagnosisRemoteDataSource dataSource;

  DiagnosisRepository({required this.dataSource});

  Future<ChatResponseModel> createSession({
    required String vehicleId,
    required String initialMessage,
  }) async {
    try {
      return await dataSource.createSession(
        vehicleId: vehicleId,
        initialMessage: initialMessage,
      );
    } catch (e) {
      throw Exception('Repository: $e');
    }
  }

  Future<List<DiagnosisSessionModel>> getSessions({
    String? vehicleId,
    int limit = 10,
  }) async {
    try {
      return await dataSource.getSessions(
        vehicleId: vehicleId,
        limit: limit,
      );
    } catch (e) {
      throw Exception('Repository: $e');
    }
  }

  Future<DiagnosisSessionModel> getSessionById(String sessionId) async {
    try {
      return await dataSource.getSessionById(sessionId);
    } catch (e) {
      throw Exception('Repository: $e');
    }
  }

  Future<List<DiagnosisMessageModel>> getMessages(String sessionId) async {
    try {
      return await dataSource.getMessages(sessionId);
    } catch (e) {
      throw Exception('Repository: $e');
    }
  }

  Future<ChatResponseModel> sendMessage({
    required String sessionId,
    required String content,
  }) async {
    try {
      return await dataSource.sendMessage(
        sessionId: sessionId,
        content: content,
      );
    } catch (e) {
      throw Exception('Repository: $e');
    }
  }

  Future<ClassificationModel> classifyProblem(String sessionId) async {
    try {
      return await dataSource.classifyProblem(sessionId);
    } catch (e) {
      throw Exception('Repository: $e');
    }
  }

  Future<UrgencyModel> getUrgency(String sessionId) async {
    try {
      return await dataSource.getUrgency(sessionId);
    } catch (e) {
      throw Exception('Repository: $e');
    }
  }

  Future<CostEstimateModel> getCostEstimate(String sessionId) async {
    try {
      return await dataSource.getCostEstimate(sessionId);
    } catch (e) {
      throw Exception('Repository: $e');
    }
  }

  Future<Map<String, dynamic>> healthCheck() async {
    try {
      return await dataSource.healthCheck();
    } catch (e) {
      throw Exception('Repository: $e');
    }
  }
}
