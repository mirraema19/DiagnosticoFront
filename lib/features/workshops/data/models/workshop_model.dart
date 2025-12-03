import 'package:equatable/equatable.dart';
import 'package:proyecto/features/workshops/data/models/review_model.dart';

class Workshop extends Equatable {
  final String id;
  final String ownerId;
  final String name;
  final String address;
  final String phone;
  final String operatingHours;
  final String? description;
  final String? email;
  final String? website;
  final double rating;
  final int reviewCount;
  final double distance;
  final String imageUrl;
  final List<String> photoUrls;
  final String priceRange;
  final List<String> tags;
  final List<String> specialties;
  final List<Review> reviews;

  // Campos de ubicación
  final String? street;
  final String? city;
  final String? state;
  final String? zipCode;
  final String? country;
  final double? latitude;
  final double? longitude;

  // Campos de estado
  final bool isApproved;
  final bool isActive;

  // Timestamps
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const Workshop({
    required this.id,
    required this.ownerId,
    required this.name,
    required this.address,
    required this.phone,
    required this.operatingHours,
    this.description,
    this.email,
    this.website,
    required this.rating,
    required this.reviewCount,
    required this.distance,
    required this.imageUrl,
    required this.photoUrls,
    required this.priceRange,
    required this.tags,
    required this.specialties,
    required this.reviews,
    this.street,
    this.city,
    this.state,
    this.zipCode,
    this.country,
    this.latitude,
    this.longitude,
    required this.isApproved,
    required this.isActive,
    this.createdAt,
    this.updatedAt,
  });

  String get businessName => name;

  factory Workshop.fromJson(Map<String, dynamic> json) {
    var reviewsList = <Review>[];
    if (json['reviews'] != null) {
      reviewsList = (json['reviews'] as List)
          .map((reviewJson) => Review.fromJson(reviewJson))
          .toList();
    }

    var specialtiesList = <String>[];
    if (json['specialties'] != null) {
      specialtiesList = (json['specialties'] as List).map((s) {
        if (s is Map) return s['specialtyType']?.toString() ?? '';
        return s.toString();
      }).toList();
    }

    var photoUrlsList = <String>[];
    if (json['photoUrls'] != null && json['photoUrls'] is List) {
      photoUrlsList = (json['photoUrls'] as List).map((e) => e.toString()).toList();
    }

    final street = json['street'] as String?;
    final city = json['city'] as String?;
    final fullAddress = '${street ?? ''}, ${city ?? ''}'.trim();

    final priceRangeVal = json['priceRange'] ?? 'MEDIUM';

    return Workshop(
      id: json['id'] ?? '',
      ownerId: json['ownerId'] ?? '',
      name: json['businessName'] ?? 'Nombre no disponible',
      address: fullAddress.isNotEmpty ? fullAddress : 'Dirección no disponible',
      phone: json['phone'] ?? 'No disponible',
      operatingHours: json['operatingHours'] ?? 'L-V 9am - 6pm',
      description: json['description'] as String?,
      email: json['email'] as String?,
      website: json['website'] as String?,
      rating: (json['overallRating'] as num?)?.toDouble() ?? 0.0,
      reviewCount: json['totalReviews'] ?? 0,
      distance: (json['distance'] as num?)?.toDouble() ?? 0.0,
      imageUrl: photoUrlsList.isNotEmpty
          ? photoUrlsList.first
          : 'assets/images/workshop_placeholder.png',
      photoUrls: photoUrlsList,
      priceRange: priceRangeVal,
      tags: [priceRangeVal],
      specialties: specialtiesList,
      reviews: reviewsList,
      street: street,
      city: city,
      state: json['state'] as String?,
      zipCode: json['zipCode'] as String?,
      country: json['country'] as String? ?? 'México',
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      isApproved: json['isApproved'] ?? false,
      isActive: json['isActive'] ?? true,
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
      updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
    );
  }

  @override
  List<Object?> get props => [
        id, ownerId, name, address, phone, operatingHours, description, email, website,
        rating, reviewCount, distance, imageUrl, photoUrls, priceRange, tags, specialties, reviews,
        street, city, state, zipCode, country, latitude, longitude,
        isApproved, isActive, createdAt, updatedAt
      ];
}