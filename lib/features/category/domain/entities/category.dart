class Category {
  final int id;
  final String name;
  final String iconName;
  final String colorHex;

  const Category({
    required this.id,
    required this.name,
    required this.iconName,
    required this.colorHex,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is Category && other.id == id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'Category(id: $id, name: $name)';
}