import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../core/config/supabase_config.dart';
import 'repository_providers.dart';

// Auth State Notifier
class AuthNotifier extends Notifier<AsyncValue<String?>> {
  StreamSubscription<AuthState>? _authSubscription;

  @override
  AsyncValue<String?> build() {
    _checkAuthStatus();
    _listenToAuthChanges();
    return const AsyncValue.loading();
  }

  void _listenToAuthChanges() {
    final supabase = SupabaseConfig.client;
    _authSubscription = supabase.auth.onAuthStateChange.listen((data) {
      final userId = data.session?.user.id;
      state = AsyncValue.data(userId);
    });
  }

  Future<void> _checkAuthStatus() async {
    try {
      final repository = ref.read(authRepositoryProvider);
      final userId = await repository.getCurrentUserId();
      state = AsyncValue.data(userId);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }

  Future<void> signIn(String email, String password) async {
    state = const AsyncValue.loading();
    try {
      final repository = ref.read(authRepositoryProvider);
      await repository.signIn(email, password);
      final userId = await repository.getCurrentUserId();
      state = AsyncValue.data(userId);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }

  Future<void> signUp(String email, String password) async {
    state = const AsyncValue.loading();
    try {
      final repository = ref.read(authRepositoryProvider);
      await repository.signUp(email, password);
      final userId = await repository.getCurrentUserId();
      state = AsyncValue.data(userId);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }

  Future<void> signOut() async {
    try {
      final repository = ref.read(authRepositoryProvider);
      await repository.signOut();
      state = const AsyncValue.data(null);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }

  void dispose() {
    _authSubscription?.cancel();
  }
}

final authNotifierProvider = NotifierProvider<AuthNotifier, AsyncValue<String?>>(() {
  return AuthNotifier();
});

// Is Signed In Provider
final isSignedInProvider = Provider<bool>((ref) {
  final authState = ref.watch(authNotifierProvider);
  return authState.when(
    data: (userId) => userId != null,
    loading: () => false,
    error: (_, __) => false,
  );
});

// Current User ID Provider
final currentUserIdProvider = Provider<String?>((ref) {
  final authState = ref.watch(authNotifierProvider);
  return authState.when(
    data: (userId) => userId,
    loading: () => null,
    error: (_, __) => null,
  );
});
