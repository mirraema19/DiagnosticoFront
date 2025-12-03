import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:proyecto/features/history/data/models/maintenance_model.dart';
import 'package:proyecto/features/history/presentation/bloc/history_bloc.dart';



class AddMaintenanceScreen extends StatefulWidget {
  const AddMaintenanceScreen({super.key});

  @override
  State<AddMaintenanceScreen> createState() => _AddMaintenanceScreenState();
}

class _AddMaintenanceScreenState extends State<AddMaintenanceScreen> {
  final _formKey = GlobalKey<FormState>();
  
  // Variable para almacenar el valor seleccionado del Dropdown
  String? _selectedServiceType;
  
  final _descriptionController = TextEditingController();
  final _workshopController = TextEditingController();
  final _mileageController = TextEditingController();
  final _costController = TextEditingController();
  final _notesController = TextEditingController();
  
  DateTime _selectedDate = DateTime.now();

  // Mapa de opciones válidas según el ServiceTypeEnum de tu backend
  final Map<String, String> _serviceOptions = {
    'OIL_CHANGE': 'Cambio de Aceite',
    'TIRE_ROTATION': 'Rotación de Llantas',
    'BRAKE_SERVICE': 'Servicio de Frenos',
    'BATTERY_REPLACEMENT': 'Cambio de Batería',
    'GENERAL_CHECKUP': 'Revisión General',
    'OTHER': 'Otro',
  };

  void _submit() {
    if (_formKey.currentState!.validate()) {
      final newRecord = Maintenance(
        id: Random().nextInt(1000).toString(),
        vehicleId: '', // Se asignará en el repositorio
        serviceType: _selectedServiceType!, // Enviamos el valor del Enum (ej. OIL_CHANGE)
        description: _descriptionController.text.isNotEmpty ? _descriptionController.text : null,
        serviceDate: _selectedDate,
        mileageAtService: int.parse(_mileageController.text),
        cost: double.tryParse(_costController.text),
        currency: 'MXN',
        workshopName: _workshopController.text.isNotEmpty ? _workshopController.text : null,
        notes: _notesController.text.isNotEmpty ? _notesController.text : null,
      );

      context.read<HistoryBloc>().add(AddMaintenanceRecord(newRecord));
      context.pop();
    }
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _workshopController.dispose();
    _mileageController.dispose();
    _costController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Registrar Mantenimiento')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // --- Dropdown para Tipo de Servicio ---
              DropdownButtonFormField<String>(
                value: _selectedServiceType,
                decoration: const InputDecoration(
                  labelText: 'Tipo de Servicio',
                  prefixIcon: Icon(Icons.build),
                ),
                items: _serviceOptions.entries.map((entry) {
                  return DropdownMenuItem(
                    value: entry.key,
                    child: Text(entry.value),
                  );
                }).toList(),
                onChanged: (value) => setState(() => _selectedServiceType = value),
                validator: (v) => v == null ? 'Por favor selecciona un servicio' : null,
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(labelText: 'Descripción (Opcional)'),
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _workshopController,
                decoration: const InputDecoration(labelText: 'Taller (Opcional)'),
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _mileageController,
                decoration: const InputDecoration(labelText: 'Kilometraje al momento'),
                keyboardType: TextInputType.number,
                validator: (v) => v!.isEmpty ? 'Requerido' : null,
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _costController,
                decoration: const InputDecoration(labelText: 'Costo (Opcional)'),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),

              ListTile(
                title: const Text('Fecha del Servicio'),
                subtitle: Text(DateFormat.yMMMd('es_ES').format(_selectedDate)),
                trailing: const Icon(Icons.calendar_today),
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: _selectedDate,
                    firstDate: DateTime(2000),
                    lastDate: DateTime.now(),
                  );
                  if (picked != null) setState(() => _selectedDate = picked);
                },
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _notesController,
                decoration: const InputDecoration(labelText: 'Notas Adicionales (Opcional)'),
                maxLines: 3,
              ),
              const SizedBox(height: 32),

              ElevatedButton(
                onPressed: _submit,
                child: const Text('GUARDAR REGISTRO'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}