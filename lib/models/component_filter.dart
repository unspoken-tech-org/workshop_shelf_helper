class ComponentFilter {
  String? searchTerm;
  int? categoryId;
  double? minCost;
  double? maxCost;
  String? orderBy;

  ComponentFilter({
    this.searchTerm,
    this.categoryId,
    this.minCost,
    this.maxCost,
    this.orderBy = 'model ASC',
  });

  ComponentFilter copyWith({
    String? searchTerm,
    int? categoryId,
    double? minCost,
    double? maxCost,
    String? orderBy,
  }) {
    return ComponentFilter(
      searchTerm: searchTerm ?? this.searchTerm,
      categoryId: categoryId ?? this.categoryId,
      minCost: minCost ?? this.minCost,
      maxCost: maxCost ?? this.maxCost,
      orderBy: orderBy ?? this.orderBy,
    );
  }

  void clear() {
    searchTerm = null;
    categoryId = null;
    minCost = null;
    maxCost = null;
    orderBy = 'model ASC';
  }
}
