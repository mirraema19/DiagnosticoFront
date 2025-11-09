import 'package:proyecto/features/appointments/data/models/appointment_model.dart';
import 'package:proyecto/features/appointments/presentation/bloc/appointments_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

class MyAppointmentsScreen extends StatelessWidget {
  const MyAppointmentsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // El BlocProvider ya no se crea aquí, se asume que existe en el contexto.
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mis Citas'),
      ),
      body: BlocBuilder<AppointmentsBloc, AppointmentsState>(
        builder: (context, state) {
          if (state is AppointmentsLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is AppointmentsLoaded) {
            if (state.appointments.isEmpty) {
              return const Center(child: Text('No tienes citas programadas.'));
            }
            // Usamos RefreshIndicator para permitir al usuario recargar la lista
            return RefreshIndicator(
              onRefresh: () async {
                context.read<AppointmentsBloc>().add(LoadAppointments());
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
            return Center(child: Text(state.message));
          }
          return const SizedBox.shrink();
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          context.push('/appointments/add');
        },
        label: const Text('Nueva Cita'),
        icon: const Icon(Icons.add),
      ),
    );
  }
}

// Widget para mostrar cada item de la lista de citas
class AppointmentListItem extends StatelessWidget {
  final Appointment appointment;

  const AppointmentListItem({super.key, required this.appointment});
  
  // Helper para obtener el color y el texto del estado de la cita
  (Color, String) _getStatusInfo(AppointmentStatus status) {
    switch (status) {
      case AppointmentStatus.received: return (Colors.blue, 'Recibido');
      case AppointmentStatus.in_diagnosis: return (Colors.orange, 'En Diagnóstico');
      case AppointmentStatus.ready: return (Colors.green, 'Listo');
      case AppointmentStatus.completed: return (Colors.grey, 'Completado');
    }
  }

  @override
  Widget build(BuildContext context) {
    final (statusColor, statusText) = _getStatusInfo(appointment.status);
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Icon(Icons.calendar_month, color: statusColor),
        title: Text(appointment.serviceType, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(
            '${appointment.workshopName}\n${DateFormat.yMMMd('es_ES').add_jm().format(appointment.date)}'),
        trailing: Chip(
          label: Text(statusText),
          backgroundColor: statusColor.withOpacity(0.1),
          side: BorderSide.none,
          labelStyle: TextStyle(color: statusColor, fontWeight: FontWeight.bold),
        ),
        onTap: () {
          // Acción futura: navegar para editar la cita
        },
      ),
    );
  }
}