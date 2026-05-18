import '../../domain/entities/question.dart';
import '../../domain/repositories/i_question_repository.dart';
import '../datasources/question_remote_datasource.dart';

class QuestionRepositoryImpl implements IQuestionRepository {
  final QuestionRemoteDataSource _dataSource;
  const QuestionRepositoryImpl(this._dataSource);

  @override
  Future<List<Question>> getQuestions({
    required int categoryId,
    required String difficulty,
    int limit = 10,
  }) =>
      _dataSource.getQuestions(
        categoryId: categoryId,
        difficulty: difficulty,
        limit: limit,
      );
}