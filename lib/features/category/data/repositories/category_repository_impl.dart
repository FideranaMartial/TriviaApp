import '../../domain/entities/category.dart';
import '../../domain/repositories/i_category_repository.dart';
import '../datasources/category_remote_datasource.dart';

class CategoryRepositoryImpl implements ICategoryRepository {
  final CategoryRemoteDataSource _dataSource;
  const CategoryRepositoryImpl(this._dataSource);

  @override
  Future<List<Category>> getCategories() => _dataSource.getCategories();
}