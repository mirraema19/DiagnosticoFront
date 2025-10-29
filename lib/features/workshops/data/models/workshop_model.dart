import 'package:equatable/equatable.dart';

class Workshop extends Equatable {
  final String id;
  final String name;
  final String address;
  final double rating;
  final int reviewCount; // NUEVO
  final double distance; // NUEVO
  final String imageUrl; // NUEVO
  final List<String> tags;

  const Workshop({
    required this.id,
    required this.name,
    required this.address,
    required this.rating,
    required this.reviewCount,
    required this.distance,
    required this.imageUrl,
    required this.tags,
  });

  @override
  List<Object?> get props => [id, name, address, rating, reviewCount, distance, imageUrl, tags];
}