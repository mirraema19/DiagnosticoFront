import 'dart:async';
import 'package:proyecto/core/widgets/scaffold_with_nav_bar.dart';
import 'package:proyecto/features/appointments/presentation/views/add_edit_appointment_screen.dart';
import 'package:proyecto/features/appointments/presentation/views/my_appointments_screen.dart';
import 'package:proyecto/features/auth/presentation/bloc/auth_bloc/auth_bloc.dart';
import 'package:proyecto/features/auth/presentation/views/login_screen.dart';
import 'package:proyecto/features/auth/presentation/views/register_screen.dart';
import 'package:proyecto/features/diagnosis/presentation/views/diagnosis_chat_screen.dart';
import 'package:proyecto/features/garaje/presentation/data/models/vehicle_model.dart';
import 'package:proyecto/features/garaje/presentation/views/add_vehicle_screen.dart';
import 'package:proyecto/features/garaje/presentation/views/edit_vehicle_screen.dart';
import 'package:proyecto/features/garaje/presentation/views/garage_screen.dart';
import 'package:proyecto/features/garaje/presentation/views/vehicle_detail_screen.dart';
import 'package:proyecto/features/history/presentation/views/history_screen.dart';
// --- IMPORTACIÓN NUEVA ---
import 'package:proyecto/features/home/presentation/views/home_screen.dart';
import 'package:proyecto/features/profile/presentation/views/profile_screen.dart';
import 'package:proyecto/features/workshops/data/models/workshop_model.dart';
import 'package:proyecto/features/workshops/presentation/views/workshop_detail_screen.dart';
import 'package:proyecto/features/workshops/presentation/views/workshop_search_screen.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AppRouter {
  final AuthBloc authBloc;

  AppRouter(this.authBloc);

  late final GoRouter router = GoRouter(
    initialLocation: '/', // Iniciar en la pestaña 'Inicio'
    refreshListenable: GoRouterRefreshStream(authBloc.stream),
    routes: [
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/register',
        name: 'register',
        builder: (context, state) => const RegisterScreen(),
      ),
      // --- ShellRoute con la navegación principal ---
      ShellRoute(
        builder: (context, state, child) {
          return ScaffoldWithNavBar(child: child);
        },
        routes: [
          // --- RUTA INICIO MODIFICADA ---
          // Apunta a la nueva HomeScreen (el dashboard)
          GoRoute(
            path: '/',
            name: 'home',
            builder: (context, state) => const HomeScreen(),
          ),
          // --- RUTA GARAJE MODIFICADA ---
          // Apunta a GarageScreen (la lista de vehículos)
          GoRoute(
            path: '/garage',
            name: 'garage',
            builder: (context, state) => const GarageScreen(),
          ),
          GoRoute(
            path: '/appointments',
            name: 'appointments',
            builder: (context, state) => const MyAppointmentsScreen(),
          ),
          GoRoute(
            path: '/profile',
            name: 'profile',
            builder: (context, state) => const ProfileScreen(),
          ),
        ],
      ),
      
      // ... (El resto de las rutas secundarias no necesita cambios)
      GoRoute(
        path: '/diagnosis',
        name: 'diagnosis',
        builder: (context, state) => const DiagnosisChatScreen(),
      ),
      GoRoute(
        path: '/history',
        name: 'history',
        builder: (context, state) => const HistoryScreen(),
      ),
      GoRoute(
        path: '/workshops',
        name: 'workshops',
        builder: (context, state) => const WorkshopSearchScreen(),
      ),
      GoRoute(
        path: '/workshops/details',
        name: 'workshopDetails',
        builder: (context, state) {
          final workshop = state.extra as Workshop;
          return WorkshopDetailScreen(workshop: workshop);
        },
      ),
      GoRoute(
        path: '/garage/add',
        name: 'addVehicle',
        builder: (context, state) => const AddVehicleScreen(),
      ),
      GoRoute(
        path: '/garage/details',
        name: 'vehicleDetails',
        builder: (context, state) {
          final vehicle = state.extra as Vehicle;
          return VehicleDetailScreen(vehicle: vehicle);
        },
      ),
      GoRoute(
        path: '/garage/edit',
        name: 'editVehicle',
        builder: (context, state) {
          final vehicle = state.extra as Vehicle;
          return EditVehicleScreen(vehicle: vehicle);
        },
      ),
      GoRoute(
        path: '/appointments/add',
        name: 'addAppointment',
        builder: (context, state) => const AddEditAppointmentScreen(),
      ),
    ],
    redirect: (BuildContext context, GoRouterState state) {
      final bool loggedIn = authBloc.state.status == AuthStatus.authenticated;
      final bool isLoggingIn = state.matchedLocation == '/login' || state.matchedLocation == '/register';

      if (!loggedIn && !isLoggingIn) return '/login';
      // --- REDIRECCIÓN MODIFICADA ---
      // Al iniciar sesión, te lleva al dashboard principal
      if (loggedIn && isLoggingIn) return '/';
      return null;
    },
  );
}

// ... (GoRouterRefreshStream class sin cambios)
class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<dynamic> stream) {
    notifyListeners();
    _subscription = stream.asBroadcastStream().listen((_) => notifyListeners());
  }
  late final StreamSubscription<dynamic> _subscription;
  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}