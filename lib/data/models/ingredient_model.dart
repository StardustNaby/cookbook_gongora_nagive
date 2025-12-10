import '../../domain/entities/ingredient.dart';

class IngredientModel extends Ingredient {
  const IngredientModel({
    required super.id,
    required super.recipeId,
    required super.name,
    required super.quantity,
    required super.unit,
  });

  factory IngredientModel.fromJson(Map<String, dynamic> json) {
    // Manejar quantity que puede venir como num, int, double o String
    double quantity;
    if (json['quantity'] is num) {
      quantity = (json['quantity'] as num).toDouble();
    } else if (json['quantity'] is String) {
      quantity = double.tryParse(json['quantity'] as String) ?? 0.0;
    } else {
      quantity = 0.0;
    }

    return IngredientModel(
      id: json['id'] as String,
      recipeId: json['recipe_id'] as String,
      name: json['name'] as String,
      quantity: quantity,
      unit: json['unit'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'recipe_id': recipeId,
      'name': name,
      'quantity': quantity,
      'unit': unit,
    };
  }

  factory IngredientModel.fromEntity(Ingredient ingredient) {
    return IngredientModel(
      id: ingredient.id,
      recipeId: ingredient.recipeId,
      name: ingredient.name,
      quantity: ingredient.quantity,
      unit: ingredient.unit,
    );
  }
}

