import 'package:proyecto/features/workshop_admin/data/datasources/workshop_admin_remote_data_source.dart';
import 'package:proyecto/features/workshop_admin/data/models/review_model.dart';
import 'package:proyecto/features/workshop_admin/data/models/specialty_model.dart';
import 'package:proyecto/features/workshop_admin/data/models/schedule_model.dart';

class WorkshopAdminRepository {
  final WorkshopAdminRemoteDataSource remoteDataSource;

  WorkshopAdminRepository({required this.remoteDataSource});

  // ==================== REVIEWS ====================

  Future<PaginatedReviewsModel> getReviews({
    required String workshopId,
    int page = 1,
    int limit = 10,
    String sortBy = 'recent',
  }) async {
    return await remoteDataSource.getReviews(
      workshopId: workshopId,
      page: page,
      limit: limit,
      sortBy: sortBy,
    );
  }

  Future<ReviewStatisticsModel> getReviewStatistics({
    required String workshopId,
  }) async {
    return await remoteDataSource.getReviewStatistics(
      workshopId: workshopId,
    );
  }

  Future<ReviewModel> respondToReview({
    required String workshopId,
    required String reviewId,
    required String responseText,
  }) async {
    if (responseText.trim().isEmpty) {
      throw Exception('La respuesta no puede estar vacía');
    }
    if (responseText.length > 500) {
      throw Exception('La respuesta no puede exceder 500 caracteres');
    }

    return await remoteDataSource.respondToReview(
      workshopId: workshopId,
      reviewId: reviewId,
      responseText: responseText,
    );
  }

  // ==================== SPECIALTIES ====================

  Future<List<WorkshopSpecialtyModel>> getSpecialties({
    required String workshopId,
  }) async {
    return await remoteDataSource.getSpecialties(
      workshopId: workshopId,
    );
  }

  Future<WorkshopSpecialtyModel> addSpecialty({
    required String workshopId,
    required String specialtyType,
    String? description,
    int? yearsOfExperience,
  }) async {
    // Validaciones
    if (description != null && description.length > 200) {
      throw Exception('La descripción no puede exceder 200 caracteres');
    }
    if (yearsOfExperience != null && yearsOfExperience < 0) {
      throw Exception('Los años de experiencia no pueden ser negativos');
    }
    if (yearsOfExperience != null && yearsOfExperience > 100) {
      throw Exception('Los años de experiencia no pueden exceder 100');
    }

    return await remoteDataSource.addSpecialty(
      workshopId: workshopId,
      specialtyType: specialtyType,
      description: description,
      yearsOfExperience: yearsOfExperience,
    );
  }

  Future<void> deleteSpecialty({
    required String workshopId,
    required String specialtyId,
  }) async {
    return await remoteDataSource.deleteSpecialty(
      workshopId: workshopId,
      specialtyId: specialtyId,
    );
  }

  // ==================== SCHEDULE ====================

  Future<List<WorkshopScheduleModel>> getSchedule({
    required String workshopId,
  }) async {
    return await remoteDataSource.getSchedule(
      workshopId: workshopId,
    );
  }

  Future<List<WorkshopScheduleModel>> setSchedule({
    required String workshopId,
    required List<CreateScheduleDto> schedules,
  }) async {
    // Validación: Debe haber exactamente 7 días
    if (schedules.length != 7) {
      throw Exception('Debes configurar los 7 días de la semana');
    }

    // Validar que cada día tenga horarios válidos si no está cerrado
    for (final schedule in schedules) {
      if (!schedule.isClosed) {
        if (schedule.openTime == null || schedule.closeTime == null) {
          throw Exception('Debes especificar horarios de apertura y cierre para días abiertos');
        }
        
        // Validar formato de hora (HH:mm)
        final timeRegex = RegExp(r'^([0-1]?[0-9]|2[0-3]):[0-5][0-9]$');
        if (!timeRegex.hasMatch(schedule.openTime!)) {
          throw Exception('Formato de hora de apertura inválido. Usa HH:mm');
        }
        if (!timeRegex.hasMatch(schedule.closeTime!)) {
          throw Exception('Formato de hora de cierre inválido. Usa HH:mm');
        }

        // Validar que la hora de cierre sea después de la de apertura
        final openParts = schedule.openTime!.split(':');
        final closeParts = schedule.closeTime!.split(':');
        final openMinutes = int.parse(openParts[0]) * 60 + int.parse(openParts[1]);
        final closeMinutes = int.parse(closeParts[0]) * 60 + int.parse(closeParts[1]);
        
        if (closeMinutes <= openMinutes) {
          throw Exception('La hora de cierre debe ser después de la hora de apertura');
        }
      }
    }

    return await remoteDataSource.setSchedule(
      workshopId: workshopId,
      schedules: schedules,
    );
  }

  // ==================== LOCATION & SEARCH ====================

  Future<List<Map<String, dynamic>>> searchNearbyWorkshops({
    required double latitude,
    required double longitude,
    double radiusKm = 10.0,
    double? minRating,
    String? priceRange,
    String? specialtyType,
  }) async {
    // Validaciones
    if (latitude < -90 || latitude > 90) {
      throw Exception('Latitud inválida. Debe estar entre -90 y 90');
    }
    if (longitude < -180 || longitude > 180) {
      throw Exception('Longitud inválida. Debe estar entre -180 y 180');
    }
    if (radiusKm <= 0 || radiusKm > 100) {
      throw Exception('El radio debe estar entre 0 y 100 km');
    }
    if (minRating != null && (minRating < 0 || minRating > 5)) {
      throw Exception('La calificación mínima debe estar entre 0 y 5');
    }
    if (priceRange != null && !['LOW', 'MEDIUM', 'HIGH'].contains(priceRange)) {
      throw Exception('Rango de precio inválido');
    }

    return await remoteDataSource.searchNearbyWorkshops(
      latitude: latitude,
      longitude: longitude,
      radiusKm: radiusKm,
      minRating: minRating,
      priceRange: priceRange,
      specialtyType: specialtyType,
    );
  }
}
