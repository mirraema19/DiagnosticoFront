import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:proyecto/core/services/service_locator.dart';
import 'package:proyecto/features/workshops/data/models/review_model.dart';
import 'package:proyecto/features/workshops/data/models/workshop_model.dart';
import 'package:proyecto/features/workshops/data/repositories/workshop_repository.dart';

class AdminReviewsTab extends StatefulWidget {
  final List<Workshop> myWorkshops;
  const AdminReviewsTab({super.key, required this.myWorkshops});

  @override
  State<AdminReviewsTab> createState() => _AdminReviewsTabState();
}

class _AdminReviewsTabState extends State<AdminReviewsTab> {
  Workshop? _selectedWorkshop;
  late Future<List<Review>> _reviewsFuture;

  @override
  void initState() {
    super.initState();
    if (widget.myWorkshops.isNotEmpty) {
      _selectedWorkshop = widget.myWorkshops.first;
      _loadReviews();
    }
  }

  void _loadReviews() {
    if (_selectedWorkshop != null) {
      setState(() {
        _reviewsFuture = sl<WorkshopRepository>().getReviews(_selectedWorkshop!.id);
      });
    }
  }

  void _replyToReview(String reviewId) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Responder Reseña'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(hintText: 'Escribe tu respuesta...'),
          maxLines: 3,
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
          ElevatedButton(
            onPressed: () async {
              try {
                await sl<WorkshopRepository>().replyToReview(
                  _selectedWorkshop!.id,
                  reviewId,
                  controller.text,
                );
                Navigator.pop(ctx);
                _loadReviews(); // Recargar
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Respuesta enviada')));
              } catch (e) {
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
              }
            },
            child: const Text('Enviar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.myWorkshops.isEmpty) {
      return const Center(child: Text('Registra un taller para ver reseñas.'));
    }

    return Column(
      children: [
        // Selector de Taller
        if (widget.myWorkshops.length > 1)
          DropdownButton<Workshop>(
            value: _selectedWorkshop,
            items: widget.myWorkshops.map((w) => DropdownMenuItem(value: w, child: Text(w.name))).toList(),
            onChanged: (w) {
              setState(() {
                _selectedWorkshop = w;
                _loadReviews();
              });
            },
          ),

        Expanded(
          child: FutureBuilder<List<Review>>(
            future: _reviewsFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
              if (snapshot.hasError) return Center(child: Text('Error: ${snapshot.error}'));
              if (!snapshot.hasData || snapshot.data!.isEmpty) return const Center(child: Text('No hay reseñas aún.'));

              return ListView.builder(
                itemCount: snapshot.data!.length,
                itemBuilder: (context, index) {
                  final review = snapshot.data![index];
                  return Card(
                    margin: const EdgeInsets.all(8),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(review.authorName, style: const TextStyle(fontWeight: FontWeight.bold)),
                              Text(DateFormat.yMMMd().format(review.date), style: const TextStyle(fontSize: 12)),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Row(children: List.generate(5, (i) => Icon(i < review.rating ? Icons.star : Icons.star_border, size: 16, color: Colors.amber))),
                          const SizedBox(height: 8),
                          Text(review.comment),
                          const Divider(),
                          if (review.workshopResponse != null)
                            Container(
                              padding: const EdgeInsets.all(8),
                              color: Colors.grey.shade100,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('Tu Respuesta:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                                  Text(review.workshopResponse!),
                                ],
                              ),
                            )
                          else
                            Align(
                              alignment: Alignment.centerRight,
                              child: TextButton.icon(
                                onPressed: () => _replyToReview(review.id), // Necesitamos el ID de la reseña, asegúrate de tenerlo en el modelo Review
                                icon: const Icon(Icons.reply),
                                label: const Text('Responder'),
                              ),
                            ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}