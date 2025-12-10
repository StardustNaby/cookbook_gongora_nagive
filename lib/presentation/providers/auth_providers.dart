import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../core/config/supabase_config.dart';
import 'repository_providers.dart';

// Auth State Notifier
class AuthNotifier extends StateNotifier<AsyncValue<String?>> {
  AuthNotifier(this._repository) : super(const AsyncValue.loading()) {
    _checkAuthStatus();
    _listenToAuthChanges();
  }

  final AuthRepository _repository;
  StreamSubscription<AuthState>? _authSubscription;

  void _listenToAuthChanges() {
    final supabase = SupabaseConfig.client;
    _authSubscription = supabase.auth.onAuthStateChange.listen((data) {
      final userId = data.session?.user.id;
      state = AsyncValue.data(userId);
    });
  }

  Future<void> _checkAuthStatus() async {
    try {
      final userId = await _repository.getCurrentUserId();
      state = AsyncValue.data(userId);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }

  Future<void> signIn(String email, String password) async {
    state = const AsyncValue.loading();
    try {
      await _repository.signIn(email, password);
      final userId = await _repository.getCurrentUserId();
      state = AsyncValue.data(userId);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }

  Future<void> signUp(String email, String password) async {
    state = const AsyncValue.loading();
    try {
      await _repository.signUp(email, password);
      final userId = await _repository.getCurrentUserId();
      state = AsyncValue.data(userId);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }

  Future<void> signOut() async {
    try {
      await _repository.signOut();
      state = const AsyncValue.data(null);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }

  Stream<AsyncValue<String?>> get stream {
    return Stream.value(state);
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    super.dispose();
  }
}

final authNotifierProvider = StateNotifierProvider<AuthNotifier, AsyncValue<String?>>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  return AuthNotifier(repository);
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
