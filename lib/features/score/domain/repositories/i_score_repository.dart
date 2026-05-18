import '../entities/score.dart';

abstract class IScoreRepository {
  Future<void> saveScore(Score score);
  Stream<List<Score>> leaderboardStream(int categoryId);
  Future<List<Score>> getPlayerScores(String playerId);
}