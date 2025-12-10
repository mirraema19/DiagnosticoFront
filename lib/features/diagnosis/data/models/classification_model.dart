import 'package:equatable/equatable.dart';

enum ProblemCategory {
  ENGINE,
  TRANSMISSION,
  BRAKES,
  ELECTRICAL,
  AIR_CONDITIONING,
  SUSPENSION,
  EXHAUST,
  FUEL_SYSTEM,
  COOLING_SYSTEM,
  TIRES,
  BATTERY,
  LIGHTS,
  OTHER;

  String get value => name;

  String get displayName {
    switch (this) {
      case ProblemCategory.ENGINE:
        return 'Motor';
      case ProblemCategory.TRANSMISSION:
        return 'Transmisión';
      case ProblemCategory.BRAKES:
        return 'Frenos';
      case ProblemCategory.ELECTRICAL:
        return 'Sistema Eléctrico';
      case ProblemCategory.AIR_CONDITIONING:
        return 'Aire Acondicionado';
      case ProblemCategory.SUSPENSION:
        return 'Suspensión';
      case ProblemCategory.EXHAUST:
        return 'Escape';
      case ProblemCategory.FUEL_SYSTEM:
        return 'Sistema de Combustible';
      case ProblemCategory.COOLING_SYSTEM:
        return 'Sistema de Enfriamiento';
      case ProblemCategory.TIRES:
        return 'Llantas';
      case ProblemCategory.BATTERY:
        return 'Batería';
      case ProblemCategory.LIGHTS:
        return 'Luces';
      case ProblemCategory.OTHER:
        return 'Otro';
    }
  }
}

class ClassificationModel extends Equatable {
  final String id;
  final String sessionId;
  final ProblemCategory category;
  final String? subcategory;
  final double confidenceScore;
  final List<String> symptoms;
  final DateTime createdAt;

  const ClassificationModel({
    required this.id,
    required this.sessionId,
    required this.category,
    this.subcategory,
    required this.confidenceScore,
    this.symptoms = const [],
    required this.createdAt,
  });

  factory ClassificationModel.fromJson(Map<String, dynamic> json) {
    return ClassificationModel(
      id: json['id'],
      sessionId: json['sessionId'], // Backend uses camelCase
      category: ProblemCategory.values.firstWhere(
        (e) => e.value == json['category'],
        orElse: () => ProblemCategory.OTHER,
      ),
      subcategory: json['subcategory'],
      confidenceScore: (json['confidenceScore'] as num).toDouble(), // Backend uses camelCase
      symptoms: (json['symptoms'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      createdAt: DateTime.parse(json['createdAt']), // Backend uses camelCase
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'sessionId': sessionId,
      'category': category.value,
      'subcategory': subcategory,
      'confidenceScore': confidenceScore,
      'symptoms': symptoms,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  @override
  List<Object?> get props => [
        id,
        sessionId,
        category,
        subcategory,
        confidenceScore,
        symptoms,
        createdAt,
      ];
}
