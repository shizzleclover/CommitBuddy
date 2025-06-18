import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';
import '../../data/models/routine.dart';
import 'cache_service.dart';
import '../constants/supabase_config.dart';

class RoutineService {
  static final _supabase = Supabase.instance.client;
  static const _uuid = Uuid();

  // Get all user routines
  static Future<List<CreatedRoutine>> getUserRoutines({bool fromCache = true}) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) throw Exception('No authenticated user');

      print('📝 Fetching routines for user: ${user.id}');

      // Try cache first if requested
      if (fromCache) {
        final cachedRoutines = CacheService.getRoutines();
        if (cachedRoutines.isNotEmpty) {
          print('✅ Found ${cachedRoutines.length} cached routines');
          return cachedRoutines.map((data) => _mapToCreatedRoutine(data)).toList();
        }
      }

      // Fetch from Supabase
      final response = await _supabase
          .from('routines')
          .select('''
            *,
            subtasks(
              id,
              title,
              estimated_duration,
              order_index,
              is_required
            )
          ''')
          .eq('user_id', user.id)
          .eq('is_active', true)
          .order('created_at', ascending: false);

      final routines = response.map((data) => _mapToCreatedRoutine(data)).toList();

      // Cache the routines
      await CacheService.saveRoutines(response.map((e) => Map<String, dynamic>.from(e)).toList());
      
      print('✅ Fetched ${routines.length} routines from Supabase');
      return routines;
    } catch (e) {
      print('❌ Error fetching routines: $e');
      throw Exception('Failed to fetch routines: $e');
    }
  }

  // Create a new routine
  static Future<CreatedRoutine> createRoutine({
    required String name,
    required String emoji,
    required String category,
    required String time,
    required List<Weekday> repeatDays,
    required List<Subtask> subtasks,
    DateTime? startDate,
  }) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) throw Exception('No authenticated user');

      print('✨ Creating routine: $name');

      final routineId = _uuid.v4();
      final now = DateTime.now();

      // Create routine
      final routineData = {
        'id': routineId,
        'user_id': user.id,
        'title': name,
        'emoji': emoji,
        'category': _normalizeCategory(category),
        'reminder_time': time,
        'days_of_week': repeatDays.map((d) => d.index).toList(),
        'is_active': true,
        'created_at': now.toIso8601String(),
        'updated_at': now.toIso8601String(),
      };

      await _supabase.from('routines').insert(routineData);

      // Create subtasks
      final subtaskData = subtasks.asMap().entries.map((entry) {
        return {
          'id': _uuid.v4(),
          'routine_id': routineId,
          'title': entry.value.name,
          'estimated_duration': entry.value.durationMinutes,
          'order_index': entry.key,
          'is_required': true,
          'created_at': now.toIso8601String(),
        };
      }).toList();

      await _supabase.from('subtasks').insert(subtaskData);

      final createdRoutine = CreatedRoutine(
        id: routineId,
        name: name,
        emoji: emoji,
        category: category,
        time: time,
        repeatDays: repeatDays,
        subtasks: subtasks,
        createdAt: now,
        startDate: startDate,
      );

      // Clear cache to force refresh
      await _clearRoutineCache();
      
      print('✅ Routine created successfully: $routineId');
      return createdRoutine;
    } catch (e) {
      print('❌ Error creating routine: $e');
      throw Exception('Failed to create routine: $e');
    }
  }

  // Update existing routine
  static Future<CreatedRoutine> updateRoutine({
    required String routineId,
    String? name,
    String? emoji,
    String? category,
    String? time,
    List<Weekday>? repeatDays,
    List<Subtask>? subtasks,
    DateTime? startDate,
    bool? isActive,
  }) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) throw Exception('No authenticated user');

      print('📝 Updating routine: $routineId');

      final updateData = <String, dynamic>{
        'updated_at': DateTime.now().toIso8601String(),
      };

      if (name != null) updateData['title'] = name;
      if (emoji != null) updateData['emoji'] = emoji;
      if (category != null) updateData['category'] = _normalizeCategory(category);
      if (time != null) updateData['reminder_time'] = time;
      if (repeatDays != null) updateData['days_of_week'] = repeatDays.map((d) => d.index).toList();
      if (isActive != null) updateData['is_active'] = isActive;

      await _supabase
          .from('routines')
          .update(updateData)
          .eq('id', routineId)
          .eq('user_id', user.id);

      // Update subtasks if provided
      if (subtasks != null) {
        // Delete existing subtasks
        await _supabase
            .from('subtasks')
            .delete()
            .eq('routine_id', routineId);

        // Create new subtasks
        final subtaskData = subtasks.asMap().entries.map((entry) {
          return {
            'id': _uuid.v4(),
            'routine_id': routineId,
            'title': entry.value.name,
            'estimated_duration': entry.value.durationMinutes,
            'order_index': entry.key,
            'is_required': true,
            'created_at': DateTime.now().toIso8601String(),
          };
        }).toList();

        await _supabase.from('subtasks').insert(subtaskData);
      }

      // Clear cache to force refresh
      await _clearRoutineCache();

      // Return updated routine
      final routines = await getUserRoutines(fromCache: false);
      final updatedRoutine = routines.firstWhere((r) => r.id == routineId);
      
      print('✅ Routine updated successfully');
      return updatedRoutine;
    } catch (e) {
      print('❌ Error updating routine: $e');
      throw Exception('Failed to update routine: $e');
    }
  }

  // Delete routine
  static Future<void> deleteRoutine(String routineId) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) throw Exception('No authenticated user');

      print('🗑️ Deleting routine: $routineId');

      // Soft delete by setting is_active to false
      await _supabase
          .from('routines')
          .update({
            'is_active': false,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', routineId)
          .eq('user_id', user.id);

      // Clear cache to force refresh
      await _clearRoutineCache();
      
      print('✅ Routine deleted successfully');
    } catch (e) {
      print('❌ Error deleting routine: $e');
      throw Exception('Failed to delete routine: $e');
    }
  }

  // Update routine status (active/inactive)
  static Future<bool> updateRoutineStatus({
    required String routineId,
    required bool isActive,
  }) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) throw Exception('No authenticated user');

      print('🔄 Updating routine status: $routineId -> $isActive');

      await _supabase
          .from('routines')
          .update({
            'is_active': isActive,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', routineId)
          .eq('user_id', user.id);

      // Clear cache to force refresh
      await _clearRoutineCache();
      
      print('✅ Routine status updated successfully');
      return true;
    } catch (e) {
      print('❌ Error updating routine status: $e');
      return false;
    }
  }

  // Complete routine
  static Future<void> completeRoutine({
    required String routineId,
    required List<String> completedSubtasks,
    int? moodRating,
    int? satisfactionRating,
    String? notes,
  }) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) throw Exception('No authenticated user');

      print('✅ Completing routine: $routineId');

      final completionId = _uuid.v4();
      final now = DateTime.now();

      // Create routine completion record
      final completionData = {
        'id': completionId,
        'user_id': user.id,
        'routine_id': routineId,
        'completed_at': now.toIso8601String(),
        'completed_subtasks': completedSubtasks,
        'mood_rating': moodRating,
        'satisfaction_rating': satisfactionRating,
        'notes': notes,
      };

      await _supabase.from('routine_completions').insert(completionData);
      
      print('✅ Routine completion recorded');
    } catch (e) {
      print('❌ Error completing routine: $e');
      throw Exception('Failed to complete routine: $e');
    }
  }

  // Get routine analytics
  static Future<Map<String, dynamic>> getRoutineAnalytics(String routineId, {int days = 30}) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) throw Exception('No authenticated user');

      print('📊 Fetching analytics for routine: $routineId');

      final analytics = await _supabase.rpc('get_routine_analytics', params: {
        'routine_id_param': routineId,
        'user_id_param': user.id,
        'days_param': days,
      });

      print('✅ Analytics fetched');
      return Map<String, dynamic>.from(analytics);
    } catch (e) {
      print('❌ Error fetching analytics: $e');
      return {};
    }
  }

  // Get today's scheduled routines
  static Future<List<CreatedRoutine>> getTodayRoutines() async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) throw Exception('No authenticated user');

      print('📅 Fetching today\'s routines');

      final today = DateTime.now();
      final weekday = today.weekday - 1; // Convert to 0-based index

      final response = await _supabase
          .from('routines')
          .select('''
            *,
            subtasks(
              id,
              title,
              estimated_duration,
              order_index,
              is_required
            )
          ''')
          .eq('user_id', user.id)
          .eq('is_active', true)
          .contains('days_of_week', [weekday])
          .order('reminder_time');

      final routines = response.map((data) => _mapToCreatedRoutine(data)).toList();
      
      print('✅ Found ${routines.length} routines for today');
      return routines;
    } catch (e) {
      print('❌ Error fetching today\'s routines: $e');
      return [];
    }
  }

  // Get routine completion history
  static Future<List<Map<String, dynamic>>> getCompletionHistory(String routineId, {int limit = 30}) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) throw Exception('No authenticated user');

      print('📈 Fetching completion history for routine: $routineId');

      final response = await _supabase
          .from('routine_completions')
          .select('*')
          .eq('user_id', user.id)
          .eq('routine_id', routineId)
          .order('completed_at', ascending: false)
          .limit(limit);

      print('✅ Found ${response.length} completion records');
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print('❌ Error fetching completion history: $e');
      return [];
    }
  }

  // Helper method to map database data to CreatedRoutine
  static CreatedRoutine _mapToCreatedRoutine(Map<String, dynamic> data) {
    final subtasks = (data['subtasks'] as List?)
        ?.map((s) => Subtask(
              id: s['id'],
              name: s['title'],
              durationMinutes: s['estimated_duration'] ?? 5,
              requiresPhotoProof: false, // This field doesn't exist in the database
              order: s['order_index'] ?? 0,
            ))
        .toList() ?? [];

    // Sort subtasks by order
    subtasks.sort((a, b) => a.order.compareTo(b.order));

    final repeatDayIndices = List<int>.from(data['days_of_week'] ?? []);
    final repeatDays = repeatDayIndices.map((index) => Weekday.values[index]).toList();

    return CreatedRoutine(
      id: data['id'],
      name: data['title'],
      emoji: data['emoji'],
      category: _denormalizeCategory(data['category']),
      time: data['reminder_time']?.toString() ?? '',
      repeatDays: repeatDays,
      subtasks: subtasks,
      createdAt: DateTime.parse(data['created_at']),
      startDate: null, // This field doesn't exist in the database
      isActive: data['is_active'] ?? true,
    );
  }

  // Clear routine cache
  static Future<void> _clearRoutineCache() async {
    try {
      final userData = CacheService.getUserProfile();
      if (userData != null) {
        // Clear only the routines data, keep other user data
        await CacheService.saveRoutines([]);
      }
      print('✅ Routine cache cleared');
    } catch (e) {
      print('❌ Error clearing routine cache: $e');
    }
  }

  // Helper method to normalize category for database
  static String _normalizeCategory(String category) {
    // Convert categories to match database constraints
    switch (category.toLowerCase()) {
      case 'self care':
        return 'selfcare';
      case 'wellness':
        return 'wellness';
      case 'fitness':
        return 'fitness';
      case 'productivity':
        return 'productivity';
      case 'learning':
        return 'learning';
      case 'mindfulness':
        return 'mindfulness';
      default:
        return category.toLowerCase().replaceAll(' ', '');
    }
  }

  // Helper method to denormalize category for display
  static String _denormalizeCategory(String category) {
    switch (category.toLowerCase()) {
      case 'selfcare':
        return 'Self Care';
      case 'wellness':
        return 'Wellness';
      case 'fitness':
        return 'Fitness';
      case 'productivity':
        return 'Productivity';
      case 'learning':
        return 'Learning';
      case 'mindfulness':
        return 'Mindfulness';
      default:
        return category;
    }
  }
} 