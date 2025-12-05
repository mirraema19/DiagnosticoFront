import 'package:equatable/equatable.dart';

// Estados de la cita según el backend
enum AppointmentStatus {
  PENDING,
  CONFIRMED,
  IN_PROGRESS,
  COMPLETED,
  CANCELLED,
}

// Tipos de servicio disponibles (sincronizados con backend)
enum ServiceType {
  OIL_CHANGE,
  TIRE_ROTATION,
  BRAKE_INSPECTION,
  BRAKE_REPLACEMENT,
  FILTER_REPLACEMENT,
  BATTERY_REPLACEMENT,
  ALIGNMENT,
  TRANSMISSION_SERVICE,
  COOLANT_FLUSH,
  ENGINE_TUNEUP,
  INSPECTION,
  OTHER,
}

class AppointmentModel extends Equatable {
  final String id;
  final String userId;
  final String vehicleId;
  final String workshopId;
  final String? diagnosisId;
  final ServiceType serviceType;
  final String? description;
  final AppointmentStatus status;
  final DateTime scheduledDate;
  final String scheduledTime;
  final int? estimatedDuration;
  final double? estimatedCost;
  final double? finalCost;
  final String? cancelReason;
  final String? cancelledBy;
  final DateTime? cancelledAt;
  final DateTime? completedAt;
  final String? notes;
  final List<String> photos;
  final List<String> documents;
  final DateTime createdAt;
  final DateTime updatedAt;

  const AppointmentModel({
    required this.id,
    required this.userId,
    required this.vehicleId,
    required this.workshopId,
    this.diagnosisId,
    required this.serviceType,
    this.description,
    required this.status,
    required this.scheduledDate,
    required this.scheduledTime,
    this.estimatedDuration,
    this.estimatedCost,
    this.finalCost,
    this.cancelReason,
    this.cancelledBy,
    this.cancelledAt,
    this.completedAt,
    this.notes,
    this.photos = const [],
    this.documents = const [],
    required this.createdAt,
    required this.updatedAt,
  });

  factory AppointmentModel.fromJson(Map<String, dynamic> json) {
    // Helper para extraer valores String de forma segura
    String _extractString(dynamic value, String fieldName) {
      if (value == null) {
        print('⚠️ Campo $fieldName es null');
        return '';
      }
      if (value is String) return value;
      if (value is Map<String, dynamic>) {
        // Caso 1: Value Object con propiedad 'value'
        if (value.containsKey('value')) {
          return value['value'].toString();
        }
        // Caso 2: Objeto con 'id'
        if (value.containsKey('id')) {
          return value['id'].toString();
        }
        // Caso 3: Objeto con '_id'
        if (value.containsKey('_id')) {
          return value['_id'].toString();
        }
        print('⚠️ Campo $fieldName es un Map sin value/id/_id: $value');
        return '';
      }
      return value.toString();
    }

    // Helper para extraer valores String opcionales
    String? _extractStringOptional(dynamic value, String fieldName) {
      if (value == null) return null;
      if (value is String) return value;
      if (value is Map<String, dynamic>) {
        // Caso 1: Value Object con propiedad 'value'
        if (value.containsKey('value')) {
          return value['value'].toString();
        }
        // Caso 2: Objeto con 'id'
        if (value.containsKey('id')) {
          return value['id'].toString();
        }
        // Caso 3: Objeto con '_id'
        if (value.containsKey('_id')) {
          return value['_id'].toString();
        }
        print('⚠️ Campo opcional $fieldName es un Map sin value/id/_id: $value');
        return null;
      }
      return value.toString();
    }

    // Helper para parsear DateTime de forma segura
    DateTime _parseDateTime(dynamic value, String fieldName) {
      try {
        if (value == null) {
          print('⚠️ Fecha $fieldName es null, usando DateTime.now()');
          return DateTime.now();
        }
        if (value is String) return DateTime.parse(value);
        if (value is DateTime) return value;
        print('⚠️ Fecha $fieldName tiene tipo inesperado: ${value.runtimeType}');
        return DateTime.now();
      } catch (e) {
        print('❌ Error parseando fecha $fieldName: $e');
        return DateTime.now();
      }
    }

    // Helper para parsear DateTime opcional
    DateTime? _parseDateTimeOptional(dynamic value, String fieldName) {
      try {
        if (value == null) return null;
        if (value is String) return DateTime.parse(value);
        if (value is DateTime) return value;
        print('⚠️ Fecha opcional $fieldName tiene tipo inesperado: ${value.runtimeType}');
        return null;
      } catch (e) {
        print('❌ Error parseando fecha opcional $fieldName: $e');
        return null;
      }
    }

    print('📝 Parseando AppointmentModel desde JSON');

    return AppointmentModel(
      id: _extractString(json['id'], 'id'),
      userId: _extractString(json['userId'], 'userId'),
      vehicleId: _extractString(json['vehicleId'], 'vehicleId'),
      workshopId: _extractString(json['workshopId'], 'workshopId'),
      diagnosisId: _extractStringOptional(json['diagnosisId'], 'diagnosisId'),
      serviceType: _parseServiceType(_extractString(json['serviceType'], 'serviceType')),
      description: _extractStringOptional(json['description'], 'description'),
      status: _parseStatus(_extractString(json['status'], 'status')),
      scheduledDate: _parseDateTime(json['scheduledDate'], 'scheduledDate'),
      scheduledTime: _extractString(json['scheduledTime'], 'scheduledTime'),
      estimatedDuration: json['estimatedDuration'] is int
          ? json['estimatedDuration'] as int
          : (json['estimatedDuration'] is num
              ? (json['estimatedDuration'] as num).toInt()
              : null),
      estimatedCost: json['estimatedCost'] != null
          ? (json['estimatedCost'] is num
              ? (json['estimatedCost'] as num).toDouble()
              : (json['estimatedCost'] is String
                  ? double.tryParse(json['estimatedCost'] as String)
                  : (json['estimatedCost'] is Map<String, dynamic>
                      ? (json['estimatedCost']['amount'] != null
                          ? (json['estimatedCost']['amount'] as num).toDouble()
                          : null)
                      : null)))
          : null,
      finalCost: json['finalCost'] != null
          ? (json['finalCost'] is num
              ? (json['finalCost'] as num).toDouble()
              : (json['finalCost'] is String
                  ? double.tryParse(json['finalCost'] as String)
                  : null))
          : null,
      cancelReason: _extractStringOptional(json['cancelReason'], 'cancelReason'),
      cancelledBy: _extractStringOptional(json['cancelledBy'], 'cancelledBy'),
      cancelledAt: _parseDateTimeOptional(json['cancelledAt'], 'cancelledAt'),
      completedAt: _parseDateTimeOptional(json['completedAt'], 'completedAt'),
      notes: _extractStringOptional(json['notes'], 'notes'),
      photos: json['photos'] is List
              ? (json['photos'] as List).map((e) => e.toString()).toList()
              : [],
      documents: json['documents'] is List
              ? (json['documents'] as List).map((e) => e.toString()).toList()
              : [],
      createdAt: _parseDateTime(json['createdAt'], 'createdAt'),
      updatedAt: _parseDateTime(json['updatedAt'], 'updatedAt'),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'vehicleId': vehicleId,
      'workshopId': workshopId,
      'diagnosisId': diagnosisId,
      'serviceType': serviceType.name,
      'description': description,
      'status': status.name,
      'scheduledDate': scheduledDate.toIso8601String(),
      'scheduledTime': scheduledTime,
      'estimatedDuration': estimatedDuration,
      'estimatedCost': estimatedCost,
      'finalCost': finalCost,
      'cancelReason': cancelReason,
      'cancelledBy': cancelledBy,
      'cancelledAt': cancelledAt?.toIso8601String(),
      'completedAt': completedAt?.toIso8601String(),
      'notes': notes,
      'photos': photos,
      'documents': documents,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  static AppointmentStatus _parseStatus(String status) {
    return AppointmentStatus.values.firstWhere(
      (e) => e.name == status,
      orElse: () => AppointmentStatus.PENDING,
    );
  }

  static ServiceType _parseServiceType(String type) {
    return ServiceType.values.firstWhere(
      (e) => e.name == type,
      orElse: () => ServiceType.OTHER,
    );
  }

  @override
  List<Object?> get props => [
        id,
        userId,
        vehicleId,
        workshopId,
        diagnosisId,
        serviceType,
        description,
        status,
        scheduledDate,
        scheduledTime,
        estimatedDuration,
        estimatedCost,
        finalCost,
        cancelReason,
        cancelledBy,
        cancelledAt,
        completedAt,
        notes,
        photos,
        documents,
        createdAt,
        updatedAt,
      ];
}

// Modelo para crear una cita
class CreateAppointmentDto {
  final String vehicleId;
  final String workshopId;
  final String? diagnosisId;
  final ServiceType serviceType;
  final String description;
  final String scheduledDate; // Format: "2024-12-15"
  final String scheduledTime; // Format: "10:00"
  final int? estimatedDuration;
  final double? estimatedCost;

  const CreateAppointmentDto({
    required this.vehicleId,
    required this.workshopId,
    this.diagnosisId,
    required this.serviceType,
    required this.description,
    required this.scheduledDate,
    required this.scheduledTime,
    this.estimatedDuration,
    this.estimatedCost,
  });

  Map<String, dynamic> toJson() {
    return {
      'vehicleId': vehicleId,
      'workshopId': workshopId,
      'diagnosisId': diagnosisId,
      'serviceType': serviceType.name,
      'description': description,
      'scheduledDate': scheduledDate,
      'scheduledTime': scheduledTime,
      'estimatedDuration': estimatedDuration,
      'estimatedCost': estimatedCost,
    };
  }
}

// Modelo para actualizar una cita (solo campos permitidos por el backend)
class UpdateAppointmentDto {
  final String? scheduledDate;
  final String? scheduledTime;
  final String? description;

  const UpdateAppointmentDto({
    this.scheduledDate,
    this.scheduledTime,
    this.description,
  });

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    if (scheduledDate != null) data['scheduledDate'] = scheduledDate;
    if (scheduledTime != null) data['scheduledTime'] = scheduledTime;
    if (description != null) data['description'] = description;
    return data;
  }
}
