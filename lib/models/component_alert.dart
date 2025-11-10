class ComponentAlert {
  final int id;
  final String model;
  final int quantity;
  final String location;
  final String categoryName;
  final int categoryId;

  ComponentAlert({
    required this.id,
    required this.model,
    required this.quantity,
    required this.location,
    required this.categoryName,
    required this.categoryId,
  });

  factory ComponentAlert.fromDatabaseMap(Map<String, dynamic> map) {
    return ComponentAlert(
      id: map['id'] as int,
      model: map['model'] as String,
      quantity: map['quantity'] as int,
      location: map['location'] as String,
      categoryName: map['category_name'] as String,
      categoryId: map['category_id'] as int,
    );
  }

  @override
  String toString() {
    return 'ComponentAlert{id: $id, model: $model, quantity: $quantity, location: $location, categoryName: $categoryName, categoryId: $categoryId}';
  }

  ComponentAlert copyWith({
    int? id,
    String? model,
    int? quantity,
    String? location,
    String? categoryName,
    int? categoryId,
  }) {
    return ComponentAlert(
      id: id ?? this.id,
      model: model ?? this.model,
      quantity: quantity ?? this.quantity,
      location: location ?? this.location,
      categoryName: categoryName ?? this.categoryName,
      categoryId: categoryId ?? this.categoryId,
    );
  }
}
