import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import 'leaderboard_screen.dart';

class ScoreScreen extends StatelessWidget {
  final int totalScore;
  final int correctAnswers;
  final int totalQuestions;
  final int categoryId;
  final int? scoreId;
  

  const ScoreScreen({
    super.key,
    required this.totalScore,
    required this.correctAnswers,
    required this.totalQuestions,
    required this.categoryId,
    this.scoreId,
  });

  @override
  Widget build(BuildContext context) {
    final percent = totalQuestions > 0
        ? (correctAnswers / totalQuestions * 100).round()
        : 0;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF2D1B69), Color(0xFF1A1A2E)],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 20),

                // Trophée
                Center(
                  child: Container(
                    width: 100,
                    height: 100,
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.orange.withOpacity(0.15),
                      border: Border.all(
                        color: AppColors.orange.withOpacity(0.4),
                        width: 2,
                      ),
                    ),
                    child: const Icon(
                      Icons.emoji_events,
                      size: 55,
                      color: AppColors.orange,
                    ),
                  ),
                ),

                const Text(
                  'Partie terminée !',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                const Text(
                  'Voici vos résultats',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 36),

                // Stats
                _StatCard(
                  icon: Icons.star,
                  iconColor: AppColors.orange,
                  label: 'Score total',
                  value: '$totalScore pts',
                ),
                const SizedBox(height: 12),
                _StatCard(
                  icon: Icons.check_circle,
                  iconColor: AppColors.correct,
                  label: 'Bonnes réponses',
                  value: '$correctAnswers / $totalQuestions',
                ),
                const SizedBox(height: 12),
                _StatCard(
                  icon: Icons.percent,
                  iconColor: AppColors.primaryLight,
                  label: 'Taux de réussite',
                  value: '$percent %',
                ),
                const SizedBox(height: 36),

                // Bouton classement
                SizedBox(
                  height: 54,
                  child: ElevatedButton(
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            LeaderboardScreen(categoryId: categoryId, currentScoreId: scoreId,),
                      ),
                    ),
                    child: const Text('Voir le classement'),
                  ),
                ),
                const SizedBox(height: 12),

                // Bouton accueil
                SizedBox(
                  height: 54,
                  child: OutlinedButton(
                    onPressed: () =>
                        Navigator.popUntil(context, (r) => r.isFirst),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: AppColors.cardBorder),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child: const Text(
                      "Retour à l'accueil",
                      style: TextStyle(color: AppColors.textSecondary),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label;
  final String value;

  const _StatCard({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.cardBorder, width: 1),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 15,
              ),
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }
}
