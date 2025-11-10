import '../../models/component.dart';

abstract class IComponentRepository {
  Future<int> create(Component component);

  Future<List<Component>> getAll();

  Future<Component?> getById(int id);

  Future<List<Component>> getByCategory(int categoryId);

  Future<int> update(Component component);

  Future<int> delete(int id);

  Future<List<Component>> search({
    String? searchTerm,
    int? categoryId,
    double? minCost,
    double? maxCost,
    String? orderBy,
  });

  Future<List<Component>> getLowStock(int threshold);
}
