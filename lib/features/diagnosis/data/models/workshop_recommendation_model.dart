import 'package:equatable/equatable.dart';

/// Modelo para representar una recomendación de taller del backend
class WorkshopRecommendationModel extends Equatable {
  final String workshopId;
  final String workshopName;
  final double matchScore;
  final List<String> reasons;
  final double? distanceKm;
  final double? rating;

  const WorkshopRecommendationModel({
    required this.workshopId,
    required this.workshopName,
    required this.matchScore,
    required this.reasons,
    this.distanceKm,
    this.rating,
  });

  factory WorkshopRecommendationModel.fromJson(Map<String, dynamic> json) {
    return WorkshopRecommendationModel(
      workshopId: json['workshop_id'] ?? json['workshopId'],
      workshopName: json['workshop_name'] ?? json['workshopName'],
      matchScore: (json['match_score'] ?? json['matchScore'] as num).toDouble(),
      reasons: (json['reasons'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      distanceKm: json['distance_km'] != null || json['distanceKm'] != null
          ? (json['distance_km'] ?? json['distanceKm'] as num?)?.toDouble()
          : null,
      rating: json['rating'] != null
          ? (json['rating'] as num).toDouble()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'workshop_id': workshopId,
      'workshop_name': workshopName,
      'match_score': matchScore,
      'reasons': reasons,
      'distance_km': distanceKm,
      'rating': rating,
    };
  }

  /// Retorna un emoji según el match score
  String get matchEmoji {
    if (matchScore >= 0.8) return '🌟'; // Excelente
    if (matchScore >= 0.6) return '✅'; // Bueno
    return '👍'; // Aceptable
  }

  /// Retorna una descripción del match score
  String get matchDescription {
    if (matchScore >= 0.8) return 'Excelente coincidencia';
    if (matchScore >= 0.6) return 'Buena coincidencia';
    return 'Coincidencia aceptable';
  }

  /// Retorna el porcentaje del match score
  String get matchPercentage => '${(matchScore * 100).toStringAsFixed(0)}%';

  @override
  List<Object?> get props => [
        workshopId,
        workshopName,
        matchScore,
        reasons,
        distanceKm,
        rating,
      ];
}
