import 'package:proyecto/features/workshops/data/datasources/workshop_remote_data_source.dart';
import 'package:proyecto/features/workshops/data/models/review_model.dart';
import 'package:proyecto/features/workshops/data/models/workshop_model.dart';
import 'package:proyecto/features/workshops/data/models/specialty_model.dart';
import 'package:proyecto/features/workshops/data/models/schedule_model.dart';

class WorkshopRepository {
  final WorkshopRemoteDataSource _remoteDataSource;

  WorkshopRepository({required WorkshopRemoteDataSource remoteDataSource}) 
    : _remoteDataSource = remoteDataSource;

  // --- CLIENTE ---
  Future<List<Workshop>> fetchWorkshops({
    double? latitude,
    double? longitude,
    double? minRating,
    String? priceRange,
    String? specialtyType,
  }) async {
    return await _remoteDataSource.getNearbyWorkshops(
      latitude: latitude,
      longitude: longitude,
      minRating: minRating,
      priceRange: priceRange,
      specialtyType: specialtyType,
    );
  }

  /// Busca talleres por especialidad usando el filtro del backend
  /// Ya NO filtra en el cliente - delega al servidor para mayor eficiencia
  Future<List<Workshop>> fetchWorkshopsBySpecialty(
    String specialty, {
    double? latitude,
    double? longitude,
  }) async {
    // Delegar filtrado al backend (más eficiente)
    return await _remoteDataSource.getNearbyWorkshops(
      latitude: latitude,
      longitude: longitude,
      specialtyType: specialty,
    );
  }

  Future<Workshop> getWorkshopById(String id) async {
    return await _remoteDataSource.getWorkshopById(id);
  }

  // --- WORKSHOP ADMIN ---
  Future<List<Workshop>> getMyWorkshops(String userId) async {
    // Usamos el método getAllWorkshops del DataSource y filtramos
    final allWorkshops = await _remoteDataSource.getAllWorkshops(limit: 100);
    return allWorkshops.where((w) => w.ownerId == userId).toList();
  }

  Future<void> createWorkshop(Map<String, dynamic> data) => _remoteDataSource.createWorkshop(data);
  Future<void> updateWorkshop(String id, Map<String, dynamic> data) => _remoteDataSource.updateWorkshop(id, data);
  Future<void> deleteWorkshop(String id) => _remoteDataSource.deleteWorkshop(id);

  // --- SYSTEM ADMIN ---
  Future<List<Workshop>> getPendingWorkshops() async {
    return await _remoteDataSource.getPendingWorkshops();
  }

  Future<List<Workshop>> getAllApprovedWorkshops() async {
    // Obtenemos todos y filtramos por aprobados (por si el backend devuelve mixtos en '/')
    final all = await _remoteDataSource.getAllWorkshops(limit: 100);
    return all.where((w) => w.isApproved == true).toList();
  }

  Future<void> approveWorkshop(String id) => _remoteDataSource.approveWorkshop(id);
  Future<void> rejectWorkshop(String id) => _remoteDataSource.rejectWorkshop(id);
  
  // --- SUB-RECURSOS: SCHEDULE ---
  Future<List<WorkshopSchedule>> getSchedule(String workshopId) => _remoteDataSource.getSchedule(workshopId);
  Future<void> setSchedule(String id, List<Map<String, dynamic>> schedule) => _remoteDataSource.setSchedule(id, schedule);

  // --- SUB-RECURSOS: SPECIALTIES ---
  Future<List<WorkshopSpecialty>> getSpecialties(String workshopId) => _remoteDataSource.getSpecialties(workshopId);
  Future<void> addSpecialty(String id, Map<String, dynamic> data) => _remoteDataSource.addSpecialty(id, data);
  Future<void> deleteSpecialty(String workshopId, String specialtyId) => _remoteDataSource.deleteSpecialty(workshopId, specialtyId);

  // --- REVIEWS ---
  Future<void> createReview(String workshopId, Map<String, dynamic> data) => _remoteDataSource.createReview(workshopId, data);
  Future<void> updateReview(String workshopId, String reviewId, Map<String, dynamic> data) => _remoteDataSource.updateReview(workshopId, reviewId, data);
  Future<void> replyToReview(String workshopId, String reviewId, String response) => _remoteDataSource.replyToReview(workshopId, reviewId, response);
  Future<void> deleteReview(String workshopId, String reviewId) => _remoteDataSource.deleteReview(workshopId, reviewId);
  
  // CORRECCIÓN DE TIPO AQUÍ: Future<List<Review>>
  Future<List<Review>> getReviews(String workshopId) async {
     return _remoteDataSource.getReviews(workshopId);
  }
  
  Future<Map<String, dynamic>> getReviewStatistics(String workshopId) async {
     return _remoteDataSource.getReviewStatistics(workshopId);
  }
}