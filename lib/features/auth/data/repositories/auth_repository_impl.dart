import '../../domain/entities/player.dart';
import '../../domain/repositories/i_auth_repository.dart';
import '../datasources/auth_remote_datasource.dart';

class AuthRepositoryImpl implements IAuthRepository {
  final AuthRemoteDataSource _dataSource;
  const AuthRepositoryImpl(this._dataSource);

  @override
  bool get isLoggedIn => _dataSource.isLoggedIn;

  @override
  String? get currentUserId => _dataSource.currentUserId;

  @override
  Stream<bool> get authStateStream => _dataSource.authStateStream;

  @override
  Future<Player> signUp({
    required String email,
    required String password,
    required String pseudo,
  }) => _dataSource.signUp(email: email, password: password, pseudo: pseudo);

  @override
  Future<Player> signIn({
    required String email,
    required String password,
  }) => _dataSource.signIn(email: email, password: password);

  @override
  Future<Player?> getCurrentPlayer() => _dataSource.getPlayer();

  @override
  Future<void> signOut() => _dataSource.signOut();
}