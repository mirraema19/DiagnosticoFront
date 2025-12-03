import 'package:equatable/equatable.dart';

/// Tipos de especialidades disponibles
enum SpecialtyType {
  ENGINE,
  TRANSMISSION,
  BRAKES,
  ELECTRICAL,
  AIR_CONDITIONING,
  SUSPENSION,
  BODYWORK,
  PAINTING,
  ALIGNMENT,
  DIAGNOSTICS,
  TIRE_SERVICE,
  OIL_CHANGE,
  GENERAL_MAINTENANCE,
}

/// Modelo para las especialidades de un taller
class WorkshopSpecialty extends Equatable {
  final String id;
  final String workshopId;
  final SpecialtyType specialtyType;
  final String? description;
  final int? yearsOfExperience;
  final DateTime createdAt;

  const WorkshopSpecialty({
    required this.id,
    required this.workshopId,
    required this.specialtyType,
    this.description,
    this.yearsOfExperience,
    required this.createdAt,
  });

  factory WorkshopSpecialty.fromJson(Map<String, dynamic> json) {
    return WorkshopSpecialty(
      id: json['id'] as String,
      workshopId: json['workshopId'] as String,
      specialtyType: _parseSpecialtyType(json['specialtyType'] as String),
      description: json['description'] as String?,
      yearsOfExperience: json['yearsOfExperience'] as int?,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'workshopId': workshopId,
      'specialtyType': specialtyType.name,
      'description': description,
      'yearsOfExperience': yearsOfExperience,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  static SpecialtyType _parseSpecialtyType(String type) {
    return SpecialtyType.values.firstWhere(
      (e) => e.name == type,
      orElse: () => SpecialtyType.GENERAL_MAINTENANCE,
    );
  }

  String get specialtyTypeName {
    switch (specialtyType) {
      case SpecialtyType.ENGINE:
        return 'Motor';
      case SpecialtyType.TRANSMISSION:
        return 'Transmisión';
      case SpecialtyType.BRAKES:
        return 'Frenos';
      case SpecialtyType.ELECTRICAL:
        return 'Sistema Eléctrico';
      case SpecialtyType.AIR_CONDITIONING:
        return 'Aire Acondicionado';
      case SpecialtyType.SUSPENSION:
        return 'Suspensión';
      case SpecialtyType.BODYWORK:
        return 'Carrocería';
      case SpecialtyType.PAINTING:
        return 'Pintura';
      case SpecialtyType.ALIGNMENT:
        return 'Alineación y Balanceo';
      case SpecialtyType.DIAGNOSTICS:
        return 'Diagnóstico';
      case SpecialtyType.TIRE_SERVICE:
        return 'Servicio de Llantas';
      case SpecialtyType.OIL_CHANGE:
        return 'Cambio de Aceite';
      case SpecialtyType.GENERAL_MAINTENANCE:
        return 'Mantenimiento General';
    }
  }

  @override
  List<Object?> get props => [
        id,
        workshopId,
        specialtyType,
        description,
        yearsOfExperience,
        createdAt,
      ];
}

/// DTO para crear una especialidad
class CreateSpecialtyDto {
  final SpecialtyType specialtyType;
  final String? description;
  final int? yearsOfExperience;

  const CreateSpecialtyDto({
    required this.specialtyType,
    this.description,
    this.yearsOfExperience,
  });

  Map<String, dynamic> toJson() {
    return {
      'specialtyType': specialtyType.name,
      'description': description,
      'yearsOfExperience': yearsOfExperience,
    };
  }
}
