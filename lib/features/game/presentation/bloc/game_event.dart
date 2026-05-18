import 'package:equatable/equatable.dart';
import '../../domain/entities/option.dart';

abstract class GameEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class LoadQuestionsEvent extends GameEvent {
  final int categoryId;
  final String difficulty;
   LoadQuestionsEvent({
    required this.categoryId,
    required this.difficulty,
  });
  @override
  List<Object?> get props => [categoryId, difficulty];
}

class AnswerSubmittedEvent extends GameEvent {
  final Option selectedOption;
   AnswerSubmittedEvent(this.selectedOption);
  @override
  List<Object?> get props => [selectedOption.id];
}

class NextQuestionEvent extends GameEvent {}

class TimerTickEvent extends GameEvent {
  final int remaining;
   TimerTickEvent(this.remaining);
  @override
  List<Object?> get props => [remaining];
}

class TimerExpiredEvent extends GameEvent {}