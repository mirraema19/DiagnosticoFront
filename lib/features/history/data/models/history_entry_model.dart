import 'package:equatable/equatable.dart';

class HistoryEntry extends Equatable {
  final String id;
  final DateTime date;
  final String serviceTitle; // RENOMBRADO
  final String workshopName; // NUEVO
  final double price; // NUEVO

  const HistoryEntry({
    required this.id,
    required this.date,
    required this.serviceTitle,
    required this.workshopName,
    required this.price,
  });

  @override
  List<Object?> get props => [id, date, serviceTitle, workshopName, price];
}