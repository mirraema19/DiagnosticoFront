import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:proyecto/features/sentiment/data/models/sentiment_models.dart';
import 'package:proyecto/features/sentiment/data/repositories/sentiment_repository.dart';

part 'sentiment_event.dart';
part 'sentiment_state.dart';

class SentimentBloc extends Bloc<SentimentEvent, SentimentState> {
  final SentimentRepository repository;

  SentimentBloc({required this.repository}) : super(SentimentInitial()) {
    on<AnalyzeTextSentiment>(_onAnalyzeTextSentiment);
    on<ClearSentimentResult>(_onClearSentimentResult);
  }

  Future<void> _onAnalyzeTextSentiment(
    AnalyzeTextSentiment event,
    Emitter<SentimentState> emit,
  ) async {
    emit(SentimentLoading());
    try {
      final result = await repository.analyzeSentiment(
        text: event.text,
        context: event.context,
      );
      emit(SentimentAnalyzed(result));
    } catch (e) {
      emit(SentimentError(e.toString()));
    }
  }

  void _onClearSentimentResult(
    ClearSentimentResult event,
    Emitter<SentimentState> emit,
  ) {
    emit(SentimentInitial());
  }
}
