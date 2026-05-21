class Score {
  final int? id;
  final String playerId;
  final String? pseudo; 
  final int categoryId;
  final int points;
  final int correctAnswers;
  final DateTime? playedAt;

  const Score({
    this.id,
    required this.playerId,
    this.pseudo,
    required this.categoryId,
    required this.points,
    required this.correctAnswers,
    this.playedAt,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is Score && other.id == id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() =>
      'Score(id: $id, points: $points, correct: $correctAnswers)';
}