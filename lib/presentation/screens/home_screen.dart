import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../domain/entities/recipe.dart';
import '../providers/recipe_providers.dart';
import '../widgets/recipe_card.dart';
import '../widgets/loading_widget.dart';
import '../widgets/error_widget.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final recipesAsync = ref.watch(recipeNotifierProvider);
    final favoriteRecipesAsync = ref.watch(favoriteRecipesProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Mi Álbum de Recetas',
          style: GoogleFonts.playfairDisplay(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: const Color(0xFFFF69B4), // Indicador rosa
          labelColor: const Color(0xFFFF69B4), // Color del texto activo
          unselectedLabelColor: const Color(0xFF8B7355), // Color del texto inactivo
          labelStyle: GoogleFonts.playfairDisplay(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
          unselectedLabelStyle: GoogleFonts.playfairDisplay(
            fontSize: 16,
            fontWeight: FontWeight.normal,
          ),
          indicatorSize: TabBarIndicatorSize.tab,
          tabs: const [
            Tab(text: 'Todas'),
            Tab(text: 'Mis Favoritas'),
          ],
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
      body: TabBarView(
        controller: _tabController,
        children: [
          // Tab 1: Todas las recetas
          _buildRecipesList(recipesAsync),
          // Tab 2: Recetas favoritas
          _buildRecipesList(favoriteRecipesAsync),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          context.push('/recipe/add');
        },
        backgroundColor: const Color(0xFFFFC1CC),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildRecipesList(AsyncValue<List<dynamic>> recipesAsync) {
    return recipesAsync.when(
      data: (recipes) {
        if (recipes.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(32.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    _tabController.index == 0
                        ? Icons.menu_book_outlined
                        : Icons.favorite_border,
                    size: 100,
                    color: Theme.of(context).colorScheme.secondary.withOpacity(0.4),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    _tabController.index == 0
                        ? 'No hay recetitas aún'
                        : 'No tienes recetas favoritas',
                    style: GoogleFonts.playfairDisplay(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF8B7355),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    _tabController.index == 0
                        ? 'Comienza a crear tu colección\nde recetas favoritas'
                        : 'Marca algunas recetas como favoritas\npara verlas aquí',
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
          color: const Color(0xFFFF69B4),
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
    );
  }
}
