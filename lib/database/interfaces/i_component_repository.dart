import 'package:workshop_shelf_helper/models/component_filter.dart';

import '../../models/component.dart';

abstract class IComponentRepository {
  Future<int> create(Component component);

  Future<List<Component>> getAll();

  Future<Component?> getById(int id);

  Future<int> update(Component component);

  Future<int> delete(int id);

  Future<List<Component>> search(ComponentFilter filter);

  Future<List<Component>> getLowStock(int threshold);
}
