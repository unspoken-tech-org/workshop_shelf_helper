import '../database/entities/component_entity.dart';
import '../models/component.dart';

class ComponentMapper {
  static ComponentEntity toEntity(Component model) {
    return ComponentEntity(
      id: model.id,
      categoryId: model.categoryId,
      model: model.model,
      quantity: model.quantity,
      location: model.location,
      polarity: model.polarity,
      package: model.package,
      unitCost: model.unitCost,
      notes: model.notes,
    );
  }
}
