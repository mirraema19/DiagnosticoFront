import 'package:proyecto/core/routes/app_router.dart';
import 'package:proyecto/core/theme/app_theme.dart';
import 'package:proyecto/features/appointments/presentation/bloc/appointments_bloc.dart';
import 'package:proyecto/features/auth/data/repositories/auth_repository.dart';
import 'package:proyecto/features/auth/presentation/bloc/auth_bloc/auth_bloc.dart';
import 'package:proyecto/features/garaje/presentation/bloc/garage_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Proveemos el AuthBloc a nivel global
    return BlocProvider(
      create: (context) => AuthBloc(
        authRepository: RepositoryProvider.of<AuthRepository>(context),
      ),
      // --- CORRECCIÓN CLAVE: MultiBlocProvider aquí ---
      // Proveemos los BLoCs de Garage y Appointments a toda la app
      child: MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (context) => GarageBloc()..add(LoadGarageData()),
          ),
          BlocProvider(
            create: (context) => AppointmentsBloc()..add(LoadAppointments()),
          ),
        ],
        child: Builder(
          builder: (context) {
            return MaterialApp.router(
              title: 'Diagnóstico Automotriz',
              debugShowCheckedModeBanner: false,
              theme: AppTheme.lightTheme,
              routerConfig: AppRouter(context.read<AuthBloc>()).router,
            );
          },
        ),
      ),
    );
  }
}