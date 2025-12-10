import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/recipe.dart';
import '../../domain/repositories/recipe_repository.dart';
import 'repository_providers.dart';

// Recipes List Provider
final recipesProvider = FutureProvider<List<Recipe>>((ref) async {
  final repository = ref.watch(recipeRepositoryProvider);
  return await repository.getRecipes();
});

// Recipe by ID Provider
final recipeByIdProvider = FutureProvider.family<Recipe, String>((ref, id) async {
  final repository = ref.watch(recipeRepositoryProvider);
  return await repository.getRecipeById(id);
});

// Recipe Notifier for CRUD operations
class RecipeNotifier extends StateNotifier<AsyncValue<List<Recipe>>> {
  RecipeNotifier(this._repository) : super(const AsyncValue.loading()) {
    _loadRecipes();
  }

  final RecipeRepository _repository;

  Future<void> _loadRecipes() async {
    state = const AsyncValue.loading();
    try {
      final recipes = await _repository.getRecipes();
      state = AsyncValue.data(recipes);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }

  Future<void> createRecipe(Recipe recipe) async {
    try {
      await _repository.createRecipe(recipe);
      await _loadRecipes();
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }

  Future<void> updateRecipe(Recipe recipe) async {
    try {
      await _repository.updateRecipe(recipe);
      await _loadRecipes();
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }

  Future<void> deleteRecipe(String id) async {
    try {
      await _repository.deleteRecipe(id);
      await _loadRecipes();
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }

  Future<void> toggleFavorite(String id) async {
    try {
      await _repository.toggleFavorite(id);
      await _loadRecipes();
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }

  Future<void> refresh() async {
    await _loadRecipes();
  }
}

final recipeNotifierProvider = StateNotifierProvider<RecipeNotifier, AsyncValue<List<Recipe>>>((ref) {
  final repository = ref.watch(recipeRepositoryProvider);
  return RecipeNotifier(repository);
});

// Favorite Recipes Provider
final favoriteRecipesProvider = Provider<AsyncValue<List<Recipe>>>((ref) {
  final recipesAsync = ref.watch(recipeNotifierProvider);
  
  return recipesAsync.when(
    data: (recipes) => AsyncValue.data(recipes.where((r) => r.isFavorite).toList()),
    loading: () => const AsyncValue.loading(),
    error: (error, stackTrace) => AsyncValue.error(error, stackTrace),
  );
});

