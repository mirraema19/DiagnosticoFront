import 'package:proyecto/features/garaje/presentation/data/models/vehicle_model.dart';
import 'package:proyecto/features/garaje/presentation/bloc/garage_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class EditVehicleScreen extends StatefulWidget {
  final Vehicle vehicle;
  const EditVehicleScreen({super.key, required this.vehicle});

  @override
  State<EditVehicleScreen> createState() => _EditVehicleScreenState();
}

class _EditVehicleScreenState extends State<EditVehicleScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controladores para pre-llenar y capturar los datos del formulario
  late final TextEditingController _makeController;
  late final TextEditingController _modelController;
  late final TextEditingController _yearController;
  late final TextEditingController _plateController;
  late final TextEditingController _mileageController;
  late final TextEditingController _imageUrlController;

  @override
  void initState() {
    super.initState();
    // Inicializamos los controladores con los datos del vehículo que se está editando
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
    // 1. Validamos que el formulario esté correcto
    if (_formKey.currentState!.validate()) {
      // 2. Creamos un nuevo objeto Vehicle con los datos actualizados del formulario
      //    Es crucial mantener el ID original para que el repositorio sepa cuál actualizar.
      final updatedVehicle = Vehicle(
        id: widget.vehicle.id, // Se mantiene el ID original
        make: _makeController.text,
        model: _modelController.text,
        year: int.parse(_yearController.text),
        plate: _plateController.text,
        mileage: int.parse(_mileageController.text),
        imageUrl: _imageUrlController.text.isNotEmpty
            ? _imageUrlController.text
            : 'assets/images/car.png', // Fallback si la URL se borra
      );

      // 3. Enviamos el evento 'UpdateVehicle' al GarageBloc con el vehículo actualizado
      context.read<GarageBloc>().add(UpdateVehicle(updatedVehicle));

      // 4. Regresamos a la pantalla de detalles y luego a la lista del garaje.
      //    Al volver a la lista, ya mostrará los datos actualizados.
      if (mounted) {
        context.pop(); // Cierra la pantalla de edición
        context.pop(); // Cierra la pantalla de detalles
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Editar Vehículo'),
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
                ElevatedButton(
                  onPressed: _submitUpdate,
                  child: const Text('ACTUALIZAR DATOS'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}