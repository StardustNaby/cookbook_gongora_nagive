import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../domain/entities/recipe.dart';
import '../../core/utils/image_helper.dart';

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
                    child: _buildImageWidget(recipe.imageUrl),
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
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Title
                    Flexible(
                      child: Text(
                        recipe.name,
                        style: GoogleFonts.playfairDisplay(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).textTheme.titleMedium?.color ?? const Color(0xFF5D4037),
                          height: 1.2,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(height: 8),
                    // Details row - Flexible para evitar overflow
                    Flexible(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Time icon
                          Icon(
                            Icons.access_time_outlined,
                            size: 16,
                            color: Theme.of(context).textTheme.bodySmall?.color ?? const Color(0xFF8B7355),
                          ),
                          const SizedBox(width: 4),
                          Flexible(
                            child: Text(
                              '${recipe.prepTimeMinutes} min',
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                color: Theme.of(context).textTheme.bodySmall?.color ?? const Color(0xFF8B7355),
                                fontWeight: FontWeight.w500,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 12),
                          // Difficulty icon
                          Icon(
                            _getDifficultyIcon(recipe.difficulty),
                            size: 16,
                            color: Theme.of(context).textTheme.bodySmall?.color ?? const Color(0xFF8B7355),
                          ),
                          const SizedBox(width: 4),
                          Flexible(
                            child: Text(
                              recipe.difficulty.displayName,
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                color: Theme.of(context).textTheme.bodySmall?.color ?? const Color(0xFF8B7355),
                                fontWeight: FontWeight.w500,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
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

  Widget _buildImageWidget(String? imageUrl) {
    // Si no hay URL, mostrar placeholder
    if (imageUrl == null || imageUrl.trim().isEmpty) {
      return Container(
        height: 180,
        width: double.infinity,
        color: const Color(0xFFFFE4E9),
        child: const Icon(
          Icons.restaurant_menu,
          size: 64,
          color: Color(0xFFFFB6C1),
        ),
      );
    }
    
    // Limpiar la URL
    final cleanedUrl = ImageHelper.cleanImageUrl(imageUrl);
    
    // Si después de limpiar no es válida, mostrar placeholder
    if (cleanedUrl == null || !ImageHelper.isValidImageUrl(cleanedUrl)) {
      debugPrint('Invalid image URL: $imageUrl (cleaned: $cleanedUrl)');
      return Container(
        height: 180,
        width: double.infinity,
        color: const Color(0xFFFFE4E9),
        child: const Icon(
          Icons.restaurant_menu,
          size: 64,
          color: Color(0xFFFFB6C1),
        ),
      );
    }
    
    return CachedNetworkImage(
      imageUrl: cleanedUrl,
      height: 180,
      width: double.infinity,
      fit: BoxFit.cover,
      httpHeaders: ImageHelper.getImageHeaders(cleanedUrl),
      placeholder: (context, url) => Container(
        height: 180,
        color: const Color(0xFFFFE4E9),
        child: const Center(
          child: CircularProgressIndicator(
            color: Color(0xFFFFB6C1),
          ),
        ),
      ),
      errorWidget: (context, url, error) {
        // Log del error para debugging
        debugPrint('Error loading image: $url');
        debugPrint('Error details: $error');
        return Container(
          height: 180,
          color: const Color(0xFFFFE4E9),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.broken_image,
                size: 48,
                color: Color(0xFFFFB6C1),
              ),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Text(
                  'Error al cargar imagen',
                  style: TextStyle(
                    fontSize: 12,
                    color: const Color(0xFFFFB6C1).withOpacity(0.7),
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        );
      },
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
