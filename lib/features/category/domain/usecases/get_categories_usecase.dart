import '../../../../core/usecases/usecase.dart';
import '../entities/category.dart';
import '../repositories/i_category_repository.dart';

class GetCategoriesUseCase implements UseCase<List<Category>, NoParams> {
  final ICategoryRepository _repository;
  const GetCategoriesUseCase(this._repository);

  @override
  Future<List<Category>> call(NoParams params) =>
      _repository.getCategories();
}