import 'package:flutter/material.dart';
import 'leaderboard_screen.dart';

class ScoreScreen extends StatelessWidget {
  final int totalScore;
  final int correctAnswers;
  final int totalQuestions;
  final int categoryId;

  const ScoreScreen({
    super.key,
    required this.totalScore,
    required this.correctAnswers,
    required this.totalQuestions,
    required this.categoryId,
  });

  @override
  Widget build(BuildContext context) {
    final percent = totalQuestions > 0
        ? (correctAnswers / totalQuestions * 100).round()
        : 0;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Icon(Icons.emoji_events, size: 90, color: Colors.amber),
              const SizedBox(height: 16),
              const Text(
                'Partie terminée !',
                style:
                    TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 36),
              _StatRow(label: 'Score total', value: '$totalScore pts'),
              const SizedBox(height: 12),
              _StatRow(
                  label: 'Bonnes réponses',
                  value: '$correctAnswers / $totalQuestions'),
              const SizedBox(height: 12),
              _StatRow(
                  label: 'Taux de réussite', value: '$percent %'),
              const SizedBox(height: 44),
              FilledButton(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        LeaderboardScreen(categoryId: categoryId),
                  ),
                ),
                child: const Text('Voir le classement'),
              ),
              const SizedBox(height: 12),
              OutlinedButton(
                onPressed: () =>
                    Navigator.popUntil(context, (r) => r.isFirst),
                child: const Text("Retour à l'accueil"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatRow extends StatelessWidget {
  final String label;
  final String value;
  const _StatRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.grey.withOpacity(0.07),
        borderRadius: BorderRadius.circular(12),
        border:
            Border.all(color: Colors.grey.withOpacity(0.2)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: const TextStyle(
                  color: Colors.grey, fontSize: 15)),
          Text(value,
              style: const TextStyle(
                  fontWeight: FontWeight.bold, fontSize: 16)),
        ],
      ),
    );
  }
}