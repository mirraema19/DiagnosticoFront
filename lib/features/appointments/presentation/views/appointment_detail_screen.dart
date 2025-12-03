import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:proyecto/core/services/service_locator.dart';
import 'package:proyecto/features/appointments/data/models/appointment_model.dart';
import 'package:proyecto/features/appointments/data/models/chat_message_model.dart';
import 'package:proyecto/features/appointments/data/models/progress_model.dart';
import 'package:proyecto/features/appointments/presentation/bloc/appointments_bloc.dart';
import 'package:intl/intl.dart';

class AppointmentDetailScreen extends StatefulWidget {
  final String appointmentId;

  const AppointmentDetailScreen({
    super.key,
    required this.appointmentId,
  });

  @override
  State<AppointmentDetailScreen> createState() =>
      _AppointmentDetailScreenState();
}

class _AppointmentDetailScreenState extends State<AppointmentDetailScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _messageController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => AppointmentsBloc(repository: sl())
        ..add(LoadAppointmentById(widget.appointmentId)),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Detalle de Cita'),
          backgroundColor: Colors.blue,
          bottom: TabBar(
            controller: _tabController,
            tabs: const [
              Tab(icon: Icon(Icons.info), text: 'Detalles'),
              Tab(icon: Icon(Icons.timeline), text: 'Progreso'),
              Tab(icon: Icon(Icons.chat), text: 'Chat'),
            ],
          ),
        ),
        body: BlocBuilder<AppointmentsBloc, AppointmentsState>(
          builder: (context, state) {
            if (state is AppointmentsLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state is AppointmentDetailLoaded) {
              return TabBarView(
                controller: _tabController,
                children: [
                  _buildDetailsTab(context, state.appointment),
                  _buildProgressTab(context),
                  _buildChatTab(context),
                ],
              );
            }

            if (state is AppointmentsError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline,
                        size: 64, color: Colors.red),
                    const SizedBox(height: 16),
                    Text(state.message),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        context
                            .read<AppointmentsBloc>()
                            .add(LoadAppointmentById(widget.appointmentId));
                      },
                      child: const Text('Reintentar'),
                    ),
                  ],
                ),
              );
            }

            return const Center(child: Text('No hay datos disponibles'));
          },
        ),
      ),
    );
  }

  Widget _buildDetailsTab(BuildContext context, AppointmentModel appointment) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildStatusCard(appointment),
          const SizedBox(height: 16),
          _buildInfoCard('Información General', [
            _InfoRow('Tipo de Servicio:', _getServiceTypeName(appointment.serviceType)),
            _InfoRow('Fecha:', DateFormat('dd/MM/yyyy').format(appointment.scheduledDate)),
            _InfoRow('Hora:', appointment.scheduledTime),
            _InfoRow('Descripción:', appointment.description),
          ]),
          const SizedBox(height: 16),
          _buildInfoCard('Costos y Duración', [
            if (appointment.estimatedDuration != null)
              _InfoRow('Duración estimada:', '${appointment.estimatedDuration} min'),
            if (appointment.estimatedCost != null)
              _InfoRow('Costo estimado:', '\$${appointment.estimatedCost!.toStringAsFixed(2)}'),
            if (appointment.finalCost != null)
              _InfoRow('Costo final:', '\$${appointment.finalCost!.toStringAsFixed(2)}',
                  bold: true),
          ]),
          const SizedBox(height: 16),
          if (appointment.status != AppointmentStatus.CANCELLED &&
              appointment.status != AppointmentStatus.COMPLETED)
            _buildActionButtons(context, appointment),
        ],
      ),
    );
  }

  Widget _buildStatusCard(AppointmentModel appointment) {
    final statusColor = _getStatusColor(appointment.status);
    final statusText = _getStatusText(appointment.status);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: statusColor.withOpacity(0.1),
        border: Border.all(color: statusColor),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline, color: statusColor, size: 32),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Estado de la Cita',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
                Text(
                  statusText,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: statusColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard(String title, List<_InfoRow> rows) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Divider(),
            ...rows.map((row) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: 140,
                        child: Text(
                          row.label,
                          style: const TextStyle(
                            fontWeight: FontWeight.w500,
                            color: Colors.grey,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Text(
                          row.value,
                          style: TextStyle(
                            fontWeight: row.bold ? FontWeight.bold : FontWeight.normal,
                          ),
                        ),
                      ),
                    ],
                  ),
                )),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context, AppointmentModel appointment) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ElevatedButton.icon(
          onPressed: () {
            _showCancelDialog(context, appointment.id);
          },
          icon: const Icon(Icons.cancel),
          label: const Text('Cancelar Cita'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 12),
          ),
        ),
      ],
    );
  }

  Widget _buildProgressTab(BuildContext context) {
    context.read<AppointmentsBloc>().add(LoadProgress(widget.appointmentId));

    return BlocBuilder<AppointmentsBloc, AppointmentsState>(
      builder: (context, state) {
        if (state is AppointmentsLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state is ProgressLoaded) {
          if (state.progressList.isEmpty) {
            return const Center(
              child: Text('No hay actualizaciones de progreso aún'),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: state.progressList.length,
            itemBuilder: (context, index) {
              final progress = state.progressList[index];
              return _buildProgressCard(progress);
            },
          );
        }

        return const Center(child: Text('No hay datos de progreso'));
      },
    );
  }

  Widget _buildProgressCard(ProgressModel progress) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(_getProgressIcon(progress.stage), color: Colors.blue),
                const SizedBox(width: 8),
                Text(
                  _getProgressStageName(progress.stage),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(progress.description),
            const SizedBox(height: 8),
            Text(
              DateFormat('dd/MM/yyyy HH:mm').format(progress.createdAt),
              style: const TextStyle(color: Colors.grey, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChatTab(BuildContext context) {
    context.read<AppointmentsBloc>().add(LoadChatMessages(widget.appointmentId));

    return Column(
      children: [
        Expanded(
          child: BlocBuilder<AppointmentsBloc, AppointmentsState>(
            builder: (context, state) {
              if (state is AppointmentsLoading) {
                return const Center(child: CircularProgressIndicator());
              }

              if (state is ChatMessagesLoaded) {
                if (state.messages.isEmpty) {
                  return const Center(
                    child: Text('No hay mensajes aún. Inicia la conversación.'),
                  );
                }

                return ListView.builder(
                  reverse: true,
                  padding: const EdgeInsets.all(16),
                  itemCount: state.messages.length,
                  itemBuilder: (context, index) {
                    final message = state.messages[state.messages.length - 1 - index];
                    return _buildMessageBubble(message);
                  },
                );
              }

              return const Center(child: Text('No hay mensajes'));
            },
          ),
        ),
        _buildMessageInput(context),
      ],
    );
  }

  Widget _buildMessageBubble(ChatMessageModel message) {
    final isCustomer = message.senderRole == SenderRole.customer;

    return Align(
      alignment: isCustomer ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(12),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.7,
        ),
        decoration: BoxDecoration(
          color: isCustomer ? Colors.blue : Colors.grey[300],
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              message.message,
              style: TextStyle(
                color: isCustomer ? Colors.white : Colors.black,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              DateFormat('HH:mm').format(message.createdAt),
              style: TextStyle(
                fontSize: 10,
                color: isCustomer ? Colors.white70 : Colors.black54,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageInput(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 1,
            blurRadius: 3,
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _messageController,
              decoration: const InputDecoration(
                hintText: 'Escribe un mensaje...',
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              ),
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            onPressed: () {
              if (_messageController.text.isNotEmpty) {
                final dto = SendMessageDto(message: _messageController.text);
                context
                    .read<AppointmentsBloc>()
                    .add(SendChatMessage(widget.appointmentId, dto));
                _messageController.clear();
              }
            },
            icon: const Icon(Icons.send),
            color: Colors.blue,
          ),
        ],
      ),
    );
  }

  void _showCancelDialog(BuildContext context, String appointmentId) {
    final reasonController = TextEditingController();

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Cancelar Cita'),
        content: TextField(
          controller: reasonController,
          decoration: const InputDecoration(
            labelText: 'Razón de cancelación',
            border: OutlineInputBorder(),
          ),
          maxLines: 3,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              if (reasonController.text.isNotEmpty) {
                context
                    .read<AppointmentsBloc>()
                    .add(CancelAppointment(appointmentId, reasonController.text));
                Navigator.pop(dialogContext);
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Confirmar'),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(AppointmentStatus status) {
    switch (status) {
      case AppointmentStatus.PENDING:
        return Colors.orange;
      case AppointmentStatus.CONFIRMED:
        return Colors.blue;
      case AppointmentStatus.IN_PROGRESS:
        return Colors.purple;
      case AppointmentStatus.COMPLETED:
        return Colors.green;
      case AppointmentStatus.CANCELLED:
        return Colors.red;
    }
  }

  String _getStatusText(AppointmentStatus status) {
    switch (status) {
      case AppointmentStatus.PENDING:
        return 'Pendiente';
      case AppointmentStatus.CONFIRMED:
        return 'Confirmada';
      case AppointmentStatus.IN_PROGRESS:
        return 'En Progreso';
      case AppointmentStatus.COMPLETED:
        return 'Completada';
      case AppointmentStatus.CANCELLED:
        return 'Cancelada';
    }
  }

  String _getServiceTypeName(ServiceType type) {
    switch (type) {
      case ServiceType.BRAKE_INSPECTION:
        return 'Inspección de Frenos';
      case ServiceType.OIL_CHANGE:
        return 'Cambio de Aceite';
      case ServiceType.TIRE_ROTATION:
        return 'Rotación de Llantas';
      case ServiceType.ENGINE_DIAGNOSTIC:
        return 'Diagnóstico de Motor';
      case ServiceType.TRANSMISSION_SERVICE:
        return 'Servicio de Transmisión';
      case ServiceType.BATTERY_REPLACEMENT:
        return 'Reemplazo de Batería';
      case ServiceType.AIR_CONDITIONING:
        return 'Aire Acondicionado';
      case ServiceType.SUSPENSION_REPAIR:
        return 'Reparación de Suspensión';
      case ServiceType.EXHAUST_SYSTEM:
        return 'Sistema de Escape';
      case ServiceType.GENERAL_MAINTENANCE:
        return 'Mantenimiento General';
      case ServiceType.OTHER:
        return 'Otro';
    }
  }

  IconData _getProgressIcon(ProgressStage stage) {
    switch (stage) {
      case ProgressStage.RECEIVED:
        return Icons.check_circle_outline;
      case ProgressStage.IN_DIAGNOSIS:
        return Icons.search;
      case ProgressStage.IN_REPAIR:
        return Icons.build;
      case ProgressStage.QUALITY_CHECK:
        return Icons.verified;
      case ProgressStage.READY_FOR_PICKUP:
        return Icons.done_all;
    }
  }

  String _getProgressStageName(ProgressStage stage) {
    switch (stage) {
      case ProgressStage.RECEIVED:
        return 'Vehículo Recibido';
      case ProgressStage.IN_DIAGNOSIS:
        return 'En Diagnóstico';
      case ProgressStage.IN_REPAIR:
        return 'En Reparación';
      case ProgressStage.QUALITY_CHECK:
        return 'Control de Calidad';
      case ProgressStage.READY_FOR_PICKUP:
        return 'Listo para Recoger';
    }
  }
}

class _InfoRow {
  final String label;
  final String value;
  final bool bold;

  _InfoRow(this.label, this.value, {this.bold = false});
}
