import 'package:flutter/material.dart';
import 'package:proyecto/features/diagnosis/data/models/classification_model.dart';
import 'package:proyecto/features/diagnosis/data/models/urgency_model.dart';
import 'package:proyecto/features/diagnosis/data/models/cost_estimate_model.dart';
import 'package:proyecto/features/diagnosis/data/models/workshop_recommendation_model.dart';

/// Widget para mostrar el resultado completo del diagnóstico
/// Incluye clasificación, urgencia, costos y talleres recomendados
class DiagnosisResultCard extends StatelessWidget {
  final ClassificationModel? classification;
  final UrgencyModel? urgency;
  final CostEstimateModel? costEstimate;
  final List<WorkshopRecommendationModel>? recommendedWorkshops;

  const DiagnosisResultCard({
    super.key,
    this.classification,
    this.urgency,
    this.costEstimate,
    this.recommendedWorkshops,
  });

  @override
  Widget build(BuildContext context) {
    // Si no hay datos, no mostrar nada
    if (classification == null && urgency == null && costEstimate == null) {
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
            // Header
            const Row(
              children: [
                Icon(
                  Icons.analytics,
                  color: Colors.blue,
                  size: 28,
                ),
                SizedBox(width: 12),
                Text(
                  'Resultado del Diagnóstico',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const Divider(height: 24),

            // Clasificación
            if (classification != null) ...[
              _buildSection(
                context,
                icon: Icons.category,
                title: 'Clasificación',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildInfoRow(
                      'Categoría',
                      classification!.category.displayName,
                    ),
                    if (classification!.subcategory != null)
                      _buildInfoRow(
                        'Subcategoría',
                        classification!.subcategory!,
                      ),
                    _buildInfoRow(
                      'Confianza',
                      '${(classification!.confidenceScore * 100).toStringAsFixed(0)}%',
                    ),
                    if (classification!.symptoms.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      const Text(
                        'Síntomas detectados:',
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 4),
                      ...classification!.symptoms.map((symptom) => Padding(
                            padding: const EdgeInsets.only(left: 8, top: 2),
                            child: Row(
                              children: [
                                const Icon(Icons.fiber_manual_record,
                                    size: 8, color: Colors.grey),
                                const SizedBox(width: 8),
                                Expanded(child: Text(symptom)),
                              ],
                            ),
                          )),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],

            // Urgencia
            if (urgency != null) ...[
              _buildSection(
                context,
                icon: Icons.warning,
                title: 'Nivel de Urgencia',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.circle,
                          color: _getUrgencyColor(urgency!.level),
                          size: 16,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          urgency!.level.displayName,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: _getUrgencyColor(urgency!.level),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(urgency!.description),
                    const SizedBox(height: 8),
                    _buildInfoRow(
                      '¿Seguro conducir?',
                      urgency!.safeToDriver ? 'Sí' : 'No',
                    ),
                    if (urgency!.maxMileageRecommended != null)
                      _buildInfoRow(
                        'Kilometraje máximo',
                        '${urgency!.maxMileageRecommended} km',
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],

            // Costo estimado
            if (costEstimate != null) ...[
              _buildSection(
                context,
                icon: Icons.attach_money,
                title: 'Estimación de Costos',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Rango estimado:',
                          style: TextStyle(fontWeight: FontWeight.w500),
                        ),
                        Text(
                          '\$${costEstimate!.minCost.toStringAsFixed(0)} - \$${costEstimate!.maxCost.toStringAsFixed(0)} ${costEstimate!.currency}',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _buildInfoRow(
                      'Piezas',
                      '\$${costEstimate!.breakdown.partsMin.toStringAsFixed(0)} - \$${costEstimate!.breakdown.partsMax.toStringAsFixed(0)}',
                    ),
                    _buildInfoRow(
                      'Mano de obra',
                      '\$${costEstimate!.breakdown.laborMin.toStringAsFixed(0)} - \$${costEstimate!.breakdown.laborMax.toStringAsFixed(0)}',
                    ),
                    const SizedBox(height: 8),
                    Text(
                      costEstimate!.disclaimer,
                      style: const TextStyle(
                        fontSize: 12,
                        fontStyle: FontStyle.italic,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
            ],

            // Talleres Recomendados
            if (recommendedWorkshops != null && recommendedWorkshops!.isNotEmpty) ...[
              const SizedBox(height: 16),
              _buildSection(
                context,
                icon: Icons.store,
                title: 'Talleres Recomendados',
                child: Column(
                  children: recommendedWorkshops!.map((workshop) => Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                workshop.workshopName,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                ),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.blue.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                workshop.matchPercentage,
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blue,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          workshop.matchDescription, // 'Excelente coincidencia'
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey[700],
                          ),
                        ),
                        const SizedBox(height: 8),
                        if (workshop.distanceKm != null || workshop.rating != null)
                          Row(
                            children: [
                              if (workshop.distanceKm != null) ...[
                                const Icon(Icons.location_on, size: 14, color: Colors.grey),
                                const SizedBox(width: 4),
                                Text(
                                  '${workshop.distanceKm!.toStringAsFixed(1)} km',
                                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                                ),
                                const SizedBox(width: 12),
                              ],
                              if (workshop.rating != null) ...[
                                const Icon(Icons.star, size: 14, color: Colors.amber),
                                const SizedBox(width: 4),
                                Text(
                                  workshop.rating!.toStringAsFixed(1),
                                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                                ),
                              ],
                            ],
                          ),
                      ],
                    ),
                  )).toList(),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSection(
    BuildContext context, {
    required IconData icon,
    required String title,
    required Widget child,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 20, color: Colors.blue),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.grey,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Color _getUrgencyColor(UrgencyLevel level) {
    switch (level) {
      case UrgencyLevel.CRITICAL:
        return Colors.red;
      case UrgencyLevel.HIGH:
        return Colors.orange;
      case UrgencyLevel.MEDIUM:
        return Colors.amber;
      case UrgencyLevel.LOW:
        return Colors.green;
    }
  }
}