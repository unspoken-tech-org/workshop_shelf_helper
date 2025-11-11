import '../database/entities/category_entity.dart';
import '../models/category.dart';

class CategoryMapper {
  static CategoryEntity toEntity(Category model) {
    return CategoryEntity(id: model.id, name: model.name, description: model.description);
  }
}
