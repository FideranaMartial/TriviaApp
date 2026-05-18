import '../../domain/entities/score.dart';
import '../../domain/repositories/i_score_repository.dart';
import '../datasources/score_remote_datasource.dart';

class ScoreRepositoryImpl implements IScoreRepository {
  final ScoreRemoteDataSource _dataSource;
  const ScoreRepositoryImpl(this._dataSource);

  @override
  Future<void> saveScore(Score score) => _dataSource.saveScore(score);

  @override
  Stream<List<Score>> leaderboardStream(int categoryId) =>
      _dataSource.leaderboardStream(categoryId);

  @override
  Future<List<Score>> getPlayerScores(String playerId) =>
      _dataSource.getPlayerScores(playerId);
}