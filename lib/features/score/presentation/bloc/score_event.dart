import 'package:equatable/equatable.dart';

abstract class ScoreEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class LoadLeaderboardEvent extends ScoreEvent {
  final int categoryId;
   LoadLeaderboardEvent(this.categoryId);
  @override
  List<Object?> get props => [categoryId];
}