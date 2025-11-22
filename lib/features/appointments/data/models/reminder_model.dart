import 'package:equatable/equatable.dart';

class Reminder extends Equatable {
  final String id;
  final String vehicleId;
  final String serviceType; // Debe coincidir con ServiceTypeEnum
  final String? description;
  final String dueType; // 'MILEAGE' o 'DATE'
  final String dueValue; // Valor como string (ej. "50000" o fecha ISO)
  final String status; // 'PENDING', 'OVERDUE', etc.
  final DateTime? postponedUntil;
  final DateTime createdAt;

  const Reminder({
    required this.id,
    required this.vehicleId,
    required this.serviceType,
    this.description,
    required this.dueType,
    required this.dueValue,
    required this.status,
    this.postponedUntil,
    required this.createdAt,
  });

  factory Reminder.fromJson(Map<String, dynamic> json) {
    return Reminder(
      id: json['id'],
      vehicleId: json['vehicleId'],
      serviceType: json['serviceType'],
      description: json['description'],
      dueType: json['dueType'],
      dueValue: json['dueValue'],
      status: json['status'],
      postponedUntil: json['postponedUntil'] != null 
          ? DateTime.parse(json['postponedUntil']) 
          : null,
      createdAt: DateTime.parse(json['createdAt']),
    );
  }

  // toJson para crear un recordatorio (CreateReminderDto)
  Map<String, dynamic> toJson() {
    return {
      'serviceType': serviceType,
      'description': description,
      'dueType': dueType,
      'dueValue': dueValue,
      // vehicleId no se envía en el body del CreateDto, va en la URL
    };
  }

  @override
  List<Object?> get props => [id, serviceType, dueType, dueValue, status];
}