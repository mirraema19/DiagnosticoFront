import 'package:proyecto/features/garaje/presentation/data/models/vehicle_model.dart';
import 'package:proyecto/features/garaje/presentation/bloc/garage_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';

class EditVehicleScreen extends StatefulWidget {
  final Vehicle vehicle;
  const EditVehicleScreen({super.key, required this.vehicle});

  @override
  State<EditVehicleScreen> createState() => _EditVehicleScreenState();
}

class _EditVehicleScreenState extends State<EditVehicleScreen> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _makeController;
  late final TextEditingController _modelController;
  late final TextEditingController _yearController;
  late final TextEditingController _plateController;
  late final TextEditingController _mileageController;
  late final TextEditingController _imageUrlController;

  @override
  void initState() {
    super.initState();
    _makeController = TextEditingController(text: widget.vehicle.make);
    _modelController = TextEditingController(text: widget.vehicle.model);
    _yearController = TextEditingController(text: widget.vehicle.year.toString());
    _plateController = TextEditingController(text: widget.vehicle.plate);
    _mileageController = TextEditingController(text: widget.vehicle.mileage.toString());
    _imageUrlController = TextEditingController(text: widget.vehicle.imageUrl);
  }

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

  void _submitUpdate() {
    if (_formKey.currentState!.validate()) {
      final updatedVehicle = Vehicle(
        id: widget.vehicle.id,
        make: _makeController.text,
        model: _modelController.text,
        year: int.parse(_yearController.text),
        plate: _plateController.text,
        mileage: int.parse(_mileageController.text),
        imageUrl: _imageUrlController.text.isNotEmpty
            ? _imageUrlController.text
            : 'assets/images/car.png',
      );

      context.read<GarageBloc>().add(UpdateVehicle(updatedVehicle));
      
      // Regresamos a la lista principal
      context.go('/garage'); 
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vehículo actualizado correctamente')),
      );
    }
  }

  // --- NUEVA FUNCIÓN PARA ELIMINAR ---
  void _confirmDelete() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('¿Eliminar Vehículo?'),
          content: Text('¿Estás seguro de que quieres eliminar tu ${widget.vehicle.make} ${widget.vehicle.model}? Esta acción no se puede deshacer.'),
          actions: [
            TextButton(
              child: const Text('Cancelar'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: const Text('Eliminar', style: TextStyle(color: Colors.red)),
              onPressed: () {
                // 1. Disparamos el evento DELETE al BLoC
                context.read<GarageBloc>().add(DeleteVehicle(widget.vehicle.id));
                
                // 2. Cerramos el diálogo
                Navigator.of(context).pop();
                
                // 3. Navegamos de vuelta a la lista (Mi Garaje) usando .go para limpiar el stack
                context.go('/garage');

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Vehículo eliminado')),
                );
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Editar Vehículo'),
        actions: [
          // Opción extra: Botón de borrar también en la AppBar
          IconButton(
            icon: const Icon(Icons.delete_outline, color: Colors.red),
            onPressed: _confirmDelete,
          ),
        ],
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
                  decoration: const InputDecoration(labelText: 'Marca'),
                  validator: (value) => value!.isEmpty ? 'Campo requerido' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _modelController,
                  decoration: const InputDecoration(labelText: 'Modelo'),
                  validator: (value) => value!.isEmpty ? 'Campo requerido' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _yearController,
                  decoration: const InputDecoration(labelText: 'Año'),
                  keyboardType: TextInputType.number,
                  validator: (value) => value!.isEmpty ? 'Campo requerido' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _plateController,
                  decoration: const InputDecoration(labelText: 'Placa'),
                  textCapitalization: TextCapitalization.characters,
                  validator: (value) => value!.isEmpty ? 'Campo requerido' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _mileageController,
                  decoration: const InputDecoration(labelText: 'Kilometraje'),
                  keyboardType: TextInputType.number,
                  validator: (value) => value!.isEmpty ? 'Campo requerido' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _imageUrlController,
                  decoration: const InputDecoration(labelText: 'URL de la Imagen (Opcional)'),
                ),
                const SizedBox(height: 32),
                
                // Botón de Actualizar
                ElevatedButton(
                  onPressed: _submitUpdate,
                  child: const Text('ACTUALIZAR DATOS'),
                ),

                const SizedBox(height: 24),
                const Divider(),
                const SizedBox(height: 16),

                // --- NUEVO BOTÓN DE ELIMINAR (Zona de peligro) ---
                OutlinedButton.icon(
                  onPressed: _confirmDelete,
                  icon: const Icon(Icons.delete_forever),
                  label: const Text('ELIMINAR VEHÍCULO'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.red,
                    side: const BorderSide(color: Colors.red),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}