import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService {
  static final SupabaseClient _client = Supabase.instance.client;

  // Get current user
  static User? getCurrentUser() {
    return _client.auth.currentUser;
  }

  // Check if user is authenticated
  static bool isAuthenticated() {
    return _client.auth.currentUser != null;
  }

  // Get current user ID
  static String? getCurrentUserId() {
    return _client.auth.currentUser?.id;
  }

  // Get current user email
  static String? getCurrentUserEmail() {
    return _client.auth.currentUser?.email;
  }

  // Sign out
  static Future<void> signOut() async {
    await _client.auth.signOut();
  }

  // Sign in with email and password
  static Future<AuthResponse> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    return await _client.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  // Sign up with email and password
  static Future<AuthResponse> signUpWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    return await _client.auth.signUp(
      email: email,
      password: password,
    );
  }

  // Listen to auth state changes
  static Stream<AuthState> get authStateChanges {
    return _client.auth.onAuthStateChange;
  }
} 