import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:proyecto/features/appointments/data/models/reminder_model.dart';
import 'package:proyecto/features/appointments/presentation/bloc/reminders/reminders_bloc.dart';

class AddReminderScreenWrapper extends StatelessWidget {
  const AddReminderScreenWrapper({super.key});
  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: BlocProvider.of<RemindersBloc>(context),
      child: const AddReminderScreen(),
    );
  }
}

class AddReminderScreen extends StatefulWidget {
  const AddReminderScreen({super.key});

  @override
  State<AddReminderScreen> createState() => _AddReminderScreenState();
}

class _AddReminderScreenState extends State<AddReminderScreen> {
  final _formKey = GlobalKey<FormState>();
  
  // Campos del formulario
  String? _selectedServiceType;
  final _descriptionController = TextEditingController();
  String _dueType = 'MILEAGE'; // Por defecto Kilometraje
  final _mileageController = TextEditingController();
  DateTime? _selectedDate;

  // Opciones de servicio (Mismas que en Mantenimiento)
  final Map<String, String> _serviceOptions = {
    'OIL_CHANGE': 'Cambio de Aceite',
    'TIRE_ROTATION': 'Rotación de Llantas',
    'BRAKE_SERVICE': 'Servicio de Frenos',
    'BATTERY_REPLACEMENT': 'Cambio de Batería',
    'GENERAL_CHECKUP': 'Revisión General',
    'OTHER': 'Otro',
  };

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    // Determinar el valor de vencimiento según el tipo
    String finalDueValue = '';
    if (_dueType == 'MILEAGE') {
      finalDueValue = _mileageController.text;
    } else {
      // Si es fecha, formatear a ISO 8601 string
      finalDueValue = _selectedDate!.toIso8601String();
    }

    final newReminder = Reminder(
      id: Random().nextInt(1000).toString(),
      vehicleId: '', // Se asigna en el repositorio
      serviceType: _selectedServiceType!,
      description: _descriptionController.text.isNotEmpty ? _descriptionController.text : null,
      dueType: _dueType,
      dueValue: finalDueValue,
      status: 'PENDING', // Estado inicial por defecto
      createdAt: DateTime.now(),
    );

    context.read<RemindersBloc>().add(AddReminder(newReminder));
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Crear Recordatorio')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // 1. Tipo de Servicio
              DropdownButtonFormField<String>(
                value: _selectedServiceType,
                decoration: const InputDecoration(labelText: 'Servicio a Recordar', prefixIcon: Icon(Icons.build)),
                items: _serviceOptions.entries.map((e) => DropdownMenuItem(value: e.key, child: Text(e.value))).toList(),
                onChanged: (v) => setState(() => _selectedServiceType = v),
                validator: (v) => v == null ? 'Requerido' : null,
              ),
              const SizedBox(height: 16),

              // 2. Descripción
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(labelText: 'Descripción (Opcional)', prefixIcon: Icon(Icons.notes)),
              ),
              const SizedBox(height: 16),

              // 3. Tipo de Vencimiento
              DropdownButtonFormField<String>(
                value: _dueType,
                decoration: const InputDecoration(labelText: 'Recordar por', prefixIcon: Icon(Icons.rule)),
                items: const [
                  DropdownMenuItem(value: 'MILEAGE', child: Text('Kilometraje')),
                  DropdownMenuItem(value: 'DATE', child: Text('Fecha')),
                ],
                onChanged: (v) {
                  setState(() {
                    _dueType = v!;
                    // Limpiamos los valores al cambiar el tipo para evitar confusión
                    _mileageController.clear();
                    _selectedDate = null;
                  });
                },
              ),
              const SizedBox(height: 16),

              // 4. Valor de Vencimiento (Dinámico)
              if (_dueType == 'MILEAGE')
                TextFormField(
                  controller: _mileageController,
                  decoration: const InputDecoration(labelText: 'Kilometraje Objetivo', prefixIcon: Icon(Icons.speed)),
                  keyboardType: TextInputType.number,
                  validator: (v) => v!.isEmpty ? 'Requerido' : null,
                )
              else
                ListTile(
                  title: Text(
                    _selectedDate == null ? 'Seleccionar Fecha' : DateFormat.yMMMd('es_ES').format(_selectedDate!),
                    style: TextStyle(color: _selectedDate == null ? Colors.grey[600] : Colors.black),
                  ),
                  leading: const Icon(Icons.calendar_today),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(color: Colors.grey.shade400),
                  ),
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now().add(const Duration(days: 30)),
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
                    );
                    if (picked != null) setState(() => _selectedDate = picked);
                  },
                ),
                // Validación manual para la fecha porque no es un TextFormField
                if (_dueType == 'DATE' && _selectedDate == null)
                  const Padding(
                    padding: EdgeInsets.only(top: 8.0, left: 12.0),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text('La fecha es requerida', style: TextStyle(color: Colors.red, fontSize: 12)),
                    ),
                  ),

              const SizedBox(height: 32),
              ElevatedButton(onPressed: _submit, child: const Text('CREAR RECORDATORIO')),
            ],
          ),
        ),
      ),
    );
  }
}