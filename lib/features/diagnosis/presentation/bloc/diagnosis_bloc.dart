import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

part 'diagnosis_event.dart';
part 'diagnosis_state.dart';

class DiagnosisBloc extends Bloc<DiagnosisEvent, DiagnosisState> {
  DiagnosisBloc() : super(const DiagnosisState()) {
    on<SendMessage>(_onSendMessage);
    // Añade un mensaje inicial del bot
    _addInitialBotMessage();
  }
  
  void _addInitialBotMessage() {
    final initialState = state.copyWith(messages: [
      const ChatMessage(
        text: 'Hola, soy tu asistente de diagnóstico. Describe el problema que tienes con tu vehículo.',
        isFromUser: false,
      ),
    ]);
    emit(initialState);
  }

  Future<void> _onSendMessage(SendMessage event, Emitter<DiagnosisState> emit) async {
    // 1. Añade el mensaje del usuario
    final userMessage = ChatMessage(text: event.message, isFromUser: true);
    final updatedMessages = List<ChatMessage>.from(state.messages)..add(userMessage);
    emit(state.copyWith(messages: updatedMessages));

    // 2. Simula la respuesta del bot después de un retraso
    await Future.delayed(const Duration(seconds: 2));

    const botResponse = ChatMessage(
      text: 'Entendido. Estoy analizando los síntomas que mencionaste...',
      isFromUser: false,
    );
    final finalMessages = List<ChatMessage>.from(state.messages)..add(botResponse);
    emit(state.copyWith(messages: finalMessages));
  }
}