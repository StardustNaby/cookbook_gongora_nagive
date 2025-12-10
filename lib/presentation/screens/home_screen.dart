import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/recipe_providers.dart';
import '../widgets/recipe_card.dart';
import '../widgets/loading_widget.dart';
import '../widgets/error_widget.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recipesAsync = ref.watch(recipeNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Mi Álbum de Recetas',
          style: GoogleFonts.playfairDisplay(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              ref.read(recipeNotifierProvider.notifier).refresh();
            },
            tooltip: 'Actualizar',
          ),
        ],
      ),
      body: recipesAsync.when(
        data: (recipes) {
          if (recipes.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(32.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.menu_book_outlined,
                      size: 100,
                      color: Theme.of(context).colorScheme.secondary.withOpacity(0.4),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'No hay recetitas aún',
                      style: GoogleFonts.playfairDisplay(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF8B7355),
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Comienza a crear tu colección\nde recetas favoritas',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        color: const Color(0xFF8B7355),
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              await ref.read(recipeNotifierProvider.notifier).refresh();
            },
            color: Theme.of(context).colorScheme.secondary,
            child: GridView.builder(
              padding: const EdgeInsets.all(12),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.75,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              itemCount: recipes.length,
              itemBuilder: (context, index) {
                final recipe = recipes[index];
                return RecipeCard(
                  recipe: recipe,
                  onTap: () {
                    context.push('/recipe/${recipe.id}');
                  },
                  onFavoriteTap: () {
                    ref.read(recipeNotifierProvider.notifier).toggleFavorite(recipe.id);
                  },
                );
              },
            ),
          );
        },
        loading: () => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(
                color: Color(0xFFFFB6C1),
                strokeWidth: 3,
              ),
              const SizedBox(height: 16),
              Text(
                'Cargando recetitas...',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  color: const Color(0xFF8B7355),
                ),
              ),
            ],
          ),
        ),
        error: (error, stackTrace) => ErrorDisplayWidget(
          message: error.toString(),
          onRetry: () {
            ref.read(recipeNotifierProvider.notifier).refresh();
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          context.push('/recipe/add');
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
