import 'package:proyecto/features/workshops/data/models/workshop_model.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class WorkshopDetailScreen extends StatelessWidget {
  final Workshop workshop;
  const WorkshopDetailScreen({super.key, required this.workshop});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(workshop.name),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.asset(
              workshop.imageUrl,
              height: 250,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(workshop.name, style: textTheme.headlineSmall),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.star, color: Colors.amber, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        '${workshop.rating} (${workshop.reviewCount} reseñas)',
                        style: textTheme.bodyLarge,
                      ),
                    ],
                  ),
                  const Divider(height: 32),
                  _buildInfoRow(
                    context,
                    icon: Icons.location_on_outlined,
                    title: 'Dirección',
                    subtitle: workshop.address,
                  ),
                  _buildInfoRow(
                    context,
                    icon: Icons.phone_outlined,
                    title: 'Teléfono',
                    subtitle: '+123 456 7890', // Dato simulado
                  ),
                   _buildInfoRow(
                    context,
                    icon: Icons.access_time_outlined,
                    title: 'Horario',
                    subtitle: 'Lunes a Viernes, 9am - 6pm', // Dato simulado
                  ),
                  const Divider(height: 32),
                  Text('Especialidades', style: textTheme.titleMedium),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8.0,
                    children: workshop.tags.map((tag) => Chip(label: Text(tag))).toList(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          context.push('/appointments/add');
        },
        label: const Text('Agendar Cita'),
        icon: const Icon(Icons.calendar_today),
      ),
    );
  }

  Widget _buildInfoRow(BuildContext context, {required IconData icon, required String title, required String subtitle}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, color: Colors.grey.shade600),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: Theme.of(context).textTheme.bodyLarge),
              Text(subtitle, style: TextStyle(color: Colors.grey.shade700)),
            ],
          )
        ],
      ),
    );
  }
}