import 'package:equatable/equatable.dart';

class Review extends Equatable {
  final String id;
  final String authorName;
  final String userId; // --- CAMPO NUEVO AGREGADO ---
  final double rating;
  final String comment;
  final DateTime date;
  final String? workshopResponse;

  const Review({
    required this.id,
    required this.authorName,
    required this.userId, // Requerido en constructor
    required this.rating,
    required this.comment,
    required this.date,
    this.workshopResponse,
  });

  factory Review.fromJson(Map<String, dynamic> json) {
    double parsedRating = 0.0;
    if (json['rating'] is Map) {
      parsedRating = (json['rating']['overall'] as num?)?.toDouble() ?? 0.0;
    } else if (json['rating'] is num) {
      parsedRating = (json['rating'] as num).toDouble();
    }

    return Review(
      id: json['id'] ?? '',
      authorName: json['userName'] ?? 'Anónimo',
      userId: json['userId'] ?? '', // Mapeo del backend
      rating: parsedRating,
      comment: json['comment'] ?? '',
      date: json['createdAt'] != null 
          ? DateTime.parse(json['createdAt']) 
          : DateTime.now(),
      workshopResponse: json['workshopResponse'],
    );
  }

  @override
  List<Object?> get props => [id, authorName, userId, rating, comment, date, workshopResponse];
}