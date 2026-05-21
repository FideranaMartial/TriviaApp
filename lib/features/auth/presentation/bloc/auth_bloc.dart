import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/usecases/usecase.dart';
import '../../domain/usecases/check_auth_usecase.dart';
import '../../domain/usecases/sign_in_usecase.dart';
import '../../domain/usecases/sign_up_usecase.dart';
import '../../domain/usecases/sign_out_usecase.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final CheckAuthUseCase checkAuth;
  final SignInUseCase signIn;
  final SignUpUseCase signUp;
  final SignOutUseCase signOut;

  // Plus de stream — tout est contrôlé manuellement
  AuthBloc({
    required this.checkAuth,
    required this.signIn,
    required this.signUp,
    required this.signOut,
  }) : super(AuthInitial()) {
    on<CheckAuthEvent>(_onCheckAuth);
    on<SignInEvent>(_onSignIn);
    on<SignUpEvent>(_onSignUp);
    on<SignOutEvent>(_onSignOut);
  }

  Future<void> _onCheckAuth(
      CheckAuthEvent e, Emitter<AuthState> emit) async {
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

  Future<void> _onSignIn(
      SignInEvent e, Emitter<AuthState> emit) async {
    // Validation locale avant d'appeler Supabase
    if (e.email.trim().isEmpty || e.password.isEmpty) {
      emit(AuthErrorState('Veuillez remplir tous les champs.'));
      return;
    }
    if (!e.email.contains('@')) {
      emit(AuthErrorState('Adresse email invalide.'));
      return;
    }

    emit(AuthLoading());
    try {
      final player = await signIn(SignInParams(
        email: e.email.trim(),
        password: e.password,
      ));
      emit(AuthenticatedState(player));
    } catch (err) {
      print('=== ERREUR SIGNIN: ${err.toString()}');
      emit(AuthErrorState(_translate(err.toString())));
    }
  }

  Future<void> _onSignUp(
      SignUpEvent e, Emitter<AuthState> emit) async {
    // Validations locales
    if (e.pseudo.trim().isEmpty ||
        e.email.trim().isEmpty ||
        e.password.isEmpty) {
      emit(AuthErrorState('Veuillez remplir tous les champs.'));
      return;
    }
    if (!e.email.contains('@')) {
      emit(AuthErrorState('Adresse email invalide.'));
      return;
    }
    if (e.password.length < 6) {
      emit(AuthErrorState(
          'Le mot de passe doit contenir au moins 6 caractères.'));
      return;
    }

    emit(AuthLoading());
    try {
      final player = await signUp(SignUpParams(
        email: e.email.trim(),
        password: e.password,
        pseudo: e.pseudo.trim(),
      ));
      emit(AuthenticatedState(player));
    } catch (err) {
      emit(AuthErrorState(_translate(err.toString())));
    }
  }

  Future<void> _onSignOut(
      SignOutEvent e, Emitter<AuthState> emit) async {
    try {
      await signOut(const NoParams());
    } catch (_) {}
    emit(UnauthenticatedState());
  }

  String _translate(String error) {
  if (error.contains('EMAIL_NOT_FOUND')) {
    return 'Aucun compte trouvé avec cet email. Veuillez vous inscrire.';
  }
  if (error.contains('WRONG_PASSWORD')) {
    return 'Mot de passe incorrect. Veuillez réessayer.';
  }
  if (error.contains('EMAIL_ALREADY_EXISTS')) {
    return 'Un compte existe déjà avec cet email. Veuillez vous connecter.';
  }
  if (error.contains('PSEUDO_TAKEN')) {
    return 'Ce pseudo est déjà utilisé. Choisissez-en un autre.';
  }
  if (error.contains('SIGNUP_FAILED')) {
    return 'Inscription échouée. Veuillez réessayer.';
  }
  if (error.contains('PROFILE_NOT_FOUND')) {
    return 'Profil introuvable. Veuillez vous inscrire.';
  }
  if (error.contains('Network') || error.contains('SocketException')) {
    return 'Pas de connexion internet.';
  }
  return 'Une erreur est survenue. Veuillez réessayer.';
}
}