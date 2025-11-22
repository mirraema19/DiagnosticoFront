import 'package:proyecto/features/garaje/presentation/data/models/vehicle_model.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';


class VehicleDetailScreen extends StatelessWidget {
  final Vehicle vehicle;
  const VehicleDetailScreen({super.key, required this.vehicle});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${vehicle.make} ${vehicle.model}'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            onPressed: () {
              context.push('/garage/edit', extra: vehicle);
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          // --- CORRECCIÓN AQUÍ ---
          // Se corrigió el nombre de la propiedad
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Intentamos mostrar la imagen de red, si falla, mostramos una imagen local
            Image.network(
              vehicle.imageUrl,
              height: 250,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                // Si la URL falla, intentamos mostrar un asset local
                return Image.asset(
                  'assets/images/car.png', // Tu imagen de fallback
                  height: 250,
                  fit: BoxFit.cover,
                  // Si incluso el asset local falla, mostramos un ícono
                  errorBuilder: (context, error, stackTrace) =>
                      const SizedBox(height: 250, child: Icon(Icons.directions_car, size: 80, color: Colors.grey)),
                );
              },
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Column(
                    children: [
                      ListTile(
                        leading: const Icon(Icons.pin_outlined),
                        title: const Text('Placa'),
                        trailing: Text(
                          vehicle.plate,
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                      ),
                      const Divider(indent: 16, endIndent: 16),
                      ListTile(
                        leading: const Icon(Icons.calendar_today_outlined),
                        title: const Text('Año'),
                        trailing: Text(
                          vehicle.year.toString(),
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                      ),
                      const Divider(indent: 16, endIndent: 16),
                      ListTile(
                        leading: const Icon(Icons.speed_outlined),
                        title: const Text('Kilometraje'),
                        trailing: Text(
                          '${vehicle.mileage} km',
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}