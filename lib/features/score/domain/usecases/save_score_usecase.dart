import '../../../../core/usecases/usecase.dart';
import '../entities/score.dart';
import '../repositories/i_score_repository.dart';

class SaveScoreUseCase implements UseCase<void, Score> {
  final IScoreRepository _repository;
  const SaveScoreUseCase(this._repository);

  @override
  Future<void> call(Score params) => _repository.saveScore(params);
}