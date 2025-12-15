class Step {
  final String id;
  final String recipeId;
  final int stepNumber;
  final String description;

  const Step({
    required this.id,
    required this.recipeId,
    required this.stepNumber,
    required this.description,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Step &&
        other.id == id &&
        other.recipeId == recipeId &&
        other.stepNumber == stepNumber &&
        other.description == description;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        recipeId.hashCode ^
        stepNumber.hashCode ^
        description.hashCode;
  }
}




