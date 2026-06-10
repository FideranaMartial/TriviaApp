import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/theme/app_theme.dart';
import '../bloc/score_bloc.dart';
import '../bloc/score_event.dart';
import '../bloc/score_state.dart';
import '../../domain/entities/score.dart';

class LeaderboardScreen extends StatelessWidget {
  final int categoryId;
  final int? currentScoreId;
  const LeaderboardScreen({
    super.key,
    required this.categoryId,
    this.currentScoreId,
  });

  @override
  Widget build(BuildContext context) {
    // Récupérer l'uid du joueur connecté
    final currentUid = Supabase.instance.client.auth.currentUser?.id ?? '';

    return BlocProvider(
      create: (_) => sl<ScoreBloc>()..add(LoadLeaderboardEvent(categoryId)),
      child: Scaffold(
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFF2D1B69), Color(0xFF1A1A2E)],
            ),
          ),
          child: SafeArea(
            child: Column(
              children: [
                // Header
                Padding(
                  padding: const EdgeInsets.fromLTRB(8, 8, 20, 0),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(
                          Icons.arrow_back_ios,
                          color: AppColors.textPrimary,
                        ),
                        onPressed: () => Navigator.pop(context),
                      ),
                      const Text(
                        'Classement',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Liste
                Expanded(
                  child: BlocBuilder<ScoreBloc, ScoreState>(
                    builder: (context, state) {
                      if (state is ScoreLoading || state is ScoreInitial) {
                        return const Center(
                          child: CircularProgressIndicator(
                            color: AppColors.orange,
                          ),
                        );
                      }
                      if (state is ScoreErrorState) {
                        return Center(
                          child: Text(
                            state.message,
                            style: const TextStyle(
                              color: AppColors.textSecondary,
                            ),
                          ),
                        );
                      }
                      if (state is LeaderboardLoadedState) {
                        if (state.scores.isEmpty) {
                          return const Center(
                            child: Text(
                              'Aucun score pour cette catégorie.',
                              style: TextStyle(color: AppColors.textSecondary),
                            ),
                          );
                        }
                        return ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: state.scores.length,
                          itemBuilder: (_, i) => _ScoreTile(
                            rank: i + 1,
                            score: state.scores[i],
                            isCurrentUser:
                                state.scores[i].playerId == currentUid,
                          ),
                        );
                      }
                      return const SizedBox.shrink();
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ScoreTile extends StatelessWidget {
  final int rank;
  final Score score;
  final bool isCurrentUser; // ← indique si c'est le joueur connecté

  const _ScoreTile({
    required this.rank,
    required this.score,
    required this.isCurrentUser,
  });

  @override
  Widget build(BuildContext context) {
    const medals = ['🥇', '🥈', '🥉'];
    final isTop3 = rank <= 3;
    final displayName = score.pseudo ?? score.playerId.substring(0, 8);

    // Couleurs selon si c'est le joueur connecté ou non
    final bgColor = isCurrentUser
        ? AppColors.orange.withOpacity(0.15)
        : isTop3
        ? AppColors.primary.withOpacity(0.15)
        : AppColors.surface;

    final borderColor = isCurrentUser
        ? AppColors.orange.withOpacity(0.7)
        : isTop3
        ? AppColors.primary.withOpacity(0.4)
        : AppColors.cardBorder;

    final avatarBg = isCurrentUser
        ? AppColors.orange.withOpacity(0.25)
        : AppColors.primary.withOpacity(0.2);

    final avatarTextColor = isCurrentUser
        ? AppColors.orange
        : AppColors.primaryLight;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor, width: isCurrentUser ? 2 : 1),
        boxShadow: isCurrentUser
            ? [
                BoxShadow(
                  color: AppColors.orange.withOpacity(0.2),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ]
            : null,
      ),
      child: Row(
        children: [
          // Rang
          SizedBox(
            width: 36,
            child: Text(
              isTop3 ? medals[rank - 1] : '$rank',
              style: TextStyle(
                fontSize: isTop3 ? 22 : 15,
                fontWeight: FontWeight.bold,
                color: isCurrentUser
                    ? AppColors.orange
                    : AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(width: 12),

          // Avatar avec initiale
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: avatarBg,
              border: isCurrentUser
                  ? Border.all(color: AppColors.orange, width: 2)
                  : null,
            ),
            child: Center(
              child: Text(
                displayName.isNotEmpty ? displayName[0].toUpperCase() : '?',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: avatarTextColor,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),

          // Pseudo + réponses
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      displayName,
                      style: TextStyle(
                        color: isCurrentUser
                            ? AppColors.orange
                            : AppColors.textPrimary,
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                      ),
                    ),
                    if (isCurrentUser) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.orange.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(99),
                        ),
                        child: const Text(
                          'Vous',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: AppColors.orange,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                Text(
                  '${score.correctAnswers} bonnes réponses',
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),

          // Points
          Text(
            '${score.points} pts',
            style: TextStyle(
              color: isCurrentUser ? AppColors.orange : AppColors.orange,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }
}
