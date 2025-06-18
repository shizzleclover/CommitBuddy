import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/services/supabase_auth_service.dart';
import '../../../core/services/cache_service.dart';

// Auth state class
class AuthState {
  final User? user;
  final bool isLoading;
  final String? error;
  final bool isAuthenticated;

  AuthState({
    this.user,
    this.isLoading = false,
    this.error,
    this.isAuthenticated = false,
  });

  AuthState copyWith({
    User? user,
    bool? isLoading,
    String? error,
    bool? isAuthenticated,
  }) {
    return AuthState(
      user: user ?? this.user,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
    );
  }
}

// Auth notifier
class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier() : super(AuthState()) {
    _initialize();
  }

  void _initialize() {
    // Initialize auth listener
    SupabaseAuthService.initializeAuthListener();
    
    // Check for existing session
    final currentUser = SupabaseAuthService.currentUser;
    if (currentUser != null) {
      state = state.copyWith(
        user: currentUser,
        isAuthenticated: true,
      );
      _loadUserProfile();
    }
  }

  Future<void> _loadUserProfile() async {
    try {
      await SupabaseAuthService.getUserProfile();
    } catch (e) {
      print('Error loading user profile: $e');
    }
  }

  // Sign in with email and password
  Future<bool> signInWithEmail(String email, String password) async {
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      final response = await SupabaseAuthService.signInWithEmail(
        email: email,
        password: password,
      );
      
      if (response.user != null) {
        state = state.copyWith(
          user: response.user,
          isAuthenticated: true,
          isLoading: false,
        );
        await _loadUserProfile();
        return true;
      }
      
      state = state.copyWith(isLoading: false, error: 'Sign in failed');
      return false;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString().replaceAll('AuthException: ', ''),
      );
      return false;
    }
  }

  // Sign up with email and password
  Future<bool> signUpWithEmail({
    required String email,
    required String password,
    String? displayName,
    String? username,
  }) async {
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      final userData = <String, dynamic>{};
      if (displayName != null) userData['display_name'] = displayName;
      if (username != null) userData['username'] = username;
      
      final response = await SupabaseAuthService.signUpWithEmail(
        email: email,
        password: password,
        userData: userData.isNotEmpty ? userData : null,
      );
      
      if (response.user != null) {
        // Check if user has a session (immediately signed in)
        if (response.session != null) {
          state = state.copyWith(
            user: response.user,
            isAuthenticated: true,
            isLoading: false,
          );
          await _loadUserProfile();
        } else {
          // User created but needs email confirmation
          state = state.copyWith(
            user: null,
            isAuthenticated: false,
            isLoading: false,
          );
        }
        return true;
      }
      
      state = state.copyWith(isLoading: false, error: 'Sign up failed');
      return false;
    } catch (e) {
      final errorMessage = e.toString().replaceAll('AuthException: ', '');
      state = state.copyWith(
        isLoading: false,
        error: errorMessage,
      );
      return false;
    }
  }

  // Sign in with Google
  Future<bool> signInWithGoogle() async {
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      final response = await SupabaseAuthService.signInWithGoogle();
      
      if (response.user != null) {
        state = state.copyWith(
          user: response.user,
          isAuthenticated: true,
          isLoading: false,
        );
        await _loadUserProfile();
        return true;
      }
      
      state = state.copyWith(isLoading: false, error: 'Google sign in failed');
      return false;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString().replaceAll('AuthException: ', ''),
      );
      return false;
    }
  }

  // Sign out
  Future<void> signOut() async {
    state = state.copyWith(isLoading: true);
    
    try {
      await SupabaseAuthService.signOut();
      state = AuthState(); // Reset to initial state
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString().replaceAll('AuthException: ', ''),
      );
    }
  }

  // Reset password
  Future<bool> resetPassword(String email) async {
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      await SupabaseAuthService.resetPassword(email);
      state = state.copyWith(isLoading: false);
      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString().replaceAll('AuthException: ', ''),
      );
      return false;
    }
  }

  // Clear error
  void clearError() {
    state = state.copyWith(error: null);
  }

  // Refresh session
  Future<void> refreshSession() async {
    try {
      final response = await SupabaseAuthService.refreshSession();
      if (response.user != null) {
        state = state.copyWith(
          user: response.user,
          isAuthenticated: true,
        );
      }
    } catch (e) {
      print('Error refreshing session: $e');
    }
  }
}

// User profile state
class UserProfileState {
  final Map<String, dynamic>? profile;
  final bool isLoading;
  final String? error;

  UserProfileState({
    this.profile,
    this.isLoading = false,
    this.error,
  });

  UserProfileState copyWith({
    Map<String, dynamic>? profile,
    bool? isLoading,
    String? error,
  }) {
    return UserProfileState(
      profile: profile ?? this.profile,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

// User profile notifier
class UserProfileNotifier extends StateNotifier<UserProfileState> {
  UserProfileNotifier() : super(UserProfileState()) {
    _loadCachedProfile();
  }

  void _loadCachedProfile() {
    final cachedProfile = SupabaseAuthService.getCachedUserProfile();
    if (cachedProfile != null) {
      state = state.copyWith(profile: cachedProfile);
    }
  }

  Future<void> loadProfile() async {
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      final profile = await SupabaseAuthService.getUserProfile();
      state = state.copyWith(profile: profile, isLoading: false);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<void> updateProfile({
    String? displayName,
    String? bio,
    String? username,
  }) async {
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      final updateData = <String, dynamic>{};
      if (displayName != null) updateData['display_name'] = displayName;
      if (bio != null) updateData['bio'] = bio;
      if (username != null) updateData['username'] = username;
      
      await SupabaseAuthService.updateProfile(data: updateData);
      await loadProfile(); // Reload profile after update
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }
}

// Main providers
final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier();
});

final userProfileProvider = StateNotifierProvider<UserProfileNotifier, UserProfileState>((ref) {
  return UserProfileNotifier();
});

// Convenience providers
final currentUserProvider = Provider<User?>((ref) {
  return ref.watch(authProvider).user;
});

final isAuthenticatedProvider = Provider<bool>((ref) {
  return ref.watch(authProvider).isAuthenticated;
});

final isLoadingProvider = Provider<bool>((ref) {
  return ref.watch(authProvider).isLoading;
});

final authErrorProvider = Provider<String?>((ref) {
  return ref.watch(authProvider).error;
});

final userProfileDataProvider = Provider<Map<String, dynamic>?>((ref) {
  return ref.watch(userProfileProvider).profile;
});

// Auth check provider for routing
final authCheckProvider = FutureProvider<bool>((ref) async {
  final authState = ref.watch(authProvider);
  
  if (authState.user != null) {
    // Load user profile if authenticated
    ref.read(userProfileProvider.notifier).loadProfile();
    return true;
  }
  
  return false;
}); 