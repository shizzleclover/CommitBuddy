import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'cache_service.dart';

class SupabaseAuthService {
  static final SupabaseClient _supabase = Supabase.instance.client;
  static final GoogleSignIn _googleSignIn = GoogleSignIn();

  // Current user getter
  static User? get currentUser => _supabase.auth.currentUser;
  
  // Current session getter
  static Session? get currentSession => _supabase.auth.currentSession;

  // Check if user is authenticated
  static bool get isAuthenticated => currentUser != null;

  // Initialize auth listener
  static void initializeAuthListener() {
    _supabase.auth.onAuthStateChange.listen((data) {
      final AuthChangeEvent event = data.event;
      final Session? session = data.session;

      switch (event) {
        case AuthChangeEvent.signedIn:
          if (session != null) {
            CacheService.saveAuthToken(session.accessToken);
            if (session.refreshToken != null) {
              CacheService.saveRefreshToken(session.refreshToken!);
            }
          }
          break;
        case AuthChangeEvent.signedOut:
          CacheService.clearAuthData();
          CacheService.clearUserData();
          break;
        case AuthChangeEvent.tokenRefreshed:
          if (session != null) {
            CacheService.saveAuthToken(session.accessToken);
          }
          break;
        default:
          break;
      }
    });
  }

  // Sign up with email and password
  static Future<AuthResponse> signUpWithEmail({
    required String email,
    required String password,
    Map<String, dynamic>? userData,
  }) async {
    try {
      print('📧 Attempting signup with email: $email');
      
      final response = await _supabase.auth.signUp(
        email: email,
        password: password,
        data: userData,
      );
      
      print('🔐 Signup response received - User: ${response.user?.id}, Session: ${response.session != null}');
      
      // Handle different signup scenarios
      if (response.user != null) {
        // User created successfully
        if (response.session != null) {
          // User is immediately signed in (email confirmation disabled)
          print('✅ User signed in immediately');
          await _saveUserProfile(response.user!);
        } else {
          // User created but needs email confirmation
          print('📬 User created, email confirmation required');
          // Still save basic profile data for when they confirm
          await _saveUserProfile(response.user!);
        }
      }
      
      return response;
    } catch (e) {
      print('❌ Signup error: $e');
      throw AuthException('Sign up failed: ${e.toString()}');
    }
  }

  // Sign in with email and password
  static Future<AuthResponse> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );
      
      if (response.session != null) {
        await _saveUserProfile(response.user!);
      }
      
      return response;
    } catch (e) {
      throw AuthException('Sign in failed: ${e.toString()}');
    }
  }

  // Sign in with Google
  static Future<AuthResponse> signInWithGoogle() async {
    try {
      // First sign out any existing Google account
      await _googleSignIn.signOut();
      
      // Trigger the Google Sign In flow
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      
      if (googleUser == null) {
        throw AuthException('Google sign in was cancelled');
      }

      // Get Google authentication details
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      
      final String? accessToken = googleAuth.accessToken;
      final String? idToken = googleAuth.idToken;

      if (accessToken == null || idToken == null) {
        throw AuthException('Failed to get Google authentication tokens');
      }

      // Sign in to Supabase using Google credentials
      final response = await _supabase.auth.signInWithIdToken(
        provider: OAuthProvider.google,
        idToken: idToken,
        accessToken: accessToken,
      );
      
      if (response.session != null) {
        await _saveUserProfile(response.user!);
      }
      
      return response;
    } catch (e) {
      throw AuthException('Google sign in failed: ${e.toString()}');
    }
  }

  // Sign out
  static Future<void> signOut() async {
    try {
      await _googleSignIn.signOut();
      await _supabase.auth.signOut();
      await CacheService.clearAuthData();
      await CacheService.clearUserData();
    } catch (e) {
      throw AuthException('Sign out failed: ${e.toString()}');
    }
  }

  // Reset password
  static Future<void> resetPassword(String email) async {
    try {
      await _supabase.auth.resetPasswordForEmail(email);
    } catch (e) {
      throw AuthException('Password reset failed: ${e.toString()}');
    }
  }

  // Update password
  static Future<UserResponse> updatePassword(String newPassword) async {
    try {
      return await _supabase.auth.updateUser(
        UserAttributes(password: newPassword),
      );
    } catch (e) {
      throw AuthException('Password update failed: ${e.toString()}');
    }
  }

  // Update user profile
  static Future<UserResponse> updateProfile({
    String? email,
    Map<String, dynamic>? data,
  }) async {
    try {
      final response = await _supabase.auth.updateUser(
        UserAttributes(
          email: email,
          data: data,
        ),
      );
      
      if (response.user != null) {
        await _saveUserProfile(response.user!);
      }
      
      return response;
    } catch (e) {
      throw AuthException('Profile update failed: ${e.toString()}');
    }
  }

  // Get user profile from Supabase
  static Future<Map<String, dynamic>?> getUserProfile() async {
    try {
      if (currentUser == null) return null;
      
      final response = await _supabase
          .from('user_profiles')
          .select()
          .eq('id', currentUser!.id)
          .single();
      
      await CacheService.saveUserProfile(response);
      return response;
    } catch (e) {
      // Return cached data if network fails
      return CacheService.getUserProfile();
    }
  }

  // Create or update user profile in database
  static Future<void> _saveUserProfile(User user) async {
    try {
      final profileData = {
        'id': user.id,
        'email': user.email,
        'username': user.userMetadata?['username'] ?? user.email?.split('@').first,
        'display_name': user.userMetadata?['display_name'] ?? 
                       user.userMetadata?['full_name'] ?? 
                       user.email?.split('@').first,
        'avatar_url': user.userMetadata?['avatar_url'],
        'updated_at': DateTime.now().toIso8601String(),
      };

      await _supabase
          .from('user_profiles')
          .upsert(profileData);
      
      await CacheService.saveUserProfile(profileData);
    } catch (e) {
      print('Error saving user profile: $e');
    }
  }

  // Check if user exists
  static Future<bool> userExists(String email) async {
    try {
      final response = await _supabase
          .from('user_profiles')
          .select('id')
          .eq('email', email)
          .maybeSingle();
      
      return response != null;
    } catch (e) {
      return false;
    }
  }

  // Refresh session
  static Future<AuthResponse> refreshSession() async {
    try {
      return await _supabase.auth.refreshSession();
    } catch (e) {
      throw AuthException('Session refresh failed: ${e.toString()}');
    }
  }

  // Get cached user data if available
  static Map<String, dynamic>? getCachedUserProfile() {
    return CacheService.getUserProfile();
  }
} 