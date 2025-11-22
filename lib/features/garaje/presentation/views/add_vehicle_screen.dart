import 'dart:math';
import 'package:proyecto/features/garaje/presentation/data/models/vehicle_model.dart';
import 'package:proyecto/features/garaje/presentation/bloc/garage_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';

// --- CORRECCIÓN: La clase Wrapper ha sido eliminada ---

class AddVehicleScreen extends StatefulWidget {
  const AddVehicleScreen({super.key});

  @override
  State<AddVehicleScreen> createState() => _AddVehicleScreenState();
}

class _AddVehicleScreenState extends State<AddVehicleScreen> {
  final _formKey = GlobalKey<FormState>();
  final _makeController = TextEditingController();
  final _modelController = TextEditingController();
  final _yearController = TextEditingController();
  final _plateController = TextEditingController();
  final _mileageController = TextEditingController();
  final _imageUrlController = TextEditingController();

  @override
  void dispose() {
    _makeController.dispose();
    _modelController.dispose();
    _yearController.dispose();
    _plateController.dispose();
    _mileageController.dispose();
    _imageUrlController.dispose();
    super.dispose();
  }

  void _submitVehicle() {
    if (_formKey.currentState!.validate()) {
      final newVehicle = Vehicle(
        id: Random().nextInt(10000).toString(),
        make: _makeController.text,
        model: _modelController.text,
        year: int.parse(_yearController.text),
        plate: _plateController.text,
        mileage: int.parse(_mileageController.text),
        imageUrl: _imageUrlController.text.isNotEmpty
            ? _imageUrlController.text
            : 'assets/images/civic.jpg',
      );
      // Ahora context.read<GarageBloc>() funcionará porque el BLoC es global
      context.read<GarageBloc>().add(AddVehicle(newVehicle));
      context.pop();
    }
  }

   @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Añadir Vehículo'),
      ),
      body: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextFormField(
                  controller: _makeController,
                  decoration: const InputDecoration(
                    label: Text('Marca'),
                    prefixIcon: Icon(Icons.factory_outlined),
                  ),
                  validator: (value) => value!.isEmpty ? 'Campo requerido' : null,
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _modelController,
                  decoration: const InputDecoration(
                    label: Text('Modelo'),
                    prefixIcon: Icon(Icons.directions_car_outlined),
                  ),
                  validator: (value) => value!.isEmpty ? 'Campo requerido' : null,
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _yearController,
                  decoration: const InputDecoration(
                    label: Text('Año'),
                    prefixIcon: Icon(Icons.calendar_today_outlined),
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) => value!.isEmpty ? 'Campo requerido' : null,
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _plateController,
                  decoration: const InputDecoration(
                    label: Text('Placa'),
                    prefixIcon: Icon(Icons.pin_outlined),
                  ),
                  textCapitalization: TextCapitalization.characters,
                  validator: (value) => value!.isEmpty ? 'Campo requerido' : null,
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _mileageController,
                  decoration: const InputDecoration(
                    label: Text('Kilometraje'),
                    prefixIcon: Icon(Icons.speed_outlined),
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) => value!.isEmpty ? 'Campo requerido' : null,
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _imageUrlController,
                  decoration: const InputDecoration(
                    label: Text('URL de la Imagen (Opcional)'),
                    prefixIcon: Icon(Icons.image_outlined),
                  ),
                ),
                const SizedBox(height: 48),
                ElevatedButton(
                  onPressed: _submitVehicle,
                  child: const Text('GUARDAR VEHÍCULO'),
                ),
              ]
                  .animate(interval: 100.ms)
                  .fadeIn(duration: 400.ms, delay: 200.ms)
                  .slideY(begin: 0.5, end: 0.0),
            ),
          ),
        ),
      ),
    );
  }
}