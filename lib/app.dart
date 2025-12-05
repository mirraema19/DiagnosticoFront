import 'package:proyecto/core/routes/app_router.dart';
import 'package:proyecto/core/services/service_locator.dart';
import 'package:proyecto/core/theme/app_theme.dart';
import 'package:proyecto/features/appointments/presentation/bloc/appointments_bloc.dart';
import 'package:proyecto/features/appointments/presentation/bloc/reminders/reminders_bloc.dart';
import 'package:proyecto/features/appointments/data/repositories/appointment_repository.dart';
import 'package:proyecto/features/auth/data/repositories/auth_repository.dart';
import 'package:proyecto/features/auth/presentation/bloc/auth_bloc/auth_bloc.dart';
import 'package:proyecto/features/garaje/presentation/bloc/garage_bloc.dart';
import 'package:proyecto/features/history/presentation/bloc/history_bloc.dart';
import 'package:proyecto/features/auth/presentation/bloc/password_reset/password_reset_bloc.dart';
import 'package:proyecto/features/workshop_admin/presentation/bloc/admin_workshop_bloc.dart';
import 'package:proyecto/features/diagnosis/presentation/bloc/diagnosis_bloc.dart';
import 'package:proyecto/features/diagnosis/data/repositories/diagnosis_repository.dart';
import 'package:proyecto/features/workshops/data/repositories/workshop_repository.dart';
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
          BlocProvider(
            create: (context) => AppointmentsBloc(repository: sl<AppointmentRepository>())
              ..add(const LoadAppointments()),
          ),
          BlocProvider(create: (context) => HistoryBloc()..add(const LoadHistory())),
          BlocProvider(create: (context) => RemindersBloc()..add(LoadReminders())),
          BlocProvider(create: (context) => PasswordResetBloc()),
          BlocProvider(create: (context) => AdminWorkshopBloc()..add(LoadMyWorkshops())),
          BlocProvider(create: (context) => DiagnosisBloc(
            repository: sl<DiagnosisRepository>(),
            workshopRepository: sl<WorkshopRepository>(),
          )),
        ],
        child: BlocListener<AuthBloc, AuthState>(
          listener: (context, state) {
            // Limpiar estado de DiagnosisBloc cuando el usuario cierra sesión
            if (state.status == AuthStatus.unauthenticated) {
              print('MyApp: User logged out, clearing DiagnosisBloc state');
              context.read<DiagnosisBloc>().add(const ClearDiagnosisState());
              context.read<GarageBloc>().add(LoadGarageData());
              context.read<AppointmentsBloc>().add(const LoadAppointments());
              context.read<HistoryBloc>().add(const LoadHistory());
            }
          },
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
      ),
    );
  }
}