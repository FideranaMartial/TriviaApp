import '../entities/player.dart';

abstract class IAuthRepository {
  bool get isLoggedIn;
  String? get currentUserId;

  Future<Player> signUp({
    required String email,
    required String password,
    required String pseudo,
  });

  Future<Player> signIn({
    required String email,
    required String password,
  });

  Future<Player?> getCurrentPlayer();
  Future<void> signOut();
}