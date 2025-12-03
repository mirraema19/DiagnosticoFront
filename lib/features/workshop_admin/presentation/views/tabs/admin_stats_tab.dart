import 'package:flutter/material.dart';
import 'package:proyecto/core/services/service_locator.dart';
import 'package:proyecto/features/workshops/data/models/workshop_model.dart';
import 'package:proyecto/features/workshops/data/repositories/workshop_repository.dart';

class AdminStatsTab extends StatelessWidget {
  final List<Workshop> myWorkshops;
  const AdminStatsTab({super.key, required this.myWorkshops});

  @override
  Widget build(BuildContext context) {
    if (myWorkshops.isEmpty) return const Center(child: Text('Sin talleres.'));
    
    // Por simplicidad, mostramos estadísticas del primer taller
    final workshop = myWorkshops.first;

    return FutureBuilder<Map<String, dynamic>>(
      future: sl<WorkshopRepository>().getReviewStatistics(workshop.id),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
        if (snapshot.hasError) return const Center(child: Text('No hay suficientes datos para estadísticas.'));

        final data = snapshot.data!;
        
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              _StatCard('Calificación General', '${data['averageOverall']} ★', Icons.star, Colors.amber),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(child: _StatCard('Calidad', '${data['averageQuality']}', Icons.high_quality, Colors.blue)),
                  const SizedBox(width: 10),
                  Expanded(child: _StatCard('Precio', '${data['averagePrice']}', Icons.attach_money, Colors.green)),
                ],
              ),
              const SizedBox(height: 10),
              _StatCard('Total Reseñas', '${data['totalReviews']}', Icons.people, Colors.purple),
              const SizedBox(height: 20),
              const Text('Distribución de Sentimientos', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              _SentimentBar('Positivo', data['sentimentDistribution']['positive'], Colors.green),
              _SentimentBar('Neutral', data['sentimentDistribution']['neutral'], Colors.grey),
              _SentimentBar('Negativo', data['sentimentDistribution']['negative'], Colors.red),
            ],
          ),
        );
      },
    );
  }

  Widget _StatCard(String title, String value, IconData icon, Color color) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Icon(icon, size: 30, color: color),
            const SizedBox(height: 8),
            Text(value, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            Text(title, style: const TextStyle(color: Colors.grey)),
          ],
        ),
      ),
    );
  }

  Widget _SentimentBar(String label, int value, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          SizedBox(width: 80, child: Text(label)),
          Expanded(
            child: LinearProgressIndicator(
              value: value / 10.0, // Normalizado a algo visual
              color: color,
              backgroundColor: color.withOpacity(0.1),
              minHeight: 10,
            ),
          ),
          const SizedBox(width: 10),
          Text(value.toString()),
        ],
      ),
    );
  }
}