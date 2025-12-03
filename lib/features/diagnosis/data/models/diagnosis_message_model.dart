import 'package:equatable/equatable.dart';

enum MessageRole {
  USER,
  ASSISTANT;

  String get value => name;
}

class DiagnosisMessageModel extends Equatable {
  final String id;
  final String sessionId;
  final MessageRole role;
  final String content;
  final DateTime timestamp;

  const DiagnosisMessageModel({
    required this.id,
    required this.sessionId,
    required this.role,
    required this.content,
    required this.timestamp,
  });

  factory DiagnosisMessageModel.fromJson(Map<String, dynamic> json) {
    return DiagnosisMessageModel(
      id: json['id'],
      sessionId: json['sessionId'],
      role: MessageRole.values.firstWhere(
        (e) => e.value == json['role'],
        orElse: () => MessageRole.USER,
      ),
      content: json['content'],
      timestamp: DateTime.parse(json['timestamp']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'sessionId': sessionId,
      'role': role.value,
      'content': content,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  @override
  List<Object?> get props => [id, sessionId, role, content, timestamp];
}
