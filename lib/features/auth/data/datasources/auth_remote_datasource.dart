import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/entities/player.dart';

class AuthRemoteDataSource {
  final SupabaseClient _client;
  const AuthRemoteDataSource(this._client);

  bool get isLoggedIn => _client.auth.currentUser != null;
  String? get currentUserId => _client.auth.currentUser?.id;

  Stream<bool> get authStateStream => _client.auth.onAuthStateChange
      .map((state) => state.session != null);

  Future<Player> signUp({
    required String email,
    required String password,
    required String pseudo,
  }) async {
    final response = await _client.auth.signUp(
      email: email,
      password: password,
    );
    if (response.user == null) throw Exception('Inscription échouée');
    return getOrCreatePlayer(pseudo);
  }

  Future<Player> signIn({
    required String email,
    required String password,
  }) async {
    await _client.auth.signInWithPassword(
      email: email,
      password: password,
    );
    final player = await getPlayer();
    if (player == null) throw Exception('Profil introuvable');
    return player;
  }

  Future<Player> getOrCreatePlayer(String pseudo) async {
    final uid = currentUserId!;
    final existing = await _client
        .from('players')
        .select()
        .eq('id', uid)
        .maybeSingle();

    if (existing != null) return _mapToPlayer(existing);

    final data = await _client
        .from('players')
        .insert({'id': uid, 'pseudo': pseudo})
        .select()
        .single();

    return _mapToPlayer(data);
  }

  Future<Player?> getPlayer() async {
    final uid = currentUserId;
    if (uid == null) return null;
    final data = await _client
        .from('players')
        .select()
        .eq('id', uid)
        .maybeSingle();
    return data != null ? _mapToPlayer(data) : null;
  }

  Future<void> signOut() => _client.auth.signOut();

  Player _mapToPlayer(Map<String, dynamic> json) => Player(
        id: json['id'] as String,
        pseudo: json['pseudo'] as String,
        avatarUrl: json['avatar_url'] as String?,
        createdAt: DateTime.parse(json['created_at'] as String),
      );
}