import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../domain/entities/recipe.dart';
import '../providers/recipe_providers.dart';
import '../providers/theme_provider.dart';
import '../widgets/recipe_card.dart';
import '../widgets/loading_widget.dart';
import '../widgets/error_widget.dart';

class HomeScreen extends ConsumerStatefulWidget {
  final bool showFavoritesOnly;
  
  const HomeScreen({
    super.key,
    this.showFavoritesOnly = false,
  });

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

enum SortOption {
  dateDesc, // Más recientes primero (por defecto)
  dateAsc,  // Más antiguas primero
  alphabetical, // Alfabético A-Z
  prepTimeAsc,  // Menor tiempo primero
  prepTimeDesc, // Mayor tiempo primero
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();
  Difficulty? _selectedDifficulty;
  SortOption _sortOption = SortOption.dateDesc; // Por defecto: más recientes primero

  @override
  void dispose() {
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

    // Apply sorting
    filtered = _sortRecipes(filtered);

    return filtered;
  }

  List<Recipe> _sortRecipes(List<Recipe> recipes) {
    final sorted = List<Recipe>.from(recipes);
    
    switch (_sortOption) {
      case SortOption.dateDesc:
        sorted.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        break;
      case SortOption.dateAsc:
        sorted.sort((a, b) => a.createdAt.compareTo(b.createdAt));
        break;
      case SortOption.alphabetical:
        sorted.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
        break;
      case SortOption.prepTimeAsc:
        sorted.sort((a, b) => a.prepTimeMinutes.compareTo(b.prepTimeMinutes));
        break;
      case SortOption.prepTimeDesc:
        sorted.sort((a, b) => b.prepTimeMinutes.compareTo(a.prepTimeMinutes));
        break;
    }
    
    return sorted;
  }

  void _showFilterBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.9,
        ),
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(30),
            topRight: Radius.circular(30),
          ),
        ),
        child: SingleChildScrollView(
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
              'Filtros y Ordenamiento',
              style: GoogleFonts.playfairDisplay(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).textTheme.titleLarge?.color ?? const Color(0xFF5D4037),
              ),
            ),
            const SizedBox(height: 24),
            // Sort section
            Text(
              'Ordenar por',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).textTheme.bodyMedium?.color,
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                _buildSortChip('Más recientes', SortOption.dateDesc),
                _buildSortChip('Más antiguas', SortOption.dateAsc),
                _buildSortChip('A-Z', SortOption.alphabetical),
                _buildSortChip('Tiempo ↑', SortOption.prepTimeAsc),
                _buildSortChip('Tiempo ↓', SortOption.prepTimeDesc),
              ],
            ),
            const SizedBox(height: 24),
            // Filter section
            Text(
              'Filtrar por Dificultad',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).textTheme.bodyMedium?.color,
              ),
            ),
            const SizedBox(height: 12),
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
                    _sortOption = SortOption.dateDesc;
                  });
                  Navigator.of(context).pop();
                },
                child: Text(
                  'Limpiar Filtros',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
            ),
            ],
          ),
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
          color: isSelected ? Colors.white : Theme.of(context).textTheme.bodyMedium?.color,
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

  Widget _buildSortChip(String label, SortOption option) {
    final isSelected = _sortOption == option;
    return FilterChip(
      label: Text(
        label,
        style: GoogleFonts.poppins(
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          color: isSelected ? Colors.white : Theme.of(context).textTheme.bodyMedium?.color,
        ),
      ),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          _sortOption = option;
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
    // Usar el provider según showFavoritesOnly
    final recipesAsync = widget.showFavoritesOnly
        ? ref.watch(favoriteRecipesProvider)
        : ref.watch(recipeNotifierProvider);

    return Scaffold(
      // Sin AppBar aquí - el MainWrapperScreen ya tiene uno
      appBar: null,
      body: Column(
        children: [
          // Title section (ya que no hay AppBar)
          Container(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
            color: Theme.of(context).scaffoldBackgroundColor,
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    widget.showFavoritesOnly ? 'Recetas Favoritas' : 'Mis Recetas',
                    style: GoogleFonts.playfairDisplay(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
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
          ),
          // Search bar
          Container(
            padding: const EdgeInsets.all(16),
            color: Theme.of(context).scaffoldBackgroundColor,
            child: TextField(
              controller: _searchController,
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(
                hintText: 'Buscar recetas...',
                hintStyle: Theme.of(context).textTheme.bodySmall,
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
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
          // Recipes list
          Expanded(
            child: _buildRecipesList(recipesAsync),
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
                        : widget.showFavoritesOnly
                            ? Icons.favorite_border
                            : Icons.menu_book_outlined,
                    size: 100,
                    color: Theme.of(context).colorScheme.secondary.withOpacity(0.4),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    _searchController.text.isNotEmpty ||
                            _selectedDifficulty != null
                        ? 'No se encontraron recetas'
                        : widget.showFavoritesOnly
                            ? 'No tienes recetas favoritas'
                            : 'No hay recetitas aún',
                    style: GoogleFonts.playfairDisplay(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).textTheme.titleLarge?.color ?? const Color(0xFF8B7355),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    _searchController.text.isNotEmpty ||
                            _selectedDifficulty != null
                        ? 'Intenta con otros términos de búsqueda\n o ajusta los filtros'
                        : widget.showFavoritesOnly
                            ? 'Marca algunas recetas como favoritas\npara verlas aquí'
                            : 'Comienza a crear tu colección\nde recetas favoritas',
                    style: Theme.of(context).textTheme.bodyMedium,
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
              childAspectRatio: 0.70, // Reducido para dar más espacio vertical
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
              style: Theme.of(context).textTheme.bodyMedium,
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
