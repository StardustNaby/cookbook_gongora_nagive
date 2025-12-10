import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/recipe_providers.dart';
import '../widgets/loading_widget.dart';
import '../widgets/error_widget.dart';
import '../widgets/ingredient_item.dart';
import '../widgets/step_item.dart';
import 'add_edit_recipe_screen.dart';

class RecipeDetailScreen extends ConsumerWidget {
  final String recipeId;

  const RecipeDetailScreen({
    super.key,
    required this.recipeId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recipeAsync = ref.watch(recipeByIdProvider(recipeId));

    return Scaffold(
      body: recipeAsync.when(
        data: (recipe) {
          return CustomScrollView(
            slivers: [
              // Hero Image with rounded bottom
              SliverAppBar(
                expandedHeight: 350,
                pinned: true,
                flexibleSpace: FlexibleSpaceBar(
                  background: ClipRRect(
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(30),
                      bottomRight: Radius.circular(30),
                    ),
                    child: Hero(
                      tag: 'recipe-image-${recipe.id}',
                      child: CachedNetworkImage(
                        imageUrl: recipe.imageUrl ?? '',
                        fit: BoxFit.cover,
                        placeholder: (context, url) => Container(
                          color: const Color(0xFFFFE4E9),
                          child: const Center(
                            child: CircularProgressIndicator(
                              color: Color(0xFFFFB6C1),
                            ),
                          ),
                        ),
                        errorWidget: (context, url, error) => Container(
                          color: const Color(0xFFFFE4E9),
                          child: const Icon(
                            Icons.restaurant_menu,
                            size: 80,
                            color: Color(0xFFFFB6C1),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                actions: [
                  // Favorite button
                  IconButton(
                    icon: Icon(
                      recipe.isFavorite ? Icons.favorite : Icons.favorite_border,
                      color: recipe.isFavorite 
                          ? const Color(0xFFFF69B4) 
                          : Colors.white,
                    ),
                    onPressed: () {
                      ref.read(recipeNotifierProvider.notifier).toggleFavorite(recipe.id);
                    },
                    tooltip: 'Favorito',
                  ),
                  // Edit button
                  IconButton(
                    icon: const Icon(Icons.edit_outlined),
                    color: Colors.white,
                    onPressed: () {
                      context.push('/recipe/edit/${recipe.id}');
                    },
                    tooltip: 'Editar',
                  ),
                  // Delete button
                  IconButton(
                    icon: const Icon(Icons.delete_outline),
                    color: Colors.white,
                    onPressed: () {
                      _showDeleteDialog(context, ref, recipe.id, recipe.name);
                    },
                    tooltip: 'Eliminar',
                  ),
                ],
              ),
              // Content
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title with Playfair Display
                      Text(
                        recipe.name,
                        style: GoogleFonts.playfairDisplay(
                          fontSize: 36,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF5D4037),
                          height: 1.2,
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Difficulty and time row
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFF91A4),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: const Color(0xFFFFB6C1),
                                width: 1.5,
                              ),
                            ),
                            child: Text(
                              recipe.difficulty.displayName,
                              style: GoogleFonts.poppins(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Icon(
                            Icons.access_time_outlined,
                            size: 18,
                            color: const Color(0xFF8B7355),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            '${recipe.prepTimeMinutes} min',
                            style: GoogleFonts.poppins(
                              color: const Color(0xFF8B7355),
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      // Description
                      if (recipe.description != null) ...[
                        const SizedBox(height: 20),
                        Text(
                          recipe.description!,
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            color: const Color(0xFF5D4037),
                            height: 1.5,
                          ),
                        ),
                      ],
                      // Ingredients ExpansionTile
                      if (recipe.ingredients.isNotEmpty) ...[
                        const SizedBox(height: 32),
                        Theme(
                          data: Theme.of(context).copyWith(
                            dividerColor: Colors.transparent,
                            expansionTileTheme: ExpansionTileThemeData(
                              backgroundColor: const Color(0xFFFFF0F5),
                              collapsedBackgroundColor: Colors.transparent,
                              iconColor: const Color(0xFFFF91A4),
                              collapsedIconColor: const Color(0xFFFF91A4),
                              textColor: const Color(0xFF5D4037),
                              collapsedTextColor: const Color(0xFF5D4037),
                            ),
                          ),
                          child: ExpansionTile(
                            initiallyExpanded: true,
                            leading: const Icon(
                              Icons.shopping_basket_outlined,
                              color: Color(0xFFFF91A4),
                            ),
                            title: Text(
                              'Ingredientes',
                              style: GoogleFonts.playfairDisplay(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFFFF91A4),
                              ),
                            ),
                            children: [
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 8,
                                ),
                                child: Column(
                                  children: recipe.ingredients
                                      .map((ingredient) => IngredientItem(
                                            ingredient: ingredient,
                                          ))
                                      .toList(),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                      // Steps ExpansionTile
                      if (recipe.steps.isNotEmpty) ...[
                        const SizedBox(height: 16),
                        Theme(
                          data: Theme.of(context).copyWith(
                            dividerColor: Colors.transparent,
                            expansionTileTheme: ExpansionTileThemeData(
                              backgroundColor: const Color(0xFFFFF0F5),
                              collapsedBackgroundColor: Colors.transparent,
                              iconColor: const Color(0xFFFF91A4),
                              collapsedIconColor: const Color(0xFFFF91A4),
                              textColor: const Color(0xFF5D4037),
                              collapsedTextColor: const Color(0xFF5D4037),
                            ),
                          ),
                          child: ExpansionTile(
                            initiallyExpanded: true,
                            leading: const Icon(
                              Icons.list_alt_outlined,
                              color: Color(0xFFFF91A4),
                            ),
                            title: Text(
                              'Pasos',
                              style: GoogleFonts.playfairDisplay(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFFFF91A4),
                              ),
                            ),
                            children: [
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 8,
                                ),
                                child: Column(
                                  children: recipe.steps
                                      .map((step) => StepItem(step: step))
                                      .toList(),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
        loading: () => const Scaffold(
          body: Center(
            child: CircularProgressIndicator(
              color: Color(0xFFFFB6C1),
            ),
          ),
        ),
        error: (error, stackTrace) => Scaffold(
          appBar: AppBar(),
          body: ErrorDisplayWidget(
            message: error.toString(),
            onRetry: () {
              ref.refresh(recipeByIdProvider(recipeId));
            },
          ),
        ),
      ),
    );
  }

  void _showDeleteDialog(
    BuildContext context,
    WidgetRef ref,
    String recipeId,
    String recipeName,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Text(
          'Eliminar Receta',
          style: GoogleFonts.playfairDisplay(
            fontWeight: FontWeight.bold,
            color: const Color(0xFF5D4037),
          ),
        ),
        content: Text(
          '¿Estás segura de que quieres eliminar "$recipeName"?',
          style: GoogleFonts.poppins(
            color: const Color(0xFF5D4037),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'Cancelar',
              style: GoogleFonts.poppins(
                color: const Color(0xFF8B7355),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.of(context).pop();
              try {
                await ref
                    .read(recipeNotifierProvider.notifier)
                    .deleteRecipe(recipeId);
                if (context.mounted) {
                  context.go('/home');
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text('Receta eliminada exitosamente'),
                      backgroundColor: const Color(0xFFFFB6C1),
                    ),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error al eliminar: $e'),
                      backgroundColor: Colors.red.shade300,
                    ),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade300,
              foregroundColor: Colors.white,
            ),
            child: Text(
              'Eliminar',
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
