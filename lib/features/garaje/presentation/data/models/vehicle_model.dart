import 'package:equatable/equatable.dart';

class Vehicle extends Equatable {
  final String id;
  final String make;      // Backend: brand
  final String model;     // Backend: model
  final int year;         // Backend: year
  final String plate;     // Backend: licensePlate
  final String imageUrl;  // Backend: photoUrl
  final int mileage;      // Backend: currentMileage
  final String? vin;      // Backend: vin (Nuevo)

  const Vehicle({
    required this.id,
    required this.make,
    required this.model,
    required this.year,
    required this.plate,
    required this.imageUrl,
    required this.mileage,
    this.vin,
  });

  // --- Mapeo de Respuesta (VehicleDto -> Vehicle) ---
  factory Vehicle.fromJson(Map<String, dynamic> json) {
    return Vehicle(
      id: json['id'] ?? '',
      // Mapeo: brand -> make
      make: json['brand'] ?? 'Marca Desconocida',
      model: json['model'] ?? 'Modelo Desconocido',
      year: json['year'] ?? 2000,
      // Mapeo: licensePlate -> plate
      plate: json['licensePlate'] ?? 'Sin Placa',
      // Mapeo: photoUrl -> imageUrl
      imageUrl: (json['photoUrl'] != null && json['photoUrl'].toString().isNotEmpty)
          ? json['photoUrl']
          : 'assets/images/car.png',
      // Mapeo: currentMileage -> mileage
      mileage: json['currentMileage'] ?? 0,
      vin: json['vin'],
    );
  }

  // --- Mapeo de Petición (Vehicle -> CreateVehicleDto) ---
  Map<String, dynamic> toJson() {
    return {
      'brand': make,
      'model': model,
      'year': year,
      'licensePlate': plate,
      'currentMileage': mileage,
      if (vin != null && vin!.isNotEmpty) 'vin': vin,
      // Solo enviamos la URL si no es el asset local
      if (!imageUrl.startsWith('assets/')) 'photoUrl': imageUrl,
    };
  }

  @override
  List<Object?> get props => [id, make, model, year, plate, imageUrl, mileage, vin];
}