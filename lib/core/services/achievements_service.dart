import 'package:supabase_flutter/supabase_flutter.dart';
import '../constants/supabase_config.dart';

class AchievementsService {
  static final _supabase = Supabase.instance.client;

  // Get user achievements
  static Future<List<Map<String, dynamic>>> getUserAchievements() async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) throw Exception('No authenticated user');

      print('🏆 Fetching achievements for user: ${user.id}');

      final response = await _supabase
          .from('achievements')
          .select('*')
          .eq('user_id', user.id)
          .order('created_at', ascending: true);

      print('✅ Found ${response.length} achievements');
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print('❌ Error fetching achievements: $e');
      return [];
    }
  }

  // Get user activity log
  static Future<List<Map<String, dynamic>>> getUserActivity({int limit = 20}) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) throw Exception('No authenticated user');

      print('📊 Fetching activity for user: ${user.id}');

      final response = await _supabase
          .from('activity_log')
          .select('*')
          .eq('user_id', user.id)
          .order('created_at', ascending: false)
          .limit(limit);

      print('✅ Found ${response.length} activity items');
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print('❌ Error fetching activity: $e');
      return [];
    }
  }

  // Manual achievement check (for when achievements might be out of sync)
  static Future<void> checkAchievements() async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) throw Exception('No authenticated user');

      print('🔄 Checking achievements for user: ${user.id}');

      await _supabase.rpc('check_and_award_achievements', params: {
        'user_id_param': user.id,
      });

      print('✅ Achievement check completed');
    } catch (e) {
      print('❌ Error checking achievements: $e');
    }
  }

  // Log custom activity
  static Future<void> logActivity({
    required String type,
    required String title,
    String? description,
    String? icon,
    String? color,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) throw Exception('No authenticated user');

      print('📝 Logging activity: $title');

      await _supabase.rpc('log_user_activity', params: {
        'user_id_param': user.id,
        'activity_type_param': type,
        'title_param': title,
        'description_param': description,
        'icon_param': icon ?? '📝',
        'color_param': color ?? '#3B82F6',
        'metadata_param': metadata ?? {},
      });

      print('✅ Activity logged successfully');
    } catch (e) {
      print('❌ Error logging activity: $e');
    }
  }

  // Get achievement stats
  static Future<Map<String, dynamic>> getAchievementStats() async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) throw Exception('No authenticated user');

      print('📈 Fetching achievement stats for user: ${user.id}');

      final response = await _supabase
          .from('achievements')
          .select('is_earned')
          .eq('user_id', user.id);

      final total = response.length;
      final earned = response.where((a) => a['is_earned'] == true).length;

      print('✅ Achievement stats: $earned/$total');
      
      return {
        'total_achievements': total,
        'earned_achievements': earned,
        'completion_percentage': total > 0 ? (earned / total * 100).round() : 0,
      };
    } catch (e) {
      print('❌ Error fetching achievement stats: $e');
      return {
        'total_achievements': 0,
        'earned_achievements': 0,
        'completion_percentage': 0,
      };
    }
  }

  // Format time ago for activity items
  static String formatTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 0) {
      return '${difference.inDays} day${difference.inDays == 1 ? '' : 's'} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hour${difference.inHours == 1 ? '' : 's'} ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minute${difference.inMinutes == 1 ? '' : 's'} ago';
    } else {
      return 'Just now';
    }
  }

  // Get achievement by type
  static Future<Map<String, dynamic>?> getAchievementByType(String type) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) throw Exception('No authenticated user');

      final response = await _supabase
          .from('achievements')
          .select('*')
          .eq('user_id', user.id)
          .eq('achievement_type', type)
          .single();

      return Map<String, dynamic>.from(response);
    } catch (e) {
      print('❌ Error fetching achievement by type: $e');
      return null;
    }
  }

  // Update achievement progress manually (for specific cases)
  static Future<void> updateAchievementProgress({
    required String type,
    required int progress,
  }) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) throw Exception('No authenticated user');

      await _supabase
          .from('achievements')
          .update({
            'current_progress': progress,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('user_id', user.id)
          .eq('achievement_type', type);

      // Check if achievement should be awarded
      await checkAchievements();
    } catch (e) {
      print('❌ Error updating achievement progress: $e');
    }
  }
} 