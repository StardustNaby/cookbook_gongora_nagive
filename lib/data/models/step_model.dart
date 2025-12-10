import '../../domain/entities/step.dart';

class StepModel extends Step {
  const StepModel({
    required super.id,
    required super.recipeId,
    required super.stepNumber,
    required super.description,
  });

  factory StepModel.fromJson(Map<String, dynamic> json) {
    // Manejar step_number que puede venir como int o String
    int stepNumber;
    if (json['step_number'] is int) {
      stepNumber = json['step_number'] as int;
    } else if (json['step_number'] is String) {
      stepNumber = int.tryParse(json['step_number'] as String) ?? 1;
    } else {
      stepNumber = (json['step_number'] as num?)?.toInt() ?? 1;
    }

    return StepModel(
      id: json['id'] as String,
      recipeId: json['recipe_id'] as String,
      stepNumber: stepNumber,
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

