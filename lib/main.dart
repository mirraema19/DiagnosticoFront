import 'package:proyecto/features/auth/data/repositories/auth_repository.dart';
import 'package:flutter/material.dart';
import 'package:proyecto/app.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

void main() {
  final authRepository = AuthRepository();

  runApp(
    RepositoryProvider.value(
      value: authRepository,
      child: const MyApp(),
    ),
  );
}