import 'package:dio/dio.dart';
import 'package:proyecto/core/services/token_storage_service.dart';

class ApiClient {
  final TokenStorageService _tokenStorage;
  final String baseUrl;
  late final Dio dio;

  ApiClient({required this.baseUrl, required TokenStorageService tokenStorage})
      : _tokenStorage = tokenStorage {
    
    // --- CORRECCIÓN CLAVE AQUÍ ---
    // Aumentamos los tiempos de espera para darle tiempo a Render de despertar.
    final options = BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 60), // Tiempo para establecer conexión
      receiveTimeout: const Duration(seconds: 60), // Tiempo para recibir la respuesta
      sendTimeout: const Duration(seconds: 60),    // Tiempo para enviar la petición
    );

    dio = Dio(options);
    
    // Interceptor para añadir el token de autorización a las cabeceras
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          if (!options.path.contains('/auth/login') && !options.path.contains('/auth/register')) {
            final token = await _tokenStorage.getAccessToken();
            if (token != null) {
              options.headers['Authorization'] = 'Bearer $token';
            }
          }
          return handler.next(options);
        },
        onError: (DioException e, handler) async {
          return handler.next(e);
        },
      ),
    );
  }
}