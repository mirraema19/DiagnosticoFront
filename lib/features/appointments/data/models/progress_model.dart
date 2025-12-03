import 'package:equatable/equatable.dart';

// Etapas del progreso
enum ProgressStage {
  RECEIVED,
  IN_DIAGNOSIS,
  IN_REPAIR,
  QUALITY_CHECK,
  READY_FOR_PICKUP,
}

class ProgressModel extends Equatable {
  final String id;
  final String appointmentId;
  final ProgressStage stage;
  final String description;
  final List<String> photos;
  final DateTime? estimatedCompletion;
  final DateTime createdAt;

  const ProgressModel({
    required this.id,
    required this.appointmentId,
    required this.stage,
    required this.description,
    required this.photos,
    this.estimatedCompletion,
    required this.createdAt,
  });

  factory ProgressModel.fromJson(Map<String, dynamic> json) {
    return ProgressModel(
      id: json['id'] as String,
      appointmentId: json['appointmentId'] as String,
      stage: _parseStage(json['stage'] as String),
      description: json['description'] as String,
      photos: (json['photos'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      estimatedCompletion: json['estimatedCompletion'] != null
          ? DateTime.parse(json['estimatedCompletion'] as String)
          : null,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'appointmentId': appointmentId,
      'stage': stage.name,
      'description': description,
      'photos': photos,
      'estimatedCompletion': estimatedCompletion?.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
    };
  }

  static ProgressStage _parseStage(String stage) {
    return ProgressStage.values.firstWhere(
      (e) => e.name == stage,
      orElse: () => ProgressStage.RECEIVED,
    );
  }

  @override
  List<Object?> get props => [
        id,
        appointmentId,
        stage,
        description,
        photos,
        estimatedCompletion,
        createdAt,
      ];
}

// DTO para crear progreso
class CreateProgressDto {
  final ProgressStage stage;
  final String description;
  final List<String> photos;
  final DateTime? estimatedCompletion;

  const CreateProgressDto({
    required this.stage,
    required this.description,
    this.photos = const [],
    this.estimatedCompletion,
  });

  Map<String, dynamic> toJson() {
    return {
      'stage': stage.name,
      'description': description,
      'photos': photos,
      'estimatedCompletion': estimatedCompletion?.toIso8601String(),
    };
  }
}
