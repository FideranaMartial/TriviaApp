import '../../../../core/usecases/usecase.dart';
import '../entities/player.dart';
import '../repositories/i_auth_repository.dart';

class SignInParams {
  final String email;
  final String password;
  const SignInParams({required this.email, required this.password});
}

class SignInUseCase implements UseCase<Player, SignInParams> {
  final IAuthRepository _repository;
  const SignInUseCase(this._repository);

  @override
  Future<Player> call(SignInParams params) =>
      _repository.signIn(email: params.email, password: params.password);
}