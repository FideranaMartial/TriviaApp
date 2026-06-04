import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../score/presentation/bloc/score_bloc.dart';
import '../../../score/presentation/bloc/score_event.dart';
import 'leaderboard_screen.dart';
import '../../../../core/theme/app_theme.dart';

class ScoreScreen extends StatefulWidget {
  final int totalScore;
  final int correctAnswers;
  final int totalQuestions;
  final int categoryId;
  // ── Ajout du pseudo pour l'enregistrement en base ──
  final String pseudo;

  const ScoreScreen({
    super.key,
    required this.totalScore,
    required this.correctAnswers,
    required this.totalQuestions,
    required this.categoryId,
    required this.pseudo,
  });

  @override
  State<ScoreScreen> createState() => _ScoreScreenState();
}

class _ScoreScreenState extends State<ScoreScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scoreAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    // ── Sauvegarde du score avec le pseudo ────────────────────────────────────
    // On déclenche l'événement de sauvegarde dès l'ouverture de l'écran.
    // Le pseudo est transmis pour être stocké dans Firestore aux côtés de
    // l'uid, ce qui permet au leaderboard d'afficher les vrais pseudos.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ScoreBloc>().add(
        SaveScoreEvent(
          categoryId: widget.categoryId,
          points: widget.totalScore,
          correctAnswers: widget.correctAnswers,
          pseudo: widget.pseudo,
        ),
      );
    });
    // ─────────────────────────────────────────────────────────────────────────

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    _scoreAnimation = Tween<double>(
      begin: 0,
      end: widget.totalScore.toDouble(),
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));
    _fadeAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeIn));
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppTheme.primaryGradient),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 20),
                  _buildAnimatedTrophy(),
                  const SizedBox(height: 20),
                  FadeTransition(
                    opacity: _fadeAnimation,
                    child: Column(
                      children: [
                        const Text(
                          'Partie terminée !',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Félicitations !',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.white.withOpacity(0.8),
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 30),
                  _buildStatCard(),
                  const SizedBox(height: 30),
                  _buildActionButtons(),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAnimatedTrophy() {
    return TweenAnimationBuilder(
      tween: Tween<double>(begin: 0, end: 1),
      duration: const Duration(milliseconds: 800),
      builder: (context, double scale, child) {
        return Transform.scale(
          scale: scale,
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: AppTheme.secondaryGradient,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFF97316).withOpacity(0.5),
                  blurRadius: 30,
                  spreadRadius: 5,
                ),
              ],
            ),
            child: const Icon(
              Icons.emoji_events,
              size: 70,
              color: Colors.white,
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatCard() {
    final percent = (widget.correctAnswers / widget.totalQuestions * 100)
        .round();

    return AnimatedBuilder(
      animation: _scoreAnimation,
      builder: (context, child) {
        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white.withOpacity(0.1),
                Colors.white.withOpacity(0.05),
              ],
            ),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: Colors.white.withOpacity(0.2),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 20,
                spreadRadius: 5,
              ),
            ],
          ),
          child: Column(
            children: [
              _buildStatRow(
                'Score total',
                '${_scoreAnimation.value.toInt()} pts',
                const Color(0xFFFB923C),
              ),
              const SizedBox(height: 12),
              _buildStatRow(
                'Bonnes réponses',
                '${widget.correctAnswers} / ${widget.totalQuestions}',
                Colors.green,
              ),
              const SizedBox(height: 12),
              _buildStatRow('Taux de réussite', '$percent%', Colors.blue),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatRow(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withOpacity(0.7),
              fontSize: 14,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        // ── Voir le classement ─────────────────────────────────────────────
        TweenAnimationBuilder(
          tween: Tween<double>(begin: 0, end: 1),
          duration: const Duration(milliseconds: 500),
          builder: (context, double scale, child) {
            return Transform.scale(
              scale: scale,
              child: Container(
                decoration: BoxDecoration(
                  gradient: AppTheme.secondaryGradient,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFF97316).withOpacity(0.4),
                      blurRadius: 15,
                    ),
                  ],
                ),
                child: ElevatedButton(
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          LeaderboardScreen(categoryId: widget.categoryId),
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    minimumSize: const Size(double.infinity, 52),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: const Text(
                    'Voir le classement',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            );
          },
        ),
        const SizedBox(height: 10),
        // ── Retour à l'accueil ────────────────────────────────────────────
        OutlinedButton(
          onPressed: () => Navigator.popUntil(context, (r) => r.isFirst),
          style: OutlinedButton.styleFrom(
            side: BorderSide(color: const Color(0xFFF97316).withOpacity(0.5)),
            minimumSize: const Size(double.infinity, 52),
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          child: const Text(
            "Retour à l'accueil",
            style: TextStyle(fontSize: 15, color: Colors.white70),
          ),
        ),
      ],
    );
  }
}

// Event used to save a score when arriving on the score screen.
class SaveScoreEvent extends ScoreEvent {
  final int categoryId;
  final int points;
  final int correctAnswers;
  final String pseudo;

  SaveScoreEvent({
    required this.categoryId,
    required this.points,
    required this.correctAnswers,
    required this.pseudo,
  });

  @override
  List<Object?> get props => [categoryId, points, correctAnswers, pseudo];
}
