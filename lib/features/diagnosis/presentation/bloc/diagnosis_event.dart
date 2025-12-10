part of 'diagnosis_bloc.dart';

abstract class DiagnosisEvent extends Equatable {
  const DiagnosisEvent();

  @override
  List<Object?> get props => [];
}

/// Crear nueva sesión de diagnóstico
class CreateDiagnosisSession extends DiagnosisEvent {
  final String vehicleId;
  final String initialMessage;

  const CreateDiagnosisSession({
    required this.vehicleId,
    required this.initialMessage,
  });

  @override
  List<Object?> get props => [vehicleId, initialMessage];
}

/// Cargar lista de sesiones
class LoadDiagnosisSessions extends DiagnosisEvent {
  final String? vehicleId;
  final int limit;

  const LoadDiagnosisSessions({this.vehicleId, this.limit = 10});

  @override
  List<Object?> get props => [vehicleId, limit];
}

/// Cargar detalle de sesión específica
class LoadSessionDetail extends DiagnosisEvent {
  final String sessionId;

  const LoadSessionDetail(this.sessionId);

  @override
  List<Object?> get props => [sessionId];
}

/// Cargar mensajes de una sesión
class LoadSessionMessages extends DiagnosisEvent {
  final String sessionId;

  const LoadSessionMessages(this.sessionId);

  @override
  List<Object?> get props => [sessionId];
}

/// Enviar mensaje en el chat
class SendDiagnosisMessage extends DiagnosisEvent {
  final String sessionId;
  final String content;

  const SendDiagnosisMessage({
    required this.sessionId,
    required this.content,
  });

  @override
  List<Object?> get props => [sessionId, content];
}

/// Clasificar problema
class ClassifyProblem extends DiagnosisEvent {
  final String sessionId;

  const ClassifyProblem(this.sessionId);

  @override
  List<Object?> get props => [sessionId];
}

/// Obtener nivel de urgencia
class GetUrgencyLevel extends DiagnosisEvent {
  final String sessionId;

  const GetUrgencyLevel(this.sessionId);

  @override
  List<Object?> get props => [sessionId];
}

/// Obtener estimación de costos
class GetCostEstimate extends DiagnosisEvent {
  final String sessionId;

  const GetCostEstimate(this.sessionId);

  @override
  List<Object?> get props => [sessionId];
}

/// Limpiar estado (volver a inicial)
class ClearDiagnosisState extends DiagnosisEvent {
  const ClearDiagnosisState();
}

/// Cargar talleres recomendados desde el backend (ML)
class LoadRecommendations extends DiagnosisEvent {
  final String sessionId;
  final int limit;

  const LoadRecommendations({
    required this.sessionId,
    this.limit = 3,
  });

  @override
  List<Object?> get props => [sessionId, limit];
}

/// Cargar sesión activa del vehículo (para persistencia de historial)
class LoadActiveSession extends DiagnosisEvent {
  final String vehicleId;

  const LoadActiveSession({required this.vehicleId});

  @override
  List<Object?> get props => [vehicleId];
}
