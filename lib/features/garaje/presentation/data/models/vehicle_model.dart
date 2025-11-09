import 'package:equatable/equatable.dart';

class Vehicle extends Equatable {
  final String id;
  final String make;
  final String model;
  final int year;
  final String plate; // NUEVO
  final String imageUrl;
  final int mileage;

  const Vehicle({
    required this.id,
    required this.make,
    required this.model,
    required this.year,
    required this.plate,
    required this.imageUrl,
    required this.mileage,
  });

  @override
  List<Object?> get props => [id, make, model, year, plate, imageUrl, mileage];
}