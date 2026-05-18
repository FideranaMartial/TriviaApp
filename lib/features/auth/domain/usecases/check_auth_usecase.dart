import '../../../../core/usecases/usecase.dart';
import '../entities/player.dart';
import '../repositories/i_auth_repository.dart';

class CheckAuthUseCase implements UseCase<Player?, NoParams> {
  final IAuthRepository _repository;
  const CheckAuthUseCase(this._repository);

  @override
  Future<Player?> call(NoParams params) =>
      _repository.getCurrentPlayer();
}