import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:proyecto/core/services/service_locator.dart';
import 'package:proyecto/features/workshops/data/models/review_model.dart';
import 'package:proyecto/features/workshops/data/repositories/workshop_repository.dart';

class CreateReviewScreen extends StatefulWidget {
  final String workshopId;
  final String? appointmentId; // ID de la cita (pasado automáticamente desde citas completadas)
  final Review? existingReview; // Si viene nulo, es CREAR. Si trae datos, es EDITAR.

  const CreateReviewScreen({
    super.key,
    required this.workshopId,
    this.appointmentId, // Nuevo parámetro opcional
    this.existingReview
  });

  @override
  State<CreateReviewScreen> createState() => _CreateReviewScreenState();
}

class _CreateReviewScreenState extends State<CreateReviewScreen> {
  // Calificaciones detalladas
  double _overallRating = 5;      // Calificación general (obligatorio)
  double _qualityRating = 5;      // Calidad del trabajo (opcional)
  double _priceRating = 5;        // Relación calidad-precio (opcional)
  double _timeRating = 5;         // Cumplimiento de tiempos (opcional)
  double _serviceRating = 5;      // Atención al cliente (opcional)

  final _commentController = TextEditingController();
  final _appointmentIdController = TextEditingController();
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();

    // Si viene appointmentId desde la navegación, lo asignamos automáticamente
    if (widget.appointmentId != null) {
      _appointmentIdController.text = widget.appointmentId!;
    }

    if (widget.existingReview != null) {
      _isEditing = true;
      _overallRating = widget.existingReview!.rating;
      _commentController.text = widget.existingReview!.comment;
      // Nota: Al editar, el backend usualmente no pide el appointmentId de nuevo
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
            'rating': {
              'overall': _overallRating.toInt(),
              'quality': _qualityRating.toInt(),
              'price': _priceRating.toInt(),
              'timeCompliance': _timeRating.toInt(),
              'customerService': _serviceRating.toInt(),
            },
            'comment': _commentController.text,
          }
        );
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Reseña actualizada')));
      } else {
        // --- CREAR ---

        // Validación: appointmentId es OBLIGATORIO según el backend
        if (_appointmentIdController.text.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Se requiere el ID de la cita para publicar la reseña'),
              backgroundColor: Colors.orange,
            )
          );
          return;
        }

        // Validación: comentario debe tener mínimo 10 caracteres
        if (_commentController.text.trim().length < 10) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('El comentario debe tener al menos 10 caracteres'),
              backgroundColor: Colors.orange,
            )
          );
          return;
        }

        final reviewData = {
          'appointmentId': _appointmentIdController.text,
          'rating': {
            'overall': _overallRating.toInt(),
            'quality': _qualityRating.toInt(),
            'price': _priceRating.toInt(),
            'timeCompliance': _timeRating.toInt(),
            'customerService': _serviceRating.toInt(),
          },
          'comment': _commentController.text.trim(),
        };

        // DEBUG: Log para verificar el appointmentId
        print('🔍 DEBUG CreateReview - appointmentId: ${_appointmentIdController.text}');
        print('🔍 DEBUG CreateReview - appointmentId length: ${_appointmentIdController.text.length}');
        print('🔍 DEBUG CreateReview - Full payload: $reviewData');

        await sl<WorkshopRepository>().createReview(widget.workshopId, reviewData);
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('¡Reseña publicada exitosamente!')));
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
            // Título principal
            const Text(
              'Califica tu Experiencia',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Tu opinión ayuda a otros usuarios',
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),

            // Calificación General (Obligatoria)
            _buildRatingSection(
              title: 'Calificación General *',
              icon: Icons.star,
              color: Colors.amber,
              rating: _overallRating,
              onRatingChanged: (rating) => setState(() => _overallRating = rating),
            ),
            const Divider(height: 32),

            // Calificaciones Opcionales
            const Text(
              'Calificaciones Detalladas (Opcional)',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 4),
            Text(
              'Ayúdanos a entender mejor tu experiencia',
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
            const SizedBox(height: 16),

            // Calidad del Trabajo
            _buildRatingSection(
              title: 'Calidad del Trabajo',
              icon: Icons.engineering,
              color: Colors.blue,
              rating: _qualityRating,
              onRatingChanged: (rating) => setState(() => _qualityRating = rating),
              isOptional: true,
            ),
            const SizedBox(height: 16),

            // Relación Calidad-Precio
            _buildRatingSection(
              title: 'Relación Calidad-Precio',
              icon: Icons.attach_money,
              color: Colors.green,
              rating: _priceRating,
              onRatingChanged: (rating) => setState(() => _priceRating = rating),
              isOptional: true,
            ),
            const SizedBox(height: 16),

            // Cumplimiento de Tiempos
            _buildRatingSection(
              title: 'Cumplimiento de Tiempos',
              icon: Icons.schedule,
              color: Colors.purple,
              rating: _timeRating,
              onRatingChanged: (rating) => setState(() => _timeRating = rating),
              isOptional: true,
            ),
            const SizedBox(height: 16),

            // Atención al Cliente
            _buildRatingSection(
              title: 'Atención al Cliente',
              icon: Icons.people,
              color: Colors.orange,
              rating: _serviceRating,
              onRatingChanged: (rating) => setState(() => _serviceRating = rating),
              isOptional: true,
            ),
            const Divider(height: 32),

            // Solo mostramos el campo si NO viene appointmentId automático y NO estamos editando
            if (!_isEditing && widget.appointmentId == null)
              Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      color: Colors.orange.shade50,
                      border: Border.all(color: Colors.orange.shade200),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.info_outline, color: Colors.orange.shade700, size: 20),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Para dejar una reseña, primero debes completar una cita con este taller',
                            style: TextStyle(
                              color: Colors.orange.shade900,
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  TextFormField(
                    controller: _appointmentIdController,
                    decoration: const InputDecoration(
                      labelText: 'ID de tu Cita *',
                      hintText: 'Ingresa el ID de tu cita completada',
                      helperText: 'Este campo es obligatorio. Debes tener una cita completada.',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.receipt_long),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),

            // Si viene appointmentId, mostrar mensaje informativo
            if (widget.appointmentId != null) ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  border: Border.all(color: Colors.green.shade200),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(Icons.check_circle, color: Colors.green.shade700, size: 20),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Esta reseña se vinculará con tu cita completada',
                        style: TextStyle(
                          color: Colors.green.shade900,
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
            ],

            TextFormField(
              controller: _commentController,
              decoration: const InputDecoration(
                labelText: 'Tu opinión *',
                hintText: 'Cuéntanos sobre tu experiencia...',
                helperText: 'Mínimo 10 caracteres, máximo 1000',
                alignLabelWithHint: true,
                border: OutlineInputBorder(),
              ),
              maxLines: 5,
              maxLength: 1000,
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

  // Widget para construir una sección de calificación
  Widget _buildRatingSection({
    required String title,
    required IconData icon,
    required Color color,
    required double rating,
    required Function(double) onRatingChanged,
    bool isOptional = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(width: 8),
            Text(
              title,
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(5, (index) {
            return IconButton(
              icon: Icon(
                index < rating ? Icons.star : Icons.star_border,
                color: color,
                size: 36,
              ),
              onPressed: () => onRatingChanged(index + 1.0),
            );
          }),
        ),
      ],
    );
  }
}