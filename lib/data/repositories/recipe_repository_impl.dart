import '../../domain/entities/recipe.dart';
import '../../domain/repositories/recipe_repository.dart';
import '../../core/config/supabase_config.dart';
import '../models/recipe_model.dart';
import '../models/ingredient_model.dart';
import '../models/step_model.dart';

class RecipeRepositoryImpl implements RecipeRepository {
  final _supabase = SupabaseConfig.client;

  @override
  Future<List<Recipe>> getRecipes() async {
    try {
      final response = await _supabase
          .from('recipes')
          .select()
          .order('created_at', ascending: false);

      final recipes = <Recipe>[];
      
      for (final recipeData in response) {
        final recipeId = recipeData['id'] as String;
        
        // Fetch ingredients and steps for this recipe
        final ingredientsResponse = await _supabase
            .from('ingredients')
            .select()
            .eq('recipe_id', recipeId)
            .order('name');
        
        final stepsResponse = await _supabase
            .from('steps')
            .select()
            .eq('recipe_id', recipeId)
            .order('step_number');
        
        final recipeJson = Map<String, dynamic>.from(recipeData);
        recipeJson['ingredients'] = ingredientsResponse;
        recipeJson['steps'] = stepsResponse;
        
        recipes.add(RecipeModel.fromJson(recipeJson));
      }
      
      return recipes;
    } catch (e) {
      throw Exception('Error fetching recipes: $e');
    }
  }

  @override
  Future<Recipe> getRecipeById(String id) async {
    try {
      final response = await _supabase
          .from('recipes')
          .select()
          .eq('id', id)
          .single();

      // Fetch ingredients and steps
      final ingredientsResponse = await _supabase
          .from('ingredients')
          .select()
          .eq('recipe_id', id)
          .order('name');
      
      final stepsResponse = await _supabase
          .from('steps')
          .select()
          .eq('recipe_id', id)
          .order('step_number');
      
      final recipeJson = Map<String, dynamic>.from(response);
      recipeJson['ingredients'] = ingredientsResponse;
      recipeJson['steps'] = stepsResponse;
      
      return RecipeModel.fromJson(recipeJson);
    } catch (e) {
      throw Exception('Error fetching recipe: $e');
    }
  }

  @override
  Future<Recipe> createRecipe(Recipe recipe) async {
    try {
      final recipeModel = RecipeModel.fromEntity(recipe);
      final recipeJson = recipeModel.toJson();
      
      // Remove nested data for recipe insert
      final recipeData = Map<String, dynamic>.from(recipeJson);
      recipeData.remove('ingredients');
      recipeData.remove('steps');
      
      // Insert recipe
      final response = await _supabase
          .from('recipes')
          .insert(recipeData)
          .select()
          .single();
      
      final recipeId = response['id'] as String;
      
      // Insert ingredients
      if (recipe.ingredients.isNotEmpty) {
        final ingredientsData = recipe.ingredients
            .map((ingredient) {
              final ingModel = IngredientModel.fromEntity(ingredient);
              final ingJson = ingModel.toJson();
              ingJson['recipe_id'] = recipeId;
              return ingJson;
            })
            .toList();
        
        await _supabase.from('ingredients').insert(ingredientsData);
      }
      
      // Insert steps
      if (recipe.steps.isNotEmpty) {
        final stepsData = recipe.steps
            .map((step) {
              final stepModel = StepModel.fromEntity(step);
              final stepJson = stepModel.toJson();
              stepJson['recipe_id'] = recipeId;
              return stepJson;
            })
            .toList();
        
        await _supabase.from('steps').insert(stepsData);
      }
      
      // Fetch complete recipe with relations
      return await getRecipeById(recipeId);
    } catch (e) {
      throw Exception('Error creating recipe: $e');
    }
  }

  @override
  Future<Recipe> updateRecipe(Recipe recipe) async {
    try {
      final recipeModel = RecipeModel.fromEntity(recipe);
      final recipeJson = recipeModel.toJson();
      
      // Remove nested data for recipe update
      final recipeData = Map<String, dynamic>.from(recipeJson);
      recipeData.remove('ingredients');
      recipeData.remove('steps');
      recipeData['updated_at'] = DateTime.now().toIso8601String();
      
      // Update recipe
      await _supabase
          .from('recipes')
          .update(recipeData)
          .eq('id', recipe.id);
      
      // Delete existing ingredients and steps
      await _supabase.from('ingredients').delete().eq('recipe_id', recipe.id);
      await _supabase.from('steps').delete().eq('recipe_id', recipe.id);
      
      // Insert updated ingredients
      if (recipe.ingredients.isNotEmpty) {
        final ingredientsData = recipe.ingredients
            .map((ingredient) {
              final ingModel = IngredientModel.fromEntity(ingredient);
              final ingJson = ingModel.toJson();
              ingJson['recipe_id'] = recipe.id;
              return ingJson;
            })
            .toList();
        
        await _supabase.from('ingredients').insert(ingredientsData);
      }
      
      // Insert updated steps
      if (recipe.steps.isNotEmpty) {
        final stepsData = recipe.steps
            .map((step) {
              final stepModel = StepModel.fromEntity(step);
              final stepJson = stepModel.toJson();
              stepJson['recipe_id'] = recipe.id;
              return stepJson;
            })
            .toList();
        
        await _supabase.from('steps').insert(stepsData);
      }
      
      // Fetch updated recipe with relations
      return await getRecipeById(recipe.id);
    } catch (e) {
      throw Exception('Error updating recipe: $e');
    }
  }

  @override
  Future<void> deleteRecipe(String id) async {
    try {
      // Delete related ingredients and steps first
      await _supabase.from('ingredients').delete().eq('recipe_id', id);
      await _supabase.from('steps').delete().eq('recipe_id', id);
      
      // Delete recipe
      await _supabase.from('recipes').delete().eq('id', id);
    } catch (e) {
      throw Exception('Error deleting recipe: $e');
    }
  }

  @override
  Future<Recipe> toggleFavorite(String id) async {
    try {
      // Get current recipe
      final recipe = await getRecipeById(id);
      
      // Toggle favorite status
      await _supabase
          .from('recipes')
          .update({'is_favorite': !recipe.isFavorite})
          .eq('id', id);
      
      // Return updated recipe
      return await getRecipeById(id);
    } catch (e) {
      throw Exception('Error toggling favorite: $e');
    }
  }
}

