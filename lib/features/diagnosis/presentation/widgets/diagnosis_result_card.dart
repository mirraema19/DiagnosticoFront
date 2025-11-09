import 'package:proyecto/features/diagnosis/presentation/bloc/diagnosis_bloc.dart';
import 'package:proyecto/features/workshops/presentation/widgets/workshop_list_item.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class DiagnosisResultCard extends StatelessWidget {
  final DiagnosisResult result;
  const DiagnosisResultCard({super.key, required this.result});

  // Helper para obtener el color del semáforo
  Color _getUrgencyColor(UrgencyLevel level) {
    switch (level) {
      case UrgencyLevel.urgent: return Colors.red;
      case UrgencyLevel.soon: return Colors.amber;
      case UrgencyLevel.programmable: return Colors.green;
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- Nivel de Urgencia ---
            Row(
              children: [
                Icon(Icons.circle, color: _getUrgencyColor(result.urgency), size: 16),
                const SizedBox(width: 8),
                Text(
                  'Nivel de Urgencia: ${result.urgency.name.toUpperCase()}',
                  style: textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: _getUrgencyColor(result.urgency),
                  ),
                ),
              ],
            ),
            const Divider(height: 24),
            // --- Categoría y Costo ---
            _buildInfoRow(context, 'Categoría del Problema:', result.problemCategory),
            const SizedBox(height: 8),
            _buildInfoRow(context, 'Costo Estimado:', result.costEstimate),
            const Divider(height: 24),
            // --- Talleres Recomendados ---
            Text(
              'Talleres Especializados Recomendados:',
              style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            ...result.recommendedWorkshops.map((workshop) => Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: GestureDetector(
                onTap: () => context.push('/workshops/details', extra: workshop),
                child: WorkshopListItem(workshop: workshop),
              ),
            )),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(BuildContext context, String title, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        Text(value),
      ],
    );
  }
}