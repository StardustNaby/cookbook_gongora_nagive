import 'package:supabase_flutter/supabase_flutter.dart';
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
        
        // Fetch ingredients
        final ingredientsResponse = await _supabase
            .from('ingredients')
            .select()
            .eq('recipe_id', recipeId)
            .order('name');
        
        // Fetch steps
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
      final userId = _supabase.auth.currentUser!.id; // 1. OBTENEMOS EL ID DEL USUARIO
      final recipeModel = RecipeModel.fromEntity(recipe);
      final recipeJson = recipeModel.toJson();
      
      // Preparar datos para insertar
      final recipeData = Map<String, dynamic>.from(recipeJson);
      recipeData.remove('ingredients');
      recipeData.remove('steps');
      recipeData.remove('id'); // 2. BORRAMOS EL ID TEMPORAL (Supabase generará uno válido)
      recipeData['user_id'] = userId; // 3. AGREGAMOS EL ID DEL USUARIO
      
      // Insertar receta
      final response = await _supabase
          .from('recipes')
          .insert(recipeData)
          .select()
          .single();
      
      final newRecipeId = response['id'] as String;
      
      // Insertar ingredientes
      if (recipe.ingredients.isNotEmpty) {
        final ingredientsData = recipe.ingredients
            .map((ingredient) {
              final ingModel = IngredientModel.fromEntity(ingredient);
              final ingJson = ingModel.toJson();
              ingJson['recipe_id'] = newRecipeId;
              ingJson.remove('id'); // Importante: Borrar ID temporal
              return ingJson;
            })
            .toList();
        
        await _supabase.from('ingredients').insert(ingredientsData);
      }
      
      // Insertar pasos
      if (recipe.steps.isNotEmpty) {
        final stepsData = recipe.steps
            .map((step) {
              final stepModel = StepModel.fromEntity(step);
              final stepJson = stepModel.toJson();
              stepJson['recipe_id'] = newRecipeId;
              stepJson.remove('id'); // Importante: Borrar ID temporal
              return stepJson;
            })
            .toList();
        
        await _supabase.from('steps').insert(stepsData);
      }
      
      return await getRecipeById(newRecipeId);
    } catch (e) {
      throw Exception('Error creating recipe: $e');
    }
  }

  @override
  Future<Recipe> updateRecipe(Recipe recipe) async {
    try {
      final recipeModel = RecipeModel.fromEntity(recipe);
      final recipeJson = recipeModel.toJson();
      
      final recipeData = Map<String, dynamic>.from(recipeJson);
      recipeData.remove('ingredients');
      recipeData.remove('steps');
      recipeData['updated_at'] = DateTime.now().toIso8601String();
      // En update no quitamos el ID porque ya es un UUID válido existente
      
      await _supabase
          .from('recipes')
          .update(recipeData)
          .eq('id', recipe.id);
      
      // Borrar antiguos y re-crear (Estrategia simple y segura)
      await _supabase.from('ingredients').delete().eq('recipe_id', recipe.id);
      await _supabase.from('steps').delete().eq('recipe_id', recipe.id);
      
      if (recipe.ingredients.isNotEmpty) {
        final ingredientsData = recipe.ingredients
            .map((ingredient) {
              final ingModel = IngredientModel.fromEntity(ingredient);
              final ingJson = ingModel.toJson();
              ingJson['recipe_id'] = recipe.id;
              ingJson.remove('id'); // Siempre dejamos que DB genere nuevos IDs al reinsertar
              return ingJson;
            })
            .toList();
        await _supabase.from('ingredients').insert(ingredientsData);
      }
      
      if (recipe.steps.isNotEmpty) {
        final stepsData = recipe.steps
            .map((step) {
              final stepModel = StepModel.fromEntity(step);
              final stepJson = stepModel.toJson();
              stepJson['recipe_id'] = recipe.id;
              stepJson.remove('id'); 
              return stepJson;
            })
            .toList();
        await _supabase.from('steps').insert(stepsData);
      }
      
      return await getRecipeById(recipe.id);
    } catch (e) {
      throw Exception('Error updating recipe: $e');
    }
  }

  @override
  Future<void> deleteRecipe(String id) async {
    try {
      // Gracias al ON DELETE CASCADE de Supabase, solo necesitamos borrar la receta
      // y los ingredientes/pasos se borran solos.
      await _supabase.from('recipes').delete().eq('id', id);
    } catch (e) {
      throw Exception('Error deleting recipe: $e');
    }
  }

  @override
  Future<Recipe> toggleFavorite(String id) async {
    try {
      final recipe = await getRecipeById(id);
      await _supabase
          .from('recipes')
          .update({'is_favorite': !recipe.isFavorite})
          .eq('id', id);
      return await getRecipeById(id);
    } catch (e) {
      throw Exception('Error toggling favorite: $e');
    }
  }
}
