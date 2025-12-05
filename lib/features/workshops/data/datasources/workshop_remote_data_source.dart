import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart'; // Para debugPrint
import 'package:proyecto/core/api/api_client.dart';
import 'package:proyecto/features/workshops/data/models/review_model.dart';
import 'package:proyecto/features/workshops/data/models/workshop_model.dart';
import 'package:proyecto/features/workshops/data/models/specialty_model.dart';
import 'package:proyecto/features/workshops/data/models/schedule_model.dart';

class WorkshopRemoteDataSource {
  final ApiClient _apiClient;

  // Base URL: .../api/workshops/workshops
  WorkshopRemoteDataSource({required ApiClient apiClient}) : _apiClient = apiClient;

  // ===========================================================================
  // SECCIÓN: CLIENTE (BÚSQUEDA)
  // ===========================================================================

  // GET .../search/nearby
  Future<List<Workshop>> getNearbyWorkshops({
    double? latitude,
    double? longitude,
    double radiusKm = 20.0,
    double? minRating,
    String? priceRange,
    String? specialtyType,
  }) async {
    try {
      // Usar ubicación proporcionada o valores por defecto (Tuxtla Gutiérrez)
      final double lat = latitude ?? 16.7516;
      final double lon = longitude ?? -93.1134;

      final Map<String, dynamic> queryParams = {
        'latitude': lat,
        'longitude': lon,
        'radiusKm': radiusKm,
      };

      if (minRating != null) queryParams['minRating'] = minRating;
      if (priceRange != null) queryParams['priceRange'] = priceRange;
      if (specialtyType != null) queryParams['specialtyType'] = specialtyType;

      final response = await _apiClient.dio.get('/search/nearby', queryParameters: queryParams);

      final List<dynamic> workshopListJson = response.data;
      return workshopListJson.map((json) => Workshop.fromJson(json)).toList();
    } on DioException catch (e) {
      final data = e.response?.data;
      final errorMessage = (data is Map<String, dynamic> && data['message'] != null)
          ? data['message'].toString()
          : e.message;
      throw Exception('Error al obtener talleres cercanos: $errorMessage');
    }
  }

  // GET /:id (Detalle)
  Future<Workshop> getWorkshopById(String id) async {
    try {
      final response = await _apiClient.dio.get('/$id');
      return Workshop.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw Exception('Error al obtener detalle: ${e.message}');
    }
  }

  // ===========================================================================
  // SECCIÓN: GENERAL / WORKSHOP ADMIN / SYSTEM ADMIN
  // ===========================================================================

  // --- MÉTODO CORREGIDO: getAllWorkshops ---
  // Este método obtiene TODOS los talleres (usado para filtrar localmente o por admin)
  Future<List<Workshop>> getAllWorkshops({int limit = 100, bool? isApproved}) async {
    try {
      final Map<String, dynamic> queryParams = {
        'limit': limit,
      };

      // Si es necesario enviar el filtro al backend
      if (isApproved != null) {
        queryParams['isApproved'] = isApproved.toString();
      }

      // GET a la raíz '/'
      final response = await _apiClient.dio.get('/', queryParameters: queryParams);
      
      final data = response.data;
      List<dynamic> list = [];

      if (data is Map && data.containsKey('workshops')) {
        list = data['workshops'];
      } else if (data is List) {
        list = data;
      }

      return list.map((json) => Workshop.fromJson(json)).toList();
    } on DioException catch (e) {
      throw Exception('Error al listar talleres: ${e.message}');
    }
  }

  // GET /me/workshops
  Future<List<Workshop>> getMyWorkshops() async {
     try {
      final response = await _apiClient.dio.get('/me/workshops');
      final List<dynamic> list = response.data['workshops'];
      return list.map((json) => Workshop.fromJson(json)).toList();
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) return [];
      throw Exception('Error al obtener mis talleres: ${e.message}');
    }
  }

  // POST / (Crear Taller)
  Future<void> createWorkshop(Map<String, dynamic> data) async {
    try {
      await _apiClient.dio.post('', data: data);
    } on DioException catch (e) {
      final responseData = e.response?.data;
      final msg = (responseData is Map<String, dynamic> && responseData['message'] != null)
          ? responseData['message'].toString()
          : e.message;
      throw Exception('Error al crear taller: $msg');
    }
  }

  // PATCH /:id (Actualizar Taller)
  Future<void> updateWorkshop(String id, Map<String, dynamic> data) async {
    try {
      await _apiClient.dio.patch('/$id', data: data);
    } on DioException catch (e) {
      throw Exception('Error al actualizar taller: ${e.message}');
    }
  }

  // DELETE /:id (Eliminar Taller)
  Future<void> deleteWorkshop(String id) async {
    try {
      await _apiClient.dio.delete('/$id');
    } on DioException catch (e) {
      throw Exception('Error al eliminar taller: ${e.message}');
    }
  }

  // --- SYSTEM ADMIN ESPECÍFICO ---

  // GET /admin/pending
  Future<List<Workshop>> getPendingWorkshops() async {
    try {
      final response = await _apiClient.dio.get('/admin/pending');
      final List<dynamic> list = response.data['workshops'];
      return list.map((json) => Workshop.fromJson(json)).toList();
    } on DioException catch (e) {
      debugPrint('❌ Error getPendingWorkshops: ${e.message}');
      throw Exception('Error al obtener talleres pendientes: ${e.message}');
    }
  }

  // PATCH /:id/approve
  Future<void> approveWorkshop(String id) async {
    try {
      await _apiClient.dio.patch('/$id/approve');
    } on DioException catch (e) {
      throw Exception('Error al aprobar taller: ${e.message}');
    }
  }

  // PATCH /:id/reject
  Future<void> rejectWorkshop(String id) async {
    try {
      await _apiClient.dio.patch('/$id/reject');
    } on DioException catch (e) {
      throw Exception('Error al rechazar taller: ${e.message}');
    }
  }

  // ===========================================================================
  // SECCIÓN: SUB-RECURSOS (Horarios, Especialidades, Reseñas)
  // ===========================================================================

  // GET /:id/schedule (Obtener horarios)
  Future<List<WorkshopSchedule>> getSchedule(String workshopId) async {
    try {
      final response = await _apiClient.dio.get('/$workshopId/schedule');
      final List<dynamic> list = response.data;
      return list.map((json) => WorkshopSchedule.fromJson(json)).toList();
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) return [];
      throw Exception('Error al obtener horarios: ${e.message}');
    }
  }

  // PUT /:id/schedule (Configurar horarios)
  Future<void> setSchedule(String workshopId, List<Map<String, dynamic>> schedule) async {
    try {
      await _apiClient.dio.put('/$workshopId/schedule', data: schedule);
    } on DioException catch (e) {
      throw Exception('Error al guardar horario: ${e.message}');
    }
  }

  // GET /:id/specialties (Obtener especialidades)
  Future<List<WorkshopSpecialty>> getSpecialties(String workshopId) async {
    try {
      final response = await _apiClient.dio.get('/$workshopId/specialties');
      final List<dynamic> list = response.data;
      return list.map((json) => WorkshopSpecialty.fromJson(json)).toList();
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) return [];
      throw Exception('Error al obtener especialidades: ${e.message}');
    }
  }

  // POST /:id/specialties (Agregar especialidad)
  Future<void> addSpecialty(String workshopId, Map<String, dynamic> data) async {
    try {
      await _apiClient.dio.post('/$workshopId/specialties', data: data);
    } on DioException catch (e) {
      throw Exception('Error al agregar especialidad: ${e.message}');
    }
  }

  // DELETE /:id/specialties/:specialtyId (Eliminar especialidad)
  Future<void> deleteSpecialty(String workshopId, String specialtyId) async {
    try {
      await _apiClient.dio.delete('/$workshopId/specialties/$specialtyId');
    } on DioException catch (e) {
      throw Exception('Error al eliminar especialidad: ${e.message}');
    }
  }

  // --- RESEÑAS (REVIEWS) ---

  // GET /:id/reviews (Obtener reseñas)
  Future<List<Review>> getReviews(String workshopId) async {
    try {
      final response = await _apiClient.dio.get('/$workshopId/reviews');
      // La respuesta es paginada { reviews: [], ... }
      final List<dynamic> list = response.data['reviews'];
      return list.map((json) => Review.fromJson(json)).toList();
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) return [];
      throw Exception('Error al obtener reseñas: ${e.message}');
    }
  }

  // GET /:id/reviews/statistics
  Future<Map<String, dynamic>> getReviewStatistics(String workshopId) async {
    try {
      final response = await _apiClient.dio.get('/$workshopId/reviews/statistics');
      return response.data;
    } on DioException catch (e) {
      throw Exception('Error al obtener estadísticas: ${e.message}');
    }
  }

  // POST crear review
  Future<void> createReview(String workshopId, Map<String, dynamic> data) async {
    try {
      await _apiClient.dio.post('/$workshopId/reviews', data: data);
    } on DioException catch (e) {
      final responseData = e.response?.data;
      final msg = (responseData is Map<String, dynamic> && responseData['message'] != null)
          ? responseData['message'].toString()
          : e.message;
      throw Exception('Error al enviar reseña: $msg');
    }
  }

  Future<void> updateReview(String workshopId, String reviewId, Map<String, dynamic> data) async {
    try {
      await _apiClient.dio.patch('/$workshopId/reviews/$reviewId', data: data);
    } on DioException catch (e) {
      throw Exception('Error al actualizar reseña: ${e.message}');
    }
  }

  Future<void> replyToReview(String workshopId, String reviewId, String response) async {
    try {
      await _apiClient.dio.post('/$workshopId/reviews/$reviewId/response', data: {'response': response});
    } on DioException catch (e) {
      throw Exception('Error al responder reseña: ${e.message}');
    }
  }

  Future<void> deleteReview(String workshopId, String reviewId) async {
    try {
      await _apiClient.dio.delete('/$workshopId/reviews/$reviewId');
    } on DioException catch (e) {
      throw Exception('Error al eliminar reseña: ${e.message}');
    }
  }
}