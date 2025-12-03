import 'package:proyecto/features/auth/presentation/bloc/auth_bloc/auth_bloc.dart';
import 'package:proyecto/features/garaje/presentation/data/models/vehicle_model.dart';
import 'package:proyecto/features/garaje/presentation/widgets/maintenance_card.dart';
import 'package:proyecto/features/garaje/presentation/widgets/vehicle_summary_card.dart';
import 'package:proyecto/features/history/presentation/bloc/history_bloc.dart';
import 'package:proyecto/features/home/presentation/bloc/home_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lottie/lottie.dart';


class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final userName = context.select((AuthBloc bloc) => bloc.state.user?.name) ?? 'Usuario';
    
    return BlocProvider(
      create: (context) => HomeBloc()..add(LoadHomeData()),
      child: Scaffold(
        body: SafeArea(
          child: MultiBlocListener(
            listeners: [
              // 1. LISTENER PARA CARGAR HISTORIAL CUANDO TENGAMOS VEHÍCULO
              BlocListener<HomeBloc, HomeState>(
                listener: (context, state) {
                  if (state is HomeLoaded && state.primaryVehicle != null) {
                    // Apenas sabemos cuál es el vehículo, pedimos su historial
                    context.read<HistoryBloc>().add(
                      LoadHistory(vehicleId: state.primaryVehicle!.id),
                    );
                  }
                },
              ),
              // 2. LISTENER PARA MOSTRAR NOTIFICACIÓN DE NUEVO SERVICIO
              BlocListener<HistoryBloc, HistoryState>(
                listener: (context, state) {
                  if (state is HistoryLoaded && state.records.isNotEmpty) {
                    final lastService = state.records.first;
                    final now = DateTime.now();
                    
                    // Comparamos solo la fecha (Año, Mes, Día)
                    final isToday = lastService.serviceDate.year == now.year &&
                                    lastService.serviceDate.month == now.month &&
                                    lastService.serviceDate.day == now.day;
                    
                    if (isToday) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('¡Nuevo servicio registrado: ${lastService.serviceType}!'),
                          backgroundColor: Colors.green,
                          behavior: SnackBarBehavior.floating,
                          duration: const Duration(seconds: 8),
                          action: SnackBarAction(
                            label: 'VER', 
                            textColor: Colors.white,
                            onPressed: () => context.push('/history'),
                          ),
                        ),
                      );
                    }
                  }
                },
              ),
            ],
            // 3. CONSTRUCCIÓN DE LA UI
            child: BlocBuilder<HomeBloc, HomeState>(
              builder: (context, state) {
                if (state is HomeLoading) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (state is HomeLoaded) {
                  if (state.primaryVehicle != null) {
                    return _buildDashboard(context, userName, state.primaryVehicle!);
                  } else {
                    return _buildWelcomeScreen(context, userName);
                  }
                }
                if (state is HomeError) {
                  // Si falla la carga del vehículo, mostramos un error discreto
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.error_outline, size: 40, color: Colors.red),
                          const SizedBox(height: 16),
                          Text(state.message, textAlign: TextAlign.center),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: () => context.read<HomeBloc>().add(LoadHomeData()),
                            child: const Text('Reintentar'),
                          )
                        ],
                      ),
                    ),
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ),
        ),
      ),
    );
  }

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

   // --- MÉTODO MODIFICADO CON LOTTIE ---
  Widget _buildWelcomeScreen(BuildContext context, String userName) {
    final textTheme = Theme.of(context).textTheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Reemplazamos el Icon por Lottie
            Lottie.asset(
              'assets/animations/gears_animation.json', // Asegúrate de que la ruta sea correcta
              height: 200, // Un tamaño más grande para que luzca
              fit: BoxFit.contain,
              // Opcional: si la animación es muy rápida puedes ajustar la velocidad
              // o si quieres que no se repita, usa repeat: false
            ),
            const SizedBox(height: 32),
            Text(
              '¡Bienvenido, $userName!', 
              style: textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
              textAlign: TextAlign.center
            ),
            const SizedBox(height: 16),
            Text(
              'Parece que aún no tienes vehículos registrados.\n\nVe a la pestaña "Mi Garaje" para añadir tu primer auto y comenzar a usar AutoDiag.',
              style: textTheme.bodyLarge?.copyWith(color: Colors.grey.shade600, height: 1.5),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            // Un botón extra para llevarlos directamente a Garaje mejora la UX
            FilledButton.icon(
              onPressed: () => context.go('/garage'), 
              icon: const Icon(Icons.arrow_forward),
              label: const Text('Ir a Mi Garaje'),
            )
          ],
        ).animate().fadeIn(duration: 600.ms).slideY(begin: 0.1, end: 0),
      ),
    );
  }

  Widget _buildActionButton({required BuildContext context, required String label, required IconData icon, required VoidCallback onPressed, bool isPrimary = false}) {
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