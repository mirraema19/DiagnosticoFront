import 'package:flutter/material.dart';

class VehicleSummaryCard extends StatelessWidget {
  final Map<String, String> vehicleData;

  const VehicleSummaryCard({
    super.key,
    required this.vehicleData,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Card(
      clipBehavior: Clip.antiAlias, // Para que la imagen respete los bordes redondeados
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Imagen del vehículo
          Container(
            color: Colors.grey.shade200,
            padding: const EdgeInsets.all(16.0),
            child: Image.asset(
              'assets/images/civic.jpg',
              fit: BoxFit.cover,
            ),
          ),
          // Información del vehículo
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${vehicleData['make']} ${vehicleData['model']} ${vehicleData['year']}',
                  style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  '45,230 km recorridos', // Dato simulado como en la imagen
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