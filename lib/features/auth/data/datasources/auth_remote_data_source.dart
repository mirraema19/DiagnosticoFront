import 'package:proyecto/core/api/api_client.dart';
import 'package:dio/dio.dart';

class AuthRemoteDataSource {
  final ApiClient _apiClient;

  AuthRemoteDataSource({required ApiClient apiClient}) : _apiClient = apiClient;

  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await _apiClient.dio.post(
        '/auth/login',
        data: {
          'email': email,
          'password': password,
        },
      );

      // ACTUALIZACIÓN BASADA EN AuthResponseDto:
      // La respuesta tiene la estructura:
      // {
      //   "user": { ... },
      //   "tokens": { "accessToken": "...", "refreshToken": "..." }
      // }
      
      final data = response.data;
      return {
        'user': data['user'],
        'accessToken': data['tokens']['accessToken'],
        'refreshToken': data['tokens']['refreshToken'],
      };
    } on DioException catch (e) {
      final errorMessage = (e.response?.data['message'] is List)
          ? e.response?.data['message'].join('\n')
          : e.response?.data['message'];
      throw Exception('Error de inicio de sesión: ${errorMessage ?? e.message}');
    }
  }

  // ACTUALIZACIÓN BASADA EN RegisterDto:
  // Se usa 'fullName' y 'role' es obligatorio.
  Future<Map<String, dynamic>> register({
    required String fullName,
    required String email,
    required String password,
    required String phone,
    required String role,
  }) async {
    try {
      final response = await _apiClient.dio.post(
        '/auth/register',
        data: {
          'email': email,
          'password': password,
          'fullName': fullName, // Campo único según RegisterDto
          'phone': phone,
          'role': role, // 'VEHICLE_OWNER' o 'WORKSHOP_ADMIN'
        },
      );
      
      // El registro también devuelve tokens y usuario según el backend típico,
      // o puede devolver solo 201 Created. Asumimos que devuelve AuthResponseDto (login automático).
      if (response.data['tokens'] != null) {
         return {
          'user': response.data['user'],
          'accessToken': response.data['tokens']['accessToken'],
          'refreshToken': response.data['tokens']['refreshToken'],
        };
      }
      return response.data;
      
    } on DioException catch (e) {
      final errorMessage = (e.response?.data['message'] is List)
          ? e.response?.data['message'].join('\n')
          : e.response?.data['message'];
      throw Exception('Error de registro: ${errorMessage ?? e.message}');
    }
    
  }

 // --- NUEVO: SOLICITAR RESET DE CONTRASEÑA ---
  Future<void> requestPasswordReset(String email) async {
    try {
      await _apiClient.dio.post(
        '/auth/request-password-reset', // Verifica si esta es la ruta exacta en tu Controller
        data: {'email': email},
      );
    } on DioException catch (e) {
      final errorMessage = e.response?.data['message'] ?? e.message;
      throw Exception('Error al solicitar recuperación: $errorMessage');
    }
  }

  // --- NUEVO: RESTABLECER CONTRASEÑA ---
  Future<void> resetPassword(String token, String newPassword) async {
    try {
      await _apiClient.dio.post(
        '/auth/reset-password', // Verifica si esta es la ruta exacta en tu Controller
        data: {
          'token': token,
          'newPassword': newPassword,
        },
      );
    } on DioException catch (e) {
      final errorMessage = e.response?.data['message'] ?? e.message;
      throw Exception('Error al restablecer contraseña: $errorMessage');
    }
  }
}