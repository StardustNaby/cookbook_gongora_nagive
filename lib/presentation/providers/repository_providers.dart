import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/repositories/recipe_repository.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../data/repositories/recipe_repository_impl.dart';
import '../../data/repositories/auth_repository_impl.dart';

// Recipe Repository Provider
final recipeRepositoryProvider = Provider<RecipeRepository>((ref) {
  return RecipeRepositoryImpl();
});

// Auth Repository Provider
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepositoryImpl();
});

