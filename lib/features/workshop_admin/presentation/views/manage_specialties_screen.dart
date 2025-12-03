import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:proyecto/core/services/service_locator.dart';
import 'package:proyecto/features/workshop_admin/presentation/bloc/admin_workshop_bloc.dart';
import 'package:proyecto/features/workshops/data/repositories/workshop_repository.dart';
import 'package:proyecto/features/workshops/data/models/specialty_model.dart';

class ManageSpecialtiesScreen extends StatefulWidget {
  final String workshopId;
  const ManageSpecialtiesScreen({super.key, required this.workshopId});

  @override
  State<ManageSpecialtiesScreen> createState() => _ManageSpecialtiesScreenState();
}

class _ManageSpecialtiesScreenState extends State<ManageSpecialtiesScreen> {
  String _selectedSpecialty = 'ENGINE';
  List<WorkshopSpecialty> _specialties = [];
  bool _isLoading = true;
  bool _isAdding = false;

  // Lista completa de especialidades disponibles del backend
  final List<String> _allSpecialtyTypes = [
    'ENGINE',
    'TRANSMISSION',
    'BRAKES',
    'ELECTRICAL',
    'AIR_CONDITIONING',
    'SUSPENSION',
    'BODYWORK',
    'PAINTING',
    'ALIGNMENT',
    'DIAGNOSTICS',
    'TIRE_SERVICE',
    'OIL_CHANGE',
    'GENERAL_MAINTENANCE',
  ];

  @override
  void initState() {
    super.initState();
    _loadSpecialties();
  }

  Future<void> _loadSpecialties() async {
    setState(() => _isLoading = true);
    try {
      final repository = sl<WorkshopRepository>();
      final specialties = await repository.getSpecialties(widget.workshopId);

      if (mounted) {
        setState(() {
          _specialties = specialties;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al cargar especialidades: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // Helper para obtener el nombre en español
  String _getDisplayName(String specialty) {
    switch (specialty) {
      case 'ENGINE':
        return 'Motor';
      case 'TRANSMISSION':
        return 'Transmisión';
      case 'BRAKES':
        return 'Frenos';
      case 'ELECTRICAL':
        return 'Sistema Eléctrico';
      case 'AIR_CONDITIONING':
        return 'Aire Acondicionado';
      case 'SUSPENSION':
        return 'Suspensión';
      case 'BODYWORK':
        return 'Carrocería';
      case 'PAINTING':
        return 'Pintura';
      case 'ALIGNMENT':
        return 'Alineación';
      case 'DIAGNOSTICS':
        return 'Diagnóstico';
      case 'TIRE_SERVICE':
        return 'Servicio de Llantas';
      case 'OIL_CHANGE':
        return 'Cambio de Aceite';
      case 'GENERAL_MAINTENANCE':
        return 'Mantenimiento General';
      default:
        return specialty;
    }
  }

  // Obtener especialidades que aún no están agregadas
  List<String> get _availableSpecialties {
    final existingTypes = _specialties.map((s) => s.specialtyType.name).toSet();
    return _allSpecialtyTypes.where((type) => !existingTypes.contains(type)).toList();
  }

  Future<void> _addSpecialty() async {
    setState(() => _isAdding = true);

    try {
      context.read<AdminWorkshopBloc>().add(AddSpecialtyEvent(
        widget.workshopId,
        {'specialtyType': _selectedSpecialty},
      ));

      // Esperar un poco para que el bloc procese
      await Future.delayed(const Duration(milliseconds: 500));

      // Recargar la lista de especialidades
      await _loadSpecialties();

      if (mounted) {
        setState(() => _isAdding = false);

        // Actualizar el dropdown a la primera especialidad disponible
        final available = _availableSpecialties;
        if (available.isNotEmpty) {
          setState(() => _selectedSpecialty = available.first);
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isAdding = false);
      }
    }
  }

  Future<void> _deleteSpecialty(WorkshopSpecialty specialty) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar eliminación'),
        content: Text('¿Estás seguro de eliminar la especialidad "${specialty.specialtyTypeName}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );

    if (confirm == true && mounted) {
      try {
        context.read<AdminWorkshopBloc>().add(
          DeleteSpecialtyEvent(widget.workshopId, specialty.id)
        );

        // Esperar un poco para que el bloc procese
        await Future.delayed(const Duration(milliseconds: 500));

        // Recargar la lista
        await _loadSpecialties();
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error al eliminar: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AdminWorkshopBloc, AdminWorkshopState>(
      listener: (context, state) {
        if (state is AdminOperationSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.green,
            ),
          );
        } else if (state is AdminError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 4),
            ),
          );
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Gestionar Especialidades'),
          backgroundColor: Colors.blue,
        ),
        body: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : Column(
                children: [
                  // Sección: Especialidades actuales
                  Expanded(
                    child: _specialties.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.build_circle_outlined,
                                  size: 80,
                                  color: Colors.grey[400],
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'No hay especialidades agregadas',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.grey[600],
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Agrega tu primera especialidad abajo',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey[500],
                                  ),
                                ),
                              ],
                            ),
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.all(16),
                            itemCount: _specialties.length,
                            itemBuilder: (context, index) {
                              final specialty = _specialties[index];
                              return Card(
                                margin: const EdgeInsets.only(bottom: 12),
                                child: ListTile(
                                  leading: const CircleAvatar(
                                    backgroundColor: Colors.blue,
                                    child: Icon(
                                      Icons.build,
                                      color: Colors.white,
                                    ),
                                  ),
                                  title: Text(
                                    specialty.specialtyTypeName,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                  subtitle: specialty.description != null
                                      ? Text(specialty.description!)
                                      : null,
                                  trailing: IconButton(
                                    icon: const Icon(
                                      Icons.delete,
                                      color: Colors.red,
                                    ),
                                    onPressed: () => _deleteSpecialty(specialty),
                                  ),
                                ),
                              );
                            },
                          ),
                  ),

                  // Sección: Agregar nueva especialidad
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      border: Border(
                        top: BorderSide(color: Colors.grey[300]!),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Agregar nueva especialidad',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        if (_availableSpecialties.isEmpty)
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.green[50],
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.green),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.check_circle, color: Colors.green[700]),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    'Has agregado todas las especialidades disponibles',
                                    style: TextStyle(color: Colors.green[700]),
                                  ),
                                ),
                              ],
                            ),
                          )
                        else
                          Column(
                            children: [
                              DropdownButtonFormField<String>(
                                initialValue: _availableSpecialties.contains(_selectedSpecialty)
                                    ? _selectedSpecialty
                                    : _availableSpecialties.first,
                                items: _availableSpecialties.map((s) => DropdownMenuItem(
                                  value: s,
                                  child: Text(_getDisplayName(s)),
                                )).toList(),
                                onChanged: _isAdding
                                    ? null
                                    : (v) => setState(() => _selectedSpecialty = v!),
                                decoration: const InputDecoration(
                                  labelText: 'Seleccionar Especialidad',
                                  border: OutlineInputBorder(),
                                  filled: true,
                                  fillColor: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 12),
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton.icon(
                                  onPressed: _isAdding ? null : _addSpecialty,
                                  icon: _isAdding
                                      ? const SizedBox(
                                          width: 20,
                                          height: 20,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            color: Colors.white,
                                          ),
                                        )
                                      : const Icon(Icons.add),
                                  label: Text(_isAdding ? 'Agregando...' : 'Agregar Especialidad'),
                                  style: ElevatedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(vertical: 16),
                                    backgroundColor: Colors.blue,
                                    foregroundColor: Colors.white,
                                  ),
                                ),
                              ),
                            ],
                          ),
                      ],
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}