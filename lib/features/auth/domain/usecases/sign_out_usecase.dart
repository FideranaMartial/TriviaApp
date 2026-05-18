import '../../../../core/usecases/usecase.dart';
import '../repositories/i_auth_repository.dart';

class SignOutUseCase implements UseCase<void, NoParams> {
  final IAuthRepository _repository;
  const SignOutUseCase(this._repository);

  @override
  Future<void> call(NoParams params) => _repository.signOut();
}