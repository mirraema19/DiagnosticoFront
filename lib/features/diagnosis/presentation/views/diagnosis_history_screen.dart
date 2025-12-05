import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:proyecto/features/diagnosis/presentation/bloc/diagnosis_bloc.dart';
import 'package:proyecto/features/diagnosis/data/models/diagnosis_session_model.dart';
import 'package:proyecto/features/garaje/presentation/bloc/garage_bloc.dart';
import 'package:proyecto/features/garaje/presentation/data/models/vehicle_model.dart';

class DiagnosisHistoryScreen extends StatefulWidget {
  const DiagnosisHistoryScreen({super.key});

  @override
  State<DiagnosisHistoryScreen> createState() => _DiagnosisHistoryScreenState();
}

class _DiagnosisHistoryScreenState extends State<DiagnosisHistoryScreen> {
  Vehicle? _selectedVehicle;

  @override
  void initState() {
    super.initState();
    context.read<DiagnosisBloc>().add(const LoadDiagnosisSessions());
  }

  void _filterByVehicle(Vehicle? vehicle) {
    setState(() => _selectedVehicle = vehicle);
    context.read<DiagnosisBloc>().add(LoadDiagnosisSessions(
          vehicleId: vehicle?.id,
        ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Historial de Diagnósticos'),
      ),
      body: Column(
        children: [
          // Vehicle filter
          BlocBuilder<GarageBloc, GarageState>(
            builder: (context, garageState) {
              if (garageState is! GarageLoaded || garageState.vehicles.isEmpty) {
                return const SizedBox.shrink();
              }

              return Container(
                padding: const EdgeInsets.all(16),
                color: Colors.grey.shade100,
                child: DropdownButtonFormField<Vehicle>(
                  initialValue: _selectedVehicle,
                  decoration: const InputDecoration(
                    labelText: 'Filtrar por vehículo',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.filter_list),
                  ),
                  items: [
                    const DropdownMenuItem<Vehicle>(
                      value: null,
                      child: Text('Todos los vehículos'),
                    ),
                    ...garageState.vehicles.map((vehicle) {
                      return DropdownMenuItem(
                        value: vehicle,
                        child: Text('${vehicle.make} ${vehicle.model}'),
                      );
                    }),
                  ],
                  onChanged: _filterByVehicle,
                ),
              );
            },
          ),

          // Sessions list
          Expanded(
            child: BlocBuilder<DiagnosisBloc, DiagnosisState>(
              builder: (context, state) {
                if (state is DiagnosisLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (state is DiagnosisError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error, size: 64, color: Colors.red),
                        const SizedBox(height: 16),
                        Text(state.message),
                      ],
                    ),
                  );
                }

                if (state is DiagnosisSessionsLoaded) {
                  if (state.sessions.isEmpty) {
                    return const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.history, size: 64, color: Colors.grey),
                          SizedBox(height: 16),
                          Text('No hay diagnósticos previos'),
                        ],
                      ),
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: state.sessions.length,
                    itemBuilder: (context, index) {
                      final session = state.sessions[index];
                      return _buildSessionCard(session);
                    },
                  );
                }

                return const SizedBox.shrink();
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSessionCard(DiagnosisSessionModel session) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () {
          context.read<DiagnosisBloc>().add(LoadSessionDetail(session.id));
          context.pop();
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      session.summary ?? 'Sesión de diagnóstico',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  _buildStatusChip(session.status),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.calendar_today, size: 14, color: Colors.grey),
                  const SizedBox(width: 4),
                  Text(
                    _formatDate(session.startedAt),
                    style: const TextStyle(fontSize: 13, color: Colors.grey),
                  ),
                  const SizedBox(width: 16),
                  const Icon(Icons.message, size: 14, color: Colors.grey),
                  const SizedBox(width: 4),
                  Text(
                    '${session.messagesCount} mensajes',
                    style: const TextStyle(fontSize: 13, color: Colors.grey),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusChip(SessionStatus status) {
    Color color;
    String label;

    switch (status) {
      case SessionStatus.ACTIVE:
        color = Colors.green;
        label = 'Activa';
        break;
      case SessionStatus.COMPLETED:
        color = Colors.blue;
        label = 'Completada';
        break;
      case SessionStatus.ABANDONED:
        color = Colors.grey;
        label = 'Abandonada';
        break;
    }

    return Chip(
      label: Text(
        label,
        style: const TextStyle(fontSize: 12, color: Colors.white),
      ),
      backgroundColor: color,
      padding: EdgeInsets.zero,
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'Hoy ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
    } else if (difference.inDays == 1) {
      return 'Ayer';
    } else if (difference.inDays < 7) {
      return 'Hace ${difference.inDays} días';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}
