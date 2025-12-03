import 'package:equatable/equatable.dart';

class Maintenance extends Equatable {
  final String id;
  final String vehicleId;
  final String serviceType;
  final String? description;
  final DateTime serviceDate;
  final int mileageAtService;
  final double? cost;
  final String currency;
  final String? workshopName;
  final String? invoiceUrl;
  final String? notes;
  
  // --- NUEVOS CAMPOS QUE FALTABAN ---
  final String? createdBy;
  final String? createdByRole; // Este es el que causaba el error
  final DateTime? createdAt;

  const Maintenance({
    required this.id,
    required this.vehicleId,
    required this.serviceType,
    this.description,
    required this.serviceDate,
    required this.mileageAtService,
    this.cost,
    required this.currency,
    this.workshopName,
    this.invoiceUrl,
    this.notes,
    this.createdBy,
    this.createdByRole,
    this.createdAt,
  });

  factory Maintenance.fromJson(Map<String, dynamic> json) {
    return Maintenance(
      id: json['id'] ?? '',
      vehicleId: json['vehicleId'] ?? '',
      serviceType: json['serviceType'] ?? 'OTHER',
      description: json['description'],
      serviceDate: json['serviceDate'] != null 
          ? DateTime.parse(json['serviceDate']) 
          : DateTime.now(),
      mileageAtService: json['mileageAtService'] ?? 0,
      cost: (json['cost'] as num?)?.toDouble(),
      currency: json['currency'] ?? 'MXN',
      workshopName: json['workshopName'],
      invoiceUrl: json['invoiceUrl'],
      notes: json['notes'],
      
      // --- MAPEO DE LOS NUEVOS CAMPOS ---
      createdBy: json['createdBy'],
      createdByRole: json['createdByRole'],
      createdAt: json['createdAt'] != null 
          ? DateTime.parse(json['createdAt']) 
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'serviceType': serviceType,
      'description': description,
      'serviceDate': serviceDate.toIso8601String().split('T')[0], // YYYY-MM-DD
      'mileageAtService': mileageAtService,
      'cost': cost,
      'currency': currency,
      'workshopName': workshopName,
      'invoiceUrl': invoiceUrl,
      'notes': notes,
      // createdBy y createdByRole usualmente no se envían al crear, los pone el backend
    };
  }

  @override
  List<Object?> get props => [
        id, 
        vehicleId, 
        serviceType, 
        serviceDate, 
        createdBy, 
        createdByRole
      ];
}