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
class RecipeNotifier extends Notifier<AsyncValue<List<Recipe>>> {
  @override
  AsyncValue<List<Recipe>> build() {
    _loadRecipes();
    return const AsyncValue.loading();
  }

  Future<void> _loadRecipes() async {
    state = const AsyncValue.loading();
    try {
      final repository = ref.read(recipeRepositoryProvider);
      final recipes = await repository.getRecipes();
      state = AsyncValue.data(recipes);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }

  Future<void> createRecipe(Recipe recipe) async {
    try {
      final repository = ref.read(recipeRepositoryProvider);
      await repository.createRecipe(recipe);
      await _loadRecipes();
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }

  Future<void> updateRecipe(Recipe recipe) async {
    try {
      final repository = ref.read(recipeRepositoryProvider);
      await repository.updateRecipe(recipe);
      await _loadRecipes();
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }

  Future<void> deleteRecipe(String id) async {
    try {
      final repository = ref.read(recipeRepositoryProvider);
      await repository.deleteRecipe(id);
      await _loadRecipes();
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }

  Future<void> toggleFavorite(String id) async {
    try {
      final repository = ref.read(recipeRepositoryProvider);
      final updatedRecipe = await repository.toggleFavorite(id);
      
      // Actualizar el estado local inmediatamente para feedback visual
      state.whenData((recipes) {
        final updatedRecipes = recipes.map((recipe) {
          return recipe.id == id ? updatedRecipe : recipe;
        }).toList();
        state = AsyncValue.data(updatedRecipes);
      });
      
      // Recargar desde el servidor para asegurar sincronización
      await _loadRecipes();
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }

  Future<void> refresh() async {
    await _loadRecipes();
  }
}

final recipeNotifierProvider = NotifierProvider<RecipeNotifier, AsyncValue<List<Recipe>>>(() {
  return RecipeNotifier();
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
