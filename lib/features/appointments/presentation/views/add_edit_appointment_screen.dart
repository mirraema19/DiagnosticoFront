import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AddEditAppointmentScreen extends StatelessWidget {
  const AddEditAppointmentScreen({super.key});

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
              decoration: const InputDecoration(
                labelText: 'Taller',
                hintText: 'Seleccionar taller',
                suffixIcon: Icon(Icons.arrow_drop_down),
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              decoration: const InputDecoration(
                labelText: 'Servicio',
                hintText: 'Ej: Cambio de aceite',
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              decoration: const InputDecoration(
                labelText: 'Fecha y Hora',
                hintText: 'Seleccionar fecha',
                suffixIcon: Icon(Icons.calendar_today),
              ),
              onTap: () async {
                // Aquí se implementaría un Date & Time Picker
                FocusScope.of(context).requestFocus(FocusNode()); // Quita el foco
                await showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime.now(),
                  lastDate: DateTime.now().add(const Duration(days: 365)),
                );
              },
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () {
                context.pop();
              },
              child: const Text('CONFIRMAR CITA'),
            )
          ],
        ),
      ),
    );
  }
}