import '../entities/score.dart';

abstract class IScoreRepository {
  Future<Score> saveScore(Score score); // ← retourne Score
  Future<List<Score>> getLeaderboard(int categoryId);
  Future<List<Score>> getPlayerScores(String playerId);
}