import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:proyecto/app.dart';
import 'package:proyecto/core/services/service_locator.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('es_ES', null);

  // --- INICIALIZAR SERVICE LOCATOR ---
  setupLocator();

  // Ya no necesitamos instanciar el repositorio aquí
  runApp(const MyApp());
}