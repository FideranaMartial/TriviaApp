import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/theme/app_theme.dart';
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
      create: (_) => sl<ScoreBloc>()..add(LoadLeaderboardEvent(categoryId)),
      child: Scaffold(
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          title: const Text(
            'Classement',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
          ),
          backgroundColor: Colors.transparent,
          elevation: 0,
          iconTheme: const IconThemeData(color: Colors.white),
        ),
        body: Container(
          decoration: const BoxDecoration(
            gradient: AppTheme.primaryGradient,
          ),
          child: SafeArea(
            child: BlocBuilder<ScoreBloc, ScoreState>(
              builder: (context, state) {
                if (state is ScoreLoading || state is ScoreInitial) {
                  return const Center(
                    child: CircularProgressIndicator(
                      color: Color(0xFFF97316),
                    ),
                  );
                }
                if (state is ScoreErrorState) {
                  return Center(
                    child: Text(
                      state.message,
                      style: const TextStyle(color: Colors.white70, fontSize: 16),
                    ),
                  );
                }
                if (state is LeaderboardLoadedState) {
                  return _LeaderboardList(scores: state.scores);
                }
                return const SizedBox.shrink();
              },
            ),
          ),
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
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.08),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.leaderboard_rounded,
                size: 50,
                color: Colors.white38,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Aucun score pour cette catégorie.',
              style: TextStyle(color: Colors.white70, fontSize: 16),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      itemCount: scores.length,
      itemBuilder: (_, i) => _ScoreTile(rank: i + 1, score: scores[i]),
    );
  }
}

class _ScoreTile extends StatelessWidget {
  final int rank;
  final Score score;
  const _ScoreTile({required this.rank, required this.score});

  // Couleur de l'avatar selon le rang
  Color get _rankColor {
    if (rank == 1) return const Color(0xFFF97316); // orange doré
    if (rank == 2) return const Color(0xFFA855F7); // violet moyen
    if (rank == 3) return const Color(0xFF7C3AED); // violet foncé
    return const Color(0xFF241858);                // surface sombre
  }

  @override
  Widget build(BuildContext context) {
    const medals = ['🥇', '🥈', '🥉'];

    // ── Fix pseudo ────────────────────────────────────────────────────────────
    // Affiche le pseudo s'il est présent et non vide.
    // Sinon affiche "Joueur #XXXX" avec les 4 derniers caractères de l'UID,
    // beaucoup plus lisible qu'un UUID brut.
    final rawId = score.playerId;
    final shortId = rawId.length >= 4
        ? rawId.substring(rawId.length - 4).toUpperCase()
        : rawId.toUpperCase();
    final displayName =
        (score.pseudo != null && score.pseudo!.trim().isNotEmpty)
            ? score.pseudo!.trim()
            : 'Joueur #$shortId';
    // ─────────────────────────────────────────────────────────────────────────

    final initials = displayName.length >= 2
        ? displayName.substring(0, 2).toUpperCase()
        : displayName.toUpperCase();

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 5),
      decoration: BoxDecoration(
        color: rank <= 3
            ? _rankColor.withOpacity(0.12)
            : Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: rank <= 3
              ? _rankColor.withOpacity(0.4)
              : Colors.white.withOpacity(0.08),
          width: 1.5,
        ),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
        leading: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Médaille ou numéro
            SizedBox(
              width: 28,
              child: Text(
                rank <= 3 ? medals[rank - 1] : '$rank',
                style: TextStyle(
                  fontSize: rank <= 3 ? 20 : 13,
                  fontWeight: FontWeight.bold,
                  color: Colors.white54,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(width: 8),
            // Avatar initiales
            CircleAvatar(
              radius: 18,
              backgroundColor: _rankColor.withOpacity(0.25),
              child: Text(
                initials,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: rank <= 3 ? _rankColor : Colors.white60,
                ),
              ),
            ),
          ],
        ),
        title: Text(
          displayName,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 15,
            color: Colors.white,
          ),
        ),
        subtitle: Text(
          '${score.correctAnswers} bonne${score.correctAnswers > 1 ? 's' : ''} '
          'réponse${score.correctAnswers > 1 ? 's' : ''}',
          style: TextStyle(
            color: Colors.white.withOpacity(0.45),
            fontSize: 12,
          ),
        ),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: const Color(0xFFF97316).withOpacity(0.15),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: const Color(0xFFF97316).withOpacity(0.4),
            ),
          ),
          child: Text(
            '${score.points} pts',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
              color: Color(0xFFFB923C),
            ),
          ),
        ),
      ),
    );
  }
}