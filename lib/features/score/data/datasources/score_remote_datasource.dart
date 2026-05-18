import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/entities/score.dart';

class ScoreRemoteDataSource {
  final SupabaseClient _client;
  const ScoreRemoteDataSource(this._client);

  Future<void> saveScore(Score score) async {
    await _client.from('scores').insert({
      'player_id': score.playerId,
      'category_id': score.categoryId,
      'points': score.points,
      'correct_answers': score.correctAnswers,
    });
  }

  Stream<List<Score>> leaderboardStream(int categoryId) {
    return _client
        .from('scores')
        .stream(primaryKey: ['id'])
        .eq('category_id', categoryId)
        .order('points', ascending: false)
        .limit(20)
        .map((rows) => rows
            .map((e) => _mapToScore(e))
            .toList());
  }

  Future<List<Score>> getPlayerScores(String playerId) async {
    final data = await _client
        .from('scores')
        .select()
        .eq('player_id', playerId)
        .order('played_at', ascending: false);

    return (data as List)
        .map((e) => _mapToScore(e as Map<String, dynamic>))
        .toList();
  }

  Score _mapToScore(Map<String, dynamic> json) => Score(
        id: json['id'] as int?,
        playerId: json['player_id'] as String,
        categoryId: json['category_id'] as int,
        points: json['points'] as int,
        correctAnswers: json['correct_answers'] as int? ?? 0,
        playedAt: json['played_at'] != null
            ? DateTime.parse(json['played_at'] as String)
            : null,
      );
}