import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:proyecto/core/services/service_locator.dart';
import 'package:proyecto/features/appointments/data/models/appointment_model.dart';
import 'package:proyecto/features/appointments/presentation/bloc/appointments_bloc.dart';
import 'package:proyecto/features/workshop_admin/presentation/bloc/admin_workshop_bloc.dart';

/// Pantalla de citas del taller para WORKSHOP_ADMIN
/// Filtra las citas por los talleres del administrador
class WorkshopAppointmentsScreen extends StatefulWidget {
  const WorkshopAppointmentsScreen({super.key});

  @override
  State<WorkshopAppointmentsScreen> createState() => _WorkshopAppointmentsScreenState();
}

class _WorkshopAppointmentsScreenState extends State<WorkshopAppointmentsScreen> {
  bool _appointmentsLoaded = false;

  @override
  void initState() {
    super.initState();
    // Primero cargar talleres
    context.read<AdminWorkshopBloc>().add(LoadMyWorkshops());
  }

  void _loadAppointmentsForWorkshop(String workshopId) {
    if (!_appointmentsLoaded) {
      print('🔄 Cargando citas para el taller: $workshopId');
      context.read<AppointmentsBloc>().add(
        LoadAppointments(workshopId: workshopId)
      );
      _appointmentsLoaded = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Citas de Mis Talleres'),
        backgroundColor: Colors.indigo,
      ),
      body: BlocBuilder<AdminWorkshopBloc, AdminWorkshopState>(
        builder: (context, workshopState) {
          if (workshopState is! AdminLoaded || workshopState.workshops.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.store_mall_directory_outlined, size: 80, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    'No tienes talleres registrados',
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          // Obtener los IDs de los talleres del admin
          final myWorkshopIds = workshopState.workshops.map((w) => w.id).toSet();

          // Cargar citas del primer taller (por ahora)
          if (myWorkshopIds.isNotEmpty) {
            _loadAppointmentsForWorkshop(myWorkshopIds.first);
          }

          return BlocBuilder<AppointmentsBloc, AppointmentsState>(
            builder: (context, appointmentState) {
              if (appointmentState is AppointmentsLoading) {
                return const Center(child: CircularProgressIndicator());
              }

              if (appointmentState is AppointmentsError) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline, size: 64, color: Colors.red),
                      const SizedBox(height: 16),
                      Text(appointmentState.message),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () {
                          if (myWorkshopIds.isNotEmpty) {
                            _appointmentsLoaded = false;
                            _loadAppointmentsForWorkshop(myWorkshopIds.first);
                          }
                        },
                        child: const Text('Reintentar'),
                      ),
                    ],
                  ),
                );
              }

              if (appointmentState is AppointmentsLoaded) {
                // Debug: Imprimir información
                print('📊 DEBUG WorkshopAppointments:');
                print('   Taller seleccionado: ${myWorkshopIds.first}');
                print('   Total citas recibidas del backend: ${appointmentState.appointments.length}');

                // Ya NO necesitamos filtrar, el backend devuelve solo las citas del taller
                final workshopAppointments = appointmentState.appointments;

                if (workshopAppointments.isEmpty) {
                  return const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.event_busy, size: 80, color: Colors.grey),
                        SizedBox(height: 16),
                        Text(
                          'No hay citas programadas',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Las citas aparecerán aquí cuando los clientes las agenden.',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                  );
                }

                return RefreshIndicator(
                  onRefresh: () async {
                    if (myWorkshopIds.isNotEmpty) {
                      context.read<AppointmentsBloc>().add(
                        LoadAppointments(workshopId: myWorkshopIds.first)
                      );
                    }
                  },
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: workshopAppointments.length,
                    itemBuilder: (context, index) {
                      final appointment = workshopAppointments[index];
                      return _buildAppointmentCard(context, appointment, workshopState.workshops);
                    },
                  ),
                );
              }

              return const Center(child: Text('No hay datos disponibles'));
            },
          );
        },
      ),
    );
  }

  Widget _buildAppointmentCard(BuildContext context, AppointmentModel appointment, List workshops) {
    final statusColor = _getStatusColor(appointment.status);
    final statusText = _getStatusText(appointment.status);

    // Buscar el nombre del taller
    String workshopName = 'Taller desconocido';
    try {
      final workshop = workshops.firstWhere(
        (w) => w.id == appointment.workshopId,
      );
      workshopName = workshop.name;
    } catch (e) {
      // Si no encuentra el taller, usar nombre por defecto
      workshopName = 'Taller desconocido';
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      child: InkWell(
        onTap: () {
          context.push('/admin/appointments/detail/${appointment.id}');
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header con estado
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: statusColor),
                    ),
                    child: Text(
                      statusText,
                      style: TextStyle(
                        color: statusColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  const Spacer(),
                  Icon(Icons.chevron_right, color: Colors.grey[400]),
                ],
              ),
              const SizedBox(height: 12),

              // Nombre del taller
              Row(
                children: [
                  const Icon(Icons.store, size: 16, color: Colors.grey),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      workshopName,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Tipo de servicio
              Row(
                children: [
                  const Icon(Icons.build, size: 16, color: Colors.grey),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _getServiceTypeName(appointment.serviceType),
                      style: const TextStyle(fontSize: 14),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Fecha y hora
              Row(
                children: [
                  const Icon(Icons.calendar_today, size: 16, color: Colors.grey),
                  const SizedBox(width: 8),
                  Text(
                    DateFormat('dd/MM/yyyy').format(appointment.scheduledDate),
                    style: const TextStyle(fontSize: 14),
                  ),
                  const SizedBox(width: 16),
                  const Icon(Icons.access_time, size: 16, color: Colors.grey),
                  const SizedBox(width: 8),
                  Text(
                    appointment.scheduledTime,
                    style: const TextStyle(fontSize: 14),
                  ),
                ],
              ),

              // Costo estimado
              if (appointment.estimatedCost != null) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.attach_money, size: 16, color: Colors.grey),
                    const SizedBox(width: 8),
                    Text(
                      '\$${appointment.estimatedCost!.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
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
}
