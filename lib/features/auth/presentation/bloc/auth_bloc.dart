import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/usecases/usecase.dart';
import '../../domain/usecases/check_auth_usecase.dart';
import '../../domain/usecases/sign_in_usecase.dart';
import '../../domain/usecases/sign_up_usecase.dart';
import '../../domain/usecases/sign_out_usecase.dart';
import '../../domain/repositories/i_auth_repository.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final CheckAuthUseCase checkAuth;
  final SignInUseCase signIn;
  final SignUpUseCase signUp;
  final SignOutUseCase signOut;
  final IAuthRepository _authRepository;

  StreamSubscription<bool>? _authSubscription;

  AuthBloc({
    required this.checkAuth,
    required this.signIn,
    required this.signUp,
    required this.signOut,
    required IAuthRepository authRepository,
  })  : _authRepository = authRepository,
        super(AuthInitial()) {
    on<CheckAuthEvent>(_onCheckAuth);
    on<SignInEvent>(_onSignIn);
    on<SignUpEvent>(_onSignUp);
    on<SignOutEvent>(_onSignOut);
    on<_AuthStateChangedEvent>(_onAuthChanged);

    _authSubscription = _authRepository.authStateStream.listen((isLoggedIn) {
      add(_AuthStateChangedEvent(isLoggedIn));
    });
  }

  Future<void> _onCheckAuth(CheckAuthEvent e, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      final player = await checkAuth(const NoParams());
      if (player != null) {
        emit(AuthenticatedState(player));
      } else {
        emit(UnauthenticatedState());
      }
    } catch (_) {
      emit(UnauthenticatedState());
    }
  }

  Future<void> _onSignIn(SignInEvent e, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      final player = await signIn(SignInParams(
        email: e.email,
        password: e.password,
      ));
      emit(AuthenticatedState(player));
    } catch (err) {
      emit(AuthErrorState(err.toString()));
    }
  }

  Future<void> _onSignUp(SignUpEvent e, Emitter<AuthState> emit) async {
  emit(AuthLoading());
  try {
    print('=== SignUp start: ${e.email}');
    final player = await signUp(SignUpParams(
      email: e.email,
      password: e.password,
      pseudo: e.pseudo,
    ));
    print('=== SignUp success: ${player.pseudo}');
    emit(AuthenticatedState(player));
  } catch (err) {
    print('=== SignUp error: $err');
    emit(AuthErrorState(err.toString()));
  }
}

  Future<void> _onSignOut(SignOutEvent e, Emitter<AuthState> emit) async {
    await signOut(const NoParams());
    emit(UnauthenticatedState());
  }

  Future<void> _onAuthChanged(
      _AuthStateChangedEvent e, Emitter<AuthState> emit) async {
    if (!e.isLoggedIn) emit(UnauthenticatedState());
  }

  @override
  Future<void> close() {
    _authSubscription?.cancel();
    return super.close();
  }
}

class _AuthStateChangedEvent extends AuthEvent {
  final bool isLoggedIn;
  _AuthStateChangedEvent(this.isLoggedIn);
}