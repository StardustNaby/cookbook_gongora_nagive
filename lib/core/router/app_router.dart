import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../presentation/screens/home_screen.dart';
import '../../presentation/screens/login_screen.dart';
import '../../presentation/screens/recipe_detail_screen.dart';
import '../../presentation/screens/add_edit_recipe_screen.dart';

final appRouter = GoRouter(
  initialLocation: '/login',
  routes: [
    GoRoute(
      path: '/login',
      name: 'login',
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: '/home',
      name: 'home',
      builder: (context, state) => const HomeScreen(),
    ),
    GoRoute(
      path: '/recipe/:id',
      name: 'recipe-detail',
      builder: (context, state) {
        final recipeId = state.pathParameters['id']!;
        return RecipeDetailScreen(recipeId: recipeId);
      },
    ),
    GoRoute(
      path: '/recipe/add',
      name: 'recipe-add',
      builder: (context, state) => const AddEditRecipeScreen(),
    ),
    GoRoute(
      path: '/recipe/edit/:id',
      name: 'recipe-edit',
      builder: (context, state) {
        // Note: This route would need the recipe object passed via extra
        // For now, we'll use the recipe ID and fetch it in the screen
        return const AddEditRecipeScreen();
      },
    ),
  ],
);

