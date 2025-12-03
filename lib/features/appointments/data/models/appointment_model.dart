import 'package:equatable/equatable.dart';

// Estados de la cita según el backend
enum AppointmentStatus {
  PENDING,
  CONFIRMED,
  IN_PROGRESS,
  COMPLETED,
  CANCELLED,
}

// Tipos de servicio disponibles
enum ServiceType {
  BRAKE_INSPECTION,
  OIL_CHANGE,
  TIRE_ROTATION,
  ENGINE_DIAGNOSTIC,
  TRANSMISSION_SERVICE,
  BATTERY_REPLACEMENT,
  AIR_CONDITIONING,
  SUSPENSION_REPAIR,
  EXHAUST_SYSTEM,
  GENERAL_MAINTENANCE,
  OTHER,
}

// Modelos auxiliares para datos relacionados
class AppointmentVehicle {
  final String id;
  final String brand;
  final String model;
  final int year;
  final String? licensePlate;

  const AppointmentVehicle({
    required this.id,
    required this.brand,
    required this.model,
    required this.year,
    this.licensePlate,
  });

  factory AppointmentVehicle.fromJson(Map<String, dynamic> json) {
    return AppointmentVehicle(
      id: json['id'] as String,
      brand: json['brand'] as String,
      model: json['model'] as String,
      year: json['year'] as int,
      licensePlate: json['licensePlate'] as String?,
    );
  }
}

class AppointmentWorkshop {
  final String id;
  final String name;
  final String? phone;
  final String? address;

  const AppointmentWorkshop({
    required this.id,
    required this.name,
    this.phone,
    this.address,
  });

  factory AppointmentWorkshop.fromJson(Map<String, dynamic> json) {
    return AppointmentWorkshop(
      id: json['id'] as String,
      name: json['name'] as String,
      phone: json['phone'] as String?,
      address: json['address'] as String?,
    );
  }
}

class AppointmentUser {
  final String id;
  final String name;
  final String email;

  const AppointmentUser({
    required this.id,
    required this.name,
    required this.email,
  });

  factory AppointmentUser.fromJson(Map<String, dynamic> json) {
    return AppointmentUser(
      id: json['id'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
    );
  }
}

class AppointmentModel extends Equatable {
  final String id;
  final String userId;
  final String vehicleId;
  final String workshopId;
  final String? diagnosisId;
  final ServiceType serviceType;
  final String description;
  final AppointmentStatus status;
  final DateTime scheduledDate;
  final String scheduledTime;
  final int? estimatedDuration;
  final double? estimatedCost;
  final double? finalCost;
  final String? cancelReason;
  final DateTime? cancelledAt;
  final DateTime? completedAt;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;

  // Datos relacionados opcionales (populated por el backend)
  final AppointmentVehicle? vehicle;
  final AppointmentWorkshop? workshop;
  final AppointmentUser? user;

  const AppointmentModel({
    required this.id,
    required this.userId,
    required this.vehicleId,
    required this.workshopId,
    this.diagnosisId,
    required this.serviceType,
    required this.description,
    required this.status,
    required this.scheduledDate,
    required this.scheduledTime,
    this.estimatedDuration,
    this.estimatedCost,
    this.finalCost,
    this.cancelReason,
    this.cancelledAt,
    this.completedAt,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
    this.vehicle,
    this.workshop,
    this.user,
  });

  factory AppointmentModel.fromJson(Map<String, dynamic> json) {
    // Helper para extraer ID de un campo que puede ser String o Map
    String _extractId(dynamic field, String key) {
      if (field == null) return '';
      if (field is String) return field;
      if (field is Map<String, dynamic>) return field['id'] as String;
      return '';
    }

    // Helper para parsear objetos relacionados
    AppointmentVehicle? _parseVehicle(dynamic vehicleData) {
      if (vehicleData == null) return null;
      if (vehicleData is Map<String, dynamic>) {
        return AppointmentVehicle.fromJson(vehicleData);
      }
      return null;
    }

    AppointmentWorkshop? _parseWorkshop(dynamic workshopData) {
      if (workshopData == null) return null;
      if (workshopData is Map<String, dynamic>) {
        return AppointmentWorkshop.fromJson(workshopData);
      }
      return null;
    }

    AppointmentUser? _parseUser(dynamic userData) {
      if (userData == null) return null;
      if (userData is Map<String, dynamic>) {
        return AppointmentUser.fromJson(userData);
      }
      return null;
    }

    return AppointmentModel(
      id: json['id'] as String,
      userId: _extractId(json['userId'] ?? json['user'], 'userId'),
      vehicleId: _extractId(json['vehicleId'] ?? json['vehicle'], 'vehicleId'),
      workshopId: _extractId(json['workshopId'] ?? json['workshop'], 'workshopId'),
      diagnosisId: json['diagnosisId'] as String?,
      serviceType: _parseServiceType(json['serviceType'] as String),
      description: json['description'] as String,
      status: _parseStatus(json['status'] as String),
      scheduledDate: DateTime.parse(json['scheduledDate'] as String),
      scheduledTime: json['scheduledTime'] as String,
      estimatedDuration: json['estimatedDuration'] as int?,
      estimatedCost: json['estimatedCost'] != null
          ? (json['estimatedCost'] as num).toDouble()
          : null,
      finalCost: json['finalCost'] != null
          ? (json['finalCost'] as num).toDouble()
          : null,
      cancelReason: json['cancelReason'] as String?,
      cancelledAt: json['cancelledAt'] != null
          ? DateTime.parse(json['cancelledAt'] as String)
          : null,
      completedAt: json['completedAt'] != null
          ? DateTime.parse(json['completedAt'] as String)
          : null,
      notes: json['notes'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      vehicle: _parseVehicle(json['vehicle']),
      workshop: _parseWorkshop(json['workshop']),
      user: _parseUser(json['user']),
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
      'cancelledAt': cancelledAt?.toIso8601String(),
      'completedAt': completedAt?.toIso8601String(),
      'notes': notes,
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
        cancelledAt,
        completedAt,
        notes,
        createdAt,
        updatedAt,
        vehicle,
        workshop,
        user,
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

// Modelo para actualizar una cita
class UpdateAppointmentDto {
  final String? scheduledDate;
  final String? scheduledTime;
  final String? description;
  final int? estimatedDuration;
  final double? estimatedCost;

  const UpdateAppointmentDto({
    this.scheduledDate,
    this.scheduledTime,
    this.description,
    this.estimatedDuration,
    this.estimatedCost,
  });

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    if (scheduledDate != null) data['scheduledDate'] = scheduledDate;
    if (scheduledTime != null) data['scheduledTime'] = scheduledTime;
    if (description != null) data['description'] = description;
    if (estimatedDuration != null) data['estimatedDuration'] = estimatedDuration;
    if (estimatedCost != null) data['estimatedCost'] = estimatedCost;
    return data;
  }
}
