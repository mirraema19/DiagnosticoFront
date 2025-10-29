import 'package:flutter/material.dart';

class MaintenanceCard extends StatelessWidget {
  const MaintenanceCard({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.amber.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.amber.shade200),
      ),
      child: Row(
        children: [
          Icon(Icons.circle, color: Colors.amber.shade600, size: 12),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Próximo Mantenimiento',
                  style: textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  'Revisión de frenos recomendada en 500 km',
                  style: textTheme.bodyMedium?.copyWith(color: Colors.grey.shade800),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Chip(
            label: const Text('Próximo'),
            backgroundColor: Colors.amber.shade100,
            side: BorderSide.none,
          )
        ],
      ),
    );
  }
}