import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:go_router/go_router.dart';
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
              // App Bar with image
              SliverAppBar(
                expandedHeight: 300,
                pinned: true,
                flexibleSpace: FlexibleSpaceBar(
                  background: CachedNetworkImage(
                    imageUrl: recipe.imageUrl ?? '',
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(
                      color: Colors.grey[300],
                      child: const Center(
                        child: CircularProgressIndicator(),
                      ),
                    ),
                    errorWidget: (context, url, error) => Container(
                      color: Colors.grey[300],
                      child: const Icon(
                        Icons.restaurant,
                        size: 64,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                ),
                actions: [
                  IconButton(
                    icon: Icon(
                      recipe.isFavorite ? Icons.favorite : Icons.favorite_border,
                      color: recipe.isFavorite ? Colors.red : Colors.white,
                    ),
                    onPressed: () {
                      ref.read(recipeNotifierProvider.notifier).toggleFavorite(recipe.id);
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.edit),
                    onPressed: () {
                      context.push('/recipe/edit/${recipe.id}');
                    },
                  ),
                ],
              ),
              // Content
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title and difficulty
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              recipe.name,
                              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.primaryContainer,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Text(
                              recipe.difficulty.displayName,
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.onPrimaryContainer,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      // Prep time
                      Row(
                        children: [
                          const Icon(Icons.timer, size: 20),
                          const SizedBox(width: 8),
                          Text(
                            '${recipe.prepTimeMinutes} minutos',
                            style: Theme.of(context).textTheme.bodyLarge,
                          ),
                        ],
                      ),
                      if (recipe.description != null) ...[
                        const SizedBox(height: 16),
                        Text(
                          recipe.description!,
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                      ],
                      // Ingredients section
                      if (recipe.ingredients.isNotEmpty) ...[
                        const SizedBox(height: 24),
                        Text(
                          'Ingredientes',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        const SizedBox(height: 8),
                        ...recipe.ingredients.map((ingredient) => IngredientItem(ingredient: ingredient)),
                      ],
                      // Steps section
                      if (recipe.steps.isNotEmpty) ...[
                        const SizedBox(height: 24),
                        Text(
                          'Pasos',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        const SizedBox(height: 8),
                        ...recipe.steps.map((step) => StepItem(step: step)),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          );
        },
        loading: () => const Scaffold(body: LoadingWidget()),
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
}

