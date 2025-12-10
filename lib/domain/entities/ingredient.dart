class Ingredient {
  final String id;
  final String recipeId;
  final String name;
  final double quantity;
  final String unit;

  const Ingredient({
    required this.id,
    required this.recipeId,
    required this.name,
    required this.quantity,
    required this.unit,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Ingredient &&
        other.id == id &&
        other.recipeId == recipeId &&
        other.name == name &&
        other.quantity == quantity &&
        other.unit == unit;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        recipeId.hashCode ^
        name.hashCode ^
        quantity.hashCode ^
        unit.hashCode;
  }
}

