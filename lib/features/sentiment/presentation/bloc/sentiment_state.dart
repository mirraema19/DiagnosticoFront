part of 'sentiment_bloc.dart';

abstract class SentimentState extends Equatable {
  const SentimentState();
  
  @override
  List<Object?> get props => [];
}

class SentimentInitial extends SentimentState {}

class SentimentLoading extends SentimentState {}

class SentimentAnalyzed extends SentimentState {
  final SentimentAnalysisModel result;

  const SentimentAnalyzed(this.result);

  @override
  List<Object?> get props => [result];
}

class SentimentError extends SentimentState {
  final String message;

  const SentimentError(this.message);

  @override
  List<Object?> get props => [message];
}
