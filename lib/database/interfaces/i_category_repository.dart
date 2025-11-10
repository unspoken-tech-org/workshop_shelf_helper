import '../../models/category.dart';

abstract class ICategoryRepository {
  Future<int> create(Category category);

  Future<List<Category>> getAll();

  Future<Category?> getById(int id);

  Future<int> update(Category category);

  Future<int> delete(int id);
}
