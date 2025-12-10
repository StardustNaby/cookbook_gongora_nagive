import 'ingredient.dart';
import 'step.dart';

enum Difficulty {
  easy,
  medium,
  hard;

  static Difficulty fromString(String value) {
    return Difficulty.values.firstWhere(
      (e) => e.name == value.toLowerCase(),
      orElse: () => Difficulty.medium,
    );
  }

  String get displayName {
    switch (this) {
      case Difficulty.easy:
        return 'Fácil';
      case Difficulty.medium:
        return 'Medio';
      case Difficulty.hard:
        return 'Difícil';
    }
  }
}

class Recipe {
  final String id;
  final String name;
  final String? description;
  final String? imageUrl;
  final int prepTimeMinutes;
  final Difficulty difficulty;
  final bool isFavorite;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final List<Ingredient> ingredients;
  final List<Step> steps;

  const Recipe({
    required this.id,
    required this.name,
    this.description,
    this.imageUrl,
    required this.prepTimeMinutes,
    required this.difficulty,
    required this.isFavorite,
    required this.createdAt,
    this.updatedAt,
    this.ingredients = const [],
    this.steps = const [],
  });

  Recipe copyWith({
    String? id,
    String? name,
    String? description,
    String? imageUrl,
    int? prepTimeMinutes,
    Difficulty? difficulty,
    bool? isFavorite,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<Ingredient>? ingredients,
    List<Step>? steps,
  }) {
    return Recipe(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      imageUrl: imageUrl ?? this.imageUrl,
      prepTimeMinutes: prepTimeMinutes ?? this.prepTimeMinutes,
      difficulty: difficulty ?? this.difficulty,
      isFavorite: isFavorite ?? this.isFavorite,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      ingredients: ingredients ?? this.ingredients,
      steps: steps ?? this.steps,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Recipe &&
        other.id == id &&
        other.name == name &&
        other.description == description &&
        other.imageUrl == imageUrl &&
        other.prepTimeMinutes == prepTimeMinutes &&
        other.difficulty == difficulty &&
        other.isFavorite == isFavorite &&
        other.createdAt == createdAt &&
        other.updatedAt == updatedAt;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        name.hashCode ^
        description.hashCode ^
        imageUrl.hashCode ^
        prepTimeMinutes.hashCode ^
        difficulty.hashCode ^
        isFavorite.hashCode ^
        createdAt.hashCode ^
        updatedAt.hashCode;
  }
}

