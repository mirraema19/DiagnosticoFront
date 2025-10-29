import 'package:proyecto/features/auth/data/repositories/auth_repository.dart';
import 'package:proyecto/features/auth/presentation/bloc/auth_bloc/auth_bloc.dart';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

part 'login_event.dart';
part 'login_state.dart';

class LoginBloc extends Bloc<LoginEvent, LoginState> {
  final AuthRepository _authRepository;
  final AuthBloc _authBloc;

  LoginBloc({
    required AuthRepository authRepository,
    required AuthBloc authBloc,
  })  : _authRepository = authRepository,
        _authBloc = authBloc,
        super(const LoginState()) {
    on<LoginSubmitted>(_onLoginSubmitted);
  }

  Future<void> _onLoginSubmitted(
    LoginSubmitted event,
    Emitter<LoginState> emit,
  ) async {
    emit(state.copyWith(status: LoginStatus.loading));
    try {
      final user = await _authRepository.login(
        email: event.email,
        password: event.password,
      );
      // CORRECCIÓN: Se usa el evento público 'AuthStatusChanged'
      _authBloc.add(AuthStatusChanged(AuthStatus.authenticated, user));
      emit(state.copyWith(status: LoginStatus.success));
    } catch (e) {
      emit(state.copyWith(
        status: LoginStatus.failure,
        errorMessage: e.toString().replaceFirst('Exception: ', ''),
      ));
    }
  }
}