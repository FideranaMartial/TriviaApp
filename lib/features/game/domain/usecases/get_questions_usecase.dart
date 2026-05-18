import '../../../../core/usecases/usecase.dart';
import '../entities/question.dart';
import '../repositories/i_question_repository.dart';

class GetQuestionsParams {
  final int categoryId;
  final String difficulty;
  final int limit;

  const GetQuestionsParams({
    required this.categoryId,
    required this.difficulty,
    this.limit = 10,
  });
}

class GetQuestionsUseCase implements UseCase<List<Question>, GetQuestionsParams> {
  final IQuestionRepository _repository;
  const GetQuestionsUseCase(this._repository);

  @override
  Future<List<Question>> call(GetQuestionsParams params) =>
      _repository.getQuestions(
        categoryId: params.categoryId,
        difficulty: params.difficulty,
        limit: params.limit,
      );
}