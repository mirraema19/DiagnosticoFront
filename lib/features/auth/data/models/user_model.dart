import 'package:equatable/equatable.dart';

class User extends Equatable {
  final String id;
  final String name; // Mapea a 'fullName' del backend
  final String email;
  final String? phone;
  final String role;
  final bool isVerified;

  const User({
    required this.id,
    required this.name,
    required this.email,
    this.phone,
    required this.role,
    required this.isVerified,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    // El backend usa 'fullName' en el UserDto o dentro de un objeto profile.
    // Usamos '??' para mayor seguridad en caso de que la estructura varíe ligeramente.
    return User(
      id: json['id'] ?? '',
      name: json['fullName'] ?? 'Usuario', 
      email: json['email'] ?? '',
      phone: json['phone'],
      role: json['role'] ?? 'VEHICLE_OWNER',
      isVerified: json['isVerified'] ?? false,
    );
  }

  @override
  List<Object?> get props => [id, name, email, phone, role, isVerified];
}