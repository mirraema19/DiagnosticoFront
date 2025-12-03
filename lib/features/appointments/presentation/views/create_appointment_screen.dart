import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:proyecto/core/services/service_locator.dart';
import 'package:proyecto/features/appointments/data/models/appointment_model.dart';
import 'package:proyecto/features/appointments/presentation/bloc/appointments_bloc.dart';
import 'package:intl/intl.dart';

class CreateAppointmentScreen extends StatefulWidget {
  final String? vehicleId;
  final String? workshopId;
  final String? diagnosisId;

  const CreateAppointmentScreen({
    super.key,
    this.vehicleId,
    this.workshopId,
    this.diagnosisId,
  });

  @override
  State<CreateAppointmentScreen> createState() =>
      _CreateAppointmentScreenState();
}

class _CreateAppointmentScreenState extends State<CreateAppointmentScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controllers
  late TextEditingController _vehicleIdController;
  late TextEditingController _workshopIdController;
  late TextEditingController _descriptionController;
  late TextEditingController _estimatedCostController;
  late TextEditingController _estimatedDurationController;

  ServiceType _selectedServiceType = ServiceType.GENERAL_MAINTENANCE;
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;

  @override
  void initState() {
    super.initState();
    _vehicleIdController = TextEditingController(text: widget.vehicleId ?? '');
    _workshopIdController = TextEditingController(text: widget.workshopId ?? '');
    _descriptionController = TextEditingController();
    _estimatedCostController = TextEditingController();
    _estimatedDurationController = TextEditingController();
  }

  @override
  void dispose() {
    _vehicleIdController.dispose();
    _workshopIdController.dispose();
    _descriptionController.dispose();
    _estimatedCostController.dispose();
    _estimatedDurationController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 90)),
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: const TimeOfDay(hour: 9, minute: 0),
    );
    if (picked != null) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  void _submitForm(BuildContext context) {
    if (_formKey.currentState!.validate()) {
      if (_selectedDate == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Por favor selecciona una fecha')),
        );
        return;
      }
      if (_selectedTime == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Por favor selecciona una hora')),
        );
        return;
      }

      final dto = CreateAppointmentDto(
        vehicleId: _vehicleIdController.text,
        workshopId: _workshopIdController.text,
        diagnosisId: widget.diagnosisId,
        serviceType: _selectedServiceType,
        description: _descriptionController.text,
        scheduledDate: DateFormat('yyyy-MM-dd').format(_selectedDate!),
        scheduledTime:
            '${_selectedTime!.hour.toString().padLeft(2, '0')}:${_selectedTime!.minute.toString().padLeft(2, '0')}',
        estimatedDuration: _estimatedDurationController.text.isNotEmpty
            ? int.parse(_estimatedDurationController.text)
            : null,
        estimatedCost: _estimatedCostController.text.isNotEmpty
            ? double.parse(_estimatedCostController.text)
            : null,
      );

      context.read<AppointmentsBloc>().add(CreateAppointment(dto));
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => AppointmentsBloc(repository: sl()),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Crear Cita'),
          backgroundColor: Colors.blue,
        ),
        body: BlocListener<AppointmentsBloc, AppointmentsState>(
          listener: (context, state) {
            if (state is AppointmentCreated) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Cita creada exitosamente'),
                  backgroundColor: Colors.green,
                ),
              );
              context.pop();
            } else if (state is AppointmentsError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Error: ${state.message}'),
                  backgroundColor: Colors.red,
                ),
              );
            }
          },
          child: BlocBuilder<AppointmentsBloc, AppointmentsState>(
            builder: (context, state) {
              if (state is AppointmentsLoading) {
                return const Center(child: CircularProgressIndicator());
              }

              return SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      TextFormField(
                        controller: _vehicleIdController,
                        decoration: const InputDecoration(
                          labelText: 'ID del Vehículo',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.directions_car),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Por favor ingresa el ID del vehículo';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _workshopIdController,
                        decoration: const InputDecoration(
                          labelText: 'ID del Taller',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.build),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Por favor ingresa el ID del taller';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<ServiceType>(
                        value: _selectedServiceType,
                        decoration: const InputDecoration(
                          labelText: 'Tipo de Servicio',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.miscellaneous_services),
                        ),
                        items: ServiceType.values.map((type) {
                          return DropdownMenuItem(
                            value: type,
                            child: Text(_getServiceTypeName(type)),
                          );
                        }).toList(),
                        onChanged: (value) {
                          if (value != null) {
                            setState(() {
                              _selectedServiceType = value;
                            });
                          }
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _descriptionController,
                        decoration: const InputDecoration(
                          labelText: 'Descripción',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.description),
                        ),
                        maxLines: 3,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Por favor ingresa una descripción';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      ListTile(
                        title: Text(
                          _selectedDate == null
                              ? 'Seleccionar Fecha'
                              : 'Fecha: ${DateFormat('dd/MM/yyyy').format(_selectedDate!)}',
                        ),
                        leading: const Icon(Icons.calendar_today),
                        tileColor: Colors.grey[100],
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                          side: BorderSide(color: Colors.grey[300]!),
                        ),
                        onTap: () => _selectDate(context),
                      ),
                      const SizedBox(height: 16),
                      ListTile(
                        title: Text(
                          _selectedTime == null
                              ? 'Seleccionar Hora'
                              : 'Hora: ${_selectedTime!.format(context)}',
                        ),
                        leading: const Icon(Icons.access_time),
                        tileColor: Colors.grey[100],
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                          side: BorderSide(color: Colors.grey[300]!),
                        ),
                        onTap: () => _selectTime(context),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _estimatedDurationController,
                        decoration: const InputDecoration(
                          labelText: 'Duración estimada (minutos)',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.timer),
                        ),
                        keyboardType: TextInputType.number,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _estimatedCostController,
                        decoration: const InputDecoration(
                          labelText: 'Costo estimado',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.attach_money),
                        ),
                        keyboardType: TextInputType.number,
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: () => _submitForm(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text(
                          'Crear Cita',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  String _getServiceTypeName(ServiceType type) {
    switch (type) {
      case ServiceType.BRAKE_INSPECTION:
        return 'Inspección de Frenos';
      case ServiceType.OIL_CHANGE:
        return 'Cambio de Aceite';
      case ServiceType.TIRE_ROTATION:
        return 'Rotación de Llantas';
      case ServiceType.ENGINE_DIAGNOSTIC:
        return 'Diagnóstico de Motor';
      case ServiceType.TRANSMISSION_SERVICE:
        return 'Servicio de Transmisión';
      case ServiceType.BATTERY_REPLACEMENT:
        return 'Reemplazo de Batería';
      case ServiceType.AIR_CONDITIONING:
        return 'Aire Acondicionado';
      case ServiceType.SUSPENSION_REPAIR:
        return 'Reparación de Suspensión';
      case ServiceType.EXHAUST_SYSTEM:
        return 'Sistema de Escape';
      case ServiceType.GENERAL_MAINTENANCE:
        return 'Mantenimiento General';
      case ServiceType.OTHER:
        return 'Otro';
    }
  }
}
