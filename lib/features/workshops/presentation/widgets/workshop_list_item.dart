import 'package:proyecto/features/workshops/data/models/workshop_model.dart';
import 'package:flutter/material.dart';

class WorkshopListItem extends StatelessWidget {
  final Workshop workshop;

  const WorkshopListItem({super.key, required this.workshop});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    // --- CORRECCIÓN: Se eliminó el widget InkWell que envolvía el Padding ---
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- Imagen del Taller ---
            ClipRRect(
              borderRadius: BorderRadius.circular(8.0),
              child: Image.asset(
                workshop.imageUrl,
                width: 80,
                height: 80,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) =>
                    const Icon(Icons.business, size: 80),
              ),
            ),
            const SizedBox(width: 16),
            // --- Información del Taller ---
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    workshop.name,
                    style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.star, color: Colors.amber, size: 16),
                      const SizedBox(width: 4),
                      Text(
                        '${workshop.rating}',
                        style: textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        ' (${workshop.reviewCount} reseñas)',
                        style: textTheme.bodyMedium?.copyWith(color: Colors.grey.shade600),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.location_on, color: Colors.grey.shade600, size: 16),
                      const SizedBox(width: 4),
                      Text(
                        workshop.address,
                        style: textTheme.bodyMedium?.copyWith(color: Colors.grey.shade600),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  // --- Tags ---
                  Wrap(
                    spacing: 6.0,
                    runSpacing: 4.0,
                    children: workshop.tags
                        .map((tag) => Chip(
                              label: Text(tag),
                              padding: EdgeInsets.zero,
                              labelStyle: textTheme.labelSmall,
                              visualDensity: VisualDensity.compact,
                            ))
                        .toList(),
                  ),
                ],
              ),
            ),
            // --- Distancia y Flecha ---
            Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                const Icon(Icons.chevron_right, color: Colors.grey),
                const SizedBox(height: 40),
                Text(
                  '${workshop.distance} km',
                  style: textTheme.bodySmall?.copyWith(color: Colors.grey.shade700),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}