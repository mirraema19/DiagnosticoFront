part of 'diagnosis_bloc.dart';

// --- NUEVOS ENUMS Y CLASES PARA EL ESTADO ---

enum UrgencyLevel { urgent, soon, programmable }
enum ConversationStage { askingProblem, askingClarification, providingDiagnosis, recommendingWorkshops }

class DiagnosisResult extends Equatable {
  final String problemCategory;
  final UrgencyLevel urgency;
  final String costEstimate;
  final List<Workshop> recommendedWorkshops;

  const DiagnosisResult({
    required this.problemCategory,
    required this.urgency,
    required this.costEstimate,
    required this.recommendedWorkshops,
  });
  
  @override
  List<Object?> get props => [problemCategory, urgency, costEstimate, recommendedWorkshops];
}

// --- CLASE CHATMESSAGE SIN CAMBIOS ---
class ChatMessage extends Equatable {
  final String text;
  final bool isFromUser;

  const ChatMessage({required this.text, required this.isFromUser});

  @override
  List<Object> get props => [text, isFromUser];
}

// --- ESTADO PRINCIPAL MODIFICADO ---
class DiagnosisState extends Equatable {
  final List<ChatMessage> messages;
  final ConversationStage stage;
  final DiagnosisResult? result; // Puede ser nulo hasta el final

  const DiagnosisState({
    this.messages = const [],
    this.stage = ConversationStage.askingProblem,
    this.result,
  });

  DiagnosisState copyWith({
    List<ChatMessage>? messages,
    ConversationStage? stage,
    DiagnosisResult? result,
  }) {
    return DiagnosisState(
      messages: messages ?? this.messages,
      stage: stage ?? this.stage,
      result: result ?? this.result,
    );
  }

  @override
  List<Object?> get props => [messages, stage, result];
}