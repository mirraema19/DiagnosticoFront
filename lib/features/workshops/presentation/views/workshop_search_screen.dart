import 'package:proyecto/core/services/service_locator.dart';
import 'package:proyecto/features/workshops/data/models/workshop_model.dart';
import 'package:proyecto/features/workshops/data/repositories/workshop_repository.dart';
import 'package:proyecto/features/workshops/presentation/widgets/workshop_list_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';

class WorkshopSearchScreen extends StatefulWidget {
  final bool selectionMode;

  const WorkshopSearchScreen({
    super.key,
    this.selectionMode = false,
  });

  @override
  State<WorkshopSearchScreen> createState() => _WorkshopSearchScreenState();
}

class _WorkshopSearchScreenState extends State<WorkshopSearchScreen> {
  final WorkshopRepository _repository = sl<WorkshopRepository>();
  late Future<List<Workshop>> _workshopsFuture;

  // Filtros
  double? _minRating;
  String? _specialtyType;

  @override
  void initState() {
    super.initState();
    _loadWorkshops();
  }

  void _loadWorkshops() {
    setState(() {
      _workshopsFuture = _repository.fetchWorkshops(
        minRating: _minRating,
        specialtyType: _specialtyType,
      );
    });
  }

  void _showFilterModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Filtrar por Calificación Mínima'),
              Slider(
                value: _minRating ?? 0,
                min: 0,
                max: 5,
                divisions: 5,
                label: (_minRating ?? 0).toString(),
                onChanged: (v) => setState(() => _minRating = v == 0 ? null : v),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  _loadWorkshops(); // Recargar con filtros
                },
                child: const Text('Aplicar'),
              )
            ],
          ),
        );
      },
    );
  }
  
  // ... (el resto del build es igual que tu archivo actual, solo asegúrate de usar _workshopsFuture)
  @override
  Widget build(BuildContext context) {
      // ... copia el build anterior
       return Scaffold(
      appBar: AppBar(
        title: Text(widget.selectionMode ? 'Seleccionar Taller' : 'Buscar Talleres'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Buscar por nombre o especialidad',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.filter_list),
                  onPressed: () => _showFilterModal(context),
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.grey.shade200,
              ),
            ),
          ),
          Expanded(
            child: FutureBuilder<List<Workshop>>(
              future: _workshopsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text('No se encontraron talleres.'));
                }

                final workshops = snapshot.data!;
                return ListView.builder(
                  padding: const EdgeInsets.only(bottom: 16),
                  itemCount: workshops.length,
                  itemBuilder: (context, index) {
                    final workshop = workshops[index];
                    return GestureDetector(
                      onTap: () {
                        if (widget.selectionMode) {
                          // Modo selección: retornar el taller seleccionado
                          context.pop({
                            'id': workshop.id,
                            'name': workshop.name,
                          });
                        } else {
                          // Modo normal: navegar al detalle
                          context.push('/workshops/details', extra: workshop);
                        }
                      },
                      child: WorkshopListItem(workshop: workshop)
                          .animate()
                          .fadeIn(delay: (100 * index).ms)
                          .slideX(begin: 0.2),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}