import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

enum UrgencyLevel {
  CRITICAL,
  HIGH,
  MEDIUM,
  LOW;

  String get value => name;

  String get displayName {
    switch (this) {
      case UrgencyLevel.CRITICAL:
        return 'Crítico';
      case UrgencyLevel.HIGH:
        return 'Alto';
      case UrgencyLevel.MEDIUM:
        return 'Medio';
      case UrgencyLevel.LOW:
        return 'Bajo';
    }
  }

  Color get color {
    switch (this) {
      case UrgencyLevel.CRITICAL:
        return Colors.red;
      case UrgencyLevel.HIGH:
        return Colors.orange;
      case UrgencyLevel.MEDIUM:
        return Colors.yellow.shade700;
      case UrgencyLevel.LOW:
        return Colors.green;
    }
  }

  IconData get icon {
    switch (this) {
      case UrgencyLevel.CRITICAL:
        return Icons.error;
      case UrgencyLevel.HIGH:
        return Icons.warning;
      case UrgencyLevel.MEDIUM:
        return Icons.info;
      case UrgencyLevel.LOW:
        return Icons.check_circle;
    }
  }
}

class UrgencyModel extends Equatable {
  final UrgencyLevel level;
  final String description;
  final bool safeToDriver;
  final int? maxMileageRecommended;

  const UrgencyModel({
    required this.level,
    required this.description,
    required this.safeToDriver,
    this.maxMileageRecommended,
  });

  factory UrgencyModel.fromJson(Map<String, dynamic> json) {
    return UrgencyModel(
      level: UrgencyLevel.values.firstWhere(
        (e) => e.value == json['level'],
        orElse: () => UrgencyLevel.MEDIUM,
      ),
      description: json['description'],
      safeToDriver: json['safeToDriver'] ?? false, // Backend uses camelCase
      maxMileageRecommended: json['maxMileageRecommended'], // Backend uses camelCase
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'level': level.value,
      'description': description,
      'safeToDriver': safeToDriver,
      'maxMileageRecommended': maxMileageRecommended,
    };
  }

  @override
  List<Object?> get props => [
        level,
        description,
        safeToDriver,
        maxMileageRecommended,
      ];
}
