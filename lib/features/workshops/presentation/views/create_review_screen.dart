import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:proyecto/core/services/service_locator.dart';
import 'package:proyecto/features/workshops/data/models/review_model.dart';
import 'package:proyecto/features/workshops/data/repositories/workshop_repository.dart';

class CreateReviewScreen extends StatefulWidget {
  final String workshopId;
  final Review? existingReview; // Si viene nulo, es CREAR. Si trae datos, es EDITAR.

  const CreateReviewScreen({
    super.key, 
    required this.workshopId, 
    this.existingReview
  });

  @override
  State<CreateReviewScreen> createState() => _CreateReviewScreenState();
}

class _CreateReviewScreenState extends State<CreateReviewScreen> {
  double _rating = 5;
  final _commentController = TextEditingController();
  final _appointmentIdController = TextEditingController();
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    if (widget.existingReview != null) {
      _isEditing = true;
      _rating = widget.existingReview!.rating;
      _commentController.text = widget.existingReview!.comment;
      // Nota: Al editar, el backend usualmente no pide el appointmentId de nuevo,
      // pero al crear sí es obligatorio.
    }
  }

  void _submit() async {
    try {
      if (_isEditing) {
        // --- EDITAR ---
        await sl<WorkshopRepository>().updateReview(
          widget.workshopId, 
          widget.existingReview!.id,
          {
            'rating': {'overall': _rating.toInt()},
            'comment': _commentController.text,
          }
        );
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Reseña actualizada')));
      } else {
        // --- CREAR ---
        if (_appointmentIdController.text.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('El ID de la cita es obligatorio')));
          return;
        }
        await sl<WorkshopRepository>().createReview(widget.workshopId, {
          'appointmentId': _appointmentIdController.text,
          'rating': {'overall': _rating.toInt()},
          'comment': _commentController.text,
        });
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Reseña publicada')));
      }
      
      if (mounted) context.pop(true); // Retorna true para indicar que hubo cambios
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_isEditing ? 'Editar Reseña' : 'Escribir Reseña')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const Text('Calificación General', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(5, (index) {
                return IconButton(
                  icon: Icon(
                    index < _rating ? Icons.star : Icons.star_border,
                    color: Colors.amber,
                    size: 40,
                  ),
                  onPressed: () => setState(() => _rating = index + 1.0),
                );
              }),
            ),
            const SizedBox(height: 20),
            
            // Solo mostramos el campo de ID de cita si estamos creando
            if (!_isEditing)
              TextFormField(
                controller: _appointmentIdController,
                decoration: const InputDecoration(
                  labelText: 'ID de tu Cita (Cópialo del Historial)',
                  hintText: 'Ej: a1b2-c3d4...',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.receipt_long),
                ),
              ),
            
            const SizedBox(height: 20),
            TextFormField(
              controller: _commentController,
              decoration: const InputDecoration(
                labelText: 'Tu opinión',
                alignLabelWithHint: true,
                border: OutlineInputBorder(),
              ),
              maxLines: 5,
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: _submit,
                child: Text(_isEditing ? 'ACTUALIZAR' : 'PUBLICAR'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}