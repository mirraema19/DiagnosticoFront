import 'package:proyecto/features/diagnosis/presentation/bloc/diagnosis_bloc.dart';
import 'package:proyecto/features/diagnosis/presentation/widgets/chat_bubble.dart';
import 'package:proyecto/features/diagnosis/presentation/widgets/diagnosis_result_card.dart';
import 'package:proyecto/features/diagnosis/presentation/widgets/message_input_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class DiagnosisChatScreen extends StatelessWidget {
  const DiagnosisChatScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => DiagnosisBloc(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Asistente de Diagnóstico'),
        ),
        body: Column(
          children: [
            Expanded(
              child: BlocBuilder<DiagnosisBloc, DiagnosisState>(
                builder: (context, state) {
                  return ListView(
                    padding: const EdgeInsets.all(8),
                    children: [
                      // Renderiza la lista de mensajes de chat
                      ...state.messages.map((message) => Animate(
                            effects: const [FadeEffect(duration: Duration(milliseconds: 300))],
                            child: ChatBubble(
                              text: message.text,
                              isFromUser: message.isFromUser,
                            ),
                          )),
                      // Si hay un resultado de diagnóstico, lo renderiza al final
                      if (state.result != null)
                        Animate(
                          effects: const [FadeEffect(delay: Duration(milliseconds: 500))],
                          child: DiagnosisResultCard(result: state.result!),
                        ),
                    ],
                  );
                },
              ),
            ),
            BlocBuilder<DiagnosisBloc, DiagnosisState>(
              builder: (context, state) {
                return MessageInputBar(
                  onSend: (message) {
                    context.read<DiagnosisBloc>().add(SendMessage(message));
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}