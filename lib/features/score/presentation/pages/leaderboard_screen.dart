import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/di/injection.dart';
import '../bloc/score_bloc.dart';
import '../bloc/score_event.dart';
import '../bloc/score_state.dart';
import '../../domain/entities/score.dart';

class LeaderboardScreen extends StatelessWidget {
  final int categoryId;
  const LeaderboardScreen({super.key, required this.categoryId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<ScoreBloc>()
        ..add(LoadLeaderboardEvent(categoryId)),
      child: Scaffold(
        appBar: AppBar(title: const Text('Classement')),
        body: BlocBuilder<ScoreBloc, ScoreState>(
          builder: (context, state) {
            if (state is ScoreLoading || state is ScoreInitial) {
              return const Center(child: CircularProgressIndicator());
            }
            if (state is ScoreErrorState) {
              return Center(child: Text(state.message));
            }
            if (state is LeaderboardLoadedState) {
              return _LeaderboardList(scores: state.scores);
            }
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }
}

class _LeaderboardList extends StatelessWidget {
  final List<Score> scores;
  const _LeaderboardList({required this.scores});

  @override
  Widget build(BuildContext context) {
    if (scores.isEmpty) {
      return const Center(
        child: Text('Aucun score pour cette catégorie.'),
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: scores.length,
      separatorBuilder: (_, __) => const Divider(height: 1),
      itemBuilder: (_, i) => _ScoreTile(rank: i + 1, score: scores[i]),
    );
  }
}

class _ScoreTile extends StatelessWidget {
  final int rank;
  final Score score;
  const _ScoreTile({required this.rank, required this.score});

  @override
  Widget build(BuildContext context) {
    const medals = ['🥇', '🥈', '🥉'];
    return ListTile(
      leading: Text(
        rank <= 3 ? medals[rank - 1] : '$rank',
        style: const TextStyle(fontSize: 20),
      ),
      title: Text(
        score.playerId.substring(0, 8),
        style: const TextStyle(fontWeight: FontWeight.w600),
      ),
      subtitle: Text('${score.correctAnswers} bonnes réponses'),
      trailing: Text(
        '${score.points} pts',
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 16,
          color: Colors.amber,
        ),
      ),
    );
  }
}