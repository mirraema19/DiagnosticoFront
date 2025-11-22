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

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('Mi Perfil'),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildHeader(context, user),
            _buildContent(context, user),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, User user) {
    return Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.center,
      children: [
        Container(
          height: 200,
          decoration: const BoxDecoration(
            gradient: AppTheme.primaryGradient,
            borderRadius: BorderRadius.vertical(bottom: Radius.circular(30)),
          ),
        ),
        Positioned(
          top: 130,
          child: Column(
            children: [
              const CircleAvatar(
                radius: 55,
                backgroundColor: AppTheme.backgroundColor,
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

  Widget _buildContent(BuildContext context, User user) {
    return Padding(
      padding: const EdgeInsets.only(top: 130, left: 16, right: 16, bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  // --- CORRECCIÓN AQUÍ ---
                  // Reemplazamos 'Vehículo' por 'Teléfono' o cualquier otro dato del usuario
                  _buildProfileInfoTile(
                    context,
                    Icons.phone_outlined,
                    'Teléfono',
                    user.phone ?? 'No especificado', // Mostramos el teléfono
                  ),
                  const Divider(height: 24),
                  _buildProfileInfoTile(
                    context,
                    Icons.history,
                    'Diagnósticos',
                    '3 completados', // Este es un dato simulado que podemos mantener por ahora
                  ),
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