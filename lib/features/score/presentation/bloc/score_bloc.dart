import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/get_leaderboard_usecase.dart';
import 'score_event.dart';
import 'score_state.dart';

class ScoreBloc extends Bloc<ScoreEvent, ScoreState> {
  final GetLeaderboardUseCase _getLeaderboard;

  ScoreBloc(this._getLeaderboard) : super(ScoreInitial()) {
    on<LoadLeaderboardEvent>(_onLoad);
  }

  Future<void> _onLoad(
    LoadLeaderboardEvent event,
    Emitter<ScoreState> emit,
  ) async {
    emit(ScoreLoading());
    await emit.forEach<List>(
      _getLeaderboard(event.categoryId),
      onData: (scores) => LeaderboardLoadedState(scores.cast()),
      onError: (e, _) => ScoreErrorState(e.toString()),
    );
  }
}