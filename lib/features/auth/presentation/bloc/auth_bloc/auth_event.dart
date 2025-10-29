part of 'auth_bloc.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object> get props => [];
}

class AuthLogoutRequested extends AuthEvent {}

// Evento interno para notificar que el estado de autenticación cambió
// CORRECCIÓN: Se quita el guion bajo para hacerlo público
class AuthStatusChanged extends AuthEvent {
  final AuthStatus status;
  final User? user;
  
  const AuthStatusChanged(this.status, [this.user]); // CORRECCIÓN: Constructor arreglado

   @override
  List<Object> get props => [status];
}