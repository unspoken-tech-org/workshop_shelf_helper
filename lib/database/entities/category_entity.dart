import '../../utils/text_normalizer.dart';

class CategoryEntity {
  int? id;
  String name;
  String nameNormalized;
  String? description;

  CategoryEntity({this.id, required this.name, this.description})
    : nameNormalized = normalizeText(name);

  Map<String, dynamic> toDatabaseMap() {
    return {'id': id, 'name': name, 'name_normalized': nameNormalized, 'description': description};
  }
}
