import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../domain/entities/recipe.dart';

class RecipeCard extends StatelessWidget {
  final Recipe recipe;
  final VoidCallback onTap;
  final VoidCallback? onFavoriteTap;

  const RecipeCard({
    super.key,
    required this.recipe,
    required this.onTap,
    this.onFavoriteTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(8),
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      color: Theme.of(context).scaffoldBackgroundColor,
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image with rounded top corners
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
              child: Stack(
                children: [
                  // Hero animation para conectar con el detalle
                  Hero(
                    tag: 'recipe-image-${recipe.id}', // El tag debe ser igual que en DetailScreen
                    child: (recipe.imageUrl != null && recipe.imageUrl!.isNotEmpty)
                        ? CachedNetworkImage(
                            imageUrl: recipe.imageUrl!,
                            height: 180,
                            width: double.infinity,
                            fit: BoxFit.cover,
                            placeholder: (context, url) => Container(
                              height: 180,
                              color: const Color(0xFFFFE4E9),
                              child: const Center(
                                child: CircularProgressIndicator(
                                  color: Color(0xFFFFB6C1),
                                ),
                              ),
                            ),
                            errorWidget: (context, url, error) => Container(
                              height: 180,
                              color: const Color(0xFFFFE4E9),
                              child: const Icon(
                                Icons.restaurant_menu,
                                size: 64,
                                color: Color(0xFFFFB6C1),
                              ),
                            ),
                          )
                        : Container(
                            height: 180,
                            width: double.infinity,
                            color: const Color(0xFFFFE4E9),
                            child: const Icon(
                              Icons.restaurant_menu,
                              size: 64,
                              color: Color(0xFFFFB6C1),
                            ),
                          ),
                  ),
                  // Favorite button
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: onFavoriteTap,
                        borderRadius: BorderRadius.circular(20),
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.9),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            recipe.isFavorite ? Icons.favorite : Icons.favorite_border,
                            color: recipe.isFavorite 
                                ? const Color(0xFFFF69B4) 
                                : const Color(0xFF8B7355),
                            size: 20,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Content
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Title
                    Text(
                      recipe.name,
                      style: GoogleFonts.playfairDisplay(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF5D4037), // Marrón oscuro
                        height: 1.2,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    // Details row
                    Row(
                      children: [
                        // Time icon
                        Icon(
                          Icons.access_time_outlined,
                          size: 16,
                          color: const Color(0xFF8B7355), // Marrón/gris
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${recipe.prepTimeMinutes} min',
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: const Color(0xFF8B7355),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(width: 12),
                        // Difficulty icon
                        Icon(
                          _getDifficultyIcon(recipe.difficulty),
                          size: 16,
                          color: const Color(0xFF8B7355),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          recipe.difficulty.displayName,
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: const Color(0xFF8B7355),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getDifficultyIcon(Difficulty difficulty) {
    switch (difficulty) {
      case Difficulty.easy:
        return Icons.sentiment_satisfied_alt_outlined;
      case Difficulty.medium:
        return Icons.sentiment_neutral_outlined;
      case Difficulty.hard:
        return Icons.sentiment_very_dissatisfied_outlined;
    }
  }
}
