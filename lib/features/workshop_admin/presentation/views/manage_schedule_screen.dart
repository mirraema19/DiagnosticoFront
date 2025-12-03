import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:proyecto/core/services/service_locator.dart';
import 'package:proyecto/features/workshop_admin/presentation/bloc/admin_workshop_bloc.dart';
import 'package:proyecto/features/workshops/data/repositories/workshop_repository.dart';

class ManageScheduleScreen extends StatefulWidget {
  final String workshopId;
  const ManageScheduleScreen({super.key, required this.workshopId});

  @override
  State<ManageScheduleScreen> createState() => _ManageScheduleScreenState();
}

class _ManageScheduleScreenState extends State<ManageScheduleScreen> {
  List<Map<String, dynamic>> _schedule = [];
  bool _isLoading = true;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _loadSchedule();
  }

  Future<void> _loadSchedule() async {
    try {
      final repository = sl<WorkshopRepository>();
      final schedules = await repository.getSchedule(widget.workshopId);

      setState(() {
        if (schedules.isNotEmpty) {
          // Cargar horarios existentes del backend
          _schedule = schedules.map((s) => s.toJson()).toList();
        } else {
          // Si no hay horarios, usar valores por defecto
          _schedule = _getDefaultSchedule();
        }
        _isLoading = false;
      });
    } catch (e) {
      // Si hay error, usar horarios por defecto
      setState(() {
        _schedule = _getDefaultSchedule();
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al cargar horarios: $e')),
      );
    }
  }

  List<Map<String, dynamic>> _getDefaultSchedule() {
    return [
      {'dayOfWeek': 'MONDAY', 'openTime': '09:00', 'closeTime': '18:00', 'isClosed': false},
      {'dayOfWeek': 'TUESDAY', 'openTime': '09:00', 'closeTime': '18:00', 'isClosed': false},
      {'dayOfWeek': 'WEDNESDAY', 'openTime': '09:00', 'closeTime': '18:00', 'isClosed': false},
      {'dayOfWeek': 'THURSDAY', 'openTime': '09:00', 'closeTime': '18:00', 'isClosed': false},
      {'dayOfWeek': 'FRIDAY', 'openTime': '09:00', 'closeTime': '18:00', 'isClosed': false},
      {'dayOfWeek': 'SATURDAY', 'openTime': '09:00', 'closeTime': '14:00', 'isClosed': false},
      {'dayOfWeek': 'SUNDAY', 'openTime': '00:00', 'closeTime': '00:00', 'isClosed': true},
    ];
  }

  Future<void> _save() async {
    setState(() {
      _isSaving = true;
    });

    try {
      context.read<AdminWorkshopBloc>().add(UpdateScheduleEvent(widget.workshopId, _schedule));

      // Esperar un poco para que el bloc procese el evento
      await Future.delayed(const Duration(milliseconds: 500));

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Horario guardado exitosamente'),
            backgroundColor: Colors.green,
          ),
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al guardar: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  String _getDayName(String day) {
    final names = {
      'MONDAY': 'Lunes',
      'TUESDAY': 'Martes',
      'WEDNESDAY': 'Miércoles',
      'THURSDAY': 'Jueves',
      'FRIDAY': 'Viernes',
      'SATURDAY': 'Sábado',
      'SUNDAY': 'Domingo',
    };
    return names[day] ?? day;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Horarios de Atención'),
        backgroundColor: Colors.blue,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _schedule.length,
              itemBuilder: (context, index) {
                final day = _schedule[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: SwitchListTile(
                    title: Text(
                      _getDayName(day['dayOfWeek']),
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: day['isClosed']
                        ? const Text(
                            'Cerrado',
                            style: TextStyle(color: Colors.red),
                          )
                        : Text(
                            '${day['openTime']} - ${day['closeTime']}',
                            style: const TextStyle(color: Colors.green),
                          ),
                    value: !day['isClosed'],
                    onChanged: _isSaving
                        ? null
                        : (isOpen) {
                            setState(() {
                              day['isClosed'] = !isOpen;
                            });
                          },
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _isSaving ? null : _save,
        backgroundColor: _isSaving ? Colors.grey : Colors.blue,
        icon: _isSaving
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : const Icon(Icons.save),
        label: Text(_isSaving ? 'Guardando...' : 'Guardar'),
      ),
    );
  }
}