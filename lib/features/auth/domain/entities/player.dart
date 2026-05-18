class Player {
  final String id;
  final String pseudo;
  final String? avatarUrl;
  final DateTime createdAt;

  const Player({
    required this.id,
    required this.pseudo,
    this.avatarUrl,
    required this.createdAt,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is Player && other.id == id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'Player(id: $id, pseudo: $pseudo)';
}