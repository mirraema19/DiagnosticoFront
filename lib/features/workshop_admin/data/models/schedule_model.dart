class WorkshopScheduleModel {
  final String id;
  final String workshopId;
  final String dayOfWeek;
  final String? openTime;
  final String? closeTime;
  final bool isClosed;
  final DateTime createdAt;
  final DateTime updatedAt;

  WorkshopScheduleModel({
    required this.id,
    required this.workshopId,
    required this.dayOfWeek,
    this.openTime,
    this.closeTime,
    required this.isClosed,
    required this.createdAt,
    required this.updatedAt,
  });

  factory WorkshopScheduleModel.fromJson(Map<String, dynamic> json) {
    return WorkshopScheduleModel(
      id: json['id'],
      workshopId: json['workshopId'],
      dayOfWeek: json['dayOfWeek'],
      openTime: json['openTime'],
      closeTime: json['closeTime'],
      isClosed: json['isClosed'] ?? false,
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'workshopId': workshopId,
      'dayOfWeek': dayOfWeek,
      'openTime': openTime,
      'closeTime': closeTime,
      'isClosed': isClosed,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  // Helper para obtener el nombre del día en español
  String get displayDayName {
    switch (dayOfWeek) {
      case 'MONDAY':
        return 'Lunes';
      case 'TUESDAY':
        return 'Martes';
      case 'WEDNESDAY':
        return 'Miércoles';
      case 'THURSDAY':
        return 'Jueves';
      case 'FRIDAY':
        return 'Viernes';
      case 'SATURDAY':
        return 'Sábado';
      case 'SUNDAY':
        return 'Domingo';
      default:
        return dayOfWeek;
    }
  }

  // Helper para obtener el horario formateado
  String get displaySchedule {
    if (isClosed) {
      return 'Cerrado';
    }
    return '$openTime - $closeTime';
  }

  WorkshopScheduleModel copyWith({
    String? id,
    String? workshopId,
    String? dayOfWeek,
    String? openTime,
    String? closeTime,
    bool? isClosed,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return WorkshopScheduleModel(
      id: id ?? this.id,
      workshopId: workshopId ?? this.workshopId,
      dayOfWeek: dayOfWeek ?? this.dayOfWeek,
      openTime: openTime ?? this.openTime,
      closeTime: closeTime ?? this.closeTime,
      isClosed: isClosed ?? this.isClosed,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

// Enum para los días de la semana
enum DayOfWeek {
  MONDAY,
  TUESDAY,
  WEDNESDAY,
  THURSDAY,
  FRIDAY,
  SATURDAY,
  SUNDAY,
}

extension DayOfWeekExtension on DayOfWeek {
  String get value {
    return toString().split('.').last;
  }

  String get displayName {
    switch (this) {
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

  int get weekdayNumber {
    switch (this) {
      case DayOfWeek.MONDAY:
        return 1;
      case DayOfWeek.TUESDAY:
        return 2;
      case DayOfWeek.WEDNESDAY:
        return 3;
      case DayOfWeek.THURSDAY:
        return 4;
      case DayOfWeek.FRIDAY:
        return 5;
      case DayOfWeek.SATURDAY:
        return 6;
      case DayOfWeek.SUNDAY:
        return 7;
    }
  }
}

// DTO para crear/actualizar horarios
class CreateScheduleDto {
  final String dayOfWeek;
  final String? openTime;
  final String? closeTime;
  final bool isClosed;

  CreateScheduleDto({
    required this.dayOfWeek,
    this.openTime,
    this.closeTime,
    required this.isClosed,
  });

  Map<String, dynamic> toJson() {
    return {
      'dayOfWeek': dayOfWeek,
      'openTime': openTime,
      'closeTime': closeTime,
      'isClosed': isClosed,
    };
  }
}
