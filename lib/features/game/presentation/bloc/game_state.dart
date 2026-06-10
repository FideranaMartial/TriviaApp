import 'package:equatable/equatable.dart';
import '../../domain/entities/question.dart';
import '../../domain/entities/option.dart';

abstract class GameState extends Equatable {
  @override
  List<Object?> get props => [];
}

class GameInitial extends GameState {}
class GameLoading extends GameState {}

class QuestionLoadedState extends GameState {
  final Question question;
  final int questionIndex;
  final int totalQuestions;
  final int score;
  final int timerSeconds;

   QuestionLoadedState({
    required this.question,
    required this.questionIndex,
    required this.totalQuestions,
    required this.score,
    required this.timerSeconds,
  });

  @override
  List<Object?> get props =>
      [question.id, questionIndex, score, timerSeconds];
}

class AnswerResultState extends GameState {
  final Question question;
  final Option selectedOption;
  final bool isCorrect;
  final int score;
  final int questionIndex;
  final int totalQuestions;

   AnswerResultState({
    required this.question,
    required this.selectedOption,
    required this.isCorrect,
    required this.score,
    required this.questionIndex,
    required this.totalQuestions,
  });

  @override
  List<Object?> get props => [selectedOption.id, isCorrect, score];
}

class GameOverState extends GameState {
  final int totalScore;
  final int correctAnswers;
  final int totalQuestions;
  final int categoryId;
  final int? scoreId;

   GameOverState({
    required this.totalScore,
    required this.correctAnswers,
    required this.totalQuestions,
    required this.categoryId,
    this.scoreId, 
  });

  @override
  List<Object?> get props => [totalScore, correctAnswers];
}

class GameErrorState extends GameState {
  final String message;
   GameErrorState(this.message);
  @override
  List<Object?> get props => [message];
}