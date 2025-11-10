class Statistics {
  final int totalCategories;
  final int totalComponents;
  final double totalValue;
  final int totalStockItems;

  Statistics({
    required this.totalCategories,
    required this.totalComponents,
    required this.totalValue,
    required this.totalStockItems,
  });

  factory Statistics.fromDatabaseMap(Map<String, dynamic> map) {
    return Statistics(
      totalCategories: map['totalCategories'] as int? ?? 0,
      totalComponents: map['totalComponents'] as int? ?? 0,
      totalValue: (map['totalValue'] as num?)?.toDouble() ?? 0.0,
      totalStockItems: map['totalStockItems'] as int? ?? 0,
    );
  }

  @override
  String toString() {
    return 'Statistics{totalCategories: $totalCategories, totalComponents: $totalComponents, totalValue: $totalValue, totalStockItems: $totalStockItems}';
  }

  Statistics copyWith({
    int? totalCategories,
    int? totalComponents,
    double? totalValue,
    int? totalStockItems,
  }) {
    return Statistics(
      totalCategories: totalCategories ?? this.totalCategories,
      totalComponents: totalComponents ?? this.totalComponents,
      totalValue: totalValue ?? this.totalValue,
      totalStockItems: totalStockItems ?? this.totalStockItems,
    );
  }
}
