import 'package:proyecto/features/workshops/data/models/workshop_model.dart';
import 'package:proyecto/features/workshops/data/repositories/workshop_repository.dart';
import 'package:proyecto/features/workshops/presentation/widgets/workshop_list_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';

class WorkshopSearchScreen extends StatefulWidget {
  const WorkshopSearchScreen({super.key});

  @override
  State<WorkshopSearchScreen> createState() => _WorkshopSearchScreenState();
}

class _WorkshopSearchScreenState extends State<WorkshopSearchScreen> {
  final WorkshopRepository _repository = WorkshopRepository();
  late final Future<List<Workshop>> _workshopsFuture;

  @override
  void initState() {
    super.initState();
    _workshopsFuture = _repository.fetchWorkshops();
  }

  void _showFilterModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('Filtros', style: Theme.of(context).textTheme.headlineSmall),
              const SizedBox(height: 20),
              const Text('Ordenar por:'),
              const Wrap(
                spacing: 8.0,
                children: [
                  Chip(label: Text('Relevancia')),
                  Chip(label: Text('Distancia')),
                  Chip(label: Text('Calificación')),
                ],
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Aplicar Filtros'),
              )
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Buscar Talleres'),
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
                    // --- ESTE GESTUREDETECTOR ES EL ÚNICO RESPONSABLE DE LA NAVEGACIÓN ---
                    return GestureDetector(
                      onTap: () {
                        context.push('/workshops/details', extra: workshop);
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