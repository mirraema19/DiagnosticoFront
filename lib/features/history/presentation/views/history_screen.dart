import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:proyecto/features/history/presentation/bloc/history_bloc.dart';
import 'package:proyecto/features/history/data/models/maintenance_model.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Historial de Servicios'),
      ),
      body: BlocBuilder<HistoryBloc, HistoryState>(
        builder: (context, state) {
          if (state is HistoryLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is HistoryLoaded) {
            if (state.records.isEmpty) {
              return const Center(child: Text('No hay registros de mantenimiento.'));
            }
            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: state.records.length,
              itemBuilder: (context, index) {
                final record = state.records[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    leading: const Icon(Icons.build_circle, color: Colors.blue),
                    title: Text(record.serviceType, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text(
                      '${DateFormat.yMMMd('es_ES').format(record.serviceDate)} - ${record.workshopName ?? 'Taller externo'}\nKm: ${record.mileageAtService}',
                    ),
                    trailing: Text(
                      record.cost != null ? '\$${record.cost}' : '-',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                  ),
                );
              },
            );
          }
          if (state is HistoryError) {
            return Center(child: Text(state.message));
          }
          return const SizedBox.shrink();
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          context.push('/history/add');
        },
        label: const Text('Registrar Servicio'),
        icon: const Icon(Icons.add),
      ),
    );
  }
}