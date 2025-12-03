import 'package:flutter/material.dart';
import 'package:proyecto/features/diagnosis/data/models/urgency_model.dart';

class UrgencyIndicator extends StatelessWidget {
  final UrgencyModel urgency;

  const UrgencyIndicator({
    super.key,
    required this.urgency,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: urgency.level.color.withOpacity(0.1),
        border: Border.all(color: urgency.level.color, width: 2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                urgency.level.icon,
                color: urgency.level.color,
                size: 28,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Nivel de Urgencia: ${urgency.level.displayName}',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: urgency.level.color,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      urgency.description,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(
                urgency.safeToDriver ? Icons.check_circle : Icons.cancel,
                color: urgency.safeToDriver ? Colors.green : Colors.red,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                urgency.safeToDriver
                    ? 'Seguro para conducir'
                    : 'NO conducir',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: urgency.safeToDriver ? Colors.green : Colors.red,
                ),
              ),
            ],
          ),
          if (urgency.maxMileageRecommended != null) ...[
            const SizedBox(height: 8),
            Text(
              'Kilometraje máximo recomendado: ${urgency.maxMileageRecommended} km',
              style: const TextStyle(
                fontSize: 13,
                color: Colors.black54,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
