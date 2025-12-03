import 'package:proyecto/features/diagnosis/data/models/classification_model.dart';

/// Maps diagnosis problem categories to workshop specialties
/// This maps directly to the backend SpecialtyType enum
class CategorySpecialtyMapper {
  /// Returns the workshop specialty string for a given problem category
  /// Maps to backend's SpecialtyType enum values
  static String? getWorkshopSpecialty(ProblemCategory category) {
    switch (category) {
      case ProblemCategory.BRAKES:
        return 'BRAKES';
      case ProblemCategory.ENGINE:
        return 'ENGINE'; // Corregido: era ENGINE_REPAIR
      case ProblemCategory.TRANSMISSION:
        return 'TRANSMISSION';
      case ProblemCategory.ELECTRICAL:
        return 'ELECTRICAL';
      case ProblemCategory.AIR_CONDITIONING:
        return 'AIR_CONDITIONING';
      case ProblemCategory.SUSPENSION:
        return 'SUSPENSION';
      case ProblemCategory.EXHAUST:
        return 'EXHAUST'; // Mapped to closest specialty
      case ProblemCategory.TIRES:
        return 'TIRE_SERVICE';
      case ProblemCategory.BATTERY:
        return 'ELECTRICAL'; // Battery falls under electrical
      case ProblemCategory.LIGHTS:
        return 'ELECTRICAL'; // Lights fall under electrical
      case ProblemCategory.FUEL_SYSTEM:
        return 'GENERAL_MAINTENANCE'; // Fuel system → general maintenance
      case ProblemCategory.COOLING_SYSTEM:
        return 'GENERAL_MAINTENANCE'; // Cooling → general maintenance
      case ProblemCategory.OTHER:
        return 'GENERAL_MAINTENANCE'; // Other → general maintenance
    }
  }
}
