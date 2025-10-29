import 'package:proyecto/features/history/data/models/history_entry_model.dart';

class HistoryRepository {
  Future<List<HistoryEntry>> fetchHistory() async {
    await Future.delayed(const Duration(seconds: 1));
    return [
      HistoryEntry(
        id: 'h1',
        date: DateTime(2025, 3, 15),
        serviceTitle: 'Cambio de aceite y filtros',
        workshopName: 'Taller Mecánico Central',
        price: 75.00,
      ),
      HistoryEntry(
        id: 'h2',
        date: DateTime(2025, 2, 10),
        serviceTitle: 'Revisión de frenos',
        workshopName: 'AutoExpert Pro',
        price: 150.00,
      ),
      HistoryEntry(
        id: 'h3',
        date: DateTime(2025, 1, 5),
        serviceTitle: 'Alineación y balanceo',
        workshopName: 'Servicio Premium Motors',
        price: 55.00,
      ),
    ];
  }
}