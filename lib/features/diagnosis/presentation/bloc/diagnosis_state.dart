part of 'diagnosis_bloc.dart';

abstract class DiagnosisState extends Equatable {
  const DiagnosisState();

  @override
  List<Object?> get props => [];
}

/// Estado inicial
class DiagnosisInitial extends DiagnosisState {
  const DiagnosisInitial();
}

/// Cargando
class DiagnosisLoading extends DiagnosisState {
  const DiagnosisLoading();
}

/// Lista de sesiones cargada
class DiagnosisSessionsLoaded extends DiagnosisState {
  final List<DiagnosisSessionModel> sessions;

  const DiagnosisSessionsLoaded(this.sessions);

  @override
  List<Object?> get props => [sessions];
}

/// Sesión activa (chat en curso)
class DiagnosisSessionActive extends DiagnosisState {
  final DiagnosisSessionModel session;
  final List<DiagnosisMessageModel> messages;
  final List<String> suggestedQuestions;
  final ClassificationModel? classification;
  final UrgencyModel? urgency;
  final CostEstimateModel? costEstimate;
  final List<WorkshopRecommendationModel>? recommendedWorkshops;

  const DiagnosisSessionActive({
    required this.session,
    required this.messages,
    this.suggestedQuestions = const [],
    this.classification,
    this.urgency,
    this.costEstimate,
    this.recommendedWorkshops,
  });

  DiagnosisSessionActive copyWith({
    DiagnosisSessionModel? session,
    List<DiagnosisMessageModel>? messages,
    List<String>? suggestedQuestions,
    ClassificationModel? classification,
    UrgencyModel? urgency,
    CostEstimateModel? costEstimate,
    List<WorkshopRecommendationModel>? recommendedWorkshops,
  }) {
    return DiagnosisSessionActive(
      session: session ?? this.session,
      messages: messages ?? this.messages,
      suggestedQuestions: suggestedQuestions ?? this.suggestedQuestions,
      classification: classification ?? this.classification,
      urgency: urgency ?? this.urgency,
      costEstimate: costEstimate ?? this.costEstimate,
      recommendedWorkshops: recommendedWorkshops ?? this.recommendedWorkshops,
    );
  }

  @override
  List<Object?> get props => [
        session,
        messages,
        suggestedQuestions,
        classification,
        urgency,
        costEstimate,
        recommendedWorkshops,
      ];
}

/// Mensaje enviado exitosamente
class DiagnosisMessageSent extends DiagnosisState {
  final ChatResponseModel response;

  const DiagnosisMessageSent(this.response);

  @override
  List<Object?> get props => [response];
}

/// Problema clasificado
class DiagnosisClassified extends DiagnosisState {
  final ClassificationModel classification;

  const DiagnosisClassified(this.classification);

  @override
  List<Object?> get props => [classification];
}

/// Urgencia obtenida
class DiagnosisUrgencyObtained extends DiagnosisState {
  final UrgencyModel urgency;

  const DiagnosisUrgencyObtained(this.urgency);

  @override
  List<Object?> get props => [urgency];
}

/// Estimación de costos obtenida
class DiagnosisCostEstimateObtained extends DiagnosisState {
  final CostEstimateModel costEstimate;

  const DiagnosisCostEstimateObtained(this.costEstimate);

  @override
  List<Object?> get props => [costEstimate];
}

/// Recomendaciones de talleres cargadas
class DiagnosisRecommendationsLoaded extends DiagnosisState {
  final List<WorkshopRecommendationModel> recommendations;

  const DiagnosisRecommendationsLoaded(this.recommendations);

  @override
  List<Object?> get props => [recommendations];
}

/// Error
class DiagnosisError extends DiagnosisState {
  final String message;

  const DiagnosisError(this.message);

  @override
  List<Object?> get props => [message];
}

