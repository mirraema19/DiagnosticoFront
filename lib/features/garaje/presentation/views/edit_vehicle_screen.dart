import 'package:proyecto/features/garaje/presentation/data/models/vehicle_model.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class EditVehicleScreen extends StatefulWidget {
  final Vehicle vehicle;
  const EditVehicleScreen({super.key, required this.vehicle});

  @override
  State<EditVehicleScreen> createState() => _EditVehicleScreenState();
}

class _EditVehicleScreenState extends State<EditVehicleScreen> {
  late final TextEditingController _mileageController;

  @override
  void initState() {
    super.initState();
    _mileageController = TextEditingController(text: widget.vehicle.mileage.toString());
  }

  @override
  void dispose() {
    _mileageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Editar Vehículo'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextFormField(
              initialValue: widget.vehicle.make,
              decoration: const InputDecoration(labelText: 'Marca'),
            ),
            const SizedBox(height: 16),
            TextFormField(
              initialValue: widget.vehicle.model,
              decoration: const InputDecoration(labelText: 'Modelo'),
            ),
            const SizedBox(height: 16),
            TextFormField(
              initialValue: widget.vehicle.year.toString(),
              decoration: const InputDecoration(labelText: 'Año'),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _mileageController,
              decoration: const InputDecoration(labelText: 'Kilometraje'),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () {
                // Lógica para editar/guardar
                context.pop();
              },
              child: const Text('ACTUALIZAR DATOS'),
            ),
          ],
        ),
      ),
    );
  }
}