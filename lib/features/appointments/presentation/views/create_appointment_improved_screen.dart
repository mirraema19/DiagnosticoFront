import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:proyecto/core/services/service_locator.dart';
import 'package:proyecto/features/appointments/data/models/appointment_model.dart';
import 'package:proyecto/features/appointments/presentation/bloc/appointments_bloc.dart';
import 'package:proyecto/features/garaje/presentation/bloc/garage_bloc.dart';
import 'package:proyecto/features/garaje/presentation/data/models/vehicle_model.dart';
import 'package:intl/intl.dart';

/// Pantalla mejorada para crear citas con selección de vehículos y talleres
class CreateAppointmentImprovedScreen extends StatefulWidget {
  final String? vehicleId;
  final String? workshopId;
  final String? diagnosisId;

  const CreateAppointmentImprovedScreen({
    super.key,
    this.vehicleId,
    this.workshopId,
    this.diagnosisId,
  });

  @override
  State<CreateAppointmentImprovedScreen> createState() =>
      _CreateAppointmentImprovedScreenState();
}

class _CreateAppointmentImprovedScreenState
    extends State<CreateAppointmentImprovedScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controllers
  late TextEditingController _descriptionController;
  late TextEditingController _estimatedCostController;
  late TextEditingController _estimatedDurationController;

  // Selected values
  Vehicle? _selectedVehicle;
  String? _selectedWorkshopId;
  String? _selectedWorkshopName;
  ServiceType _selectedServiceType = ServiceType.GENERAL_MAINTENANCE;
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;

  // Lists
  List<Vehicle> _vehicles = [];
  bool _loadingVehicles = true;

  @override
  void initState() {
    super.initState();
    _descriptionController = TextEditingController();
    _estimatedCostController = TextEditingController();
    _estimatedDurationController = TextEditingController();

    // Pre-seleccionar workshop si viene como parámetro
    _selectedWorkshopId = widget.workshopId;

    // Cargar vehículos
    _loadVehicles();
  }

  void _loadVehicles() {
    final garageState = context.read<GarageBloc>().state;
    if (garageState is GarageLoaded) {
      setState(() {
        _vehicles = garageState.vehicles;
        _loadingVehicles = false;

        // Pre-seleccionar vehículo si viene como parámetro
        if (widget.vehicleId != null) {
          try {
            _selectedVehicle = _vehicles.firstWhere(
              (v) => v.id == widget.vehicleId,
            );
          } catch (e) {
            // Si no se encuentra el vehículo, seleccionar el primero
            if (_vehicles.isNotEmpty) {
              _selectedVehicle = _vehicles.first;
            }
          }
        } else if (_vehicles.isNotEmpty) {
          _selectedVehicle = _vehicles.first;
        }
      });
    } else {
      // Si no están cargados, cargarlos
      context.read<GarageBloc>().add(LoadGarageData());
    }
  }

  @override
  void dispose() {
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
      if (_selectedVehicle == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Por favor selecciona un vehículo'),
            backgroundColor: Colors.orange,
          ),
        );
        return;
      }

      if (_selectedWorkshopId == null || _selectedWorkshopId!.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Por favor ingresa el ID del taller'),
            backgroundColor: Colors.orange,
          ),
        );
        return;
      }

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
        vehicleId: _selectedVehicle!.id,
        workshopId: _selectedWorkshopId!,
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

              return BlocListener<GarageBloc, GarageState>(
                listener: (context, garageState) {
                  if (garageState is GarageLoaded) {
                    setState(() {
                      _vehicles = garageState.vehicles;
                      _loadingVehicles = false;
                      if (_selectedVehicle == null && _vehicles.isNotEmpty) {
                        _selectedVehicle = _vehicles.first;
                      }
                    });
                  }
                },
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // SELECTOR DE VEHÍCULO
                        _buildVehicleSelector(),
                        const SizedBox(height: 16),

                        // SELECTOR DE TALLER
                        _buildWorkshopSelector(),
                        const SizedBox(height: 16),

                        // TIPO DE SERVICIO
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

                        // DESCRIPCIÓN
                        TextFormField(
                          controller: _descriptionController,
                          decoration: const InputDecoration(
                            labelText: 'Descripción del problema',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.description),
                            hintText: 'Describe el problema o servicio necesario',
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

                        // FECHA
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

                        // HORA
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

                        // DURACIÓN ESTIMADA (Opcional)
                        TextFormField(
                          controller: _estimatedDurationController,
                          decoration: const InputDecoration(
                            labelText: 'Duración estimada (minutos) - Opcional',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.timer),
                          ),
                          keyboardType: TextInputType.number,
                        ),
                        const SizedBox(height: 16),

                        // COSTO ESTIMADO (Opcional)
                        TextFormField(
                          controller: _estimatedCostController,
                          decoration: const InputDecoration(
                            labelText: 'Costo estimado - Opcional',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.attach_money),
                          ),
                          keyboardType: TextInputType.number,
                        ),
                        const SizedBox(height: 24),

                        // BOTÓN DE CREAR
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
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildVehicleSelector() {
    if (_loadingVehicles) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Row(
            children: [
              CircularProgressIndicator(),
              SizedBox(width: 16),
              Text('Cargando vehículos...'),
            ],
          ),
        ),
      );
    }

    if (_vehicles.isEmpty) {
      return Card(
        color: Colors.orange[50],
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              const Icon(Icons.warning, color: Colors.orange, size: 48),
              const SizedBox(height: 8),
              const Text(
                'No tienes vehículos registrados',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              ElevatedButton.icon(
                onPressed: () {
                  context.push('/garage/add');
                },
                icon: const Icon(Icons.add),
                label: const Text('Agregar Vehículo'),
              ),
            ],
          ),
        ),
      );
    }

    return DropdownButtonFormField<Vehicle>(
      value: _selectedVehicle,
      decoration: const InputDecoration(
        labelText: 'Selecciona tu Vehículo',
        border: OutlineInputBorder(),
        prefixIcon: Icon(Icons.directions_car),
      ),
      items: _vehicles.map((vehicle) {
        return DropdownMenuItem(
          value: vehicle,
          child: Text(
            '${vehicle.make} ${vehicle.model} (${vehicle.year}) - ${vehicle.plate}',
            overflow: TextOverflow.ellipsis,
          ),
        );
      }).toList(),
      onChanged: (value) {
        setState(() {
          _selectedVehicle = value;
        });
      },
      validator: (value) {
        if (value == null) {
          return 'Por favor selecciona un vehículo';
        }
        return null;
      },
    );
  }

  // Selector de Taller
  Widget _buildWorkshopSelector() {
    return InkWell(
      onTap: () async {
        // Navegar a la pantalla de búsqueda de talleres en modo selección
        final result = await context.push('/workshops?selectionMode=true');
        if (result != null && result is Map<String, dynamic>) {
          setState(() {
            _selectedWorkshopId = result['id'] as String;
            _selectedWorkshopName = result['name'] as String;
          });
        }
      },
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: 'Taller',
          border: const OutlineInputBorder(),
          prefixIcon: const Icon(Icons.build),
          errorText: _selectedWorkshopId == null ? 'Selecciona un taller' : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                _selectedWorkshopName ?? 'Toca para seleccionar un taller',
                style: TextStyle(
                  color: _selectedWorkshopName != null
                      ? Colors.black
                      : Colors.grey[600],
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const Icon(Icons.arrow_forward_ios, size: 16),
          ],
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
