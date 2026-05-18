class Option {
  final int id;
  final int questionId;
  final String text;
  final bool isCorrect;

  const Option({
    required this.id,
    required this.questionId,
    required this.text,
    required this.isCorrect,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is Option && other.id == id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'Option(id: $id, text: $text, isCorrect: $isCorrect)';
}