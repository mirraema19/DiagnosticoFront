import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:proyecto/features/workshops/data/models/review_model.dart';
import 'package:proyecto/features/workshops/data/models/workshop_model.dart';

class WorkshopDetailScreen extends StatelessWidget {
  final Workshop workshop;
  const WorkshopDetailScreen({super.key, required this.workshop});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      // Usamos un AppBar flexible para que la imagen se vea detrás
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- SECCIÓN DE LA IMAGEN DE CABECERA ---
            _HeaderImage(workshop: workshop),

            // --- SECCIÓN DE INFORMACIÓN PRINCIPAL ---
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(workshop.name, style: textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.star, color: Colors.amber, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        '${workshop.rating} (${workshop.reviewCount} reseñas verificadas)',
                        style: textTheme.bodyLarge,
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  
                  _buildSectionTitle(context, 'Sobre el Taller'),
                  Text(workshop.description, style: textTheme.bodyMedium?.copyWith(color: Colors.grey.shade700)),
                  
                  const Divider(height: 32),
                  
                  _buildSectionTitle(context, 'Especialidades Técnicas'),
                  Wrap(
                    spacing: 8.0,
                    runSpacing: 4.0,
                    children: workshop.specialties.map((tag) => Chip(label: Text(tag))).toList(),
                  ),

                  const Divider(height: 32),
                  
                  _buildSectionTitle(context, 'Información y Contacto'),
                  _buildInfoRow(context, icon: Icons.location_on_outlined, text: workshop.address),
                  _buildInfoRow(context, icon: Icons.phone_outlined, text: workshop.phone),
                  _buildInfoRow(context, icon: Icons.access_time_outlined, text: workshop.operatingHours),

                  const Divider(height: 32),

                  _buildSectionTitle(context, 'Calificaciones y Comentarios'),
                  // --- SECCIÓN DE RESEÑAS ---
                  workshop.reviews.isEmpty
                      ? const Padding(
                          padding: EdgeInsets.symmetric(vertical: 24.0),
                          child: Center(child: Text('Este taller aún no tiene reseñas.')),
                        )
                      : Column(
                          children: workshop.reviews.map((review) => _ReviewListItem(review: review)).toList(),
                        ),
                ],
              ),
            ),
          ],
        ),
      ),
      // Botón flotante para la acción principal
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: FilledButton.icon(
            onPressed: () {
              context.push('/appointments/add');
            },
            label: const Text('Agendar una Cita'),
            icon: const Icon(Icons.calendar_today),
            style: FilledButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
          ),
        ),
      ),
    );
  }

  // Helper para los títulos de sección
  Widget _buildSectionTitle(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
      ),
    );
  }

  // Helper para las filas de información (dirección, teléfono, etc.)
  Widget _buildInfoRow(BuildContext context, {required IconData icon, required String text}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Theme.of(context).colorScheme.primary, size: 20),
          const SizedBox(width: 16),
          Expanded(child: Text(text, style: Theme.of(context).textTheme.bodyLarge)),
        ],
      ),
    );
  }
}

// Widget para la cabecera con imagen
class _HeaderImage extends StatelessWidget {
  const _HeaderImage({required this.workshop});
  final Workshop workshop;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 250,
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage(workshop.imageUrl),
          fit: BoxFit.cover,
          colorFilter: ColorFilter.mode(
            Colors.black.withOpacity(0.4),
            BlendMode.darken,
          ),
        ),
      ),
    );
  }
}

// Widget para mostrar cada reseña individualmente
class _ReviewListItem extends StatelessWidget {
  final Review review;
  const _ReviewListItem({required this.review});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(review.authorName, style: const TextStyle(fontWeight: FontWeight.bold)),
              Text(
                DateFormat.yMMMd('es_ES').format(review.date),
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            children: List.generate(5, (index) {
              return Icon(
                index < review.rating ? Icons.star : Icons.star_border,
                color: Colors.amber,
                size: 16,
              );
            }),
          ),
          const SizedBox(height: 8),
          Text(review.comment, style: TextStyle(color: Colors.grey.shade800)),
        ],
      ),
    );
  }
}