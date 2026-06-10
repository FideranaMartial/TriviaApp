import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/entities/score.dart';

class ScoreRemoteDataSource {
  final SupabaseClient _client;
  const ScoreRemoteDataSource(this._client);

  Future<Score> saveScore(Score score) async {
  final data = await _client
      .from('scores')
      .insert({
        'player_id': score.playerId,
        'category_id': score.categoryId,
        'points': score.points,
        'correct_answers': score.correctAnswers,
      })
      .select()
      .single(); // ← récupère la ligne insérée avec son id

  // ignore: unnecessary_cast
  return _mapToScore(data as Map<String, dynamic>);
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

  // Méthode séparée pour récupérer le classement avec les pseudos
  Future<List<Score>> getLeaderboardWithPseudos(int categoryId) async {
    final data = await _client
        .from('scores')
        .select('*, players(pseudo)')  // ← JOIN avec players
        .eq('category_id', categoryId)
        .order('points', ascending: false)
        .limit(20);

    return (data as List)
        .map((e) => _mapToScoreWithPseudo(e as Map<String, dynamic>))
        .toList();
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

  Score _mapToScoreWithPseudo(Map<String, dynamic> json) => Score(
        id: json['id'] as int?,
        playerId: json['player_id'] as String,
        // Récupère le pseudo depuis le JOIN, sinon affiche les 8 premiers chars de l'UID
        pseudo: (json['players'] as Map<String, dynamic>?)?['pseudo'] as String?,
        categoryId: json['category_id'] as int,
        points: json['points'] as int,
        correctAnswers: json['correct_answers'] as int? ?? 0,
        playedAt: json['played_at'] != null
            ? DateTime.parse(json['played_at'] as String)
            : null,
      );
}