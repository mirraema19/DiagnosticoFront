import 'package:proyecto/features/auth/presentation/bloc/auth_bloc/auth_bloc.dart';
import 'package:proyecto/features/garaje/presentation/widgets/maintenance_card.dart';
import 'package:proyecto/features/garaje/presentation/widgets/vehicle_summary_card.dart';
import 'package:proyecto/features/home/presentation/bloc/home_bloc.dart';
import 'package:proyecto/features/garaje/presentation/data/models/vehicle_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final userName = context.select((AuthBloc bloc) => bloc.state.user?.name) ?? 'Usuario';
    
    return BlocProvider(
      create: (context) => HomeBloc()..add(LoadHomeData()),
      child: Scaffold(
        body: SafeArea(
          child: BlocBuilder<HomeBloc, HomeState>(
            builder: (context, state) {
              if (state is HomeLoading) {
                return const Center(child: CircularProgressIndicator());
              }
              if (state is HomeLoaded) {
                // --- CORRECCIÓN: Comprobamos si el vehículo es nulo ---
                if (state.primaryVehicle != null) {
                  // Si HAY un vehículo, mostramos el dashboard normal
                  return _buildDashboard(context, userName, state.primaryVehicle!);
                } else {
                  // Si NO HAY vehículo, mostramos una pantalla de bienvenida
                  return _buildWelcomeScreen(context, userName);
                }
              }
              if (state is HomeError) {
                // Esto ahora solo se mostrará si hay un error de red real
                return Center(child: Text(state.message));
              }
              return const SizedBox.shrink();
            },
          ),
        ),
      ),
    );
  }

  // --- WIDGET PARA EL DASHBOARD NORMAL ---
  Widget _buildDashboard(BuildContext context, String userName, Vehicle vehicle) {
    final textTheme = Theme.of(context).textTheme;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Hola, $userName', style: textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text('Tu asistente personal para tu auto', style: textTheme.bodyLarge?.copyWith(color: Colors.grey.shade600)),
          const SizedBox(height: 24),
          VehicleSummaryCard(vehicle: vehicle),
          const SizedBox(height: 24),
          _buildActionButton(context: context, label: 'Iniciar Diagnóstico', icon: Icons.document_scanner_outlined, isPrimary: true, onPressed: () => context.push('/diagnosis')),
          const SizedBox(height: 12),
          _buildActionButton(context: context, label: 'Buscar un Taller', icon: Icons.location_on_outlined, onPressed: () => context.push('/workshops')),
          const SizedBox(height: 12),
          _buildActionButton(context: context, label: 'Ver Historial', icon: Icons.history_outlined, onPressed: () => context.push('/history')),
          const SizedBox(height: 24),
          const MaintenanceCard(),
        ].animate(interval: 100.ms).fadeIn(duration: 300.ms).slideY(begin: 0.2),
      ),
    );
  }

  // --- NUEVO WIDGET PARA LA PANTALLA DE BIENVENIDA ---
  Widget _buildWelcomeScreen(BuildContext context, String userName) {
    final textTheme = Theme.of(context).textTheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.no_crash_outlined, size: 80, color: Colors.grey),
            const SizedBox(height: 24),
            Text('¡Bienvenido, $userName!', style: textTheme.headlineSmall, textAlign: TextAlign.center),
            const SizedBox(height: 8),
            Text(
              'Parece que aún no tienes vehículos. ¡Añade el primero en la pestaña "Mi Garaje" para empezar!',
              style: textTheme.bodyLarge?.copyWith(color: Colors.grey.shade700),
              textAlign: TextAlign.center,
            ),
          ],
        ).animate().fadeIn(),
      ),
    );
  }

  // Helper para construir los botones de acción del dashboard
  Widget _buildActionButton({
    required BuildContext context,
    required String label,
    required IconData icon,
    required VoidCallback onPressed,
    bool isPrimary = false,
  }) {
    final style = Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold);
    return SizedBox(
      width: double.infinity,
      child: isPrimary
          ? FilledButton.icon(
              onPressed: onPressed,
              icon: Icon(icon),
              label: Text(label),
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                textStyle: style,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
            )
          : OutlinedButton.icon(
              onPressed: onPressed,
              icon: Icon(icon),
              label: Text(label),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                textStyle: style,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
            ),
    );
  }
}