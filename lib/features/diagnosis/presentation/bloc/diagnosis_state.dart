part of 'diagnosis_bloc.dart';

// Modelo simple para representar un mensaje
class ChatMessage extends Equatable {
  final String text;
  final bool isFromUser;

  const ChatMessage({required this.text, required this.isFromUser});

  @override
  List<Object> get props => [text, isFromUser];
}

class DiagnosisState extends Equatable {
  final List<ChatMessage> messages;

  const DiagnosisState({this.messages = const []});

  DiagnosisState copyWith({List<ChatMessage>? messages}) {
    return DiagnosisState(
      messages: messages ?? this.messages,
    );
  }

  @override
  List<Object> get props => [messages];
}