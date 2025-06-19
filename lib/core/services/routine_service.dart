import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';
import '../../data/models/routine.dart';
import 'cache_service.dart';
import '../constants/supabase_config.dart';

class RoutineService {
  static final _supabase = Supabase.instance.client;
  static const _uuid = Uuid();

  // Get all user routines
  static Future<List<CreatedRoutine>> getUserRoutines({bool fromCache = true, bool includeArchived = false}) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) throw Exception('No authenticated user');

      print('📝 Fetching routines for user: ${user.id}');

      // Try cache first if requested
      if (fromCache) {
        final cachedRoutines = CacheService.getRoutines();
        if (cachedRoutines.isNotEmpty) {
          print('✅ Found ${cachedRoutines.length} cached routines');
          try {
            // Ensure cached data is properly typed with better error handling
            final typedCachedRoutines = cachedRoutines.map((data) {
              if (data is Map<String, dynamic>) {
                return _ensureProperTypes(data);
              } else if (data is Map) {
                return _ensureProperTypes(Map<String, dynamic>.from(data));
              } else {
                throw Exception('Invalid cached routine data type: ${data.runtimeType}');
              }
            }).toList();
            return typedCachedRoutines.map((data) => _mapToCreatedRoutine(data)).toList();
          } catch (e) {
            print('❌ Error processing cached routines: $e. Clearing cache and fetching from server.');
            await _clearRoutineCache();
            // Continue to fetch from server
          }
        }
      }

      // Fetch from Supabase
      var query = _supabase
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
          .eq('user_id', user.id);
      
      // Only filter by is_active if not including archived
      if (!includeArchived) {
        query = query.eq('is_active', true);
      }
      
      final response = await query.order('created_at', ascending: false);

      // Convert LinkedMap to Map<String, dynamic> properly with better type handling
      final routineData = response.map((item) {
        Map<String, dynamic> processedItem;
        if (item is Map<String, dynamic>) {
          processedItem = item;
        } else if (item is Map) {
          processedItem = Map<String, dynamic>.from(item);
        } else {
          throw Exception('Unexpected data type from Supabase: ${item.runtimeType}');
        }
        return _ensureProperTypes(processedItem);
      }).toList();

      final routines = routineData.map((data) => _mapToCreatedRoutine(data)).toList();

      // Cache the routines
      await CacheService.saveRoutines(routineData);
      
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
    bool? isPinned,
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
        'is_pinned': isPinned ?? false,
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
        isPinned: isPinned ?? false,
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
    bool? isPinned,
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
      if (isPinned != null) updateData['is_pinned'] = isPinned;

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

  // Get today's scheduled routines (including pinned routines)
  static Future<List<CreatedRoutine>> getTodayRoutines() async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) throw Exception('No authenticated user');

      print('📅 Fetching today\'s routines');

      final today = DateTime.now();
      final weekday = today.weekday - 1; // Convert to 0-based index

      // Try the complex query first, fallback to simpler queries if it fails
      List<dynamic> response;
      try {
        // Get routines that are either scheduled for today OR pinned
        response = await _supabase
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
            .or('days_of_week.cs.{$weekday},is_pinned.eq.true')
            .order('is_pinned', ascending: false)
            .order('reminder_time');
      } catch (e) {
        print('⚠️ Complex query failed, trying fallback: $e');
        
        // Fallback: Get all active routines and filter client-side
        response = await _supabase
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
            .order('is_pinned', ascending: false)
            .order('reminder_time');
      }

      // Convert LinkedMap to Map<String, dynamic> properly with better type handling
      final routineData = response.map((item) {
        Map<String, dynamic> processedItem;
        if (item is Map<String, dynamic>) {
          processedItem = item;
        } else if (item is Map) {
          processedItem = Map<String, dynamic>.from(item);
        } else {
          throw Exception('Unexpected data type from Supabase: ${item.runtimeType}');
        }
        return _ensureProperTypes(processedItem);
      }).toList();

      var routines = routineData.map((data) => _mapToCreatedRoutine(data)).toList();
      
      // If we used the fallback query, filter client-side
      if (response.length > 0) {
        routines = routines.where((routine) {
          // Include if pinned
          if (routine.isPinned) return true;
          
          // Include if scheduled for today
          final todayWeekday = Weekday.values[weekday];
          return routine.repeatDays.contains(todayWeekday);
        }).toList();
      }
      
      print('✅ Found ${routines.length} routines for today (including pinned)');
      return routines;
    } catch (e) {
      print('❌ Error fetching today\'s routines: $e');
      // Return empty list but don't crash the app
      return [];
    }
  }

  // Get only pinned routines
  static Future<List<CreatedRoutine>> getPinnedRoutines() async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) throw Exception('No authenticated user');

      print('📌 Fetching pinned routines');

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
          .eq('is_pinned', true)
          .order('reminder_time');

      // Convert LinkedMap to Map<String, dynamic> properly with better type handling
      final routineData = response.map((item) {
        Map<String, dynamic> processedItem;
        if (item is Map<String, dynamic>) {
          processedItem = item;
        } else if (item is Map) {
          processedItem = Map<String, dynamic>.from(item);
        } else {
          throw Exception('Unexpected data type from Supabase: ${item.runtimeType}');
        }
        return _ensureProperTypes(processedItem);
      }).toList();

      final routines = routineData.map((data) => _mapToCreatedRoutine(data)).toList();
      
      print('✅ Found ${routines.length} pinned routines');
      return routines;
    } catch (e) {
      print('❌ Error fetching pinned routines: $e');
      return [];
    }
  }

  // Toggle routine pin status
  static Future<bool> toggleRoutinePin(String routineId) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) throw Exception('No authenticated user');

      print('📌 Toggling pin status for routine: $routineId');

      // First get the current pin status
      final currentRoutine = await _supabase
          .from('routines')
          .select('is_pinned')
          .eq('id', routineId)
          .eq('user_id', user.id)
          .single();

      final currentPinStatus = currentRoutine['is_pinned'] as bool? ?? false;
      final newPinStatus = !currentPinStatus;

      // Update the pin status
      await _supabase
          .from('routines')
          .update({
            'is_pinned': newPinStatus,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', routineId)
          .eq('user_id', user.id);

      // Clear cache to force refresh
      await _clearRoutineCache();
      
      print('✅ Routine pin status updated: $routineId -> $newPinStatus');
      return true;
    } catch (e) {
      print('❌ Error toggling routine pin: $e');
      return false;
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

  // Helper method to ensure proper types for all nested data
  static Map<String, dynamic> _ensureProperTypes(Map<String, dynamic> data) {
    final result = Map<String, dynamic>.from(data);
    
    // Handle subtasks specifically
    if (result['subtasks'] != null) {
      final subtasks = result['subtasks'];
      if (subtasks is List) {
        result['subtasks'] = subtasks.map((subtask) {
          if (subtask is Map<String, dynamic>) {
            return subtask;
          } else if (subtask is Map) {
            return Map<String, dynamic>.from(subtask);
          } else {
            throw Exception('Invalid subtask data type: ${subtask.runtimeType}');
          }
        }).toList();
      }
    }
    
    // Handle days_of_week
    if (result['days_of_week'] != null) {
      final daysOfWeek = result['days_of_week'];
      if (daysOfWeek is List) {
        result['days_of_week'] = List<int>.from(daysOfWeek);
      }
    }
    
    return result;
  }

  // Helper method to map database data to CreatedRoutine
  static CreatedRoutine _mapToCreatedRoutine(Map<String, dynamic> data) {
    try {
      final subtasks = (data['subtasks'] as List?)
          ?.map((s) {
            // Ensure s is a Map<String, dynamic>
            final subtaskMap = s is Map<String, dynamic> ? s : Map<String, dynamic>.from(s as Map);
            return Subtask(
              id: subtaskMap['id']?.toString() ?? '',
              name: subtaskMap['title']?.toString() ?? '',
              durationMinutes: subtaskMap['estimated_duration'] as int? ?? 5,
              requiresPhotoProof: false, // This field doesn't exist in the database
              order: subtaskMap['order_index'] as int? ?? 0,
            );
          })
          .toList() ?? [];

      // Sort subtasks by order
      subtasks.sort((a, b) => a.order.compareTo(b.order));

      final repeatDayIndices = List<int>.from(data['days_of_week'] ?? []);
      final repeatDays = repeatDayIndices.map((index) => 
        index >= 0 && index < Weekday.values.length ? Weekday.values[index] : Weekday.monday
      ).toList();

      return CreatedRoutine(
        id: data['id']?.toString() ?? '',
        name: data['title']?.toString() ?? '',
        emoji: data['emoji']?.toString() ?? '📝',
        category: _denormalizeCategory(data['category']?.toString() ?? 'habit'),
        time: data['reminder_time']?.toString() ?? '',
        repeatDays: repeatDays,
        subtasks: subtasks,
        createdAt: data['created_at'] != null ? DateTime.parse(data['created_at']) : DateTime.now(),
        startDate: null, // This field doesn't exist in the database
        isActive: data['is_active'] as bool? ?? true,
        isPinned: data['is_pinned'] as bool? ?? false,
      );
    } catch (e) {
      print('❌ Error mapping routine data: $e');
      print('Data: $data');
      throw Exception('Failed to map routine data: $e');
    }
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
    // Map to allowed categories: 'personal', 'work', 'health', 'learning', 'habit'
    switch (category.toLowerCase()) {
      case 'self care':
      case 'wellness':
      case 'mindfulness':
        return 'personal';
      case 'fitness':
        return 'health';
      case 'productivity':
        return 'work';
      case 'learning':
        return 'learning';
      default:
        return 'habit'; // Default to habit for any other category
    }
  }

  // Helper method to denormalize category for display
  static String _denormalizeCategory(String category) {
    switch (category.toLowerCase()) {
      case 'personal':
        return 'Self Care';
      case 'health':
        return 'Fitness';
      case 'work':
        return 'Productivity';
      case 'learning':
        return 'Learning';
      case 'habit':
        return 'Habit';
      default:
        // Capitalize first letter
        return category.isEmpty ? 'General' : 
          category[0].toUpperCase() + category.substring(1);
    }
  }


} 