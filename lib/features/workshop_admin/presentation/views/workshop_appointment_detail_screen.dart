import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:proyecto/core/services/service_locator.dart';
import 'package:proyecto/features/appointments/data/models/appointment_model.dart';
import 'package:proyecto/features/appointments/data/models/chat_message_model.dart';
import 'package:proyecto/features/appointments/data/models/progress_model.dart';
import 'package:proyecto/features/appointments/presentation/bloc/appointments_bloc.dart';
import 'package:proyecto/features/auth/presentation/bloc/auth_bloc/auth_bloc.dart';
import 'package:intl/intl.dart';

/// Pantalla de detalle de cita para WORKSHOP_ADMIN
/// Incluye funcionalidades para agregar progreso, chat y completar cita
class WorkshopAppointmentDetailScreen extends StatefulWidget {
  final String appointmentId;

  const WorkshopAppointmentDetailScreen({
    super.key,
    required this.appointmentId,
  });

  @override
  State<WorkshopAppointmentDetailScreen> createState() =>
      _WorkshopAppointmentDetailScreenState();
}

class _WorkshopAppointmentDetailScreenState
    extends State<WorkshopAppointmentDetailScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _messageController = TextEditingController();
  AppointmentModel? _currentAppointment;
  // bool _progressLoaded = false; // Removed to force reload

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);

    // Escuchar cambios de tab
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        _onTabChanged(_tabController.index);
      }
    });

    // Cargar el appointment cuando inicia la pantalla
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AppointmentsBloc>().add(LoadAppointmentById(widget.appointmentId));
    });
  }

  void _onTabChanged(int index) {
    if (index == 1) {
      // Tab de Progreso - Se recarga SIEMPRE al entrar
      print('💬 [Taller] Recargando progreso al entrar al tab...');
      context.read<AppointmentsBloc>().add(LoadProgress(widget.appointmentId));
    } else if (index == 2) {
      // Tab de Chat - Se recarga SIEMPRE al entrar
      print('💬 [Taller] Recargando chat al entrar al tab...');
      context.read<AppointmentsBloc>().add(LoadChatMessages(widget.appointmentId));
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Detalle de Cita - Taller'),
          backgroundColor: Colors.indigo,
          bottom: TabBar(
            controller: _tabController,
            tabs: const [
              Tab(icon: Icon(Icons.info), text: 'Detalles'),
              Tab(icon: Icon(Icons.timeline), text: 'Progreso'),
              Tab(icon: Icon(Icons.chat), text: 'Chat'),
            ],
          ),
        ),
        body: BlocListener<AppointmentsBloc, AppointmentsState>(
          listener: (context, state) {
            // Guardamos el appointment cuando se carga
            if (state is AppointmentDetailLoaded) {
              setState(() {
                _currentAppointment = state.appointment;
              });
            }

            // Actualizar appointment cuando se confirma
            if (state is AppointmentConfirmed) {
              setState(() {
                _currentAppointment = state.appointment;
              });
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Cita aceptada exitosamente'),
                  backgroundColor: Colors.green,
                ),
              );
            }

            // Actualizar appointment cuando se completa
            if (state is AppointmentCompleted) {
              setState(() {
                _currentAppointment = state.appointment;
              });
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Cita completada exitosamente'),
                  backgroundColor: Colors.green,
                ),
              );
            }

            // Mostrar mensaje cuando se agrega progreso
            if (state is ProgressAdded) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Progreso agregado exitosamente'),
                  backgroundColor: Colors.green,
                ),
              );
              // Recargar progreso automáticamente después de agregar
              context.read<AppointmentsBloc>().add(LoadProgress(widget.appointmentId));
            }

            // Mostrar mensaje cuando se envía un mensaje
            if (state is ChatMessageSent) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Mensaje enviado'),
                  backgroundColor: Colors.green,
                ),
              );
              // Recargar chat automáticamente después de enviar
              context.read<AppointmentsBloc>().add(LoadChatMessages(widget.appointmentId));
            }
          },
          child: BlocBuilder<AppointmentsBloc, AppointmentsState>(
            builder: (context, state) {
              // Mostrar loading solo en la primera carga
              if (state is AppointmentsLoading && _currentAppointment == null) {
                return const Center(child: CircularProgressIndicator());
              }

              // Si ya tenemos un appointment guardado, lo mostramos
              if (_currentAppointment != null) {
                return TabBarView(
                  controller: _tabController,
                  children: [
                    _buildDetailsTab(context, _currentAppointment!),
                    _buildProgressTab(context),
                    _buildChatTab(context),
                  ],
                );
              }

              // Solo mostrar error si no hay appointment guardado
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

              return const Center(child: CircularProgressIndicator());
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
            _InfoRow('Descripción:', appointment.description ?? 'Sin descripción'),
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
          if (appointment.status == AppointmentStatus.PENDING ||
              appointment.status == AppointmentStatus.CONFIRMED ||
              appointment.status == AppointmentStatus.IN_PROGRESS)
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
        // Botón de Aceptar Cita (solo si está PENDING)
        if (appointment.status == AppointmentStatus.PENDING)
          ElevatedButton.icon(
            onPressed: () {
              _showConfirmDialog(context, appointment.id);
            },
            icon: const Icon(Icons.check),
            label: const Text('Aceptar Cita'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),

        // Botón de Completar Cita (solo si está CONFIRMED o IN_PROGRESS)
        if (appointment.status == AppointmentStatus.CONFIRMED ||
            appointment.status == AppointmentStatus.IN_PROGRESS)
          ElevatedButton.icon(
            onPressed: () {
              _showCompleteDialog(context, appointment.id);
            },
            icon: const Icon(Icons.check_circle),
            label: const Text('Completar Cita'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
      ],
    );
  }

  Widget _buildProgressTab(BuildContext context) {
    // Verificar si la cita está confirmada para permitir agregar progreso
    final canAddProgress = _currentAppointment != null &&
        (_currentAppointment!.status == AppointmentStatus.CONFIRMED ||
         _currentAppointment!.status == AppointmentStatus.IN_PROGRESS);

    return Stack(
      children: [
        BlocBuilder<AppointmentsBloc, AppointmentsState>(
          buildWhen: (previous, current) {
            // Solo rebuild cuando sea un estado relacionado con progreso o loading
            final shouldBuild = current is ProgressLoaded ||
                                current is AppointmentsLoading ||
                                current is ProgressAdded;
            print('🎨 buildWhen: ${current.runtimeType} -> shouldBuild: $shouldBuild');
            return shouldBuild;
          },
          builder: (context, state) {
            print('🎨 UI Progreso recibió estado: ${state.runtimeType}');

            if (state is AppointmentsLoading) {
              print('🎨 Mostrando loading...');
              return const Center(child: CircularProgressIndicator());
            }

            if (state is ProgressLoaded) {
              print('🎨 ProgressLoaded con ${state.progressList.length} items');
              if (state.progressList.isEmpty) {
                print('🎨 Lista vacía, mostrando mensaje...');

                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.timeline, size: 64, color: Colors.grey),
                      const SizedBox(height: 16),
                      const Text(
                        'No hay actualizaciones de progreso aún',
                        style: TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        canAddProgress
                            ? 'Presiona el botón + para agregar una actualización'
                            : 'Debes aceptar la cita primero para agregar progreso',
                        style: TextStyle(
                          fontSize: 14,
                          color: canAddProgress ? Colors.grey : Colors.orange,
                          fontWeight: canAddProgress ? FontWeight.normal : FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                );
              }

              print('🎨 Mostrando lista de ${state.progressList.length} items');
              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: state.progressList.length,
                itemBuilder: (context, index) {
                  final progress = state.progressList[index];
                  return _buildProgressCard(progress);
                },
              );
            }

            print('🎨 Estado no reconocido, mostrando mensaje por defecto');
            return const Center(child: Text('No hay datos de progreso'));
          },
        ),
        // Botón flotante para agregar progreso (solo si está confirmada)
        if (canAddProgress)
          Positioned(
            bottom: 16,
            right: 16,
            child: FloatingActionButton(
              onPressed: () => _showAddProgressDialog(context),
              backgroundColor: Colors.indigo,
              child: const Icon(Icons.add),
            ),
          ),
      ],
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
                Icon(_getProgressIcon(progress.stage), color: Colors.indigo),
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
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.chat_bubble_outline, size: 64, color: Colors.grey),
                        SizedBox(height: 16),
                        Text(
                          'No hay mensajes aún',
                          style: TextStyle(fontSize: 16, color: Colors.grey),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Inicia la conversación con el cliente',
                          style: TextStyle(fontSize: 14, color: Colors.grey),
                        ),
                      ],
                    ),
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
    // Obtener el usuario autenticado actual
    final currentUser = context.read<AuthBloc>().state.user;
    
    // Determinar si el mensaje fue enviado por el usuario actual
    final isCurrentUser = currentUser != null && message.senderId == currentUser.id;
    
    // Determinar si el mensaje es de un mecánico (para el color)
    final isMechanic = message.senderRole == SenderRole.mechanic;

    return Align(
      alignment: isCurrentUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(12),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.7,
        ),
        decoration: BoxDecoration(
          // Taller (Mecánico) = Azul, Cliente (Usuario Vehículo) = Verde
          color: isMechanic ? Colors.blue[700] : Colors.green[600],
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Etiqueta de remitente para mayor claridad
            Text(
              isCurrentUser ? 'Tú (Taller)' : (isMechanic ? 'Taller' : 'Cliente'),
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: Colors.white.withOpacity(0.9),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              message.message,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              DateFormat('HH:mm').format(message.createdAt),
              style: const TextStyle(
                fontSize: 10,
                color: Colors.white70,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageInput(BuildContext context) {
    // Verificar si la cita está confirmada para permitir enviar mensajes
    final canSendMessage = _currentAppointment != null &&
        (_currentAppointment!.status == AppointmentStatus.CONFIRMED ||
         _currentAppointment!.status == AppointmentStatus.IN_PROGRESS ||
         _currentAppointment!.status == AppointmentStatus.COMPLETED);

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
              enabled: canSendMessage,
              decoration: InputDecoration(
                hintText: canSendMessage
                    ? 'Escribe un mensaje al cliente...'
                    : 'Debes aceptar la cita primero',
                border: const OutlineInputBorder(),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              ),
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            onPressed: canSendMessage
                ? () {
                    if (_messageController.text.isNotEmpty) {
                      final dto = SendMessageDto(message: _messageController.text);
                      context
                          .read<AppointmentsBloc>()
                          .add(SendChatMessage(widget.appointmentId, dto));
                      _messageController.clear();
                    }
                  }
                : null,
            icon: const Icon(Icons.send),
            color: canSendMessage ? Colors.indigo : Colors.grey,
          ),
        ],
      ),
    );
  }

  void _showAddProgressDialog(BuildContext context) {
    final descriptionController = TextEditingController();
    ProgressStage? selectedStage;

    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Agregar Actualización de Progreso'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<ProgressStage>(
                  value: selectedStage,
                  decoration: const InputDecoration(
                    labelText: 'Etapa',
                    border: OutlineInputBorder(),
                  ),
                  items: ProgressStage.values.map((stage) {
                    return DropdownMenuItem(
                      value: stage,
                      child: Text(_getProgressStageName(stage)),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedStage = value;
                    });
                  },
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: descriptionController,
                  decoration: const InputDecoration(
                    labelText: 'Descripción',
                    border: OutlineInputBorder(),
                    hintText: 'Ej: Reemplazando pastillas de freno...',
                  ),
                  maxLines: 3,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () {
                if (selectedStage != null && descriptionController.text.isNotEmpty) {
                  final dto = CreateProgressDto(
                    stage: selectedStage!,
                    description: descriptionController.text,
                  );
                  context.read<AppointmentsBloc>().add(
                    AddProgress(widget.appointmentId, dto)
                  );
                  Navigator.pop(dialogContext);
                  // El BLoC recarga automáticamente después de agregar
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.indigo),
              child: const Text('Agregar'),
            ),
          ],
        ),
      ),
    );
  }

  void _showConfirmDialog(BuildContext context, String appointmentId) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Confirmar Cita'),
        content: const Text(
          '¿Estás seguro de que deseas aceptar esta cita?\n\n'
          'Al aceptar la cita, podrás agregar progreso y chatear con el cliente.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              context.read<AppointmentsBloc>().add(
                ConfirmAppointment(appointmentId)
              );
              Navigator.pop(dialogContext);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
            child: const Text('Aceptar Cita'),
          ),
        ],
      ),
    );
  }

  void _showCompleteDialog(BuildContext context, String appointmentId) {
    final finalCostController = TextEditingController();
    final notesController = TextEditingController();

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Completar Cita'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: finalCostController,
                decoration: const InputDecoration(
                  labelText: 'Costo Final',
                  border: OutlineInputBorder(),
                  prefixText: '\$',
                ),
                keyboardType: TextInputType.numberWithOptions(decimal: true),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: notesController,
                decoration: const InputDecoration(
                  labelText: 'Notas adicionales (opcional)',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              if (finalCostController.text.isNotEmpty) {
                final finalCost = double.tryParse(finalCostController.text);
                if (finalCost != null) {
                  context.read<AppointmentsBloc>().add(
                    CompleteAppointment(
                      appointmentId,
                      finalCost,
                      notes: notesController.text.isNotEmpty ? notesController.text : null,
                    )
                  );
                  Navigator.pop(dialogContext);
                }
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            child: const Text('Completar'),
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
      case ServiceType.OIL_CHANGE:
        return 'Cambio de Aceite';
      case ServiceType.TIRE_ROTATION:
        return 'Rotación de Llantas';
      case ServiceType.BRAKE_INSPECTION:
        return 'Inspección de Frenos';
      case ServiceType.BRAKE_REPLACEMENT:
        return 'Reemplazo de Frenos';
      case ServiceType.FILTER_REPLACEMENT:
        return 'Reemplazo de Filtros';
      case ServiceType.BATTERY_REPLACEMENT:
        return 'Reemplazo de Batería';
      case ServiceType.ALIGNMENT:
        return 'Alineación y Balanceo';
      case ServiceType.TRANSMISSION_SERVICE:
        return 'Servicio de Transmisión';
      case ServiceType.COOLANT_FLUSH:
        return 'Cambio de Refrigerante';
      case ServiceType.ENGINE_TUNEUP:
        return 'Afinación de Motor';
      case ServiceType.INSPECTION:
        return 'Inspección General';
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
