import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:proyecto/core/services/service_locator.dart';
import 'package:proyecto/features/appointments/data/models/appointment_model.dart';
import 'package:proyecto/features/appointments/presentation/bloc/appointments_bloc.dart';

class MyAppointmentsScreen extends StatefulWidget {
  const MyAppointmentsScreen({super.key});

  @override
  State<MyAppointmentsScreen> createState() => _MyAppointmentsScreenState();
}

class _MyAppointmentsScreenState extends State<MyAppointmentsScreen> {
  AppointmentStatus? _selectedFilter;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          AppointmentsBloc(repository: sl())..add(const LoadAppointments()),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Mis Citas'),
          backgroundColor: Colors.blue,
          actions: [
            PopupMenuButton<AppointmentStatus?>(
              icon: const Icon(Icons.filter_list),
              onSelected: (status) {
                setState(() {
                  _selectedFilter = status;
                });
                context.read<AppointmentsBloc>().add(
                      LoadAppointments(status: status?.name),
                    );
              },
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: null,
                  child: Text('Todas'),
                ),
                const PopupMenuItem(
                  value: AppointmentStatus.PENDING,
                  child: Text('Pendientes'),
                ),
                const PopupMenuItem(
                  value: AppointmentStatus.CONFIRMED,
                  child: Text('Confirmadas'),
                ),
                const PopupMenuItem(
                  value: AppointmentStatus.IN_PROGRESS,
                  child: Text('En Progreso'),
                ),
                const PopupMenuItem(
                  value: AppointmentStatus.COMPLETED,
                  child: Text('Completadas'),
                ),
                const PopupMenuItem(
                  value: AppointmentStatus.CANCELLED,
                  child: Text('Canceladas'),
                ),
              ],
            ),
          ],
        ),
        body: BlocListener<AppointmentsBloc, AppointmentsState>(
          listener: (context, state) {
            if (state is AppointmentCancelled) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Cita cancelada exitosamente'),
                  backgroundColor: Colors.orange,
                ),
              );
              context.read<AppointmentsBloc>().add(const LoadAppointments());
            }
          },
          child: BlocBuilder<AppointmentsBloc, AppointmentsState>(
            builder: (context, state) {
              if (state is AppointmentsLoading) {
                return const Center(child: CircularProgressIndicator());
              }

              if (state is AppointmentsLoaded) {
                if (state.appointments.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.event_busy,
                          size: 64,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _selectedFilter == null
                              ? 'No tienes citas programadas'
                              : 'No hay citas con este filtro',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return RefreshIndicator(
                  onRefresh: () async {
                    context.read<AppointmentsBloc>().add(
                          LoadAppointments(status: _selectedFilter?.name),
                        );
                  },
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: state.appointments.length,
                    itemBuilder: (context, index) {
                      final appointment = state.appointments[index];
                      return AppointmentListItem(appointment: appointment);
                    },
                  ),
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
                      Text(
                        state.message,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () {
                          context
                              .read<AppointmentsBloc>()
                              .add(const LoadAppointments());
                        },
                        child: const Text('Reintentar'),
                      ),
                    ],
                  ),
                );
              }

              return const SizedBox.shrink();
            },
          ),
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () {
            context.push('/appointments/create');
          },
          backgroundColor: Colors.blue,
          label: const Text('Nueva Cita', style: TextStyle(color: Colors.white)),
          icon: const Icon(Icons.add, color: Colors.white),
        ),
      ),
    );
  }
}

class AppointmentListItem extends StatelessWidget {
  final AppointmentModel appointment;

  const AppointmentListItem({super.key, required this.appointment});

  (Color, String) _getStatusInfo(AppointmentStatus status) {
    switch (status) {
      case AppointmentStatus.PENDING:
        return (Colors.orange, 'Pendiente');
      case AppointmentStatus.CONFIRMED:
        return (Colors.blue, 'Confirmada');
      case AppointmentStatus.IN_PROGRESS:
        return (Colors.purple, 'En Progreso');
      case AppointmentStatus.COMPLETED:
        return (Colors.green, 'Completada');
      case AppointmentStatus.CANCELLED:
        return (Colors.red, 'Cancelada');
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

  @override
  Widget build(BuildContext context) {
    final (statusColor, statusText) = _getStatusInfo(appointment.status);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      child: InkWell(
        onTap: () {
          context.push('/appointments/detail/${appointment.id}');
        },
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.build, color: statusColor, size: 24),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _getServiceTypeName(appointment.serviceType),
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          appointment.description ?? 'Sin descripción',
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Chip(
                    label: Text(statusText),
                    backgroundColor: statusColor.withOpacity(0.1),
                    side: BorderSide.none,
                    labelStyle: TextStyle(
                      color: statusColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                    padding: EdgeInsets.zero,
                  ),
                ],
              ),
              const Divider(height: 24),
              Row(
                children: [
                  Icon(Icons.calendar_today, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 8),
                  Text(
                    DateFormat('dd/MM/yyyy').format(appointment.scheduledDate),
                    style: TextStyle(color: Colors.grey[700]),
                  ),
                  const SizedBox(width: 16),
                  Icon(Icons.access_time, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 8),
                  Text(
                    appointment.scheduledTime,
                    style: TextStyle(color: Colors.grey[700]),
                  ),
                ],
              ),
              if (appointment.estimatedCost != null) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.attach_money, size: 16, color: Colors.grey[600]),
                    const SizedBox(width: 8),
                    Text(
                      'Costo estimado: \$${appointment.estimatedCost!.toStringAsFixed(2)}',
                      style: TextStyle(
                        color: Colors.grey[700],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],

              // Botón "Dejar Reseña" solo para citas completadas
              if (appointment.status == AppointmentStatus.COMPLETED) ...[
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () {
                      // Navegar a la pantalla de crear reseña con el appointmentId
                      context.push(
                        '/workshops/${appointment.workshopId}/review',
                        extra: {
                          'appointmentId': appointment.id,
                          'workshopId': appointment.workshopId,
                        },
                      );
                    },
                    icon: const Icon(Icons.rate_review, size: 18),
                    label: const Text('Dejar Reseña del Servicio'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.blue,
                      side: const BorderSide(color: Colors.blue, width: 1.5),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
