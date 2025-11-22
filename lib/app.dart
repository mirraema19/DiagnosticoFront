import 'package:proyecto/core/routes/app_router.dart';
import 'package:proyecto/core/services/service_locator.dart';
import 'package:proyecto/core/theme/app_theme.dart';
import 'package:proyecto/features/appointments/presentation/bloc/appointments_bloc.dart';
import 'package:proyecto/features/appointments/presentation/bloc/reminders/reminders_bloc.dart'; // NUEVO
import 'package:proyecto/features/auth/data/repositories/auth_repository.dart';
import 'package:proyecto/features/auth/presentation/bloc/auth_bloc/auth_bloc.dart';
import 'package:proyecto/features/garaje/presentation/bloc/garage_bloc.dart';
import 'package:proyecto/features/history/presentation/bloc/history_bloc.dart'; // NUEVO
import 'package:proyecto/features/auth/presentation/bloc/password_reset/password_reset_bloc.dart'; // NUEVO
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => AuthBloc(authRepository: sl<AuthRepository>()),
      child: MultiBlocProvider(
        providers: [
          BlocProvider(create: (context) => GarageBloc()..add(LoadGarageData())),
          BlocProvider(create: (context) => AppointmentsBloc()..add(LoadAppointments())),
          // --- NUEVOS BLOCS ---
          BlocProvider(create: (context) => HistoryBloc()..add(LoadHistory())),
          BlocProvider(create: (context) => RemindersBloc()..add(LoadReminders())),
          BlocProvider(create: (context) => PasswordResetBloc()),
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