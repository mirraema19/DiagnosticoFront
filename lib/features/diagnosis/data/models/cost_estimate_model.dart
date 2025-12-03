import 'package:equatable/equatable.dart';

class CostBreakdown extends Equatable {
  final double partsMin;
  final double partsMax;
  final double laborMin;
  final double laborMax;

  const CostBreakdown({
    required this.partsMin,
    required this.partsMax,
    required this.laborMin,
    required this.laborMax,
  });

  factory CostBreakdown.fromJson(Map<String, dynamic> json) {
    return CostBreakdown(
      partsMin: (json['partsMin'] as num).toDouble(),
      partsMax: (json['partsMax'] as num).toDouble(),
      laborMin: (json['laborMin'] as num).toDouble(),
      laborMax: (json['laborMax'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'partsMin': partsMin,
      'partsMax': partsMax,
      'laborMin': laborMin,
      'laborMax': laborMax,
    };
  }

  @override
  List<Object?> get props => [partsMin, partsMax, laborMin, laborMax];
}

class CostEstimateModel extends Equatable {
  final double minCost;
  final double maxCost;
  final String currency;
  final CostBreakdown breakdown;
  final String disclaimer;

  const CostEstimateModel({
    required this.minCost,
    required this.maxCost,
    this.currency = 'MXN',
    required this.breakdown,
    required this.disclaimer,
  });

  factory CostEstimateModel.fromJson(Map<String, dynamic> json) {
    return CostEstimateModel(
      minCost: (json['minCost'] as num).toDouble(),
      maxCost: (json['maxCost'] as num).toDouble(),
      currency: json['currency'] ?? 'MXN',
      breakdown: CostBreakdown.fromJson(json['breakdown']),
      disclaimer: json['disclaimer'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'minCost': minCost,
      'maxCost': maxCost,
      'currency': currency,
      'breakdown': breakdown.toJson(),
      'disclaimer': disclaimer,
    };
  }

  @override
  List<Object?> get props => [minCost, maxCost, currency, breakdown, disclaimer];
}
