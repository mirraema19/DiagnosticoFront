import 'dart:math';
import 'package:proyecto/features/appointments/data/models/appointment_model.dart';
import 'package:proyecto/features/appointments/presentation/bloc/appointments_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

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
              decoration: const InputDecoration(labelText: 'Taller'),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _serviceController,
              decoration: const InputDecoration(labelText: 'Servicio'),
            ),
            const SizedBox(height: 16),
            TextFormField(
              readOnly: true,
              decoration: InputDecoration(
                labelText: 'Fecha y Hora',
                hintText: DateFormat.yMMMd('es_ES').add_jm().format(_selectedDate),
                suffixIcon: const Icon(Icons.calendar_today),
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
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: _submitAppointment,
              child: const Text('CONFIRMAR CITA'),
            )
          ],
        ),
      ),
    );
  }
}