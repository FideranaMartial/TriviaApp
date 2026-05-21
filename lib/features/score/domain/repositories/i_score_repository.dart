import '../entities/score.dart';

abstract class IScoreRepository {
  Future<void> saveScore(Score score);
  Future<List<Score>> getLeaderboard(int categoryId);
  Future<List<Score>> getPlayerScores(String playerId);
}