import '../../domain/entities/score.dart';
import '../../domain/repositories/i_score_repository.dart';
import '../datasources/score_remote_datasource.dart';

class ScoreRepositoryImpl implements IScoreRepository {
  final ScoreRemoteDataSource _dataSource;
  const ScoreRepositoryImpl(this._dataSource);

  @override
Future<Score> saveScore(Score score) =>
    _dataSource.saveScore(score);

  @override
  Future<List<Score>> getLeaderboard(int categoryId) =>
      _dataSource.getLeaderboardWithPseudos(categoryId);

  @override
  Future<List<Score>> getPlayerScores(String playerId) =>
      _dataSource.getPlayerScores(playerId);
}