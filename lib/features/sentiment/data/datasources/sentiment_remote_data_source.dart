import 'package:dio/dio.dart';
import 'package:proyecto/features/sentiment/data/models/sentiment_models.dart';

class SentimentRemoteDataSource {
  final Dio dio;
  static const String baseUrl = 'https://ai-diagnosis-service-autodiag.onrender.com';

  SentimentRemoteDataSource({required this.dio});

  /// POST /sentiment/analyze - Analizar sentimiento de un texto
  Future<SentimentAnalysisModel> analyzeSentiment({
    required String text,
    Map<String, dynamic>? context,
  }) async {
    try {
      final response = await dio.post(
        '$baseUrl/sentiment/analyze',
        data: {
          'text': text,
          if (context != null) 'context': context,
        },
      );
      return SentimentAnalysisModel.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw Exception('Error al analizar sentimiento: ${e.message}');
    }
  }

  /// POST /sentiment/batch - Analizar sentimiento en lote
  Future<List<BatchSentimentItemModel>> analyzeBatchSentiment({
    required List<Map<String, String>> texts,
  }) async {
    try {
      final response = await dio.post(
        '$baseUrl/sentiment/batch',
        data: {'texts': texts},
      );
      return (response.data as List)
          .map((json) => BatchSentimentItemModel.fromJson(json))
          .toList();
    } on DioException catch (e) {
      throw Exception('Error al analizar sentimientos en lote: ${e.message}');
    }
  }
}
