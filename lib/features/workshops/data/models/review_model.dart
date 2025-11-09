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

  @override
  List<Object?> get props => [authorName, rating, comment, date];
}