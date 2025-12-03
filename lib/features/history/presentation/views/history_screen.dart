import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:proyecto/features/history/presentation/bloc/history_bloc.dart';

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
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(32.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.history_edu, size: 60, color: Colors.grey),
                      const SizedBox(height: 16),
                      const Text(
                        'No hay servicios registrados.',
                        style: TextStyle(fontSize: 18, color: Colors.grey),
                      ),
                      const SizedBox(height: 8),
                      // --- CAMBIO: Mensaje actualizado ---
                      Text(
                        'Los mantenimientos realizados por tu taller certificado aparecerán aquí automáticamente.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
              );
            }
            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: state.records.length,
              itemBuilder: (context, index) {
                final record = state.records[index];
                
                // Lógica para distinguir quién creó el registro (opcional visualmente)
                final bool isCreatedByAdmin = record.createdByRole == 'WORKSHOP_ADMIN';

                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    leading: Icon(
                      Icons.build_circle, 
                      // Azul si es taller, Gris si fue (hipotéticamente) el usuario
                      color: isCreatedByAdmin ? Colors.blue[700] : Colors.grey,
                    ),
                    title: Text(record.serviceType, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('${DateFormat.yMMMd('es_ES').format(record.serviceDate)} - ${record.workshopName ?? 'Taller'}'),
                        Text('Km: ${record.mileageAtService}'),
                        if (isCreatedByAdmin)
                          const Padding(
                            padding: EdgeInsets.only(top: 4.0),
                            child: Row(
                              children: [
                                Icon(Icons.verified, size: 14, color: Colors.green),
                                SizedBox(width: 4),
                                Text('Verificado por Taller', style: TextStyle(color: Colors.green, fontSize: 12, fontWeight: FontWeight.bold)),
                              ],
                            ),
                          ),
                      ],
                    ),
                    isThreeLine: true,
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
      // --- CAMBIO: Se eliminó el floatingActionButton ---
    );
  }
}