import 'package:proyecto/features/auth/data/models/user_model.dart';

class AuthRepository {
  // --- CORRECCIÓN: Singleton para mantener el estado de los usuarios ---
  static final AuthRepository _instance = AuthRepository._internal();
  factory AuthRepository() {
    return _instance;
  }
  AuthRepository._internal();

  // Guardamos el usuario logueado actualmente
  User? _user;
  
  // Simulación de base de datos de usuarios
  final Map<String, User> _registeredUsers = {
    'test@test.com': const User(
        id: 'user123',
        name: 'Alex Reyes',
        email: 'test@test.com',
        vehicleModel: 'Toyota Corolla 2022',
    )
  };
  final Map<String, String> _passwords = {'test@test.com': 'password'};


  Future<User?> get currentUser async => _user;

  Future<User> login({required String email, required String password}) async {
    await Future.delayed(const Duration(seconds: 1));
    if (_registeredUsers.containsKey(email) && _passwords[email] == password) {
      _user = _registeredUsers[email];
      return _user!;
    } else {
      throw Exception('Credenciales incorrectas');
    }
  }

  // --- NUEVO MÉTODO PARA REGISTRAR USUARIOS ---
  Future<void> register({required String name, required String email, required String password}) async {
    await Future.delayed(const Duration(seconds: 1));
    if (_registeredUsers.containsKey(email)) {
      throw Exception('El email ya está registrado.');
    }
    _registeredUsers[email] = User(
      id: 'user${DateTime.now().millisecondsSinceEpoch}',
      name: name,
      email: email,
      vehicleModel: 'Sin vehículo',
    );
    _passwords[email] = password;
  }

  Future<void> logout() async {
    await Future.delayed(const Duration(milliseconds: 500));
    _user = null;
  }
}