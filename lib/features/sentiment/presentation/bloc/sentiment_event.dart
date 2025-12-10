part of 'sentiment_bloc.dart';

abstract class SentimentEvent extends Equatable {
  const SentimentEvent();

  @override
  List<Object?> get props => [];
}

class AnalyzeTextSentiment extends SentimentEvent {
  final String text;
  final Map<String, dynamic>? context;

  const AnalyzeTextSentiment({
    required this.text,
    this.context,
  });

  @override
  List<Object?> get props => [text, context];
}

class ClearSentimentResult extends SentimentEvent {}
