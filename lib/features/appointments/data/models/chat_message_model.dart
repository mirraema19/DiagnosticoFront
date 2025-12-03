import 'package:equatable/equatable.dart';

enum SenderRole {
  customer,
  mechanic,
}

enum AttachmentType {
  IMAGE,
  VIDEO,
  DOCUMENT,
}

class AttachmentModel extends Equatable {
  final AttachmentType type;
  final String url;

  const AttachmentModel({
    required this.type,
    required this.url,
  });

  factory AttachmentModel.fromJson(Map<String, dynamic> json) {
    return AttachmentModel(
      type: _parseAttachmentType(json['type'] as String),
      url: json['url'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type.name,
      'url': url,
    };
  }

  static AttachmentType _parseAttachmentType(String type) {
    return AttachmentType.values.firstWhere(
      (e) => e.name == type,
      orElse: () => AttachmentType.IMAGE,
    );
  }

  @override
  List<Object?> get props => [type, url];
}

class ChatMessageModel extends Equatable {
  final String id;
  final String appointmentId;
  final String senderId;
  final SenderRole senderRole;
  final String message;
  final List<AttachmentModel> attachments;
  final bool isRead;
  final DateTime createdAt;

  const ChatMessageModel({
    required this.id,
    required this.appointmentId,
    required this.senderId,
    required this.senderRole,
    required this.message,
    required this.attachments,
    required this.isRead,
    required this.createdAt,
  });

  factory ChatMessageModel.fromJson(Map<String, dynamic> json) {
    return ChatMessageModel(
      id: json['id'] as String,
      appointmentId: json['appointmentId'] as String,
      senderId: json['senderId'] as String,
      senderRole: _parseSenderRole(json['senderRole'] as String),
      message: json['message'] as String,
      attachments: (json['attachments'] as List<dynamic>?)
              ?.map((e) => AttachmentModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      isRead: json['isRead'] as bool,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'appointmentId': appointmentId,
      'senderId': senderId,
      'senderRole': senderRole.name,
      'message': message,
      'attachments': attachments.map((e) => e.toJson()).toList(),
      'isRead': isRead,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  static SenderRole _parseSenderRole(String role) {
    return SenderRole.values.firstWhere(
      (e) => e.name == role,
      orElse: () => SenderRole.customer,
    );
  }

  @override
  List<Object?> get props => [
        id,
        appointmentId,
        senderId,
        senderRole,
        message,
        attachments,
        isRead,
        createdAt,
      ];
}

// DTO para enviar mensaje
class SendMessageDto {
  final String message;
  final List<AttachmentModel> attachments;

  const SendMessageDto({
    required this.message,
    this.attachments = const [],
  });

  Map<String, dynamic> toJson() {
    return {
      'message': message,
      'attachments': attachments.map((e) => e.toJson()).toList(),
    };
  }
}
