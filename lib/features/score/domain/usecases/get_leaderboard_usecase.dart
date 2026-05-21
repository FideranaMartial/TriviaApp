import '../../../../core/usecases/usecase.dart';
import '../entities/score.dart';
import '../repositories/i_score_repository.dart';

class GetLeaderboardUseCase implements UseCase<List<Score>, int> {
  final IScoreRepository _repository;
  const GetLeaderboardUseCase(this._repository);

  @override
  Future<List<Score>> call(int categoryId) =>
      _repository.getLeaderboard(categoryId);
}