import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

// Esta pantalla redirige a la nueva pantalla de crear cita
// Se mantiene para compatibilidad con código existente
class AddEditAppointmentScreen extends StatelessWidget {
  const AddEditAppointmentScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Redirigir automáticamente a la nueva pantalla
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.go('/appointments/create');
    });

    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
