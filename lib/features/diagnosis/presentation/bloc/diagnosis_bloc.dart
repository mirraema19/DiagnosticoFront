import 'dart:async';
import 'package:proyecto/core/services/service_locator.dart'; // --- IMPORTACIÓN NUEVA ---
import 'package:proyecto/features/workshops/data/models/workshop_model.dart';
import 'package:proyecto/features/workshops/data/repositories/workshop_repository.dart';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

part 'diagnosis_event.dart';
part 'diagnosis_state.dart';

class DiagnosisBloc extends Bloc<DiagnosisEvent, DiagnosisState> {
  // --- CORRECCIÓN: Obtenemos el repositorio desde el Service Locator ---
  final WorkshopRepository _workshopRepository = sl<WorkshopRepository>();

  DiagnosisBloc() : super(const DiagnosisState()) {
    on<SendMessage>(_onSendMessage);
    // Mensaje inicial del bot
    emit(state.copyWith(messages: [
      const ChatMessage(
        text: 'Hola, soy tu asistente de diagnóstico. Por favor, describe el problema que tienes con tu vehículo.',
        isFromUser: false,
      ),
    ]));
  }

  Future<void> _onSendMessage(SendMessage event, Emitter<DiagnosisState> emit) async {
    // 1. Añade el mensaje del usuario a la lista
    final userMessage = ChatMessage(text: event.message, isFromUser: true);
    final currentMessages = List<ChatMessage>.from(state.messages)..add(userMessage);
    emit(state.copyWith(messages: currentMessages));
    
    // 2. Simula la lógica de la IA basada en la etapa de la conversación
    await Future.delayed(const Duration(seconds: 1));

    switch (state.stage) {
      // ETAPA 1: Usuario describe el problema -> IA pide clarificación
      case ConversationStage.askingProblem:
        _addBotMessage(
          'Entendido. ¿El problema ocurre al encender el auto, al acelerar, o en todo momento?',
          emit,
        );
        emit(state.copyWith(stage: ConversationStage.askingClarification));
        break;

      // ETAPA 2: Usuario clarifica -> IA da el diagnóstico completo
      case ConversationStage.askingClarification:
        _addBotMessage('Gracias por la información. Estoy analizando los síntomas...', emit);
        await Future.delayed(const Duration(seconds: 2));
        
        try {
          // --- AHORA LA LLAMADA ES REAL (a través del repositorio conectado) ---
          final recommendedWorkshops = await _workshopRepository.fetchWorkshopsBySpecialty('Frenos');
          
          _addBotMessage('Análisis completado. Aquí está el diagnóstico preliminar:', emit);
          
          final diagnosisResult = DiagnosisResult(
            problemCategory: 'Frenos',
            urgency: UrgencyLevel.urgent,
            costEstimate: '\$150 - \$300',
            recommendedWorkshops: recommendedWorkshops,
          );

          emit(state.copyWith(
            stage: ConversationStage.recommendingWorkshops,
            result: diagnosisResult,
          ));

        } catch (e) {
          _addBotMessage('Lo siento, hubo un error al buscar talleres recomendados.', emit);
        }
        break;
      
      // Conversación finalizada
      case ConversationStage.providingDiagnosis:
      case ConversationStage.recommendingWorkshops:
        _addBotMessage('Si tienes otra consulta, no dudes en preguntar.', emit);
        break;
    }
  }
  
  // Helper para añadir mensajes del bot
  void _addBotMessage(String text, Emitter<DiagnosisState> emit) {
    final botMessage = ChatMessage(text: text, isFromUser: false);
    final updatedMessages = List<ChatMessage>.from(state.messages)..add(botMessage);
    emit(state.copyWith(messages: updatedMessages));
  }
}