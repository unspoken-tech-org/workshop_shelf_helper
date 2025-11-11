class Component {
  int? id;
  int categoryId;
  String categoryName;
  String model;
  int quantity;
  String location;
  String? polarity;
  String? package;
  double unitCost;
  String? notes;

  Component({
    this.id,
    required this.categoryId,
    required this.categoryName,
    required this.model,
    required this.quantity,
    required this.location,
    this.polarity,
    this.package,
    required this.unitCost,
    this.notes,
  });

  double get totalValue => quantity * unitCost;

  factory Component.fromDatabaseMap(Map<String, dynamic> map) {
    return Component(
      id: map['id'] as int?,
      categoryId: map['category_id'] as int,
      categoryName: map['category_name'] as String,
      model: map['model'] as String,
      quantity: map['quantity'] as int,
      location: map['location'] as String,
      polarity: map['polarity'] as String?,
      package: map['package'] as String?,
      unitCost: (map['unit_cost'] as num).toDouble(),
      notes: map['notes'] as String?,
    );
  }

  @override
  String toString() {
    return 'Component{id: $id, categoryName: $categoryName, model: $model, quantity: $quantity, location: $location}';
  }

  Component copyWith({
    int? id,
    int? categoryId,
    String? categoryName,
    String? model,
    int? quantity,
    String? location,
    String? polarity,
    String? package,
    double? unitCost,
    String? notes,
  }) {
    return Component(
      id: id ?? this.id,
      categoryId: categoryId ?? this.categoryId,
      categoryName: categoryName ?? this.categoryName,
      model: model ?? this.model,
      quantity: quantity ?? this.quantity,
      location: location ?? this.location,
      polarity: polarity ?? this.polarity,
      package: package ?? this.package,
      unitCost: unitCost ?? this.unitCost,
      notes: notes ?? this.notes,
    );
  }
}
