import 'option.dart';

class Question {
  final int id;
  final int categoryId;
  final String text;
  final String difficulty;
  final int timeLimit;
  final List<Option> options;

  const Question({
    required this.id,
    required this.categoryId,
    required this.text,
    required this.difficulty,
    required this.timeLimit,
    required this.options,
  });

  Option? get correctOption =>
      options.where((o) => o.isCorrect).isNotEmpty
          ? options.firstWhere((o) => o.isCorrect)
          : null;

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is Question && other.id == id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'Question(id: $id, text: $text)';
}