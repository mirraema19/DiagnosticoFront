class WorkshopSpecialtyModel {
  final String id;
  final String workshopId;
  final String specialtyType;
  final String? description;
  final int? yearsOfExperience;
  final DateTime createdAt;

  WorkshopSpecialtyModel({
    required this.id,
    required this.workshopId,
    required this.specialtyType,
    this.description,
    this.yearsOfExperience,
    required this.createdAt,
  });

  factory WorkshopSpecialtyModel.fromJson(Map<String, dynamic> json) {
    return WorkshopSpecialtyModel(
      id: json['id'],
      workshopId: json['workshopId'],
      specialtyType: json['specialtyType'],
      description: json['description'],
      yearsOfExperience: json['yearsOfExperience'],
      createdAt: DateTime.parse(json['createdAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'workshopId': workshopId,
      'specialtyType': specialtyType,
      'description': description,
      'yearsOfExperience': yearsOfExperience,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  // Helper para obtener el nombre legible de la especialidad
  String get displayName {
    switch (specialtyType) {
      case 'ENGINE':
        return 'Motor';
      case 'TRANSMISSION':
        return 'Transmisión';
      case 'BRAKES':
        return 'Frenos';
      case 'ELECTRICAL':
        return 'Sistema Eléctrico';
      case 'AIR_CONDITIONING':
        return 'Aire Acondicionado';
      case 'SUSPENSION':
        return 'Suspensión';
      case 'BODYWORK':
        return 'Carrocería';
      case 'PAINTING':
        return 'Pintura';
      case 'ALIGNMENT':
        return 'Alineación';
      case 'DIAGNOSTICS':
        return 'Diagnóstico';
      case 'TIRE_SERVICE':
        return 'Servicio de Llantas';
      case 'OIL_CHANGE':
        return 'Cambio de Aceite';
      case 'GENERAL_MAINTENANCE':
        return 'Mantenimiento General';
      default:
        return specialtyType;
    }
  }
}

// Enum para los tipos de especialidad
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

extension SpecialtyTypeExtension on SpecialtyType {
  String get value {
    return toString().split('.').last;
  }

  String get displayName {
    switch (this) {
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
        return 'Alineación';
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
}
