import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:proyecto/features/diagnosis/presentation/bloc/diagnosis_bloc.dart';
import 'package:proyecto/features/diagnosis/presentation/views/widgets/chat_message_bubble.dart';
import 'package:proyecto/features/diagnosis/presentation/views/widgets/recommended_workshops_card.dart';
import 'package:proyecto/features/diagnosis/presentation/views/widgets/cost_estimate_card.dart';
import 'package:proyecto/features/diagnosis/presentation/views/widgets/urgency_indicator.dart';
import 'package:proyecto/features/diagnosis/presentation/views/widgets/classification_card.dart';
import 'package:proyecto/features/diagnosis/presentation/views/diagnosis_history_screen.dart';
import 'package:proyecto/features/garaje/presentation/bloc/garage_bloc.dart';
import 'package:proyecto/features/garaje/presentation/data/models/vehicle_model.dart';

class DiagnosisChatScreen extends StatefulWidget {
  const DiagnosisChatScreen({super.key});

  @override
  State<DiagnosisChatScreen> createState() => _DiagnosisChatScreenState();
}

class _DiagnosisChatScreenState extends State<DiagnosisChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  Vehicle? _selectedVehicle;
  String? _currentSessionId;

  @override
  void initState() {
    super.initState();
    _loadActiveSessionIfAvailable();
  }

  void _loadActiveSessionIfAvailable() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final garageState = context.read<GarageBloc>().state;
      
      if (garageState is GarageLoaded && garageState.vehicles.isNotEmpty) {
        final defaultVehicle = garageState.vehicles.first;
        setState(() {
          _selectedVehicle = defaultVehicle;
        });
        
        print('DiagnosisChatScreen: Loading active session for vehicle ${defaultVehicle.id}');
        context.read<DiagnosisBloc>().add(
          LoadActiveSession(vehicleId: defaultVehicle.id),
        );
      }
    });
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  void _startNewSession() {
    if (_selectedVehicle == null || _messageController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecciona un vehículo y escribe un mensaje')),
      );
      return;
    }

    print('DiagnosisChatScreen: Starting new session for vehicle ${_selectedVehicle!.id}');
    context.read<DiagnosisBloc>().add(CreateDiagnosisSession(
          vehicleId: _selectedVehicle!.id,
          initialMessage: _messageController.text.trim(),
        ));

    _messageController.clear();
  }

  void _sendMessage() {
    if (_currentSessionId == null || _messageController.text.trim().isEmpty) {
      return;
    }

    final messageContent = _messageController.text.trim();
    print('DiagnosisChatScreen: Sending message to session $_currentSessionId');
    
    context.read<DiagnosisBloc>().add(SendDiagnosisMessage(
          sessionId: _currentSessionId!,
          content: messageContent,
        ));

    _messageController.clear();
    Future.delayed(const Duration(milliseconds: 100), _scrollToBottom);
  }

  void _searchWorkshops() {
    final diagnosisState = context.read<DiagnosisBloc>().state;
    if (diagnosisState is! DiagnosisSessionActive) return;

    // Verificar si ya tenemos clasificación del backend
    if (diagnosisState.classification == null) {
      // Si no hay clasificación, disparar el proceso
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Analizando el problema... Por favor espera un momento.'),
          duration: Duration(seconds: 2),
        ),
      );

      // Disparar clasificación (que automáticamente cargará urgencia, costos y talleres)
      context.read<DiagnosisBloc>().add(
        ClassifyProblem(diagnosisState.session.id),
      );
      return;
    }

    // Si ya tenemos clasificación, recargar talleres con la categoría correcta
    final category = diagnosisState.classification!.category;
    print('DiagnosisChatScreen: Searching workshops for category: $category (from backend classification)');

    // TODO: Obtener ubicación real
    context.read<DiagnosisBloc>().add(LoadRecommendedWorkshops(
      category: category,
      latitude: 0.0,
      longitude: 0.0,
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Diagnóstico con IA'),
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () {
              // Navigate to diagnosis history screen
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const DiagnosisHistoryScreen(),
                ),
              );
            },
          ),
        ],
      ),
      body: BlocConsumer<DiagnosisBloc, DiagnosisState>(
        listener: (context, state) {
          if (state is DiagnosisSessionActive) {
            _currentSessionId = state.session.id;
            Future.delayed(const Duration(milliseconds: 100), _scrollToBottom);
          } else if (state is DiagnosisError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
                duration: const Duration(seconds: 5),
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is DiagnosisInitial) {
            return _buildVehicleSelector();
          }

          if (state is DiagnosisLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is DiagnosisSessionActive) {
            return _buildChatInterface(state);
          }

          return _buildVehicleSelector();
        },
      ),
    );
  }

  Widget _buildVehicleSelector() {
    return BlocBuilder<GarageBloc, GarageState>(
      builder: (context, garageState) {
        if (garageState is! GarageLoaded) {
          return const Center(child: CircularProgressIndicator());
        }

        if (garageState.vehicles.isEmpty) {
          return const Center(
            child: Text('No tienes vehículos registrados'),
          );
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 40),
              const Icon(Icons.chat, size: 80, color: Colors.blue),
              const SizedBox(height: 24),
              const Text(
                'Inicia un diagnóstico',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              const Text(
                'Selecciona tu vehículo y describe el problema',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.black54),
              ),
              const SizedBox(height: 32),
              DropdownButtonFormField<Vehicle>(
                value: _selectedVehicle,
                decoration: const InputDecoration(
                  labelText: 'Seleccionar Vehículo',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.directions_car),
                ),
                items: garageState.vehicles.map((vehicle) {
                  return DropdownMenuItem(
                    value: vehicle,
                    child: Text('${vehicle.make} ${vehicle.model} (${vehicle.year})'),
                  );
                }).toList(),
                onChanged: (vehicle) {
                  setState(() => _selectedVehicle = vehicle);
                },
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _messageController,
                maxLines: 4,
                decoration: const InputDecoration(
                  labelText: 'Describe el problema',
                  hintText: 'Ej: Mi auto hace un ruido extraño al frenar',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: _startNewSession,
                icon: const Icon(Icons.send),
                label: const Text('INICIAR DIAGNÓSTICO'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        );
      },
    );
  }

  Widget _buildChatInterface(DiagnosisSessionActive state) {
    return Column(
      children: [
        // Messages list
        Expanded(
          child: ListView.builder(
            controller: _scrollController,
            padding: const EdgeInsets.symmetric(vertical: 16),
            itemCount: state.messages.length +
                (state.classification != null ? 1 : 0) +
                (state.urgency != null ? 1 : 0) +
                (state.costEstimate != null ? 1 : 0) +
                (state.recommendedWorkshops != null && state.recommendedWorkshops!.isNotEmpty ? 1 : 0) +
                (state.suggestedQuestions.isNotEmpty ? 1 : 0) +
                1, // Workshop search button
            itemBuilder: (context, index) {
              int currentIndex = index;

              // Messages
              if (currentIndex < state.messages.length) {
                return ChatMessageBubble(message: state.messages[currentIndex]);
              }
              currentIndex -= state.messages.length;

              // Classification Card
              if (state.classification != null && currentIndex == 0) {
                return ClassificationCard(classification: state.classification!);
              }
              if (state.classification != null) currentIndex--;

              // Urgency Indicator
              if (state.urgency != null && currentIndex == 0) {
                return UrgencyIndicator(urgency: state.urgency!);
              }
              if (state.urgency != null) currentIndex--;

              // Cost Estimate
              if (state.costEstimate != null && currentIndex == 0) {
                return CostEstimateCard(costEstimate: state.costEstimate!);
              }
              if (state.costEstimate != null) currentIndex--;

              // Recommended Workshops
              if (state.recommendedWorkshops != null &&
                  state.recommendedWorkshops!.isNotEmpty &&
                  currentIndex == 0) {
                return RecommendedWorkshopsCard(workshops: state.recommendedWorkshops!);
              }
              if (state.recommendedWorkshops != null && state.recommendedWorkshops!.isNotEmpty) {
                currentIndex--;
              }

              // Suggested Questions
              if (state.suggestedQuestions.isNotEmpty && currentIndex == 0) {
                return _buildSuggestedQuestions(state.suggestedQuestions);
              }
              if (state.suggestedQuestions.isNotEmpty) currentIndex--;

              // Workshop Search Button
              if (currentIndex == 0) {
                return _buildWorkshopSearchButton();
              }

              return const SizedBox.shrink();
            },
          ),
        ),

        // Message input
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 4,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _messageController,
                  decoration: const InputDecoration(
                    hintText: 'Escribe tu mensaje...',
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                  maxLines: null,
                  textInputAction: TextInputAction.send,
                  onSubmitted: (_) => _sendMessage(),
                ),
              ),
              const SizedBox(width: 8),
              IconButton.filled(
                onPressed: _sendMessage,
                icon: const Icon(Icons.send),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildWorkshopSearchButton() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ElevatedButton.icon(
        onPressed: _searchWorkshops,
        icon: const Icon(Icons.search),
        label: const Text('Buscar Talleres Recomendados'),
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          backgroundColor: Colors.blue,
          foregroundColor: Colors.white,
        ),
      ),
    );
  }

  Widget _buildSuggestedQuestions(List<String> questions) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Preguntas sugeridas:',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Colors.black54,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: questions.map((question) {
              return ActionChip(
                label: Text(question),
                onPressed: () {
                  _messageController.text = question;
                  _sendMessage();
                },
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}