import 'package:proyecto/features/appointments/data/models/appointment_model.dart';
import 'package:proyecto/features/appointments/data/repositories/appointment_repository.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

class MyAppointmentsScreen extends StatefulWidget {
  const MyAppointmentsScreen({super.key});

  @override
  State<MyAppointmentsScreen> createState() => _MyAppointmentsScreenState();
}

class _MyAppointmentsScreenState extends State<MyAppointmentsScreen> {
  final AppointmentRepository _repository = AppointmentRepository();
  late Future<List<Appointment>> _appointmentsFuture;

  @override
  void initState() {
    super.initState();
    _appointmentsFuture = _repository.getAppointments();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mis Citas'),
      ),
      body: FutureBuilder<List<Appointment>>(
        future: _appointmentsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No tienes citas programadas.'));
          }

          final appointments = snapshot.data!;
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: appointments.length,
            itemBuilder: (context, index) {
              final appointment = appointments[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  leading: const Icon(Icons.calendar_month),
                  title: Text(appointment.serviceType),
                  subtitle: Text(
                      '${appointment.workshopName}\n${DateFormat.yMMMd().add_jm().format(appointment.date)}'),
                  trailing: Chip(
                    label: Text(appointment.status.name),
                    backgroundColor: appointment.status == AppointmentStatus.confirmed
                        ? Colors.blue.shade100
                        : Colors.grey.shade300,
                  ),
                  onTap: () {
                    // Navegar a editar cita
                  },
                ),
              );
            },
          );
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