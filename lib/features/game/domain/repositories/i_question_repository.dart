import '../entities/question.dart';

abstract class IQuestionRepository {
  Future<List<Question>> getQuestions({
    required int categoryId,
    required String difficulty,
    int limit,
  });
}