import 'package:equatable/equatable.dart';
import 'package:proyecto/features/workshops/data/models/review_model.dart';

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
  final List<Review> reviews;

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
    required this.reviews,
  });

  // --- CORRECCIÓN DEFINITIVA DE fromJson ---
  factory Workshop.fromJson(Map<String, dynamic> json) {
    // El backend puede que no envíe reviews en la lista principal, manejamos el caso
    var reviewsList = (json['reviews'] as List<dynamic>? ?? [])
        .map((reviewJson) => Review.fromJson(reviewJson))
        .toList();

    // Combinamos los campos de dirección del backend en uno solo para el frontend
    final fullAddress = '${json['street'] ?? ''}, ${json['city'] ?? ''}'.trim();

    return Workshop(
      id: json['id'] ?? '',
      name: json['name'] ?? 'Nombre no disponible',
      address: fullAddress.isNotEmpty ? fullAddress : 'Dirección no disponible',
      phone: json['phone'] ?? 'Teléfono no disponible',
      operatingHours: json['operatingHours'] ?? 'No especificado',
      description: json['description'] ?? '',
      // Leemos 'averageRating' y 'totalReviews' del backend
      rating: (json['averageRating'] as num?)?.toDouble() ?? 0.0,
      reviewCount: json['totalReviews'] ?? 0,
      // El endpoint 'nearby' añade este campo. Si no, usamos 0.0
      distance: (json['distance'] as num?)?.toDouble() ?? 0.0,
      imageUrl: json['imageUrl'] ?? 'assets/images/workshop_placeholder.png',
      // 'tags' puede no existir en el backend, usamos una lista vacía
      tags: List<String>.from(json['tags'] ?? []),
      specialties: List<String>.from(json['specialties'] ?? []),
      reviews: reviewsList,
    );
  }

  @override
  List<Object?> get props => [
        id, name, address, phone, operatingHours, description, rating,
        reviewCount, distance, imageUrl, tags, specialties, reviews
      ];
}