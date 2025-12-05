import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:proyecto/features/workshops/data/models/workshop_model.dart';
import 'package:proyecto/features/workshop_admin/presentation/bloc/admin_workshop_bloc.dart';

class EditWorkshopScreen extends StatefulWidget {
  final Workshop workshop;
  const EditWorkshopScreen({super.key, required this.workshop});

  @override
  State<EditWorkshopScreen> createState() => _EditWorkshopScreenState();
}

class _EditWorkshopScreenState extends State<EditWorkshopScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _phoneController;
  late final TextEditingController _descController;
  late String _priceRange;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.workshop.name);
    _phoneController = TextEditingController(text: widget.workshop.phone);
    _descController = TextEditingController(text: widget.workshop.description);
    _priceRange = widget.workshop.priceRange;
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      final data = {
        'businessName': _nameController.text,
        'phone': _phoneController.text,
        'description': _descController.text,
        'priceRange': _priceRange,
      };
      context.read<AdminWorkshopBloc>().add(UpdateWorkshopEvent(widget.workshop.id, data));
      context.pop();
    }
  }

  void _delete() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('¿Eliminar Taller?'),
        content: const Text('Esta acción no se puede deshacer.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
          TextButton(
            onPressed: () {
              context.read<AdminWorkshopBloc>().add(DeleteWorkshopEvent(widget.workshop.id));
              Navigator.pop(ctx); // Close dialog
              context.pop(); // Close screen
            },
            child: const Text('Eliminar', style: TextStyle(color: Colors.red)),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Editar Taller'),
        actions: [
          IconButton(icon: const Icon(Icons.delete), onPressed: _delete),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Nombre'),
                validator: (v) => v!.isEmpty ? 'Requerido' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _phoneController,
                decoration: const InputDecoration(labelText: 'Teléfono'),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descController,
                decoration: const InputDecoration(labelText: 'Descripción'),
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                initialValue: _priceRange,
                decoration: const InputDecoration(labelText: 'Rango de Precios'),
                items: const [
                  DropdownMenuItem(value: 'LOW', child: Text('Económico')),
                  DropdownMenuItem(value: 'MEDIUM', child: Text('Medio')),
                  DropdownMenuItem(value: 'HIGH', child: Text('Premium')),
                ],
                onChanged: (v) => setState(() => _priceRange = v!),
              ),
              const SizedBox(height: 32),
              
              // Botones para gestionar Horarios y Especialidades
              ListTile(
                title: const Text('Gestionar Horarios'),
                trailing: const Icon(Icons.arrow_forward_ios),
                onTap: () => context.push('/admin/workshops/${widget.workshop.id}/schedule'),
                tileColor: Colors.grey.shade100,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              const SizedBox(height: 12),
              ListTile(
                title: const Text('Gestionar Especialidades'),
                trailing: const Icon(Icons.arrow_forward_ios),
                onTap: () => context.push('/admin/workshops/${widget.workshop.id}/specialties'),
                tileColor: Colors.grey.shade100,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),

              const SizedBox(height: 32),
              ElevatedButton(onPressed: _submit, child: const Text('GUARDAR CAMBIOS')),
            ],
          ),
        ),
      ),
    );
  }
}