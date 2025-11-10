class CategoryStock {
  final int id;
  final String name;
  final int componentCount;
  final int itemQuantity;
  final double totalValue;

  CategoryStock({
    required this.id,
    required this.name,
    required this.componentCount,
    required this.itemQuantity,
    required this.totalValue,
  });

  factory CategoryStock.fromDatabaseMap(Map<String, dynamic> map) {
    return CategoryStock(
      id: map['id'] as int,
      name: map['category'] as String? ?? map['name'] as String,
      componentCount: map['component_count'] as int? ?? 0,
      itemQuantity: map['item_quantity'] as int? ?? 0,
      totalValue: (map['total_value'] as num?)?.toDouble() ?? 0.0,
    );
  }

  @override
  String toString() {
    return 'CategoryStock{id: $id, name: $name, componentCount: $componentCount, itemQuantity: $itemQuantity, totalValue: $totalValue}';
  }

  CategoryStock copyWith({
    int? id,
    String? name,
    int? componentCount,
    int? itemQuantity,
    double? totalValue,
  }) {
    return CategoryStock(
      id: id ?? this.id,
      name: name ?? this.name,
      componentCount: componentCount ?? this.componentCount,
      itemQuantity: itemQuantity ?? this.itemQuantity,
      totalValue: totalValue ?? this.totalValue,
    );
  }
}
