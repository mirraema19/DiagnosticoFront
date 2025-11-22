import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:proyecto/core/services/service_locator.dart';
import 'package:proyecto/features/auth/data/repositories/auth_repository.dart';

part 'password_reset_event.dart';
part 'password_reset_state.dart';

class PasswordResetBloc extends Bloc<PasswordResetEvent, PasswordResetState> {
  final AuthRepository _authRepository = sl<AuthRepository>();

  PasswordResetBloc() : super(const PasswordResetState()) {
    on<RequestResetCode>(_onRequestResetCode);
    on<SubmitNewPassword>(_onSubmitNewPassword);
  }

  Future<void> _onRequestResetCode(
    RequestResetCode event,
    Emitter<PasswordResetState> emit,
  ) async {
    emit(const PasswordResetState(status: ResetStatus.loading));
    try {
      await _authRepository.requestPasswordReset(event.email);
      emit(const PasswordResetState(status: ResetStatus.requestSuccess));
    } catch (e) {
      emit(PasswordResetState(
        status: ResetStatus.failure,
        errorMessage: e.toString().replaceAll('Exception:', ''),
      ));
    }
  }

  Future<void> _onSubmitNewPassword(
    SubmitNewPassword event,
    Emitter<PasswordResetState> emit,
  ) async {
    emit(const PasswordResetState(status: ResetStatus.loading));
    try {
      await _authRepository.resetPassword(
        token: event.token,
        newPassword: event.newPassword,
      );
      emit(const PasswordResetState(status: ResetStatus.resetSuccess));
    } catch (e) {
      emit(PasswordResetState(
        status: ResetStatus.failure,
        errorMessage: e.toString().replaceAll('Exception:', ''),
      ));
    }
  }
}