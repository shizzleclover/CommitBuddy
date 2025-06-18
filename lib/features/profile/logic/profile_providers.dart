import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/services/profile_service.dart';
import '../../../core/services/achievements_service.dart';

// Profile State
class ProfileState {
  final Map<String, dynamic>? profile;
  final Map<String, dynamic>? stats;
  final List<Map<String, dynamic>> activity;
  final List<Map<String, dynamic>> achievements;
  final Map<String, dynamic>? achievementStats;
  final bool isLoading;
  final String? error;

  const ProfileState({
    this.profile,
    this.stats,
    this.activity = const [],
    this.achievements = const [],
    this.achievementStats,
    this.isLoading = false,
    this.error,
  });

  ProfileState copyWith({
    Map<String, dynamic>? profile,
    Map<String, dynamic>? stats,
    List<Map<String, dynamic>>? activity,
    List<Map<String, dynamic>>? achievements,
    Map<String, dynamic>? achievementStats,
    bool? isLoading,
    String? error,
  }) {
    return ProfileState(
      profile: profile ?? this.profile,
      stats: stats ?? this.stats,
      activity: activity ?? this.activity,
      achievements: achievements ?? this.achievements,
      achievementStats: achievementStats ?? this.achievementStats,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

// Profile Notifier
class ProfileNotifier extends StateNotifier<ProfileState> {
  ProfileNotifier() : super(const ProfileState());

  // Load user profile
  Future<void> loadProfile({bool fromCache = true}) async {
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      final profile = await ProfileService.getCurrentUserProfile();
      state = state.copyWith(
        profile: profile,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  // Load user stats
  Future<void> loadStats() async {
    try {
      final stats = await ProfileService.getUserStats();
      state = state.copyWith(stats: stats);
    } catch (e) {
      print('Error loading stats: $e');
    }
  }

  // Load user activity from Supabase
  Future<void> loadActivity() async {
    try {
      final activity = await AchievementsService.getUserActivity();
      state = state.copyWith(activity: activity);
    } catch (e) {
      print('Error loading activity: $e');
    }
  }

  // Load user achievements from Supabase
  Future<void> loadAchievements() async {
    try {
      final achievements = await AchievementsService.getUserAchievements();
      final achievementStats = await AchievementsService.getAchievementStats();
      
      state = state.copyWith(
        achievements: achievements,
        achievementStats: achievementStats,
      );
    } catch (e) {
      print('Error loading achievements: $e');
    }
  }

  // Check and refresh achievements
  Future<void> checkAchievements() async {
    try {
      await AchievementsService.checkAchievements();
      await loadAchievements(); // Refresh after checking
    } catch (e) {
      print('Error checking achievements: $e');
    }
  }

  // Update profile
  Future<bool> updateProfile({
    String? username,
    String? displayName,
    String? bio,
    String? profileImageUrl,
    Map<String, dynamic>? metadata,
  }) async {
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      final updatedProfile = await ProfileService.updateUserProfile(
        username: username,
        displayName: displayName,
        bio: bio,
        profileImageUrl: profileImageUrl,
        metadata: metadata,
      );
      
      state = state.copyWith(
        profile: updatedProfile,
        isLoading: false,
      );
      
      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      return false;
    }
  }

  // Upload profile image
  Future<String?> uploadProfileImage(List<int> imageBytes, String fileName) async {
    try {
      return await ProfileService.uploadProfileImage(imageBytes, fileName);
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return null;
    }
  }

  // Clear error
  void clearError() {
    state = state.copyWith(error: null);
  }

  // Refresh all profile data
  Future<void> refresh() async {
    await Future.wait([
      loadProfile(fromCache: false),
      loadStats(),
      loadActivity(),
      loadAchievements(),
    ]);
  }

  // Refresh profile (alias for compatibility)
  Future<void> refreshProfile() async {
    await loadProfile(fromCache: false);
  }
}

// Providers
final profileProvider = StateNotifierProvider<ProfileNotifier, ProfileState>((ref) {
  return ProfileNotifier();
});

// Convenient getters
final profileDataProvider = Provider<Map<String, dynamic>?>((ref) {
  return ref.watch(profileProvider).profile;
});

final profileStatsProvider = Provider<Map<String, dynamic>?>((ref) {
  return ref.watch(profileProvider).stats;
});

final profileActivityProvider = Provider<List<Map<String, dynamic>>>((ref) {
  return ref.watch(profileProvider).activity;
});

final profileAchievementsProvider = Provider<List<Map<String, dynamic>>>((ref) {
  return ref.watch(profileProvider).achievements;
});

final profileAchievementStatsProvider = Provider<Map<String, dynamic>?>((ref) {
  return ref.watch(profileProvider).achievementStats;
});

final isProfileLoadingProvider = Provider<bool>((ref) {
  return ref.watch(profileProvider).isLoading;
});

final profileLoadingProvider = Provider<bool>((ref) {
  return ref.watch(profileProvider).isLoading;
});

final profileErrorProvider = Provider<String?>((ref) {
  return ref.watch(profileProvider).error;
});

// FutureProvider for initial profile load
final profileInitProvider = FutureProvider<Map<String, dynamic>?>((ref) async {
  return await ProfileService.getCurrentUserProfile();
}); 