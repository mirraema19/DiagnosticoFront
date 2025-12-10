import 'package:proyecto/features/sentiment/data/datasources/sentiment_remote_data_source.dart';
import 'package:proyecto/features/sentiment/data/models/sentiment_models.dart';

class SentimentRepository {
  final SentimentRemoteDataSource dataSource;

  SentimentRepository({required this.dataSource});

  Future<SentimentAnalysisModel> analyzeSentiment({
    required String text,
    Map<String, dynamic>? context,
  }) async {
    try {
      return await dataSource.analyzeSentiment(
        text: text,
        context: context,
      );
    } catch (e) {
      throw Exception('Repository: $e');
    }
  }

  Future<List<BatchSentimentItemModel>> analyzeBatchSentiment({
    required List<Map<String, String>> texts,
  }) async {
    try {
      return await dataSource.analyzeBatchSentiment(texts: texts);
    } catch (e) {
      throw Exception('Repository: $e');
    }
  }
}
