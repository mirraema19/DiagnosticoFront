import 'package:dio/dio.dart';
import 'package:proyecto/core/api/api_client.dart';
import 'package:proyecto/features/workshop_admin/data/models/review_model.dart';
import 'package:proyecto/features/workshop_admin/data/models/specialty_model.dart';
import 'package:proyecto/features/workshop_admin/data/models/schedule_model.dart';

class WorkshopAdminRemoteDataSource {
  final ApiClient apiClient;

  WorkshopAdminRemoteDataSource({required this.apiClient});

  // ==================== REVIEWS ====================

  /// Obtener reseñas de un taller con paginación
  /// GET /workshops/{workshopId}/reviews
  Future<PaginatedReviewsModel> getReviews({
    required String workshopId,
    int page = 1,
    int limit = 10,
    String sortBy = 'recent',
  }) async {
    try {
      final response = await apiClient.dio.get(
        '/$workshopId/reviews',
        queryParameters: {
          'page': page,
          'limit': limit,
          'sortBy': sortBy,
        },
      );
      return PaginatedReviewsModel.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Obtener estadísticas de reseñas de un taller
  /// GET /workshops/{workshopId}/reviews/statistics
  Future<ReviewStatisticsModel> getReviewStatistics({
    required String workshopId,
  }) async {
    try {
      final response = await apiClient.dio.get(
        '/$workshopId/reviews/statistics',
      );
      return ReviewStatisticsModel.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Responder a una reseña (solo propietario del taller)
  /// POST /workshops/{workshopId}/reviews/{reviewId}/response
  Future<ReviewModel> respondToReview({
    required String workshopId,
    required String reviewId,
    required String responseText,
  }) async {
    try {
      final response = await apiClient.dio.post(
        '/$workshopId/reviews/$reviewId/response',
        data: {
          'responseText': responseText,
        },
      );
      return ReviewModel.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // ==================== SPECIALTIES ====================

  /// Obtener especialidades de un taller
  /// GET /workshops/{workshopId}/specialties
  Future<List<WorkshopSpecialtyModel>> getSpecialties({
    required String workshopId,
  }) async {
    try {
      final response = await apiClient.dio.get(
        '/$workshopId/specialties',
      );
      final List<dynamic> data = response.data;
      return data.map((json) => WorkshopSpecialtyModel.fromJson(json)).toList();
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Agregar especialidad a un taller (solo propietario)
  /// POST /workshops/{workshopId}/specialties
  Future<WorkshopSpecialtyModel> addSpecialty({
    required String workshopId,
    required String specialtyType,
    String? description,
    int? yearsOfExperience,
  }) async {
    try {
      final response = await apiClient.dio.post(
        '/$workshopId/specialties',
        data: {
          'specialtyType': specialtyType,
          'description': description,
          'yearsOfExperience': yearsOfExperience,
        },
      );
      return WorkshopSpecialtyModel.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      // Error 409 = Especialidad duplicada
      if (e.response?.statusCode == 409) {
        throw Exception('Esta especialidad ya existe para el taller');
      }
      throw _handleError(e);
    }
  }

  /// Eliminar especialidad de un taller (solo propietario)
  /// DELETE /workshops/{workshopId}/specialties/{specialtyId}
  Future<void> deleteSpecialty({
    required String workshopId,
    required String specialtyId,
  }) async {
    try {
      await apiClient.dio.delete(
        '/$workshopId/specialties/$specialtyId',
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // ==================== SCHEDULE ====================

  /// Obtener horarios de un taller
  /// GET /workshops/{workshopId}/schedule
  Future<List<WorkshopScheduleModel>> getSchedule({
    required String workshopId,
  }) async {
    try {
      final response = await apiClient.dio.get(
        '/$workshopId/schedule',
      );
      final List<dynamic> data = response.data;
      return data.map((json) => WorkshopScheduleModel.fromJson(json)).toList();
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Configurar horarios de un taller (REEMPLAZA todos los horarios existentes)
  /// PUT /workshops/{workshopId}/schedule
  /// IMPORTANTE: Enviar el array completo de 7 días, no es actualización parcial
  Future<List<WorkshopScheduleModel>> setSchedule({
    required String workshopId,
    required List<CreateScheduleDto> schedules,
  }) async {
    try {
      final response = await apiClient.dio.put(
        '/$workshopId/schedule',
        data: schedules.map((s) => s.toJson()).toList(),
      );
      final List<dynamic> data = response.data;
      return data.map((json) => WorkshopScheduleModel.fromJson(json)).toList();
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // ==================== LOCATION & SEARCH ====================

  /// Buscar talleres cercanos por ubicación
  /// GET /workshops/search/nearby
  Future<List<Map<String, dynamic>>> searchNearbyWorkshops({
    required double latitude,
    required double longitude,
    double radiusKm = 10.0,
    double? minRating,
    String? priceRange,
    String? specialtyType,
  }) async {
    try {
      // IMPORTANTE: La ruta base ya incluye /workshops/workshops
      // Necesitamos hacer la petición a la raíz y agregar /search/nearby
      final response = await apiClient.dio.get(
        '/search/nearby',
        queryParameters: {
          'latitude': latitude,
          'longitude': longitude,
          'radiusKm': radiusKm,
          if (minRating != null) 'minRating': minRating,
          if (priceRange != null) 'priceRange': priceRange,
          if (specialtyType != null) 'specialtyType': specialtyType,
        },
      );
      return List<Map<String, dynamic>>.from(response.data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // ==================== ERROR HANDLING ====================

  Exception _handleError(DioException e) {
    if (e.response != null) {
      final statusCode = e.response!.statusCode;
      final data = e.response!.data;
      final message = (data is Map<String, dynamic> && data['message'] != null)
          ? data['message'].toString()
          : 'Error desconocido';

      switch (statusCode) {
        case 400:
          return Exception('Datos inválidos: $message');
        case 401:
          return Exception('No autenticado. Por favor inicia sesión nuevamente.');
        case 403:
          return Exception('No tienes permisos para realizar esta acción');
        case 404:
          return Exception('Recurso no encontrado');
        case 409:
          return Exception('Conflicto: $message');
        case 500:
          return Exception('Error del servidor. Intenta más tarde.');
        default:
          return Exception('Error: $message');
      }
    } else if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout) {
      return Exception('Tiempo de espera agotado. Verifica tu conexión.');
    } else if (e.type == DioExceptionType.connectionError) {
      return Exception('Error de conexión. Verifica tu internet.');
    } else {
      return Exception('Error inesperado: ${e.message}');
    }
  }
}
