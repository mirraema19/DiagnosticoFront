import 'package:equatable/equatable.dart';

/// Etiqueta de sentimiento
enum SentimentLabel {
  POSITIVE,
  NEUTRAL,
  NEGATIVE;

  String get value => name;

  String get displayName {
    switch (this) {
      case SentimentLabel.POSITIVE:
        return 'Positivo';
      case SentimentLabel.NEUTRAL:
        return 'Neutral';
      case SentimentLabel.NEGATIVE:
        return 'Negativo';
    }
  }

  String get emoji {
    switch (this) {
      case SentimentLabel.POSITIVE:
        return '😊';
      case SentimentLabel.NEUTRAL:
        return '😐';
      case SentimentLabel.NEGATIVE:
        return '😠';
    }
  }
}

/// Scores detallados de sentimiento
class SentimentScores extends Equatable {
  final double positive;
  final double neutral;
  final double negative;

  const SentimentScores({
    required this.positive,
    required this.neutral,
    required this.negative,
  });

  factory SentimentScores.fromJson(Map<String, dynamic> json) {
    return SentimentScores(
      positive: (json['positive'] as num).toDouble(),
      neutral: (json['neutral'] as num).toDouble(),
      negative: (json['negative'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'positive': positive,
      'neutral': neutral,
      'negative': negative,
    };
  }

  @override
  List<Object?> get props => [positive, neutral, negative];
}

/// Resultado del análisis de sentimiento
class SentimentResult extends Equatable {
  final SentimentLabel label;
  final double score;
  final SentimentScores scores;

  const SentimentResult({
    required this.label,
    required this.score,
    required this.scores,
  });

  factory SentimentResult.fromJson(Map<String, dynamic> json) {
    return SentimentResult(
      label: SentimentLabel.values.firstWhere(
        (e) => e.value == json['label'],
        orElse: () => SentimentLabel.NEUTRAL,
      ),
      score: (json['score'] as num).toDouble(),
      scores: SentimentScores.fromJson(json['scores'] as Map<String, dynamic>),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'label': label.value,
      'score': score,
      'scores': scores.toJson(),
    };
  }

  @override
  List<Object?> get props => [label, score, scores];
}

/// Modelo completo de análisis de sentimiento
class SentimentAnalysisModel extends Equatable {
  final String id;
  final String text;
  final SentimentResult sentiment;
  final Map<String, dynamic>? context;
  final DateTime analyzedAt;

  const SentimentAnalysisModel({
    required this.id,
    required this.text,
    required this.sentiment,
    this.context,
    required this.analyzedAt,
  });

  factory SentimentAnalysisModel.fromJson(Map<String, dynamic> json) {
    return SentimentAnalysisModel(
      id: json['id'],
      text: json['text'],
      sentiment: SentimentResult.fromJson(json['sentiment'] as Map<String, dynamic>),
      context: json['context'] as Map<String, dynamic>?,
      analyzedAt: DateTime.parse(json['analyzed_at'] ?? json['analyzedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'text': text,
      'sentiment': sentiment.toJson(),
      'context': context,
      'analyzed_at': analyzedAt.toIso8601String(),
    };
  }

  @override
  List<Object?> get props => [id, text, sentiment, context, analyzedAt];
}

/// Item individual en análisis batch de sentimiento
class BatchSentimentItemModel extends Equatable {
  final String id;
  final SentimentResult sentiment;

  const BatchSentimentItemModel({
    required this.id,
    required this.sentiment,
  });

  factory BatchSentimentItemModel.fromJson(Map<String, dynamic> json) {
    return BatchSentimentItemModel(
      id: json['id'],
      sentiment: SentimentResult.fromJson(json['sentiment'] as Map<String, dynamic>),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'sentiment': sentiment.toJson(),
    };
  }

  @override
  List<Object?> get props => [id, sentiment];
}
