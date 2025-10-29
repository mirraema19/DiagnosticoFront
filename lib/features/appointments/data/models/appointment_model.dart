import 'package:equatable/equatable.dart';

enum AppointmentStatus { confirmed, completed, cancelled }

class Appointment extends Equatable {
  final String id;
  final DateTime date;
  final String workshopName;
  final String serviceType;
  final AppointmentStatus status;

  const Appointment({
    required this.id,
    required this.date,
    required this.workshopName,
    required this.serviceType,
    required this.status,
  });

  @override
  List<Object?> get props => [id, date, workshopName, serviceType, status];
}