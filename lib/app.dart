import 'package:proyecto/core/routes/app_router.dart';
import 'package:proyecto/core/theme/app_theme.dart';
import 'package:proyecto/features/auth/data/repositories/auth_repository.dart';
import 'package:proyecto/features/auth/presentation/bloc/auth_bloc/auth_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      // Proveemos el AuthBloc a nivel global
      create: (context) => AuthBloc(
        authRepository: RepositoryProvider.of<AuthRepository>(context),
      ),
      child: Builder(
        builder: (context) {
          return MaterialApp.router(
            title: 'Diagnóstico Automotriz',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            // La configuración del router ahora puede acceder al AuthBloc
            routerConfig: AppRouter(context.read<AuthBloc>()).router,
          );
        },
      ),
    );
  }
}