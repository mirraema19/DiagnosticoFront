import 'package:equatable/equatable.dart';
import 'package:proyecto/features/workshops/data/models/review_model.dart'; // Importamos el nuevo modelo

class Workshop extends Equatable {
  final String id;
  final String name;
  final String address;
  final String phone;
  final String operatingHours;
  final String description;
  final double rating;
  final int reviewCount;
  final double distance;
  final String imageUrl;
  final List<String> tags;
  final List<String> specialties;
  final List<Review> reviews; // NUEVO: Lista de reseñas

  const Workshop({
    required this.id,
    required this.name,
    required this.address,
    required this.phone,
    required this.operatingHours,
    required this.description,
    required this.rating,
    required this.reviewCount,
    required this.distance,
    required this.imageUrl,
    required this.tags,
    required this.specialties,
    required this.reviews, // NUEVO
  });

  @override
  List<Object?> get props => [
        id, name, address, phone, operatingHours, description, rating,
        reviewCount, distance, imageUrl, tags, specialties, reviews
      ];
}