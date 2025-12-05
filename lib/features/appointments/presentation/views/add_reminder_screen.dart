import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:proyecto/features/appointments/data/models/reminder_model.dart';
import 'package:proyecto/features/appointments/presentation/bloc/reminders/reminders_bloc.dart';

// Wrapper para inyección de dependencias
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
  
  // Controladores
  String? _selectedServiceType;
  final _descriptionController = TextEditingController();
  String _dueType = 'MILEAGE'; // Valor por defecto: Kilometraje
  final _mileageController = TextEditingController();
  DateTime? _selectedDate;

  // Opciones de servicio (Mismo Enum que el backend)
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

    // Validación extra para la fecha
    if (_dueType == 'DATE' && _selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor selecciona una fecha')),
      );
      return;
    }

    // PREPARAR EL VALOR (dueValue)
    String finalDueValue = '';
    if (_dueType == 'MILEAGE') {
      // Si es kilometraje, enviamos el número como string: "50000"
      finalDueValue = _mileageController.text; 
    } else {
      // Si es fecha, enviamos formato ISO: "2025-11-25T..."
      finalDueValue = _selectedDate!.toIso8601String();
    }

    final newReminder = Reminder(
      id: Random().nextInt(1000).toString(),
      vehicleId: '', // El repositorio asignará el vehículo principal
      serviceType: _selectedServiceType!,
      description: _descriptionController.text.isNotEmpty ? _descriptionController.text : null,
      dueType: _dueType,
      dueValue: finalDueValue,
      status: 'PENDING',
      createdAt: DateTime.now(),
    );

    // Enviamos al BLoC
    context.read<RemindersBloc>().add(AddReminder(newReminder));
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Recordatorio creado exitosamente')),
    );
    
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Configura cuándo quieres recibir el aviso.',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
              const SizedBox(height: 24),

              // 1. TIPO DE SERVICIO
              DropdownButtonFormField<String>(
                initialValue: _selectedServiceType,
                decoration: const InputDecoration(
                  labelText: 'Servicio a Recordar',
                  prefixIcon: Icon(Icons.build),
                ),
                items: _serviceOptions.entries.map((e) => DropdownMenuItem(value: e.key, child: Text(e.value))).toList(),
                onChanged: (v) => setState(() => _selectedServiceType = v),
                validator: (v) => v == null ? 'Requerido' : null,
              ),
              const SizedBox(height: 16),

              // 2. DESCRIPCIÓN
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Nota (Opcional)',
                  prefixIcon: Icon(Icons.notes),
                  hintText: 'Ej: Usar aceite sintético',
                ),
              ),
              const SizedBox(height: 16),

              // 3. TIPO DE VENCIMIENTO (Kilometraje o Fecha)
              DropdownButtonFormField<String>(
                initialValue: _dueType,
                decoration: const InputDecoration(
                  labelText: 'Recordar por...',
                  prefixIcon: Icon(Icons.rule),
                ),
                items: const [
                  DropdownMenuItem(value: 'MILEAGE', child: Text('Kilometraje')),
                  DropdownMenuItem(value: 'DATE', child: Text('Fecha')),
                ],
                onChanged: (v) {
                  setState(() {
                    _dueType = v!;
                    // Limpiamos los campos opuestos al cambiar
                    _mileageController.clear();
                    _selectedDate = null;
                  });
                },
              ),
              const SizedBox(height: 16),

              // 4. INPUT DINÁMICO (Depende de la selección anterior)
              if (_dueType == 'MILEAGE')
                TextFormField(
                  controller: _mileageController,
                  decoration: const InputDecoration(
                    labelText: 'Kilometraje Objetivo',
                    hintText: 'Ej: 50000',
                    prefixIcon: Icon(Icons.speed),
                    helperText: 'Te avisaremos cuando tu auto se acerque a este kilometraje.',
                  ),
                  keyboardType: TextInputType.number,
                  validator: (v) => v!.isEmpty ? 'Requerido' : null,
                )
              else
                ListTile(
                  title: Text(
                    _selectedDate == null ? 'Seleccionar Fecha' : DateFormat.yMMMd('es_ES').format(_selectedDate!),
                    style: TextStyle(color: _selectedDate == null ? Colors.grey[600] : Colors.black),
                  ),
                  leading: const Icon(Icons.calendar_month),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(color: Colors.grey.shade400),
                  ),
                  tileColor: Colors.white,
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now().add(const Duration(days: 90)), // Sugerir 3 meses
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
                    );
                    if (picked != null) setState(() => _selectedDate = picked);
                  },
                ),

              const SizedBox(height: 40),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _submit,
                  child: const Text('CREAR RECORDATORIO'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}