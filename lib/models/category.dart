class Category {
  int? id;
  String name;
  String? description;

  Category({this.id, required this.name, this.description});

  factory Category.fromMap(Map<String, dynamic> map) {
    return Category(
      id: map['id'] as int?,
      name: map['name'] as String,
      description: map['description'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {'id': id, 'name': name, 'description': description};
  }

  @override
  String toString() {
    return 'Category{id: $id, name: $name, description: $description}';
  }

  Category copyWith({int? id, String? name, String? description}) {
    return Category(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
    );
  }
}
