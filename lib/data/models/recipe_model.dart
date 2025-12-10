import '../../domain/entities/recipe.dart';
import '../../domain/entities/step.dart';
import 'ingredient_model.dart';
import 'step_model.dart';

class RecipeModel extends Recipe {
  const RecipeModel({
    required super.id,
    required super.name,
    super.description,
    super.imageUrl,
    required super.prepTimeMinutes,
    required super.difficulty,
    required super.isFavorite,
    required super.createdAt,
    super.updatedAt,
    super.ingredients,
    super.steps,
  });

  factory RecipeModel.fromJson(Map<String, dynamic> json) {
    return RecipeModel(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      imageUrl: json['image_url'] as String?,
      prepTimeMinutes: json['prep_time_minutes'] as int,
      difficulty: Difficulty.fromString(json['difficulty'] as String),
      isFavorite: json['is_favorite'] as bool? ?? false,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
      ingredients: json['ingredients'] != null
          ? (json['ingredients'] as List)
              .map((ingredient) => IngredientModel.fromJson(ingredient as Map<String, dynamic>))
              .toList()
          : [],
      steps: json['steps'] != null
          ? (json['steps'] as List)
              .map((step) => StepModel.fromJson(step as Map<String, dynamic>))
              .toList()
          : [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'image_url': imageUrl,
      'prep_time_minutes': prepTimeMinutes,
      'difficulty': difficulty.name,
      'is_favorite': isFavorite,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'ingredients': ingredients
          .map((ingredient) => IngredientModel.fromEntity(ingredient).toJson())
          .toList(),
      'steps': steps
          .map((step) => StepModel.fromEntity(step).toJson())
          .toList(),
    };
  }

  factory RecipeModel.fromEntity(Recipe recipe) {
    return RecipeModel(
      id: recipe.id,
      name: recipe.name,
      description: recipe.description,
      imageUrl: recipe.imageUrl,
      prepTimeMinutes: recipe.prepTimeMinutes,
      difficulty: recipe.difficulty,
      isFavorite: recipe.isFavorite,
      createdAt: recipe.createdAt,
      updatedAt: recipe.updatedAt,
      ingredients: recipe.ingredients,
      steps: recipe.steps,
    );
  }
}

