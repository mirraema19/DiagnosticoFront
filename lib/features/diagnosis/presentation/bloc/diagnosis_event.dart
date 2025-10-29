part of 'diagnosis_bloc.dart';

abstract class DiagnosisEvent extends Equatable {
  const DiagnosisEvent();

  @override
  List<Object> get props => [];
}

/// Evento para enviar un nuevo mensaje al chat de diagnóstico
class SendMessage extends DiagnosisEvent {
  final String message;

  const SendMessage(this.message);

  @override
  List<Object> get props => [message];
}