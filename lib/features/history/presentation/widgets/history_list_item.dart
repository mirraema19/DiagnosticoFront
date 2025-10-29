import 'package:proyecto/features/history/data/models/history_entry_model.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class HistoryListItem extends StatelessWidget {
  final HistoryEntry entry;
  const HistoryListItem({super.key, required this.entry});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // --- LÍNEA DE TIEMPO ---
          _TimelineMarker(),
          const SizedBox(width: 16),
          // --- TARJETA DE CONTENIDO ---
          Expanded(
            child: Card(
              margin: const EdgeInsets.symmetric(vertical: 8),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            entry.serviceTitle,
                            style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                          ),
                        ),
                        Chip(
                          label: Text('\$${entry.price.toStringAsFixed(0)}'),
                          backgroundColor: Colors.green.shade100,
                          side: BorderSide.none,
                          labelStyle: TextStyle(
                            color: Colors.green.shade800,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    _buildInfoRow(
                      context,
                      icon: Icons.calendar_today,
                      text: DateFormat.yMMMMd('es_ES').format(entry.date),
                    ),
                    const SizedBox(height: 4),
                    _buildInfoRow(
                      context,
                      icon: Icons.business,
                      text: entry.workshopName,
                    ),
                    const Divider(height: 24),
                    InkWell(
                      onTap: () {},
                      child: Row(
                        children: [
                          Text(
                            'Ver detalles y facturas',
                            style: textTheme.bodyMedium?.copyWith(
                              color: Theme.of(context).colorScheme.primary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Icon(
                            Icons.arrow_forward,
                            size: 16,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Helper para las filas de información con ícono
  Widget _buildInfoRow(BuildContext context, {required IconData icon, required String text}) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey.shade600),
        const SizedBox(width: 8),
        Text(
          text,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey.shade700),
        ),
      ],
    );
  }
}

// Widget privado para dibujar el punto y la línea de la timeline
class _TimelineMarker extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Theme.of(context).scaffoldBackgroundColor,
            border: Border.all(
              color: Theme.of(context).colorScheme.primary,
              width: 3,
            ),
          ),
        ),
        Expanded(
          child: Container(
            width: 2,
            color: Colors.grey.shade300,
          ),
        )
      ],
    );
  }
}