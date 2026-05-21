import 'package:get_it/get_it.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// DataSources
import '../../features/auth/data/datasources/auth_remote_datasource.dart';
import '../../features/category/data/datasources/category_remote_datasource.dart';
import '../../features/game/data/datasources/question_remote_datasource.dart';
import '../../features/score/data/datasources/score_remote_datasource.dart';

// Repositories (interfaces)
import '../../features/auth/domain/repositories/i_auth_repository.dart';
import '../../features/category/domain/repositories/i_category_repository.dart';
import '../../features/game/domain/repositories/i_question_repository.dart';
import '../../features/score/domain/repositories/i_score_repository.dart';

// Repositories (implementations)
import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/category/data/repositories/category_repository_impl.dart';
import '../../features/game/data/repositories/question_repository_impl.dart';
import '../../features/score/data/repositories/score_repository_impl.dart';

// Use Cases — Auth
import '../../features/auth/domain/usecases/check_auth_usecase.dart';
import '../../features/auth/domain/usecases/sign_in_usecase.dart';
import '../../features/auth/domain/usecases/sign_up_usecase.dart';
import '../../features/auth/domain/usecases/sign_out_usecase.dart';

// Use Cases — Category
import '../../features/category/domain/usecases/get_categories_usecase.dart';

// Use Cases — Game
import '../../features/game/domain/usecases/get_questions_usecase.dart';

// Use Cases — Score
import '../../features/score/domain/usecases/save_score_usecase.dart';
import '../../features/score/domain/usecases/get_leaderboard_usecase.dart';

// BLoCs & Cubits
import '../../features/auth/presentation/bloc/auth_bloc.dart';
import '../../features/category/presentation/cubit/category_cubit.dart';
import '../../features/game/presentation/bloc/game_bloc.dart';
import '../../features/score/presentation/bloc/score_bloc.dart';

final GetIt sl = GetIt.instance;

void setupInjection() {
  final client = Supabase.instance.client;

  // ── DataSources ──────────────────────────────────────────
  sl.registerLazySingleton(() => AuthRemoteDataSource(client));
  sl.registerLazySingleton(() => CategoryRemoteDataSource(client));
  sl.registerLazySingleton(() => QuestionRemoteDataSource(client));
  sl.registerLazySingleton(() => ScoreRemoteDataSource(client));

  // ── Repositories ─────────────────────────────────────────
  sl.registerLazySingleton<IAuthRepository>(
      () => AuthRepositoryImpl(sl()));
  sl.registerLazySingleton<ICategoryRepository>(
      () => CategoryRepositoryImpl(sl()));
  sl.registerLazySingleton<IQuestionRepository>(
      () => QuestionRepositoryImpl(sl()));
  sl.registerLazySingleton<IScoreRepository>(
      () => ScoreRepositoryImpl(sl()));

  // ── Use Cases ─────────────────────────────────────────────
  sl.registerLazySingleton(() => CheckAuthUseCase(sl()));
  sl.registerLazySingleton(() => SignInUseCase(sl()));
  sl.registerLazySingleton(() => SignUpUseCase(sl()));
  sl.registerLazySingleton(() => SignOutUseCase(sl()));
  sl.registerLazySingleton(() => GetCategoriesUseCase(sl()));  // ← manquait
  sl.registerLazySingleton(() => GetQuestionsUseCase(sl()));   // ← manquait
  sl.registerLazySingleton(() => SaveScoreUseCase(sl()));      // ← manquait
  sl.registerLazySingleton(() => GetLeaderboardUseCase(sl())); // ← manquait

  // ── BLoCs & Cubits ────────────────────────────────────────
  sl.registerFactory(() => AuthBloc(
        checkAuth: sl(),
        signIn: sl(),
        signUp: sl(),
        signOut: sl(),
      ));
  sl.registerFactory(() => CategoryCubit(sl()));
  sl.registerFactory(() => GameBloc(
        getQuestions: sl(),
        saveScore: sl(),
      ));
  sl.registerFactory(() => ScoreBloc(sl()));
}