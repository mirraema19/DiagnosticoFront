part of 'password_reset_bloc.dart';

abstract class PasswordResetEvent extends Equatable {
  const PasswordResetEvent();
  @override
  List<Object> get props => [];
}

class RequestResetCode extends PasswordResetEvent {
  final String email;
  const RequestResetCode(this.email);
  @override
  List<Object> get props => [email];
}

class SubmitNewPassword extends PasswordResetEvent {
  final String token;
  final String newPassword;
  const SubmitNewPassword({required this.token, required this.newPassword});
  @override
  List<Object> get props => [token, newPassword];
}