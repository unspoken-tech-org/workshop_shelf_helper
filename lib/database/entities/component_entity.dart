import '../../utils/text_normalizer.dart';

class ComponentEntity {
  int? id;
  int categoryId;
  String model;
  String modelNormalized;
  int quantity;
  String location;
  String locationNormalized;
  String? polarity;
  String? package;
  double unitCost;
  String? notes;

  ComponentEntity({
    this.id,
    required this.categoryId,
    required this.model,
    required this.quantity,
    required this.location,
    this.polarity,
    this.package,
    required this.unitCost,
    this.notes,
  }) : modelNormalized = normalizeText(model),
       locationNormalized = normalizeText(location);

  Map<String, dynamic> toDatabaseMap() {
    return {
      'id': id,
      'category_id': categoryId,
      'model': model,
      'model_normalized': modelNormalized,
      'quantity': quantity,
      'location': location,
      'location_normalized': locationNormalized,
      'polarity': polarity,
      'package': package,
      'unit_cost': unitCost,
      'notes': notes,
    };
  }
}
