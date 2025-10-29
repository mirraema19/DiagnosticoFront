import 'package:proyecto/core/theme/app_theme.dart';
import 'package:proyecto/features/auth/data/models/user_model.dart';
import 'package:proyecto/features/auth/presentation/bloc/auth_bloc/auth_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final User? user = context.select((AuthBloc bloc) => bloc.state.user);

    if (user == null) {
      return const Scaffold(body: Center(child: Text('Usuario no encontrado.')));
    }

    // CORRECCIÓN: Se utiliza un Scaffold con un AppBar transparente y un body flexible.
    return Scaffold(
      // Hacemos que el body se extienda detrás del AppBar
      extendBodyBehindAppBar: true, 
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('Mi Perfil'),
        // El color del texto y los iconos del AppBar se heredarán del tema,
        // pero podemos asegurarnos de que sean blancos para el fondo oscuro.
        foregroundColor: Colors.white,
      ),
      // CORRECCIÓN: Usamos SingleChildScrollView para evitar overflows en pantallas pequeñas.
      body: SingleChildScrollView(
        child: Column(
          children: [
            // SECCIÓN 1: Cabecera con el fondo y la información del usuario
            _buildHeader(context, user),

            // SECCIÓN 2: Contenido principal (tarjetas y botón)
            _buildContent(context, user),
          ],
        ),
      ),
    );
  }

  // Widget para la cabecera
  Widget _buildHeader(BuildContext context, User user) {
    return Stack(
      clipBehavior: Clip.none, // Permite que el avatar se salga del Stack
      alignment: Alignment.center,
      children: [
        // Fondo con gradiente y forma curva
        Container(
          height: 200,
          decoration: const BoxDecoration(
            gradient: AppTheme.primaryGradient,
            borderRadius: BorderRadius.vertical(bottom: Radius.circular(30)),
          ),
        ),
        // Posicionamos el avatar para que quede mitad dentro, mitad fuera
        Positioned(
          top: 130, // Aproximadamente AppBar height + un poco de espacio
          child: Column(
            children: [
              const CircleAvatar(
                radius: 55,
                backgroundColor: AppTheme.backgroundColor, // Borde blanco
                child: CircleAvatar(
                  radius: 50,
                  backgroundColor: Colors.white,
                  child: Icon(Icons.person, size: 60, color: AppTheme.primaryColor),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                user.name,
                style: Theme.of(context)
                    .textTheme
                    .headlineSmall
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Text(user.email, style: Theme.of(context).textTheme.bodyMedium),
            ],
          ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.3),
        ),
      ],
    );
  }

  // Widget para el contenido debajo de la cabecera
  Widget _buildContent(BuildContext context, User user) {
    return Padding(
      // Añadimos un espacio superior grande para dejar sitio a la cabecera y al avatar
      padding: const EdgeInsets.only(top: 130, left: 16, right: 16, bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  _buildProfileInfoTile(
                    context, Icons.directions_car, 'Vehículo', user.vehicleModel),
                  const Divider(height: 24),
                  _buildProfileInfoTile(
                    context, Icons.history, 'Diagnósticos', '3 completados'),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              context.read<AuthBloc>().add(AuthLogoutRequested());
            },
            icon: const Icon(Icons.logout),
            label: const Text('CERRAR SESIÓN'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade400,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ).animate().fadeIn(delay: 400.ms),
    );
  }

  Widget _buildProfileInfoTile(
      BuildContext context, IconData icon, String title, String subtitle) {
    return ListTile(
      leading: Icon(icon, color: Theme.of(context).primaryColor),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Text(subtitle),
    );
  }
}