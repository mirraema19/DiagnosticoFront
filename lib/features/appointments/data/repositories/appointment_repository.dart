import 'package:proyecto/features/appointments/data/datasources/appointment_remote_data_source.dart';
import 'package:proyecto/features/appointments/data/models/appointment_model.dart';
import 'package:proyecto/features/appointments/data/models/progress_model.dart';
import 'package:proyecto/features/appointments/data/models/chat_message_model.dart';
import 'package:proyecto/features/appointments/data/models/notification_model.dart';

class AppointmentRepository {
  final AppointmentRemoteDataSource _remoteDataSource;

  AppointmentRepository({
    required AppointmentRemoteDataSource remoteDataSource,
  }) : _remoteDataSource = remoteDataSource;

  // =============================================
  // APPOINTMENT METHODS
  // =============================================

  /// Crear una nueva cita
  Future<AppointmentModel> createAppointment(CreateAppointmentDto dto) async {
    try {
      return await _remoteDataSource.createAppointment(dto);
    } catch (e) {
      throw Exception('Error al crear la cita: $e');
    }
  }

  /// Obtener todas las citas del usuario o taller
  Future<List<AppointmentModel>> getAppointments({
    String? status,
    int? limit,
    String? workshopId,
  }) async {
    try {
      return await _remoteDataSource.getAppointments(
        status: status,
        limit: limit,
        workshopId: workshopId,
      );
    } catch (e) {
      throw Exception('Error al obtener las citas: $e');
    }
  }

  /// Obtener una cita por ID
  Future<AppointmentModel> getAppointmentById(String id) async {
    try {
      return await _remoteDataSource.getAppointmentById(id);
    } catch (e) {
      throw Exception('Error al obtener la cita: $e');
    }
  }

  /// Actualizar una cita
  Future<AppointmentModel> updateAppointment(
    String id,
    UpdateAppointmentDto dto,
  ) async {
    try {
      return await _remoteDataSource.updateAppointment(id, dto);
    } catch (e) {
      throw Exception('Error al actualizar la cita: $e');
    }
  }

  /// Cancelar una cita
  Future<AppointmentModel> cancelAppointment(String id, String reason) async {
    try {
      return await _remoteDataSource.cancelAppointment(id, reason);
    } catch (e) {
      throw Exception('Error al cancelar la cita: $e');
    }
  }

  /// Completar una cita (solo para talleres)
  Future<AppointmentModel> completeAppointment(
    String id, {
    required double finalCost,
    String? notes,
  }) async {
    try {
      return await _remoteDataSource.completeAppointment(
        id,
        finalCost: finalCost,
        notes: notes,
      );
    } catch (e) {
      throw Exception('Error al completar la cita: $e');
    }
  }

  // =============================================
  // PROGRESS METHODS
  // =============================================

  /// Agregar progreso a una cita (solo para talleres)
  Future<ProgressModel> addProgress(
    String appointmentId,
    CreateProgressDto dto,
  ) async {
    try {
      return await _remoteDataSource.addProgress(appointmentId, dto);
    } catch (e) {
      throw Exception('Error al agregar progreso: $e');
    }
  }

  /// Obtener el progreso de una cita
  Future<List<ProgressModel>> getProgress(String appointmentId) async {
    try {
      return await _remoteDataSource.getProgress(appointmentId);
    } catch (e) {
      throw Exception('Error al obtener el progreso: $e');
    }
  }

  // =============================================
  // CHAT METHODS
  // =============================================

  /// Enviar un mensaje en el chat de una cita
  Future<ChatMessageModel> sendMessage(
    String appointmentId,
    SendMessageDto dto,
  ) async {
    try {
      return await _remoteDataSource.sendMessage(appointmentId, dto);
    } catch (e) {
      throw Exception('Error al enviar el mensaje: $e');
    }
  }

  /// Obtener mensajes del chat de una cita
  Future<List<ChatMessageModel>> getChatMessages(
    String appointmentId, {
    int? limit,
  }) async {
    try {
      return await _remoteDataSource.getChatMessages(
        appointmentId,
        limit: limit,
      );
    } catch (e) {
      throw Exception('Error al obtener los mensajes: $e');
    }
  }

  // =============================================
  // NOTIFICATION METHODS
  // =============================================

  /// Obtener todas las notificaciones del usuario
  Future<List<NotificationModel>> getNotifications({int? limit}) async {
    try {
      return await _remoteDataSource.getNotifications(limit: limit);
    } catch (e) {
      throw Exception('Error al obtener las notificaciones: $e');
    }
  }

  /// Marcar una notificación como leída
  Future<NotificationModel> markNotificationAsRead(String id) async {
    try {
      return await _remoteDataSource.markNotificationAsRead(id);
    } catch (e) {
      throw Exception('Error al marcar la notificación como leída: $e');
    }
  }
}
