import 'package:flutter/material.dart';
import 'package:proyecto/features/diagnosis/data/models/workshop_recommendation_model.dart';

/// Widget para mostrar las recomendaciones de talleres del backend ML
class WorkshopRecommendationsWidget extends StatelessWidget {
  final List<WorkshopRecommendationModel> recommendations;
  final VoidCallback? onViewAllWorkshops;

  const WorkshopRecommendationsWidget({
    super.key,
    required this.recommendations,
    this.onViewAllWorkshops,
  });

  @override
  Widget build(BuildContext context) {
    if (recommendations.isEmpty) {
      return const SizedBox.shrink();
    }

    return Card(
      margin: const EdgeInsets.all(16),
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.build_circle,
                  color: Colors.blue,
                  size: 28,
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    'Talleres Recomendados',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                if (onViewAllWorkshops != null)
                  TextButton(
                    onPressed: onViewAllWorkshops,
                    child: const Text('Ver todos'),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            const Text(
              'Basado en Machine Learning y tu ubicación',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
            const Divider(height: 24),
            ...recommendations.map((workshop) => _buildWorkshopCard(context, workshop)),
          ],
        ),
      ),
    );
  }

  Widget _buildWorkshopCard(BuildContext context, WorkshopRecommendationModel workshop) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      child: InkWell(
        onTap: () {
          // TODO: Navegar al detalle del taller
          print('Tapped on workshop: ${workshop.workshopId}');
        },
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header con nombre y match score
              Row(
                children: [
                  Expanded(
                    child: Text(
                      workshop.workshopName,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  _buildMatchScoreBadge(workshop),
                ],
              ),
              const SizedBox(height: 8),

              // Match description
              Row(
                children: [
                  Text(
                    workshop.matchEmoji,
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    workshop.matchDescription,
                    style: TextStyle(
                      fontSize: 14,
                      color: _getMatchColor(workshop.matchScore),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Razones de recomendación
              ...workshop.reasons.map((reason) => Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(
                          Icons.check_circle,
                          size: 16,
                          color: Colors.green,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            reason,
                            style: const TextStyle(fontSize: 14),
                          ),
                        ),
                      ],
                    ),
                  )),

              // Información adicional (distancia y rating)
              if (workshop.distanceKm != null || workshop.rating != null)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Row(
                    children: [
                      if (workshop.distanceKm != null) ...[
                        const Icon(Icons.location_on, size: 16, color: Colors.grey),
                        const SizedBox(width: 4),
                        Text(
                          '${workshop.distanceKm!.toStringAsFixed(1)} km',
                          style: const TextStyle(fontSize: 13, color: Colors.grey),
                        ),
                        const SizedBox(width: 16),
                      ],
                      if (workshop.rating != null) ...[
                        const Icon(Icons.star, size: 16, color: Colors.amber),
                        const SizedBox(width: 4),
                        Text(
                          workshop.rating!.toStringAsFixed(1),
                          style: const TextStyle(fontSize: 13, color: Colors.grey),
                        ),
                      ],
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMatchScoreBadge(WorkshopRecommendationModel workshop) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: _getMatchColor(workshop.matchScore).withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _getMatchColor(workshop.matchScore),
          width: 1.5,
        ),
      ),
      child: Text(
        workshop.matchPercentage,
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.bold,
          color: _getMatchColor(workshop.matchScore),
        ),
      ),
    );
  }

  Color _getMatchColor(double score) {
    if (score >= 0.8) return Colors.green;
    if (score >= 0.6) return Colors.orange;
    return Colors.blue;
  }
}
