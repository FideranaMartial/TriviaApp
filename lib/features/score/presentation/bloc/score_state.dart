import 'package:equatable/equatable.dart';
import '../../domain/entities/score.dart';

abstract class ScoreState extends Equatable {
  @override
  List<Object?> get props => [];
}

class ScoreInitial extends ScoreState {}
class ScoreLoading extends ScoreState {}

class LeaderboardLoadedState extends ScoreState {
  final List<Score> scores;
   LeaderboardLoadedState(this.scores);
  @override
  List<Object?> get props => [scores];
}

class ScoreErrorState extends ScoreState {
  final String message;
   ScoreErrorState(this.message);
  @override
  List<Object?> get props => [message];
}