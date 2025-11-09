import 'package:proyecto/features/auth/data/repositories/auth_repository.dart';
import 'package:flutter/material.dart';
import 'package:proyecto/app.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
// --- IMPORTACIÓN NUEVA ---
import 'package:intl/date_symbol_data_local.dart';

// --- MODIFICACIÓN: La función main ahora es async ---
void main() async {
  // Asegura que los bindings de Flutter estén inicializados antes de cualquier otra cosa
  WidgetsFlutterBinding.ensureInitialized();

  // --- MODIFICACIÓN: Inicializamos el formato de fecha para toda la app aquí ---
  // Esto carga los datos para el español y evita el error en cualquier pantalla.
  await initializeDateFormatting('es_ES', null);

  // El resto del código se mantiene igual
  final authRepository = AuthRepository();

  runApp(
    RepositoryProvider.value(
      value: authRepository,
      child: const MyApp(),
    ),
  );
}