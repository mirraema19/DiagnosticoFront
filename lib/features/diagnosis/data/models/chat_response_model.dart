import 'package:equatable/equatable.dart';
import 'diagnosis_message_model.dart';

class ChatResponseModel extends Equatable {
  final DiagnosisMessageModel userMessage;
  final DiagnosisMessageModel assistantMessage;
  final List<String> suggestedQuestions;

  const ChatResponseModel({
    required this.userMessage,
    required this.assistantMessage,
    this.suggestedQuestions = const [],
  });

  factory ChatResponseModel.fromJson(Map<String, dynamic> json) {
    return ChatResponseModel(
      userMessage: DiagnosisMessageModel.fromJson(json['userMessage']),
      assistantMessage: DiagnosisMessageModel.fromJson(json['assistantMessage']),
      suggestedQuestions: (json['suggestedQuestions'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userMessage': userMessage.toJson(),
      'assistantMessage': assistantMessage.toJson(),
      'suggestedQuestions': suggestedQuestions,
    };
  }

  @override
  List<Object?> get props => [userMessage, assistantMessage, suggestedQuestions];
}
