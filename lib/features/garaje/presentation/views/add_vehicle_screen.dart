import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AddVehicleScreen extends StatelessWidget {
  const AddVehicleScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Añadir Vehículo'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextFormField(decoration: const InputDecoration(labelText: 'Marca')),
            const SizedBox(height: 16),
            TextFormField(decoration: const InputDecoration(labelText: 'Modelo')),
            const SizedBox(height: 16),
            TextFormField(
              decoration: const InputDecoration(labelText: 'Año'),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            TextFormField(
              decoration: const InputDecoration(labelText: 'Kilometraje'),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () {
                // Lógica para añadir vehículo
                context.pop();
              },
              child: const Text('GUARDAR VEHÍCULO'),
            ),
          ],
        ),
      ),
    );
  }
}