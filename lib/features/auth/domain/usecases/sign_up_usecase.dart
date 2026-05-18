import '../../../../core/usecases/usecase.dart';
import '../entities/player.dart';
import '../repositories/i_auth_repository.dart';

class SignUpParams {
  final String email;
  final String password;
  final String pseudo;
  const SignUpParams({
    required this.email,
    required this.password,
    required this.pseudo,
  });
}

class SignUpUseCase implements UseCase<Player, SignUpParams> {
  final IAuthRepository _repository;
  const SignUpUseCase(this._repository);

  @override
  Future<Player> call(SignUpParams params) => _repository.signUp(
        email: params.email,
        password: params.password,
        pseudo: params.pseudo,
      );
}