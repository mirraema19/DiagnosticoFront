import 'package:equatable/equatable.dart';

enum NotificationType {
  APPOINTMENT_CONFIRMED,
  APPOINTMENT_CANCELLED,
  APPOINTMENT_REMINDER,
  PROGRESS_UPDATE,
  CHAT_MESSAGE,
  APPOINTMENT_COMPLETED,
}

class NotificationModel extends Equatable {
  final String id;
  final NotificationType type;
  final String title;
  final String message;
  final bool isRead;
  final DateTime? readAt;
  final DateTime createdAt;

  const NotificationModel({
    required this.id,
    required this.type,
    required this.title,
    required this.message,
    required this.isRead,
    this.readAt,
    required this.createdAt,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'] as String,
      type: _parseType(json['type'] as String),
      title: json['title'] as String,
      message: json['message'] as String,
      isRead: json['isRead'] as bool,
      readAt: json['readAt'] != null
          ? DateTime.parse(json['readAt'] as String)
          : null,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type.name,
      'title': title,
      'message': message,
      'isRead': isRead,
      'readAt': readAt?.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
    };
  }

  static NotificationType _parseType(String type) {
    return NotificationType.values.firstWhere(
      (e) => e.name == type,
      orElse: () => NotificationType.PROGRESS_UPDATE,
    );
  }

  @override
  List<Object?> get props => [
        id,
        type,
        title,
        message,
        isRead,
        readAt,
        createdAt,
      ];
}
