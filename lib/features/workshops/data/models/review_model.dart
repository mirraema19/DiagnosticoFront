import 'package:equatable/equatable.dart';

class Review extends Equatable {
  final String authorName;
  final double rating;
  final String comment;
  final DateTime date;

  const Review({
    required this.authorName,
    required this.rating,
    required this.comment,
    required this.date,
  });

  // --- CONSTRUCTOR fromJson AÑADIDO ---
  factory Review.fromJson(Map<String, dynamic> json) {
    return Review(
      authorName: json['authorName'] ?? 'Anónimo',
      rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
      comment: json['comment'] ?? '',
      date: json['date'] != null ? DateTime.parse(json['date']) : DateTime.now(),
    );
  }

  @override
  List<Object?> get props => [authorName, rating, comment, date];
}