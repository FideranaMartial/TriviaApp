import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/entities/question.dart';
import '../../domain/usecases/get_questions_usecase.dart';
import '../../../score/domain/entities/score.dart';
import '../../../score/domain/usecases/save_score_usecase.dart';
import 'game_event.dart';
import 'game_state.dart';

class GameBloc extends Bloc<GameEvent, GameState> {
  final GetQuestionsUseCase getQuestions;
  final SaveScoreUseCase saveScore;

  List<Question> _questions = [];
  int _currentIndex = 0;
  int _score = 0;
  int _correctAnswers = 0;
  Timer? _timer;

  GameBloc({
    required this.getQuestions,
    required this.saveScore,
  }) : super(GameInitial()) {
    on<LoadQuestionsEvent>(_onLoad);
    on<AnswerSubmittedEvent>(_onAnswer);
    on<NextQuestionEvent>(_onNext);
    on<TimerTickEvent>(_onTick);
    on<TimerExpiredEvent>(_onExpired);
  }

  // ── Timer ────────────────────────────────────────────────

  void _startTimer(int seconds) {
    _timer?.cancel();
    int remaining = seconds;
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      remaining--;
      if (remaining <= 0) {
        t.cancel();
        add(TimerExpiredEvent());
      } else {
        add(TimerTickEvent(remaining));
      }
    });
  }

  // ── Handlers ─────────────────────────────────────────────

  Future<void> _onLoad(
    LoadQuestionsEvent event,
    Emitter<GameState> emit,
  ) async {
    emit(GameLoading());
    try {
      _questions = await getQuestions(GetQuestionsParams(
        categoryId: event.categoryId,
        difficulty: event.difficulty,
      ));
      _currentIndex = 0;
      _score = 0;
      _correctAnswers = 0;

      if (_questions.isEmpty) {
        emit( GameErrorState(
            'Aucune question disponible pour cette catégorie et cette difficulté.'));
        return;
      }

      _emitCurrentQuestion(emit);
    } catch (e) {
      emit(GameErrorState(e.toString()));
    }
  }

  void _onTick(TimerTickEvent event, Emitter<GameState> emit) {
    final current = state;
    if (current is QuestionLoadedState) {
      emit(QuestionLoadedState(
        question: current.question,
        questionIndex: current.questionIndex,
        totalQuestions: current.totalQuestions,
        score: current.score,
        timerSeconds: event.remaining,
      ));
    }
  }

  Future<void> _onExpired(
    TimerExpiredEvent event,
    Emitter<GameState> emit,
  ) async {
    _timer?.cancel();
    if (_isLastQuestion) {
      await _finish(emit);
    } else {
      _currentIndex++;
      _emitCurrentQuestion(emit);
    }
  }

  void _onAnswer(
    AnswerSubmittedEvent event,
    Emitter<GameState> emit,
  ) {
    _timer?.cancel();
    final current = state;
    if (current is! QuestionLoadedState) return;

    final isCorrect = event.selectedOption.isCorrect;
    if (isCorrect) {
      _score += 10;
      _correctAnswers++;
    }

    emit(AnswerResultState(
      question: current.question,
      selectedOption: event.selectedOption,
      isCorrect: isCorrect,
      score: _score,
      questionIndex: _currentIndex,
      totalQuestions: _questions.length,
    ));
  }

  Future<void> _onNext(
    NextQuestionEvent event,
    Emitter<GameState> emit,
  ) async {
    if (_isLastQuestion) {
      await _finish(emit);
    } else {
      _currentIndex++;
      _emitCurrentQuestion(emit);
    }
  }

  // ── Helpers ──────────────────────────────────────────────

  bool get _isLastQuestion => _currentIndex >= _questions.length - 1;

  void _emitCurrentQuestion(Emitter<GameState> emit) {
    final q = _questions[_currentIndex];
    _startTimer(q.timeLimit);
    emit(QuestionLoadedState(
      question: q,
      questionIndex: _currentIndex,
      totalQuestions: _questions.length,
      score: _score,
      timerSeconds: q.timeLimit,
    ));
  }

  Future<void> _finish(Emitter<GameState> emit) async {
    final uid = Supabase.instance.client.auth.currentUser?.id;
    if (uid != null && _questions.isNotEmpty) {
      try {
        await saveScore(Score(
          playerId: uid,
          categoryId: _questions.first.categoryId,
          points: _score,
          correctAnswers: _correctAnswers,
        ));
      } catch (_) {}
    }
    emit(GameOverState(
      totalScore: _score,
      correctAnswers: _correctAnswers,
      totalQuestions: _questions.length,
      categoryId: _questions.isNotEmpty ? _questions.first.categoryId : 0,
    ));
  }

  @override
  Future<void> close() {
    _timer?.cancel();
    return super.close();
  }
}