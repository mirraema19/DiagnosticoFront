import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

// Widgets Core
import 'package:proyecto/core/widgets/scaffold_with_nav_bar.dart';

// Auth
import 'package:proyecto/features/auth/presentation/bloc/auth_bloc/auth_bloc.dart';
import 'package:proyecto/features/auth/presentation/views/login_screen.dart';
import 'package:proyecto/features/auth/presentation/views/register_screen.dart';
import 'package:proyecto/features/auth/presentation/views/forgot_password_screen.dart';
import 'package:proyecto/features/auth/presentation/views/reset_password_screen.dart';

// Admin
import 'package:proyecto/features/workshop_admin/presentation/views/admin_dashboard_screen.dart';
import 'package:proyecto/features/workshop_admin/presentation/views/create_workshop_screen.dart';
import 'package:proyecto/features/workshop_admin/presentation/views/edit_workshop_screen.dart';
import 'package:proyecto/features/workshop_admin/presentation/views/manage_schedule_screen.dart';
import 'package:proyecto/features/workshop_admin/presentation/views/manage_specialties_screen.dart';
import 'package:proyecto/features/workshop_admin/presentation/views/admin_add_maintenance_screen.dart';

// Home
import 'package:proyecto/features/home/presentation/views/home_screen.dart';

// Garage
import 'package:proyecto/features/garaje/presentation/data/models/vehicle_model.dart';
import 'package:proyecto/features/garaje/presentation/views/garage_screen.dart';
import 'package:proyecto/features/garaje/presentation/views/add_vehicle_screen.dart';
import 'package:proyecto/features/garaje/presentation/views/edit_vehicle_screen.dart';
import 'package:proyecto/features/garaje/presentation/views/vehicle_detail_screen.dart';

// Appointments & Reminders
import 'package:proyecto/features/appointments/presentation/views/my_appointments_screen.dart';
import 'package:proyecto/features/appointments/presentation/views/add_edit_appointment_screen.dart';
import 'package:proyecto/features/appointments/presentation/views/create_appointment_improved_screen.dart';
import 'package:proyecto/features/appointments/presentation/views/appointment_detail_screen.dart';
import 'package:proyecto/features/appointments/presentation/views/notifications_screen.dart';
import 'package:proyecto/features/appointments/presentation/views/reminders_screen.dart';
import 'package:proyecto/features/appointments/presentation/views/add_reminder_screen.dart';

// Workshops
import 'package:proyecto/features/workshops/data/models/workshop_model.dart';
import 'package:proyecto/features/workshops/presentation/views/workshop_search_screen.dart';
import 'package:proyecto/features/workshops/presentation/views/workshop_detail_screen.dart';

// Diagnosis
import 'package:proyecto/features/diagnosis/presentation/views/diagnosis_chat_screen.dart';
import 'package:proyecto/features/diagnosis/presentation/views/diagnosis_history_screen.dart';

// History
import 'package:proyecto/features/history/presentation/views/history_screen.dart';
import 'package:proyecto/features/history/presentation/views/add_maintenance_screen.dart';

// Profile
import 'package:proyecto/features/profile/presentation/views/profile_screen.dart';

class AppRouter {
  final AuthBloc authBloc;

  AppRouter(this.authBloc);

  late final GoRouter router = GoRouter(
    initialLocation: '/',
    refreshListenable: GoRouterRefreshStream(authBloc.stream),
    routes: [
      // --- RUTAS PÚBLICAS (AUTH) ---
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
      GoRoute(
        path: '/forgot-password',
        name: 'forgotPassword',
        builder: (context, state) => const ForgotPasswordScreen(),
      ),
      GoRoute(
        path: '/reset-password',
        name: 'resetPassword',
        builder: (context, state) => const ResetPasswordScreen(),
      ),

      // --- RUTA DE ADMIN ---
      GoRoute(
        path: '/admin',
        name: 'adminDashboard',
        builder: (context, state) => const AdminDashboardScreen(),
      ),
      GoRoute(
        path: '/admin/create-workshop',
        name: 'createWorkshop',
        builder: (context, state) => const CreateWorkshopScreen(),
      ),
      GoRoute(
        path: '/admin/edit-workshop',
        name: 'editWorkshop',
        builder: (context, state) {
          final workshop = state.extra as Workshop;
          return EditWorkshopScreen(workshop: workshop);
        },
      ),
      GoRoute(
        path: '/admin/workshops/:id/schedule',
        name: 'manageSchedule',
        builder: (context, state) {
          final workshopId = state.pathParameters['id']!;
          return ManageScheduleScreen(workshopId: workshopId);
        },
      ),
      GoRoute(
        path: '/admin/workshops/:id/specialties',
        name: 'manageSpecialties',
        builder: (context, state) {
          final workshopId = state.pathParameters['id']!;
          return ManageSpecialtiesScreen(workshopId: workshopId);
        },
      ),
      GoRoute(
        path: '/admin/add-service',
        name: 'adminAddService',
        builder: (context, state) => const AdminAddMaintenanceScreen(),
      ),

      // --- NAVEGACIÓN PRINCIPAL CLIENTE (SHELL) ---
      ShellRoute(
        builder: (context, state, child) {
          return ScaffoldWithNavBar(child: child);
        },
        routes: [
          GoRoute(
            path: '/',
            name: 'home',
            builder: (context, state) => const HomeScreen(),
          ),
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

      // --- RUTAS SECUNDARIAS (PUSH) ---

      // Diagnóstico
      GoRoute(
        path: '/diagnosis',
        name: 'diagnosis',
        builder: (context, state) => const DiagnosisChatScreen(),
      ),
      GoRoute(
        path: '/diagnosis/history',
        name: 'diagnosisHistory',
        builder: (context, state) => const DiagnosisHistoryScreen(),
      ),

      // Talleres
      GoRoute(
        path: '/workshops',
        name: 'workshops',
        builder: (context, state) {
          final selectionMode = state.uri.queryParameters['selectionMode'] == 'true';
          return WorkshopSearchScreen(selectionMode: selectionMode);
        },
      ),
      GoRoute(
        path: '/workshops/details',
        name: 'workshopDetails',
        builder: (context, state) {
          final workshop = state.extra as Workshop;
          return WorkshopDetailScreen(workshop: workshop);
        },
      ),

      // Garaje
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

      // Citas (antiguo - mantener para compatibilidad)
      GoRoute(
        path: '/appointments/add',
        name: 'addAppointment',
        builder: (context, state) => const AddEditAppointmentScreen(),
      ),

      // Nuevas rutas de Appointments
      GoRoute(
        path: '/appointments/create',
        name: 'createAppointment',
        builder: (context, state) {
          final vehicleId = state.uri.queryParameters['vehicleId'];
          final workshopId = state.uri.queryParameters['workshopId'];
          final diagnosisId = state.uri.queryParameters['diagnosisId'];
          return CreateAppointmentImprovedScreen(
            vehicleId: vehicleId,
            workshopId: workshopId,
            diagnosisId: diagnosisId,
          );
        },
      ),
      GoRoute(
        path: '/appointments/detail/:id',
        name: 'appointmentDetail',
        builder: (context, state) {
          final appointmentId = state.pathParameters['id']!;
          return AppointmentDetailScreen(appointmentId: appointmentId);
        },
      ),

      // Notificaciones
      GoRoute(
        path: '/notifications',
        name: 'notifications',
        builder: (context, state) => const NotificationsScreen(),
      ),

      // Historial
      GoRoute(
        path: '/history',
        name: 'history',
        builder: (context, state) => const HistoryScreen(),
      ),
      GoRoute(
        path: '/history/add',
        name: 'addHistory',
        builder: (context, state) => const AddMaintenanceScreen(),
      ),

      // Recordatorios
      GoRoute(
        path: '/reminders',
        name: 'reminders',
        builder: (context, state) => const RemindersScreen(),
      ),
      GoRoute(
        path: '/reminders/add',
        name: 'addReminder',
        builder: (context, state) => const AddReminderScreenWrapper(),
      ),
    ],

    // --- LÓGICA DE REDIRECCIÓN ---
    redirect: (BuildContext context, GoRouterState state) {
      final bool loggedIn = authBloc.state.status == AuthStatus.authenticated;
      
      // Rutas permitidas sin login
      final bool isLoggingIn = state.matchedLocation == '/login';
      final bool isRegistering = state.matchedLocation == '/register';
      final bool isRecovering = state.matchedLocation == '/forgot-password' || state.matchedLocation == '/reset-password';

      // Si NO está logueado y NO está en una página pública -> ir a login
      if (!loggedIn && !isLoggingIn && !isRegistering && !isRecovering) {
        return '/login';
      }

      // Si SÍ está logueado e intenta ir a una página pública -> redirigir según rol
      if (loggedIn && (isLoggingIn || isRegistering || isRecovering)) {
        final userRole = authBloc.state.user?.role;
        if (userRole == 'WORKSHOP_ADMIN') {
          return '/admin';
        }
        return '/';
      }

      return null;
    },
  );
}

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