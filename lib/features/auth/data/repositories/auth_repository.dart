import 'package:proyecto/core/services/token_storage_service.dart';
import 'package:proyecto/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:proyecto/features/auth/data/models/user_model.dart';

class AuthRepository {
  final AuthRemoteDataSource _remoteDataSource;
  final TokenStorageService _tokenStorage;
  
  User? _user;

  AuthRepository({
    required AuthRemoteDataSource remoteDataSource,
    required TokenStorageService tokenStorage,
  }) : _remoteDataSource = remoteDataSource,
       _tokenStorage = tokenStorage;

  Future<User?> get currentUser async => _user;

  Future<User> login({required String email, required String password}) async {
    final response = await _remoteDataSource.login(email, password);
    
    await _tokenStorage.saveTokens(
      accessToken: response['accessToken'],
      refreshToken: response['refreshToken'],
    );
    
    _user = User.fromJson(response['user']);
    return _user!;
  }

  // ACTUALIZACIÓN: Usamos fullName
  Future<void> register({
    required String fullName,
    required String email,
    required String password,
    required String phone,
    required String role,
  }) async {
    final response = await _remoteDataSource.register(
      fullName: fullName,
      email: email,
      password: password,
      phone: phone,
      role: role,
    );

    // Si el backend devuelve tokens al registrarse (login automático), los guardamos
    if (response.containsKey('accessToken')) {
       await _tokenStorage.saveTokens(
        accessToken: response['accessToken'],
        refreshToken: response['refreshToken'],
      );
      if (response.containsKey('user')) {
        _user = User.fromJson(response['user']);
      }
    }
  }

  Future<void> logout() async {
    await _tokenStorage.deleteAllTokens();
    _user = null;
  }
  
 // --- NUEVOS MÉTODOS ---
  Future<void> requestPasswordReset(String email) async {
    await _remoteDataSource.requestPasswordReset(email);
  }

  Future<void> resetPassword({required String token, required String newPassword}) async {
    await _remoteDataSource.resetPassword(token, newPassword);
  }
}