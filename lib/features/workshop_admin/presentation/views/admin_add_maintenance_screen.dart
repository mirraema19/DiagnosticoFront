import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:proyecto/features/history/data/models/maintenance_model.dart';
import 'package:proyecto/features/history/presentation/bloc/history_bloc.dart';

class AdminAddMaintenanceScreen extends StatefulWidget {
  const AdminAddMaintenanceScreen({super.key});

  @override
  State<AdminAddMaintenanceScreen> createState() => _AdminAddMaintenanceScreenState();
}

class _AdminAddMaintenanceScreenState extends State<AdminAddMaintenanceScreen> {
  final _formKey = GlobalKey<FormState>();
  
  // Campos del formulario
  final _vehicleIdController = TextEditingController(); // CRÍTICO: ID del auto del cliente
  String? _selectedServiceType;
  final _descriptionController = TextEditingController();
  final _mileageController = TextEditingController();
  final _costController = TextEditingController();
  final _notesController = TextEditingController();
  
  final DateTime _selectedDate = DateTime.now();

  // Opciones válidas según tu Backend
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
        id: Random().nextInt(1000).toString(), // ID temporal, el backend asigna el real
        
        // IMPORTANTE: Usamos el ID que el Admin escribió
        vehicleId: _vehicleIdController.text.trim(), 
        
        serviceType: _selectedServiceType!,
        description: _descriptionController.text.isNotEmpty ? _descriptionController.text : null,
        serviceDate: _selectedDate,
        mileageAtService: int.parse(_mileageController.text),
        cost: double.tryParse(_costController.text),
        currency: 'MXN',
        // El nombre del taller lo pondrá el backend basado en el usuario logueado (Admin)
        // o podemos enviarlo si queremos forzarlo. Lo enviamos como null para que el back decida o "Mi Taller".
        workshopName: 'Taller Certificado', 
        notes: _notesController.text.isNotEmpty ? _notesController.text : null,
      );

      // Usamos el HistoryBloc global para enviar la petición
      context.read<HistoryBloc>().add(AddMaintenanceRecord(newRecord));
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Servicio registrado en la bitácora del cliente')),
      );
      
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Registrar Servicio a Cliente'),
        backgroundColor: Colors.indigo, // Color distintivo para Admin
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Card(
                color: Result.warning, // Color suave
                child: Padding(
                  padding: EdgeInsets.all(12.0),
                  child: Text(
                    'Ingresa el ID del Vehículo del cliente para registrar el mantenimiento en su historial oficial.',
                    style: TextStyle(fontSize: 12),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // --- CAMPO DE ID DE VEHÍCULO ---
              TextFormField(
                controller: _vehicleIdController,
                decoration: const InputDecoration(
                  labelText: 'ID del Vehículo (UUID)',
                  prefixIcon: Icon(Icons.vpn_key),
                  border: OutlineInputBorder(),
                ),
                validator: (v) => v!.isEmpty ? 'El ID del vehículo es obligatorio' : null,
              ),
              const SizedBox(height: 20),
              
              const Divider(),
              const SizedBox(height: 20),

              // Dropdown de Servicio
              DropdownButtonFormField<String>(
                initialValue: _selectedServiceType,
                decoration: const InputDecoration(
                  labelText: 'Tipo de Servicio', 
                  prefixIcon: Icon(Icons.build)
                ),
                items: _serviceOptions.entries.map((e) => DropdownMenuItem(value: e.key, child: Text(e.value))).toList(),
                onChanged: (v) => setState(() => _selectedServiceType = v),
                validator: (v) => v == null ? 'Requerido' : null,
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _mileageController,
                decoration: const InputDecoration(labelText: 'Kilometraje Actual', prefixIcon: Icon(Icons.speed)),
                keyboardType: TextInputType.number,
                validator: (v) => v!.isEmpty ? 'Requerido' : null,
              ),
              const SizedBox(height: 16),
              
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(labelText: 'Descripción del Trabajo'),
                maxLines: 2,
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _costController,
                decoration: const InputDecoration(labelText: 'Costo Total', prefixIcon: Icon(Icons.attach_money)),
                keyboardType: TextInputType.number,
              ),
              
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _submit,
                  icon: const Icon(Icons.save),
                  label: const Text('GUARDAR EN BITÁCORA'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.indigo,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Pequeño helper para colores (opcional si no tienes definida la clase Result)
class Result { static const warning = Color(0xFFFFF3E0); }