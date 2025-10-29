import 'dart:async';
import 'package:proyecto/features/auth/data/models/user_model.dart';
import 'package:proyecto/features/auth/data/repositories/auth_repository.dart';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository _authRepository;
  
  AuthBloc({required AuthRepository authRepository})
      : _authRepository = authRepository,
        super(const AuthState.unknown()) {
    on<AuthLogoutRequested>(_onLogoutRequested);
    // CORRECCIÓN: Se usa el evento público 'AuthStatusChanged'
    on<AuthStatusChanged>(_onAuthStatusChanged);
  }

  // CORRECCIÓN: El tipo del evento ahora es 'AuthStatusChanged'
  void _onAuthStatusChanged(AuthStatusChanged event, Emitter<AuthState> emit) {
     switch (event.status) {
      case AuthStatus.unauthenticated:
        return emit(const AuthState.unauthenticated());
      case AuthStatus.authenticated:
        // Se asegura de que el usuario no sea nulo para el estado autenticado
        if (event.user != null) {
          return emit(AuthState.authenticated(event.user!));
        }
        // Si por alguna razón el usuario es nulo, se considera no autenticado
        return emit(const AuthState.unauthenticated());
      default:
        return emit(const AuthState.unknown());
    }
  }

  Future<void> _onLogoutRequested(AuthLogoutRequested event, Emitter<AuthState> emit) async {
    // Llama al método de logout del repositorio
    await _authRepository.logout();
    // Emite el estado no autenticado
    emit(const AuthState.unauthenticated());
  }
}