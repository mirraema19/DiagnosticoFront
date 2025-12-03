import 'package:equatable/equatable.dart';

/// Días de la semana
enum DayOfWeek {
  MONDAY,
  TUESDAY,
  WEDNESDAY,
  THURSDAY,
  FRIDAY,
  SATURDAY,
  SUNDAY,
}

/// Modelo para el horario de un taller
class WorkshopSchedule extends Equatable {
  final String id;
  final String workshopId;
  final DayOfWeek dayOfWeek;
  final String? openTime;  // Formato: "HH:MM"
  final String? closeTime; // Formato: "HH:MM"
  final bool isClosed;

  const WorkshopSchedule({
    required this.id,
    required this.workshopId,
    required this.dayOfWeek,
    this.openTime,
    this.closeTime,
    required this.isClosed,
  });

  factory WorkshopSchedule.fromJson(Map<String, dynamic> json) {
    return WorkshopSchedule(
      id: json['id'] as String,
      workshopId: json['workshopId'] as String,
      dayOfWeek: _parseDayOfWeek(json['dayOfWeek'] as String),
      openTime: json['openTime'] as String?,
      closeTime: json['closeTime'] as String?,
      isClosed: json['isClosed'] as bool,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'workshopId': workshopId,
      'dayOfWeek': dayOfWeek.name,
      'openTime': openTime,
      'closeTime': closeTime,
      'isClosed': isClosed,
    };
  }

  static DayOfWeek _parseDayOfWeek(String day) {
    return DayOfWeek.values.firstWhere(
      (e) => e.name == day,
      orElse: () => DayOfWeek.MONDAY,
    );
  }

  String get dayOfWeekName {
    switch (dayOfWeek) {
      case DayOfWeek.MONDAY:
        return 'Lunes';
      case DayOfWeek.TUESDAY:
        return 'Martes';
      case DayOfWeek.WEDNESDAY:
        return 'Miércoles';
      case DayOfWeek.THURSDAY:
        return 'Jueves';
      case DayOfWeek.FRIDAY:
        return 'Viernes';
      case DayOfWeek.SATURDAY:
        return 'Sábado';
      case DayOfWeek.SUNDAY:
        return 'Domingo';
    }
  }

  String get scheduleText {
    if (isClosed) {
      return 'Cerrado';
    }
    if (openTime != null && closeTime != null) {
      return '$openTime - $closeTime';
    }
    return 'No especificado';
  }

  @override
  List<Object?> get props => [
        id,
        workshopId,
        dayOfWeek,
        openTime,
        closeTime,
        isClosed,
      ];
}

/// DTO para crear/actualizar horarios
class CreateScheduleDto {
  final DayOfWeek dayOfWeek;
  final String? openTime;
  final String? closeTime;
  final bool isClosed;

  const CreateScheduleDto({
    required this.dayOfWeek,
    this.openTime,
    this.closeTime,
    this.isClosed = false,
  });

  Map<String, dynamic> toJson() {
    return {
      'dayOfWeek': dayOfWeek.name,
      'openTime': openTime,
      'closeTime': closeTime,
      'isClosed': isClosed,
    };
  }
}
