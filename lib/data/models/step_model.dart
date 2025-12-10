import '../../domain/entities/step.dart';

class StepModel extends Step {
  const StepModel({
    required super.id,
    required super.recipeId,
    required super.stepNumber,
    required super.description,
  });

  factory StepModel.fromJson(Map<String, dynamic> json) {
    return StepModel(
      id: json['id'] as String,
      recipeId: json['recipe_id'] as String,
      stepNumber: json['step_number'] as int,
      description: json['description'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'recipe_id': recipeId,
      'step_number': stepNumber,
      'description': description,
    };
  }

  factory StepModel.fromEntity(Step step) {
    return StepModel(
      id: step.id,
      recipeId: step.recipeId,
      stepNumber: step.stepNumber,
      description: step.description,
    );
  }
}

