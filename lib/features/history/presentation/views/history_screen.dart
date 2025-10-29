import 'package:proyecto/features/history/data/models/history_entry_model.dart';
import 'package:proyecto/features/history/data/repositories/history_repository.dart';
import 'package:proyecto/features/history/presentation/widgets/history_list_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/date_symbol_data_local.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final HistoryRepository _repository = HistoryRepository();
  late final Future<List<HistoryEntry>> _historyFuture;

  @override
  void initState() {
    super.initState();
    // Inicializa el formato de fecha en español
    initializeDateFormatting('es_ES', null);
    _historyFuture = _repository.fetchHistory();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Historial de Servicios'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline),
            onPressed: () {
              // Acción para añadir nuevo historial
            },
          ),
        ],
      ),
      body: FutureBuilder<List<HistoryEntry>>(
        future: _historyFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No hay historial disponible.'));
          }

          final historyEntries = snapshot.data!;
          return ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            itemCount: historyEntries.length,
            itemBuilder: (context, index) {
              return HistoryListItem(entry: historyEntries[index])
                  .animate()
                  .fadeIn(delay: (100 * index).ms)
                  .slideX(begin: 0.2);
            },
          );
        },
      ),
    );
  }
}