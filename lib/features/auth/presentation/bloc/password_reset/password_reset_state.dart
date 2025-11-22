part of 'password_reset_bloc.dart';

enum ResetStatus { initial, loading, requestSuccess, resetSuccess, failure }

class PasswordResetState extends Equatable {
  final ResetStatus status;
  final String? errorMessage;

  const PasswordResetState({
    this.status = ResetStatus.initial,
    this.errorMessage,
  });

  @override
  List<Object?> get props => [status, errorMessage];
}