import 'package:proyecto/features/auth/data/models/user_model.dart';

class AuthRepository {
  User? _user;

  Future<User?> get currentUser async => _user;

  Future<User> login({required String email, required String password}) async {
    await Future.delayed(const Duration(seconds: 2));
    // Simulación de validación
    if (email == 'test@test.com' && password == 'password') {
      _user = const User(
        id: 'user123',
        name: 'Emanuel García',
        email: 'test@test.com',
        vehicleModel: 'Toyota Corolla 2022',
      );
      return _user!;
    } else {
      throw Exception('Credenciales incorrectas');
    }
  }

  Future<void> logout() async {
    await Future.delayed(const Duration(milliseconds: 500));
    _user = null;
  }
}