import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/recipe_providers.dart';
import '../widgets/recipe_card.dart';
import '../widgets/loading_widget.dart';
import '../widgets/error_widget.dart';
import 'recipe_detail_screen.dart';
import 'add_edit_recipe_screen.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recipesAsync = ref.watch(recipeNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Recetas de Cocina'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              ref.read(recipeNotifierProvider.notifier).refresh();
            },
          ),
        ],
      ),
      body: recipesAsync.when(
        data: (recipes) {
          if (recipes.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.restaurant_menu,
                    size: 64,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No hay recetas disponibles',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Agrega tu primera receta',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey[600],
                        ),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              await ref.read(recipeNotifierProvider.notifier).refresh();
            },
            child: ListView.builder(
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
        loading: () => const LoadingWidget(),
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

