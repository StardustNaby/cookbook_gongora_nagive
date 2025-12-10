import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../presentation/screens/splash_screen.dart';
import '../../presentation/screens/main_wrapper_screen.dart';
import '../../presentation/screens/home_screen.dart';
import '../../presentation/screens/login_screen.dart';
import '../../presentation/screens/register_screen.dart';
import '../../presentation/screens/recipe_detail_screen.dart';
import '../../presentation/screens/add_edit_recipe_screen.dart';
import '../../presentation/screens/profile_screen.dart';
import '../../presentation/providers/auth_providers.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  final isSignedIn = ref.watch(isSignedInProvider);

  return GoRouter(
    initialLocation: '/splash',
    redirect: (context, state) {
      final isAuthenticated = isSignedIn;
      final isGoingToSplash = state.matchedLocation == '/splash';
      final isGoingToLogin = state.matchedLocation == '/login';
      final isGoingToRegister = state.matchedLocation == '/register';

      // Si está en splash, no redirigir
      if (isGoingToSplash) {
        return null;
      }

      // Si no está autenticado y no va a login/register, redirigir a login
      if (!isAuthenticated && !isGoingToLogin && !isGoingToRegister) {
        return '/login';
      }

      // Si está autenticado y va a login/register, redirigir a home
      if (isAuthenticated && (isGoingToLogin || isGoingToRegister)) {
        return '/home';
      }

      return null;
    },
    routes: [
      // Rutas fuera del Shell (sin barra de navegación)
      GoRoute(
        path: '/splash',
        name: 'splash',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/register',
        name: 'register',
        builder: (context, state) => const RegisterScreen(),
      ),
      // Rutas de recetas fuera del Shell (root navigator)
      GoRoute(
        path: '/recipe/add',
        name: 'recipe-add',
        builder: (context, state) => const AddEditRecipeScreen(),
      ),
      GoRoute(
        path: '/recipe/edit/:id',
        name: 'recipe-edit',
        builder: (context, state) {
          final recipeId = state.pathParameters['id']!;
          return AddEditRecipeScreen(recipeId: recipeId);
        },
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
        path: '/profile',
        name: 'profile',
        builder: (context, state) => const ProfileScreen(),
      ),
      // Shell con navegación anidada
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return MainWrapperScreen(navigationShell: navigationShell);
        },
        branches: [
          // Rama 1: Inicio
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/home',
                name: 'home',
                builder: (context, state) => const HomeScreen(
                  showFavoritesOnly: false,
                ),
              ),
            ],
          ),
          // Rama 2: Favoritos
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/favorites',
                name: 'favorites',
                builder: (context, state) => const HomeScreen(
                  showFavoritesOnly: true,
                ),
              ),
            ],
          ),
        ],
      ),
    ],
  );
});
