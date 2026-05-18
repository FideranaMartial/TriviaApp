import '../entities/score.dart';
import '../repositories/i_score_repository.dart';

class GetLeaderboardUseCase {
  final IScoreRepository _repository;
  const GetLeaderboardUseCase(this._repository);

  Stream<List<Score>> call(int categoryId) =>
      _repository.leaderboardStream(categoryId);
}