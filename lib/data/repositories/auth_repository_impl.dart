import '../../domain/repositories/auth_repository.dart';
import '../../core/config/supabase_config.dart';

class AuthRepositoryImpl implements AuthRepository {
  final _supabase = SupabaseConfig.client;

  @override
  Future<void> signIn(String email, String password) async {
    try {
      final response = await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );
      
      if (response.user == null) {
        throw Exception('Sign in failed: No user returned');
      }
    } catch (e) {
      throw Exception('Error signing in: $e');
    }
  }

  @override
  Future<void> signUp(String email, String password) async {
    try {
      final response = await _supabase.auth.signUp(
        email: email,
        password: password,
      );
      
      if (response.user == null) {
        throw Exception('Sign up failed: No user returned');
      }
    } catch (e) {
      throw Exception('Error signing up: $e');
    }
  }

  @override
  Future<void> signOut() async {
    try {
      await _supabase.auth.signOut();
    } catch (e) {
      throw Exception('Error signing out: $e');
    }
  }

  @override
  Future<String?> getCurrentUserId() async {
    try {
      final user = _supabase.auth.currentUser;
      return user?.id;
    } catch (e) {
      throw Exception('Error getting current user: $e');
    }
  }

  @override
  Future<bool> isSignedIn() async {
    try {
      final user = _supabase.auth.currentUser;
      return user != null;
    } catch (e) {
      throw Exception('Error checking sign in status: $e');
    }
  }
}




