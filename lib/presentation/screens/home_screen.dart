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
  final TextEditingController _searchController = TextEditingController();
  Difficulty? _selectedDifficulty;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  List<Recipe> _filterRecipes(List<Recipe> recipes) {
    var filtered = recipes;

    // Filter by search query
    if (_searchController.text.isNotEmpty) {
      final query = _searchController.text.toLowerCase();
      filtered = filtered.where((recipe) {
        return recipe.name.toLowerCase().contains(query) ||
            (recipe.description?.toLowerCase().contains(query) ?? false);
      }).toList();
    }

    // Filter by difficulty
    if (_selectedDifficulty != null) {
      filtered = filtered.where((recipe) {
        return recipe.difficulty == _selectedDifficulty;
      }).toList();
    }

    return filtered;
  }

  void _showFilterBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Color(0xFFFFF8F0), // Rosa pálido
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(30),
            topRight: Radius.circular(30),
          ),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle bar
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: const Color(0xFFFFB6C1),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            // Title
            Text(
              'Filtrar por Dificultad',
              style: GoogleFonts.playfairDisplay(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF5D4037),
              ),
            ),
            const SizedBox(height: 20),
            // Difficulty chips
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                _buildDifficultyChip('Todas', null),
                _buildDifficultyChip('Fácil', Difficulty.easy),
                _buildDifficultyChip('Media', Difficulty.medium),
                _buildDifficultyChip('Difícil', Difficulty.hard),
              ],
            ),
            const SizedBox(height: 24),
            // Apply button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  setState(() {});
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFFC1CC),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                ),
                child: Text(
                  'Aplicar Filtros',
                  style: GoogleFonts.playfairDisplay(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            // Clear filters button
            SizedBox(
              width: double.infinity,
              child: TextButton(
                onPressed: () {
                  setState(() {
                    _selectedDifficulty = null;
                  });
                  Navigator.of(context).pop();
                },
                child: Text(
                  'Limpiar Filtros',
                  style: GoogleFonts.poppins(
                    color: const Color(0xFF8B7355),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDifficultyChip(String label, Difficulty? difficulty) {
    final isSelected = _selectedDifficulty == difficulty;
    return FilterChip(
      label: Text(
        label,
        style: GoogleFonts.poppins(
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          color: isSelected ? Colors.white : const Color(0xFF5D4037),
        ),
      ),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          _selectedDifficulty = selected ? difficulty : null;
        });
      },
      backgroundColor: const Color(0xFFFFE4E9), // Rosa pastel
      selectedColor: const Color(0xFFFF91A4), // Rosa más fuerte cuando está seleccionado
      checkmarkColor: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: isSelected
              ? const Color(0xFFFF69B4)
              : const Color(0xFFFFB6C1),
          width: isSelected ? 2 : 1,
        ),
      ),
    );
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
            icon: const Icon(Icons.filter_list),
            onPressed: () => _showFilterBottomSheet(context),
            tooltip: 'Filtros',
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              ref.read(recipeNotifierProvider.notifier).refresh();
            },
            tooltip: 'Actualizar',
          ),
        ],
      ),
      body: Column(
        children: [
          // Search bar
          Container(
            padding: const EdgeInsets.all(16),
            color: const Color(0xFFFFF8F0),
            child: TextField(
              controller: _searchController,
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(
                hintText: 'Buscar recetas...',
                hintStyle: GoogleFonts.poppins(
                  color: const Color(0xFF8B7355),
                ),
                prefixIcon: const Icon(
                  Icons.search,
                  color: Color(0xFFFF69B4), // Icono de lupa rosa
                ),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: const BorderSide(
                    color: Color(0xFFFFB6C1),
                    width: 2,
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: const BorderSide(
                    color: Color(0xFFFFB6C1),
                    width: 2,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: const BorderSide(
                    color: Color(0xFFFF69B4),
                    width: 2.5,
                  ),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 16,
                ),
              ),
              style: GoogleFonts.poppins(),
            ),
          ),
          // Recipes list
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                // Tab 1: Todas las recetas
                _buildRecipesList(recipesAsync),
                // Tab 2: Recetas favoritas
                _buildRecipesList(favoriteRecipesAsync),
              ],
            ),
          ),
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

  Widget _buildRecipesList(AsyncValue<List<Recipe>> recipesAsync) {
    return recipesAsync.when(
      data: (recipes) {
        // Apply filters
        final filteredRecipes = _filterRecipes(recipes);

        if (filteredRecipes.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(32.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    _searchController.text.isNotEmpty ||
                            _selectedDifficulty != null
                        ? Icons.search_off
                        : _tabController.index == 0
                            ? Icons.menu_book_outlined
                            : Icons.favorite_border,
                    size: 100,
                    color: Theme.of(context).colorScheme.secondary.withOpacity(0.4),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    _searchController.text.isNotEmpty ||
                            _selectedDifficulty != null
                        ? 'No se encontraron recetas'
                        : _tabController.index == 0
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
                    _searchController.text.isNotEmpty ||
                            _selectedDifficulty != null
                        ? 'Intenta con otros términos de búsqueda\n o ajusta los filtros'
                        : _tabController.index == 0
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
            itemCount: filteredRecipes.length,
            itemBuilder: (context, index) {
              final recipe = filteredRecipes[index];
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
