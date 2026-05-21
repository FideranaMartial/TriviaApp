import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/entities/player.dart';

class AuthRemoteDataSource {
  final SupabaseClient _client;
  const AuthRemoteDataSource(this._client);

  bool get isLoggedIn => _client.auth.currentUser != null;
  String? get currentUserId => _client.auth.currentUser?.id;

  Future<Player> signUp({
    required String email,
    required String password,
    required String pseudo,
  }) async {
    // Vérifier si le pseudo est déjà pris
    final existingPseudo = await _client
        .from('players')
        .select('id')
        .eq('pseudo', pseudo)
        .maybeSingle();

    if (existingPseudo != null) {
      throw Exception('PSEUDO_TAKEN');
    }

    // Vérifier si l'email est déjà utilisé
    final emailExists = await _client
        .rpc('check_email_exists', params: {'user_email': email});

    if (emailExists == true) {
      throw Exception('EMAIL_ALREADY_EXISTS');
    }

    final response = await _client.auth.signUp(
      email: email,
      password: password,
    );

    if (response.user == null) {
      throw Exception('SIGNUP_FAILED');
    }

    return getOrCreatePlayer(pseudo);
  }

  Future<Player> signIn({
    required String email,
    required String password,
  }) async {
    // Vérifier d'abord si l'email existe
    final emailExists = await _client
        .rpc('check_email_exists', params: {'user_email': email});

    if (emailExists != true) {
      throw Exception('EMAIL_NOT_FOUND');
    }

    // L'email existe — tenter la connexion
    try {
      final response = await _client.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (response.user == null) {
        throw Exception('WRONG_PASSWORD');
      }

      final player = await getPlayer();
      if (player == null) {
        await _client.auth.signOut();
        throw Exception('PROFILE_NOT_FOUND');
      }

      return player;
    } on AuthException catch (e) {
      if (e.message.contains('Invalid login credentials') ||
          e.message.contains('invalid_credentials')) {
        throw Exception('WRONG_PASSWORD');
      }
      throw Exception(e.message);
    }
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