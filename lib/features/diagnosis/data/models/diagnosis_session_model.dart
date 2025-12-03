import 'package:equatable/equatable.dart';

enum SessionStatus {
  ACTIVE,
  COMPLETED,
  ABANDONED;

  String get value => name;
}

class DiagnosisSessionModel extends Equatable {
  final String id;
  final String userId;
  final String vehicleId;
  final SessionStatus status;
  final DateTime startedAt;
  final DateTime? completedAt;
  final int messagesCount;
  final String? summary;

  const DiagnosisSessionModel({
    required this.id,
    required this.userId,
    required this.vehicleId,
    required this.status,
    required this.startedAt,
    this.completedAt,
    required this.messagesCount,
    this.summary,
  });

  factory DiagnosisSessionModel.fromJson(Map<String, dynamic> json) {
    return DiagnosisSessionModel(
      id: json['id'],
      userId: json['userId'],
      vehicleId: json['vehicleId'],
      status: SessionStatus.values.firstWhere(
        (e) => e.value == json['status'],
        orElse: () => SessionStatus.ACTIVE,
      ),
      startedAt: DateTime.parse(json['startedAt']),
      completedAt: json['completedAt'] != null 
          ? DateTime.parse(json['completedAt']) 
          : null,
      messagesCount: json['messagesCount'] ?? 0,
      summary: json['summary'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'vehicleId': vehicleId,
      'status': status.value,
      'startedAt': startedAt.toIso8601String(),
      'completedAt': completedAt?.toIso8601String(),
      'messagesCount': messagesCount,
      'summary': summary,
    };
  }

  @override
  List<Object?> get props => [
        id,
        userId,
        vehicleId,
        status,
        startedAt,
        completedAt,
        messagesCount,
        summary,
      ];
}
