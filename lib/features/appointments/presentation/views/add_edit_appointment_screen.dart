import 'dart:math';
import 'package:proyecto/features/appointments/data/models/appointment_model.dart';
import 'package:proyecto/features/appointments/presentation/bloc/appointments_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:flutter_animate/flutter_animate.dart';
// --- CORRECCIÓN: La clase Wrapper ha sido eliminada ---

class AddEditAppointmentScreen extends StatefulWidget {
  const AddEditAppointmentScreen({super.key});

  @override
  State<AddEditAppointmentScreen> createState() => _AddEditAppointmentScreenState();
}

class _AddEditAppointmentScreenState extends State<AddEditAppointmentScreen> {
  final _workshopController = TextEditingController(text: 'Taller Mecánico Central');
  final _serviceController = TextEditingController(text: 'Revisión general');
  DateTime _selectedDate = DateTime.now().add(const Duration(days: 2));

  @override
  void dispose() {
    _workshopController.dispose();
    _serviceController.dispose();
    super.dispose();
  }

  void _submitAppointment() {
    if (_workshopController.text.isEmpty || _serviceController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Por favor, completa todos los campos.')));
      return;
    }

    final newAppointment = Appointment(
      id: Random().nextInt(1000).toString(),
      date: _selectedDate,
      workshopName: _workshopController.text,
      serviceType: _serviceController.text,
      status: AppointmentStatus.received,
    );
    
    // Ahora context.read<AppointmentsBloc>() funcionará correctamente
    context.read<AppointmentsBloc>().add(AddAppointment(newAppointment));
    context.pop();
  }

   @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Agendar Cita'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextFormField(
              controller: _workshopController,
              decoration: const InputDecoration(
                label: Text('Taller'),
                prefixIcon: Icon(Icons.build_outlined),
                suffixIcon: Icon(Icons.arrow_drop_down),
              ),
            ),
            const SizedBox(height: 20),
            TextFormField(
              controller: _serviceController,
              decoration: const InputDecoration(
                label: Text('Servicio'),
                prefixIcon: Icon(Icons.miscellaneous_services_outlined),
              ),
            ),
            const SizedBox(height: 20),
            TextFormField(
              readOnly: true,
              // Usamos un controlador para poder actualizar el texto dinámicamente
              controller: TextEditingController(
                text: DateFormat.yMMMd('es_ES').add_jm().format(_selectedDate),
              ),
              decoration: const InputDecoration(
                label: Text('Fecha y Hora'),
                prefixIcon: Icon(Icons.calendar_today_outlined),
              ),
              onTap: () async {
                FocusScope.of(context).requestFocus(FocusNode());
                final pickedDate = await showDatePicker(
                  context: context,
                  initialDate: _selectedDate,
                  firstDate: DateTime.now(),
                  lastDate: DateTime.now().add(const Duration(days: 365)),
                );
                if (pickedDate != null) {
                  setState(() {
                    _selectedDate = pickedDate;
                  });
                }
              },
            ),
            const SizedBox(height: 48),
            ElevatedButton(
              onPressed: _submitAppointment,
              child: const Text('CONFIRMAR CITA'),
            )
          ]
              .animate(interval: 100.ms)
              .fadeIn(duration: 400.ms, delay: 200.ms)
              .slideY(begin: 0.5, end: 0.0),
        ),
      ),
    );
  }
}