import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../category/domain/entities/category.dart';
import '../../../score/presentation/pages/score_screen.dart';
import '../../domain/entities/option.dart';
import '../bloc/game_bloc.dart';
import '../bloc/game_event.dart';
import '../bloc/game_state.dart';

class GameScreen extends StatelessWidget {
  final Category category;
  final String difficulty;

  const GameScreen({
    super.key,
    required this.category,
    required this.difficulty,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<GameBloc>()
        ..add(
          LoadQuestionsEvent(categoryId: category.id, difficulty: difficulty),
        ),
      child: _GameView(category: category),
    );
  }
}

class _GameView extends StatelessWidget {
  final Category category;
  const _GameView({required this.category});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<GameBloc, GameState>(
      listener: (context, state) {
        if (state is GameOverState) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => ScoreScreen(
                totalScore: state.totalScore,
                correctAnswers: state.correctAnswers,
                totalQuestions: state.totalQuestions,
                categoryId: state.categoryId,
                scoreId: state.scoreId,
              ),
            ),
          );
        }
      },
      builder: (context, state) {
        if (state is GameLoading) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(color: AppColors.orange),
            ),
          );
        }
        if (state is GameErrorState) {
          return Scaffold(
            body: Center(
              child: Text(
                state.message,
                style: const TextStyle(color: AppColors.textSecondary),
              ),
            ),
          );
        }
        if (state is QuestionLoadedState) {
          return _QuestionView(state: state, category: category);
        }
        if (state is AnswerResultState) {
          return _AnswerResultView(state: state, category: category);
        }
        return const Scaffold(
          body: Center(
            child: CircularProgressIndicator(color: AppColors.orange),
          ),
        );
      },
    );
  }
}

// ── Timer circulaire ──────────────────────────────────────────
class _CircularTimer extends StatelessWidget {
  final int seconds;
  final int maxSeconds;
  const _CircularTimer({required this.seconds, required this.maxSeconds});

  @override
  Widget build(BuildContext context) {
    final progress = seconds / maxSeconds;
    final color = seconds <= 5
        ? AppColors.wrong
        : seconds <= 10
        ? Colors.amber
        : AppColors.orange;

    return SizedBox(
      width: 72,
      height: 72,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CustomPaint(
            size: const Size(72, 72),
            painter: _TimerPainter(progress: progress, color: color),
          ),
          Text(
            '$seconds',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

class _TimerPainter extends CustomPainter {
  final double progress;
  final Color color;
  _TimerPainter({required this.progress, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 4;
    final strokeWidth = 5.0;

    // Fond
    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..color = AppColors.cardBorder
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth,
    );

    // Arc progress
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -pi / 2,
      2 * pi * progress,
      false,
      Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(_TimerPainter old) =>
      old.progress != progress || old.color != color;
}

// ── Vue Question ──────────────────────────────────────────────
class _QuestionView extends StatelessWidget {
  final QuestionLoadedState state;
  final Category category;
  const _QuestionView({required this.state, required this.category});

  @override
  Widget build(BuildContext context) {
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
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Column(
              children: [
                // Header : score | progress | timer
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Score
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.person_outline,
                            color: AppColors.textSecondary,
                            size: 16,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            '${state.questionIndex + 1} of ${state.totalQuestions}',
                            style: const TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Timer circulaire
                    _CircularTimer(
                      seconds: state.timerSeconds,
                      maxSeconds: state.question.timeLimit,
                    ),

                    // Points
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.emoji_events,
                            color: AppColors.orange,
                            size: 16,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            '${state.score} pts',
                            style: const TextStyle(
                              color: AppColors.orange,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Progress bar
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: (state.questionIndex + 1) / state.totalQuestions,
                    backgroundColor: AppColors.surface,
                    valueColor: const AlwaysStoppedAnimation(AppColors.orange),
                    minHeight: 6,
                  ),
                ),
                const SizedBox(height: 24),

                // Carte question
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceLight,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: AppColors.cardBorder, width: 1),
                  ),
                  child: Column(
                    children: [
                      Text(
                        'Question ${(state.questionIndex + 1).toString().padLeft(2, '0')}',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppColors.orange,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        category.name,
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 12),
                        child: Divider(color: AppColors.cardBorder),
                      ),
                      Text(
                        '"${state.question.text}"',
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                          height: 1.5,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Options
                Expanded(
                  child: ListView(
                    children: state.question.options
                        .map(
                          (opt) => _OptionTile(
                            option: opt,
                            onTap: () => context.read<GameBloc>().add(
                              AnswerSubmittedEvent(opt),
                            ),
                          ),
                        )
                        .toList(),
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

class _OptionTile extends StatelessWidget {
  final Option option;
  final VoidCallback onTap;
  const _OptionTile({required this.option, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.cardBorder, width: 1),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                option.text,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.cardBorder, width: 1.5),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Vue Résultat Réponse ──────────────────────────────────────
class _AnswerResultView extends StatelessWidget {
  final AnswerResultState state;
  final Category category;
  const _AnswerResultView({required this.state, required this.category});

  @override
  Widget build(BuildContext context) {
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
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                // Options avec couleurs résultat
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Icône résultat
                      Container(
                        width: 90,
                        height: 90,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: state.isCorrect
                              ? AppColors.correct.withOpacity(0.15)
                              : AppColors.wrong.withOpacity(0.15),
                        ),
                        child: Icon(
                          state.isCorrect ? Icons.check_circle : Icons.cancel,
                          size: 60,
                          color: state.isCorrect
                              ? AppColors.correct
                              : AppColors.wrong,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        state.isCorrect
                            ? 'Bonne réponse ! +10 pts'
                            : 'Mauvaise réponse',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: state.isCorrect
                              ? AppColors.correct
                              : AppColors.wrong,
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Toutes les options avec couleurs
                      ...state.question.options.map((opt) {
                        Color borderColor = AppColors.cardBorder;
                        Color bgColor = AppColors.surface;
                        Color textColor = AppColors.textPrimary;
                        Widget? trailing;

                        if (opt.isCorrect) {
                          borderColor = AppColors.correct;
                          bgColor = AppColors.correct.withOpacity(0.1);
                          textColor = AppColors.correct;
                          trailing = const Icon(
                            Icons.check_circle,
                            color: AppColors.correct,
                            size: 24,
                          );
                        } else if (opt.id == state.selectedOption.id) {
                          borderColor = AppColors.wrong;
                          bgColor = AppColors.wrong.withOpacity(0.1);
                          textColor = AppColors.wrong;
                          trailing = const Icon(
                            Icons.cancel,
                            color: AppColors.wrong,
                            size: 24,
                          );
                        }

                        return Container(
                          margin: const EdgeInsets.only(bottom: 10),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 14,
                          ),
                          decoration: BoxDecoration(
                            color: bgColor,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: borderColor, width: 1.5),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  opt.text,
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w500,
                                    color: textColor,
                                  ),
                                ),
                              ),
                              if (trailing != null) trailing,
                            ],
                          ),
                        );
                      }),
                    ],
                  ),
                ),

                // Bouton suivant
                SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: ElevatedButton(
                    onPressed: () =>
                        context.read<GameBloc>().add(NextQuestionEvent()),
                    child: Text(
                      state.questionIndex < state.totalQuestions - 1
                          ? 'Question suivante'
                          : 'Voir mon score',
                    ),
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
