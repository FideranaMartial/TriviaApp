import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/di/injection.dart';
import '../../../category/domain/entities/category.dart';
import '../../../score/presentation/pages/score_screen.dart';
import '../../domain/entities/option.dart';
import '../bloc/game_bloc.dart';
import '../bloc/game_event.dart';
import '../bloc/game_state.dart';
import '../../../../core/theme/app_theme.dart';

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
                categoryId: state.categoryId, pseudo: '',
              ),
            ),
          );
        }
      },
      builder: (context, state) {
        if (state is GameLoading) {
          return const Scaffold(
            body: Center(child: _AnimatedGameLoader()),
          );
        }
        if (state is GameErrorState) {
          return Scaffold(
            body: Center(child: Text(state.message)),
          );
        }
        if (state is QuestionLoadedState) {
          return _QuestionView(state: state, category: category);
        }
        if (state is AnswerResultState) {
          return _AnimatedAnswerResultView(state: state, category: category);
        }
        return const Scaffold(
          body: Center(child: CircularProgressIndicator()),
        );
      },
    );
  }
}

class _AnimatedGameLoader extends StatelessWidget {
  const _AnimatedGameLoader();

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        TweenAnimationBuilder(
          tween: Tween<double>(begin: 0, end: 1),
          duration: const Duration(milliseconds: 800),
          builder: (context, double value, child) {
            return Transform.scale(
              scale: value,
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: AppTheme.secondaryGradient,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.deepPurple.withOpacity(0.4),
                      blurRadius: 20,
                    ),
                  ],
                ),
                child: const SizedBox(
                  height: 50,
                  width: 50,
                  child: CircularProgressIndicator(
                    strokeWidth: 3,
                    color: Colors.white,
                  ),
                ),
              ),
            );
          },
        ),
        const SizedBox(height: 20),
        const Text(
          'Chargement des questions...',
          style: TextStyle(color: Colors.white70, fontSize: 16),
        ),
      ],
    );
  }
}

class _QuestionView extends StatefulWidget {
  final QuestionLoadedState state;
  final Category category;

  const _QuestionView({required this.state, required this.category});

  @override
  State<_QuestionView> createState() => _QuestionViewState();
}

class _QuestionViewState extends State<_QuestionView> with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _fadeAnimation = CurvedAnimation(parent: _fadeController, curve: Curves.easeIn);
    _fadeController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  Color get _color => Color(int.parse(widget.category.colorHex.replaceFirst('#', '0xFF')));

  @override
  Widget build(BuildContext context) {
    final timerRatio = widget.state.timerSeconds / widget.state.question.timeLimit;
    final timerColor = widget.state.timerSeconds <= 5 ? Colors.red : _color;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(widget.category.name),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: AppTheme.primaryGradient,
        ),
        child: SafeArea(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildProgressBar(_color),
                  const SizedBox(height: 20),
                  _buildScoreAndTimer(timerColor),
                  const SizedBox(height: 8),
                  _buildTimerBar(timerColor, timerRatio),
                  const SizedBox(height: 20),
                  _buildQuestionCard(_color),
                  const SizedBox(height: 20),
                  ...widget.state.question.options.map(
                    (opt) => _AnimatedOptionButton(
                      option: opt,
                      color: _color,
                      index: widget.state.question.options.indexOf(opt),
                      onTap: () => context.read<GameBloc>().add(AnswerSubmittedEvent(opt)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProgressBar(Color color) {
    return Column(
      children: [
        Text(
          'Question ${widget.state.questionIndex + 1} / ${widget.state.totalQuestions}',
          style: const TextStyle(color: Colors.white70, fontSize: 13),
        ),
        const SizedBox(height: 4),
        LinearProgressIndicator(
          value: (widget.state.questionIndex + 1) / widget.state.totalQuestions,
          color: color,
          backgroundColor: Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(4),
        ),
      ],
    );
  }

  Widget _buildScoreAndTimer(Color timerColor) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            children: [
              const Icon(Icons.star, color: Colors.amber, size: 18),
              const SizedBox(width: 4),
              Text(
                '${widget.state.score}',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: timerColor.withOpacity(0.2),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: timerColor, width: 1),
          ),
          child: Row(
            children: [
              Icon(Icons.timer, color: timerColor, size: 16),
              const SizedBox(width: 4),
              Text(
                '${widget.state.timerSeconds}s',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: timerColor,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTimerBar(Color timerColor, double timerRatio) {
    return TweenAnimationBuilder(
      tween: Tween<double>(begin: 1, end: timerRatio),
      duration: const Duration(milliseconds: 300),
      builder: (context, double value, child) {
        return LinearProgressIndicator(
          value: value,
          color: timerColor,
          backgroundColor: Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(4),
        );
      },
    );
  }

  Widget _buildQuestionCard(Color color) {
    return Expanded(
      child: Container(
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
          border: Border.all(color: color.withOpacity(0.3), width: 2),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.2),
              blurRadius: 20,
              spreadRadius: 2,
            ),
          ],
        ),
        alignment: Alignment.center,
        padding: const EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Text(
            widget.state.question.text,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Colors.white,
              height: 1.4,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}

class _AnimatedOptionButton extends StatefulWidget {
  final Option option;
  final Color color;
  final int index;
  final VoidCallback onTap;

  const _AnimatedOptionButton({
    required this.option,
    required this.color,
    required this.index,
    required this.onTap,
  });

  @override
  State<_AnimatedOptionButton> createState() => _AnimatedOptionButtonState();
}

class _AnimatedOptionButtonState extends State<_AnimatedOptionButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 300 + (widget.index * 50)),
    );
    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic);
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _animation,
      child: SlideTransition(
        position: Tween<Offset>(begin: const Offset(0, 0.5), end: Offset.zero).animate(_animation),
        child: Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: OutlinedButton(
            onPressed: widget.onTap,
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
              side: BorderSide(color: widget.color.withOpacity(0.5), width: 2),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              backgroundColor: widget.color.withOpacity(0.1),
            ),
            child: Text(
              widget.option.text,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 15, color: Colors.white),
            ),
          ),
        ),
      ),
    );
  }
}

class _AnimatedAnswerResultView extends StatefulWidget {
  final AnswerResultState state;
  final Category category;

  const _AnimatedAnswerResultView({required this.state, required this.category});

  @override
  State<_AnimatedAnswerResultView> createState() => _AnimatedAnswerResultViewState();
}

class _AnimatedAnswerResultViewState extends State<_AnimatedAnswerResultView>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _scaleAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.elasticOut),
    );
    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = Color(int.parse(widget.category.colorHex.replaceFirst('#', '0xFF')));

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: AppTheme.primaryGradient,
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                ScaleTransition(
                  scale: _scaleAnimation,
                  child: Icon(
                    widget.state.isCorrect ? Icons.check_circle : Icons.cancel,
                    size: 100,
                    color: widget.state.isCorrect ? Colors.green : Colors.red,
                  ),
                ),
                const SizedBox(height: 24),
                FadeTransition(
                  opacity: _fadeAnimation,
                  child: Column(
                    children: [
                      Text(
                        widget.state.isCorrect
                            ? 'Bonne réponse ! ✨'
                            : 'Mauvaise réponse 😔',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: widget.state.isCorrect ? Colors.green : Colors.red,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      if (widget.state.isCorrect) ...[
                        const SizedBox(height: 8),
                        const Text(
                          '+10 points',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.amber,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ] else ...[
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Column(
                            children: [
                              const Text(
                                'La bonne réponse était :',
                                style: TextStyle(color: Colors.white70),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                widget.state.question.correctOption?.text ?? '',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      ],
                      const SizedBox(height: 32),
                      Container(
                        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          'Score actuel : ${widget.state.score} pts',
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                        ),
                      ),
                      const SizedBox(height: 40),
                      _buildNextButton(color),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNextButton(Color color) {
    return TweenAnimationBuilder(
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
                  color: color.withOpacity(0.4),
                  blurRadius: 15,
                ),
              ],
            ),
            child: ElevatedButton(
              onPressed: () => context.read<GameBloc>().add(NextQuestionEvent()),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: Text(
                widget.state.questionIndex < widget.state.totalQuestions - 1
                    ? 'Question suivante →'
                    : 'Voir mon score 🏆',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        );
      },
    );
  }
}