import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/di/injection.dart';
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
        ..add(LoadQuestionsEvent(
          categoryId: category.id,
          difficulty: difficulty,
        )),
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
              ),
            ),
          );
        }
      },
      builder: (context, state) {
        if (state is GameLoading) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        if (state is GameErrorState) {
          return Scaffold(
            appBar: AppBar(),
            body: Center(child: Text(state.message)),
          );
        }
        if (state is QuestionLoadedState) {
          return _QuestionView(state: state, category: category);
        }
        if (state is AnswerResultState) {
          return _AnswerResultView(state: state, category: category);
        }
        return const Scaffold(
          body: Center(child: CircularProgressIndicator()),
        );
      },
    );
  }
}

class _QuestionView extends StatelessWidget {
  final QuestionLoadedState state;
  final Category category;
  const _QuestionView({required this.state, required this.category});

  Color get _color =>
      Color(int.parse(category.colorHex.replaceFirst('#', '0xFF')));

  @override
  Widget build(BuildContext context) {
    final timerRatio = state.timerSeconds / state.question.timeLimit;
    final timerColor = state.timerSeconds <= 5 ? Colors.red : _color;

    return Scaffold(
      appBar: AppBar(
        title: Text(category.name),
        backgroundColor: _color.withOpacity(0.08),
        automaticallyImplyLeading: false,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Progression questions
            Text(
              'Question ${state.questionIndex + 1} / ${state.totalQuestions}',
              style: const TextStyle(color: Colors.grey, fontSize: 13),
            ),
            const SizedBox(height: 4),
            LinearProgressIndicator(
              value: (state.questionIndex + 1) / state.totalQuestions,
              color: _color,
              backgroundColor: _color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(4),
            ),
            const SizedBox(height: 14),

            // Score + Timer
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Score : ${state.score}',
                    style: const TextStyle(
                        fontSize: 15, fontWeight: FontWeight.w600)),
                Row(children: [
                  Icon(Icons.timer, color: timerColor, size: 18),
                  const SizedBox(width: 4),
                  Text('${state.timerSeconds}s',
                      style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: timerColor)),
                ]),
              ],
            ),
            const SizedBox(height: 4),
            LinearProgressIndicator(
              value: timerRatio,
              color: timerColor,
              backgroundColor: Colors.grey.withOpacity(0.15),
              borderRadius: BorderRadius.circular(4),
            ),
            const SizedBox(height: 28),

            // Question
            Expanded(
              child: Container(
                alignment: Alignment.center,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: _color.withOpacity(0.07),
                  borderRadius: BorderRadius.circular(16),
                  border:
                      Border.all(color: _color.withOpacity(0.25)),
                ),
                child: Text(
                  state.question.text,
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.w600),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Options
            ...state.question.options.map(
              (opt) => _OptionButton(
                option: opt,
                color: _color,
                onTap: () => context
                    .read<GameBloc>()
                    .add(AnswerSubmittedEvent(opt)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OptionButton extends StatelessWidget {
  final Option option;
  final Color color;
  final VoidCallback onTap;
  const _OptionButton({
    required this.option,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: OutlinedButton(
        onPressed: onTap,
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
          side: BorderSide(color: color.withOpacity(0.5)),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        child: Text(option.text,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 15)),
      ),
    );
  }
}

class _AnswerResultView extends StatelessWidget {
  final AnswerResultState state;
  final Category category;
  const _AnswerResultView(
      {required this.state, required this.category});

  @override
  Widget build(BuildContext context) {
    final color =
        Color(int.parse(category.colorHex.replaceFirst('#', '0xFF')));

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Icon(
              state.isCorrect ? Icons.check_circle : Icons.cancel,
              size: 90,
              color: state.isCorrect ? Colors.green : Colors.red,
            ),
            const SizedBox(height: 16),
            Text(
              state.isCorrect ? 'Bonne réponse !  +10 pts' : 'Mauvaise réponse',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: state.isCorrect ? Colors.green : Colors.red,
              ),
              textAlign: TextAlign.center,
            ),
            if (!state.isCorrect) ...[
              const SizedBox(height: 12),
              const Text('La bonne réponse était :',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey)),
              const SizedBox(height: 6),
              Text(
                state.question.correctOption?.text ?? '',
                style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.green),
                textAlign: TextAlign.center,
              ),
            ],
            const SizedBox(height: 24),
            Text('Score actuel : ${state.score}',
                style: const TextStyle(fontSize: 17),
                textAlign: TextAlign.center),
            const SizedBox(height: 36),
            FilledButton(
              onPressed: () =>
                  context.read<GameBloc>().add(NextQuestionEvent()),
              style: FilledButton.styleFrom(
                backgroundColor: color,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              child: Text(
                state.questionIndex < state.totalQuestions - 1
                    ? 'Question suivante'
                    : 'Voir mon score',
                style: const TextStyle(color: Colors.white, fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }
}