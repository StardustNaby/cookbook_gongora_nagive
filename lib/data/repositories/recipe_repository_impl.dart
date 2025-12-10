import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/entities/recipe.dart';
import '../../domain/repositories/recipe_repository.dart';
import '../../core/config/supabase_config.dart';
import '../models/recipe_model.dart';
import '../models/ingredient_model.dart';
import '../models/step_model.dart';

class RecipeRepositoryImpl implements RecipeRepository {
  final _supabase = SupabaseConfig.client;
  
  /// Mapa de URLs antiguas de Google Share a nuevas URLs directas
  /// Se actualiza automáticamente cuando se detectan URLs de Google Share
  static const Map<String, String> _imageUrlMappings = {
    // Mapeo basado en nombres de recetas comunes
    'papas': 'https://www.johaprato.com/files/styles/flexslider_full/public/papas_fritas.jpg?itok=VaKy_ix9',
    'frita': 'https://www.johaprato.com/files/styles/flexslider_full/public/papas_fritas.jpg?itok=VaKy_ix9',
    'french': 'https://www.johaprato.com/files/styles/flexslider_full/public/papas_fritas.jpg?itok=VaKy_ix9',
    'pastel': 'https://i.pinimg.com/736x/97/32/fb/9732fbf43434915aa777468897715690.jpg',
    'fresa': 'https://i.pinimg.com/736x/97/32/fb/9732fbf43434915aa777468897715690.jpg',
    'strawberry': 'https://i.pinimg.com/736x/97/32/fb/9732fbf43434915aa777468897715690.jpg',
  };
  
  /// Actualiza automáticamente URLs de Google Share a URLs directas
  /// basándose en el nombre de la receta
  String? _updateImageUrlIfNeeded(String? imageUrl, String recipeName) {
    if (imageUrl == null || imageUrl.isEmpty) return imageUrl;
    
    // Si es una URL de Google Share, intentar mapearla
    if (imageUrl.contains('share.google')) {
      final nameLower = recipeName.toLowerCase();
      
      // Buscar coincidencias en el nombre de la receta
      for (final entry in _imageUrlMappings.entries) {
        if (nameLower.contains(entry.key)) {
          // Actualizar en la base de datos de forma asíncrona
          _updateImageUrlInDatabase(recipeName, entry.value);
          return entry.value;
        }
      }
      
      // Si no hay coincidencia, retornar null para mostrar placeholder
      return null;
    }
    
    return imageUrl;
  }
  
  /// Actualiza la URL de la imagen en la base de datos
  Future<void> _updateImageUrlInDatabase(String recipeName, String newUrl) async {
    try {
      // Buscar la receta por nombre y actualizar su URL
      await _supabase
          .from('recipes')
          .update({'image_url': newUrl})
          .ilike('name', '%$recipeName%');
    } catch (e) {
      // Silenciar errores de actualización para no interrumpir el flujo
      debugPrint('Error updating image URL for $recipeName: $e');
    }
  }

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
        
        // Actualizar URL de imagen si es necesario
        final recipeName = recipeJson['name'] as String;
        final currentImageUrl = recipeJson['image_url'] as String?;
        final updatedImageUrl = _updateImageUrlIfNeeded(currentImageUrl, recipeName);
        if (updatedImageUrl != currentImageUrl) {
          recipeJson['image_url'] = updatedImageUrl;
        }
        
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
      
      // Actualizar URL de imagen si es necesario
      final recipeName = recipeJson['name'] as String;
      final currentImageUrl = recipeJson['image_url'] as String?;
      final updatedImageUrl = _updateImageUrlIfNeeded(currentImageUrl, recipeName);
      if (updatedImageUrl != currentImageUrl) {
        recipeJson['image_url'] = updatedImageUrl;
      }
      
      return RecipeModel.fromJson(recipeJson);
    } catch (e) {
      throw Exception('Error fetching recipe: $e');
    }
  }

  @override
  Future<Recipe> createRecipe(Recipe recipe) async {
    try {
      // Verificar que el usuario esté autenticado
      final currentUser = _supabase.auth.currentUser;
      if (currentUser == null) {
        throw Exception('Usuario no autenticado. Por favor inicia sesión.');
      }
      
      final userId = currentUser.id;
      final recipeModel = RecipeModel.fromEntity(recipe);
      final recipeJson = recipeModel.toJson();
      
      // Preparar datos para insertar
      final recipeData = <String, dynamic>{};
      
      // Copiar solo los campos necesarios (sin id, ingredients, steps)
      recipeData['name'] = recipeJson['name'] as String;
      if (recipeJson['description'] != null) {
        recipeData['description'] = recipeJson['description'] as String;
      }
      if (recipeJson['image_url'] != null) {
        recipeData['image_url'] = recipeJson['image_url'] as String;
      }
      recipeData['prep_time_minutes'] = recipeJson['prep_time_minutes'] as int; // Asegurar que sea int
      recipeData['difficulty'] = recipeJson['difficulty'] as String;
      recipeData['is_favorite'] = recipeJson['is_favorite'] as bool;
      recipeData['user_id'] = userId; // OBLIGATORIO: ID del usuario
      // NO incluimos 'id' - Supabase lo generará automáticamente
      // NO incluimos 'created_at' ni 'updated_at' - Supabase los maneja
      
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
              return <String, dynamic>{
                'recipe_id': newRecipeId,
                'name': ingJson['name'] as String,
                'quantity': (ingJson['quantity'] as num).toDouble(), // Asegurar que sea double
                'unit': ingJson['unit'] as String,
                // NO incluimos 'id' - Supabase lo generará
              };
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
              return <String, dynamic>{
                'recipe_id': newRecipeId,
                'step_number': stepJson['step_number'] as int, // Asegurar que sea int
                'description': stepJson['description'] as String,
                // NO incluimos 'id' - Supabase lo generará
              };
            })
            .toList();
        
        await _supabase.from('steps').insert(stepsData);
      }
      
      return await getRecipeById(newRecipeId);
    } catch (e) {
      // Mejorar el mensaje de error para debugging
      final errorMessage = e.toString();
      if (errorMessage.contains('null value') || errorMessage.contains('violates')) {
        throw Exception('Error de validación: Verifica que todos los campos requeridos estén completos. Detalle: $errorMessage');
      } else if (errorMessage.contains('permission') || errorMessage.contains('RLS')) {
        throw Exception('Error de permisos: Verifica que estés autenticado correctamente. Detalle: $errorMessage');
      } else {
        throw Exception('Error creando receta: $errorMessage');
      }
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
      // Obtener la receta actual
      final recipe = await getRecipeById(id);
      final newFavoriteStatus = !recipe.isFavorite;
      
      // Actualizar en Supabase
      await _supabase
          .from('recipes')
          .update({'is_favorite': newFavoriteStatus})
          .eq('id', id);
      
      // Retornar la receta actualizada
      return await getRecipeById(id);
    } catch (e) {
      throw Exception('Error toggling favorite: $e');
    }
  }
}
