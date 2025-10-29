import 'package:proyecto/features/garaje/presentation/data/models/vehicle_model.dart';
import 'package:flutter/material.dart';

// Este widget se usa en la pantalla de INICIO (el dashboard)
class VehicleSummaryCard extends StatelessWidget {
  final Vehicle vehicle;

  const VehicleSummaryCard({
    super.key,
    required this.vehicle,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Card(
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            color: Colors.grey.shade200,
            width: double.infinity,
            height: 200,
            child: Image.asset(
              vehicle.imageUrl,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return const Center(child: Icon(Icons.image_not_supported_outlined, size: 50, color: Colors.grey));
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${vehicle.make} ${vehicle.model} ${vehicle.year}',
                  style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  '${vehicle.mileage} km recorridos',
                  style: textTheme.bodyMedium?.copyWith(color: Colors.grey.shade700),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}