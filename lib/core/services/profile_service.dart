import 'dart:typed_data';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';
import 'cache_service.dart';
import '../constants/supabase_config.dart';

class ProfileService {
  static final _supabase = Supabase.instance.client;
  static const _uuid = Uuid();

  // Get current user profile
  static Future<Map<String, dynamic>?> getCurrentUserProfile() async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) return null;

      print('📱 Fetching profile for user: ${user.id}');

      // Try cache first
      final cachedProfile = CacheService.getUserProfile();
      if (cachedProfile != null) {
        print('✅ Found cached profile');
        return cachedProfile;
      }

      // Fetch from Supabase
      final response = await _supabase
          .from('user_profiles')
          .select('*')
          .eq('id', user.id)
          .maybeSingle();

      if (response != null) {
        // Cache the profile
        await CacheService.saveUserProfile(response);
        print('✅ Profile fetched and cached');
        return response;
      }

      print('❌ No profile found');
      return null;
    } catch (e) {
      print('❌ Error fetching profile: $e');
      throw Exception('Failed to fetch profile: $e');
    }
  }

  // Update user profile
  static Future<Map<String, dynamic>?> updateUserProfile({
    String? username,
    String? displayName,
    String? bio,
    String? profileImageUrl,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) throw Exception('No authenticated user');

      print('📝 Updating profile for user: ${user.id}');

      final updateData = <String, dynamic>{
        'updated_at': DateTime.now().toIso8601String(),
      };

      if (username != null) updateData['username'] = username;
      if (displayName != null) updateData['display_name'] = displayName;
      if (bio != null) updateData['bio'] = bio;
      if (profileImageUrl != null) updateData['profile_image_url'] = profileImageUrl;
      if (metadata != null) updateData['metadata'] = metadata;

      final response = await _supabase
          .from('user_profiles')
          .update(updateData)
          .eq('id', user.id)
          .select()
          .single();

      // Update cache
      await CacheService.saveUserProfile(response);
      print('✅ Profile updated and cached');

      return response;
    } catch (e) {
      print('❌ Error updating profile: $e');
      throw Exception('Failed to update profile: $e');
    }
  }

  // Get user stats
  static Future<Map<String, dynamic>> getUserStats() async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) throw Exception('No authenticated user');

      print('📊 Fetching user stats for: ${user.id}');

      // Get routine stats
      final routineStats = await _supabase.rpc('get_user_dashboard_data', 
        params: {'user_id_param': user.id}
      );

      // Get buddy count
      final buddyCountResponse = await _supabase
          .from('buddies')
          .select('id')
          .eq('user_id', user.id)
          .count();

      // Get current streak from routine_completions
      final streakData = await _supabase.rpc('calculate_routine_streak',
        params: {'user_id_param': user.id}
      );

      final stats = {
        'total_routines': routineStats['total_routines'] ?? 0,
        'completed_sessions': routineStats['completed_sessions'] ?? 0,
        'current_streak': streakData ?? 0,
        'longest_streak': routineStats['longest_streak'] ?? 0,
        'total_minutes': routineStats['total_minutes'] ?? 0,
        'buddies_count': buddyCountResponse.count ?? 0,
        'last_updated': DateTime.now().toIso8601String(),
      };

      print('✅ User stats fetched: $stats');
      return stats;
    } catch (e) {
      print('❌ Error fetching user stats: $e');
      // Return default stats on error
      return {
        'total_routines': 0,
        'completed_sessions': 0,
        'current_streak': 0,
        'longest_streak': 0,
        'total_minutes': 0,
        'buddies_count': 0,
        'last_updated': DateTime.now().toIso8601String(),
      };
    }
  }

  // Upload profile image
  static Future<String?> uploadProfileImage(List<int> imageBytes, String fileName) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) throw Exception('No authenticated user');

      print('🖼️ Uploading profile image: $fileName');

      final filePath = 'profiles/${user.id}/$fileName';
      
      await _supabase.storage
          .from('avatars')
          .uploadBinary(filePath, Uint8List.fromList(imageBytes));

      final url = _supabase.storage
          .from('avatars')
          .getPublicUrl(filePath);

      print('✅ Profile image uploaded: $url');
      return url;
    } catch (e) {
      print('❌ Error uploading profile image: $e');
      throw Exception('Failed to upload profile image: $e');
    }
  }

  // Delete profile image
  static Future<void> deleteProfileImage(String imagePath) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) throw Exception('No authenticated user');

      print('🗑️ Deleting profile image: $imagePath');

      await _supabase.storage
          .from('avatars')
          .remove([imagePath]);

      print('✅ Profile image deleted');
    } catch (e) {
      print('❌ Error deleting profile image: $e');
      throw Exception('Failed to delete profile image: $e');
    }
  }

  // Get user activity history
  static Future<List<Map<String, dynamic>>> getUserActivity({int limit = 50}) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) throw Exception('No authenticated user');

      print('📈 Fetching user activity for: ${user.id}');

      final response = await _supabase
          .from('routine_completions')
          .select('''
            id,
            completed_at,
            mood_rating,
            satisfaction_rating,
            notes,
            routines!inner(
              name,
              emoji,
              category
            )
          ''')
          .eq('user_id', user.id)
          .order('completed_at', ascending: false)
          .limit(limit);

      print('✅ User activity fetched: ${response.length} records');
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print('❌ Error fetching user activity: $e');
      return [];
    }
  }

  // Clear profile cache
  static Future<void> clearProfileCache() async {
    try {
      await CacheService.clearUserData();
      print('✅ Profile cache cleared');
    } catch (e) {
      print('❌ Error clearing profile cache: $e');
    }
  }
} 