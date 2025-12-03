import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:proyecto/core/services/service_locator.dart';
import 'package:proyecto/features/auth/presentation/bloc/auth_bloc/auth_bloc.dart';
import 'package:proyecto/features/workshops/data/models/review_model.dart';
import 'package:proyecto/features/workshops/data/models/workshop_model.dart';
import 'package:proyecto/features/workshops/data/repositories/workshop_repository.dart';
import 'package:proyecto/features/workshops/presentation/views/create_review_screen.dart';

class WorkshopDetailScreen extends StatefulWidget {
  final Workshop workshop;
  const WorkshopDetailScreen({super.key, required this.workshop});

  @override
  State<WorkshopDetailScreen> createState() => _WorkshopDetailScreenState();
}

class _WorkshopDetailScreenState extends State<WorkshopDetailScreen> {
  late Workshop _workshop;

  @override
  void initState() {
    super.initState();
    _workshop = widget.workshop;
  }

  // Método para recargar el taller y ver las nuevas reseñas
  Future<void> _refreshWorkshop() async {
    try {
      final updated = await sl<WorkshopRepository>().getWorkshopById(_workshop.id);
      setState(() {
        _workshop = updated;
      });
    } catch (_) {
      // Ignoramos errores de recarga silenciosa
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final currentUser = context.read<AuthBloc>().state.user;
    final currentUserId = currentUser?.id;
    final isOwner = currentUser?.role == 'VEHICLE_OWNER';

    return Scaffold(
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
            _HeaderImage(workshop: _workshop),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(_workshop.name, style: textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.star, color: Colors.amber, size: 20),
                      const SizedBox(width: 8),
                      Text('${_workshop.rating} (${_workshop.reviewCount} reseñas)', style: textTheme.bodyLarge),
                    ],
                  ),
                  const SizedBox(height: 24),
                  _buildSectionTitle('Sobre el Taller'),
                  Text(_workshop.description ?? 'Sin descripción.', style: textTheme.bodyMedium),
                  const Divider(height: 32),
                  _buildSectionTitle('Información'),
                  _buildInfoRow(Icons.location_on, _workshop.address),
                  _buildInfoRow(Icons.phone, _workshop.phone),
                  _buildInfoRow(Icons.schedule, _workshop.operatingHours),
                  
                  const Divider(height: 32),
                  
                  // CABECERA DE RESEÑAS
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildSectionTitle('Reseñas'),
                      if (isOwner)
                        TextButton.icon(
                          onPressed: () async {
                            final result = await Navigator.push(
                              context, 
                              MaterialPageRoute(builder: (_) => CreateReviewScreen(workshopId: _workshop.id))
                            );
                            if (result == true) {
                               ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Gracias por tu reseña')));
                               _refreshWorkshop(); // Recargamos para ver la nueva reseña
                            }
                          },
                          icon: const Icon(Icons.rate_review),
                          label: const Text('Opinar'),
                        ),
                    ],
                  ),
                  
                  _workshop.reviews.isEmpty
                      ? const Center(child: Padding(padding: EdgeInsets.all(20), child: Text('Sin reseñas aún.')))
                      : Column(
                          children: _workshop.reviews.map((review) => _ReviewItem(
                            review: review, 
                            isMyReview: review.userId == currentUserId, 
                            workshopId: _workshop.id,
                            onUpdate: _refreshWorkshop,
                          )).toList(),
                        ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: FilledButton.icon(
            onPressed: () => context.push('/appointments/add'),
            label: const Text('Agendar Cita'),
            icon: const Icon(Icons.calendar_today),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold));
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(children: [Icon(icon, size: 20, color: Colors.blue), const SizedBox(width: 12), Expanded(child: Text(text))]),
    );
  }
}

class _ReviewItem extends StatelessWidget {
  final Review review;
  final bool isMyReview;
  final String workshopId;
  final VoidCallback onUpdate;

  const _ReviewItem({
    required this.review, 
    required this.isMyReview,
    required this.workshopId,
    required this.onUpdate,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(review.authorName, style: const TextStyle(fontWeight: FontWeight.bold)),
                if (isMyReview)
                  PopupMenuButton<String>(
                    onSelected: (value) async {
                      if (value == 'edit') {
                         await Navigator.push(context, MaterialPageRoute(builder: (_) => CreateReviewScreen(workshopId: workshopId, existingReview: review)));
                         onUpdate();
                      } else if (value == 'delete') {
                         await sl<WorkshopRepository>().deleteReview(workshopId, review.id);
                         onUpdate();
                      }
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem(value: 'edit', child: Text('Editar')),
                      const PopupMenuItem(value: 'delete', child: Text('Eliminar', style: TextStyle(color: Colors.red))),
                    ],
                    child: const Icon(Icons.more_vert, size: 20, color: Colors.grey),
                  ),
              ],
            ),
            Row(children: List.generate(5, (i) => Icon(i < review.rating ? Icons.star : Icons.star_border, size: 16, color: Colors.amber))),
            const SizedBox(height: 8),
            Text(review.comment),
            if (review.workshopResponse != null)
              Container(
                margin: const EdgeInsets.only(top: 8), 
                padding: const EdgeInsets.all(8),
                color: Colors.blue.shade50,
                width: double.infinity,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Respuesta del Taller:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                    Text(review.workshopResponse!, style: const TextStyle(fontSize: 12)),
                  ],
                ),
              )
          ],
        ),
      ),
    );
  }
}

class _HeaderImage extends StatelessWidget {
  final Workshop workshop;
  const _HeaderImage({required this.workshop});
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 200,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.grey.shade300,
      ),
      child: Image.asset(
        'assets/images/Mecanico.jpg',
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            color: Colors.grey.shade400,
            child: const Center(
              child: Icon(Icons.build, size: 50, color: Colors.white),
            ),
          );
        },
      ),
    );
  }
}