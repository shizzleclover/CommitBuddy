import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/services/routine_service.dart';
import '../../../data/models/routine.dart';

// Routine State
class RoutineState {
  final List<CreatedRoutine> routines;
  final List<CreatedRoutine> todayRoutines;
  final bool isLoading;
  final String? error;

  const RoutineState({
    this.routines = const [],
    this.todayRoutines = const [],
    this.isLoading = false,
    this.error,
  });

  RoutineState copyWith({
    List<CreatedRoutine>? routines,
    List<CreatedRoutine>? todayRoutines,
    bool? isLoading,
    String? error,
  }) {
    return RoutineState(
      routines: routines ?? this.routines,
      todayRoutines: todayRoutines ?? this.todayRoutines,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

// Routine Notifier
class RoutineNotifier extends StateNotifier<RoutineState> {
  RoutineNotifier() : super(const RoutineState());

  // Load all user routines
  Future<void> loadRoutines({bool fromCache = true}) async {
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      final routines = await RoutineService.getUserRoutines(fromCache: fromCache);
      state = state.copyWith(
        routines: routines,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  // Load today's routines
  Future<void> loadTodayRoutines() async {
    try {
      final todayRoutines = await RoutineService.getTodayRoutines();
      state = state.copyWith(todayRoutines: todayRoutines);
    } catch (e) {
      print('Error loading today\'s routines: $e');
    }
  }

  // Create new routine
  Future<bool> createRoutine({
    required String name,
    required String emoji,
    required String category,
    required String time,
    required List<Weekday> repeatDays,
    required List<Subtask> subtasks,
    DateTime? startDate,
  }) async {
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      final newRoutine = await RoutineService.createRoutine(
        name: name,
        emoji: emoji,
        category: category,
        time: time,
        repeatDays: repeatDays,
        subtasks: subtasks,
        startDate: startDate,
      );
      
      // Add to current list
      state = state.copyWith(
        routines: [newRoutine, ...state.routines],
        isLoading: false,
      );
      
      // Refresh today's routines if needed
      await loadTodayRoutines();
      
      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      return false;
    }
  }

  // Delete routine
  Future<bool> deleteRoutine(String routineId) async {
    try {
      await RoutineService.deleteRoutine(routineId);
      
      // Remove from current list
      state = state.copyWith(
        routines: state.routines.where((r) => r.id != routineId).toList(),
        todayRoutines: state.todayRoutines.where((r) => r.id != routineId).toList(),
      );
      
      return true;
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return false;
    }
  }

  // Complete routine
  Future<bool> completeRoutine({
    required String routineId,
    required List<String> completedSubtasks,
    int? moodRating,
    int? satisfactionRating,
    String? notes,
  }) async {
    try {
      await RoutineService.completeRoutine(
        routineId: routineId,
        completedSubtasks: completedSubtasks,
        moodRating: moodRating,
        satisfactionRating: satisfactionRating,
        notes: notes,
      );
      
      return true;
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return false;
    }
  }

  // Clear error
  void clearError() {
    state = state.copyWith(error: null);
  }

  // Refresh all routine data
  Future<void> refresh() async {
    await Future.wait([
      loadRoutines(fromCache: false),
      loadTodayRoutines(),
    ]);
  }

  // Refresh routines (alias for compatibility)
  Future<void> refreshRoutines() async {
    await loadRoutines(fromCache: false);
  }

  // Refresh today's routines
  Future<void> refreshTodayRoutines() async {
    await loadTodayRoutines();
  }

  // Save/Create routine  
  Future<bool> saveRoutine({
    required String name,
    required String emoji,
    required String category,
    required TimeOfDay time,
    required List<Weekday> repeatDays,
    required List<Subtask> subtasks,
  }) async {
    try {
      final timeString = '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
      final routine = await RoutineService.createRoutine(
        name: name,
        emoji: emoji,
        category: category,
        time: timeString,
        repeatDays: repeatDays,
        subtasks: subtasks,
      );
      
      if (routine != null) {
        await loadRoutines(fromCache: false);
        return true;
      }
      
      return false;
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return false;
    }
  }

  // Update routine
  Future<bool> updateRoutine({
    required String routineId,
    required String name,
    required String emoji,
    required String category,
    required TimeOfDay time,
    required List<Weekday> repeatDays,
    required List<Subtask> subtasks,
  }) async {
    try {
      final timeString = '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
      final routine = await RoutineService.updateRoutine(
        routineId: routineId,
        name: name,
        emoji: emoji,
        category: category,
        time: timeString,
        repeatDays: repeatDays,
        subtasks: subtasks,
      );
      
      if (routine != null) {
        await loadRoutines(fromCache: false);
        return true;
      }
      
      return false;
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return false;
    }
  }

  // Duplicate routine
  Future<bool> duplicateRoutine(String routineId) async {
    try {
      final routine = getRoutineById(routineId);
      if (routine == null) return false;

      // Convert time string back to TimeOfDay for the method call
      final timeParts = routine.time.split(':');
      final timeOfDay = TimeOfDay(
        hour: int.parse(timeParts[0]), 
        minute: int.parse(timeParts[1])
      );

      // Create a copy with modified name
      final success = await saveRoutine(
        name: '${routine.name} (Copy)',
        emoji: routine.emoji,
        category: routine.category,
        time: timeOfDay,
        repeatDays: routine.repeatDays,
        subtasks: routine.subtasks,
      );
      
      return success;
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return false;
    }
  }

  // Toggle routine active status
  Future<bool> toggleRoutineActive(String routineId) async {
    try {
      final routine = getRoutineById(routineId);
      if (routine == null) return false;

      final success = await RoutineService.updateRoutineStatus(
        routineId: routineId,
        isActive: !routine.isActive,
      );
      
      if (success) {
        await loadRoutines(fromCache: false);
      }
      
      return success;
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return false;
    }
  }

  // Get routine by ID
  CreatedRoutine? getRoutineById(String id) {
    try {
      return state.routines.firstWhere((r) => r.id == id);
    } catch (e) {
      return null;
    }
  }

  // Get routines by category
  List<CreatedRoutine> getRoutinesByCategory(String category) {
    return state.routines.where((r) => r.category == category).toList();
  }

  // Get active routines (for today)
  List<CreatedRoutine> getActiveRoutines() {
    final today = DateTime.now();
    final weekday = Weekday.values[today.weekday - 1];
    
    return state.routines.where((r) => r.repeatDays.contains(weekday)).toList();
  }
}

// Individual Routine Analytics State
class RoutineAnalyticsState {
  final Map<String, dynamic> analytics;
  final List<Map<String, dynamic>> completionHistory;
  final bool isLoading;
  final String? error;

  const RoutineAnalyticsState({
    this.analytics = const {},
    this.completionHistory = const [],
    this.isLoading = false,
    this.error,
  });

  RoutineAnalyticsState copyWith({
    Map<String, dynamic>? analytics,
    List<Map<String, dynamic>>? completionHistory,
    bool? isLoading,
    String? error,
  }) {
    return RoutineAnalyticsState(
      analytics: analytics ?? this.analytics,
      completionHistory: completionHistory ?? this.completionHistory,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

// Routine Analytics Notifier
class RoutineAnalyticsNotifier extends StateNotifier<RoutineAnalyticsState> {
  RoutineAnalyticsNotifier() : super(const RoutineAnalyticsState());

  // Load routine analytics
  Future<void> loadAnalytics(String routineId, {int days = 30}) async {
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      final analytics = await RoutineService.getRoutineAnalytics(routineId, days: days);
      state = state.copyWith(
        analytics: analytics,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  // Load completion history
  Future<void> loadCompletionHistory(String routineId, {int limit = 30}) async {
    try {
      final history = await RoutineService.getCompletionHistory(routineId, limit: limit);
      state = state.copyWith(completionHistory: history);
    } catch (e) {
      print('Error loading completion history: $e');
    }
  }

  // Clear error
  void clearError() {
    state = state.copyWith(error: null);
  }
}

// Providers
final routineProvider = StateNotifierProvider<RoutineNotifier, RoutineState>((ref) {
  return RoutineNotifier();
});

final routineAnalyticsProvider = StateNotifierProvider<RoutineAnalyticsNotifier, RoutineAnalyticsState>((ref) {
  return RoutineAnalyticsNotifier();
});

// Convenient getters
final allRoutinesProvider = Provider<List<CreatedRoutine>>((ref) {
  return ref.watch(routineProvider).routines;
});

final todayRoutinesProvider = Provider<List<CreatedRoutine>>((ref) {
  return ref.watch(routineProvider).todayRoutines;
});

final routineLoadingProvider = Provider<bool>((ref) {
  return ref.watch(routineProvider).isLoading;
});

final routineErrorProvider = Provider<String?>((ref) {
  return ref.watch(routineProvider).error;
});

// FutureProvider for initial routine load
final routineInitProvider = FutureProvider<List<CreatedRoutine>>((ref) async {
  return await RoutineService.getUserRoutines();
});

// Provider for routine categories
final routineCategoriesProvider = Provider<List<String>>((ref) {
  final routines = ref.watch(allRoutinesProvider);
  final categories = routines.map((r) => r.category).toSet().toList();
  return categories;
});

// Provider for routine stats
final routineStatsProvider = Provider<Map<String, int>>((ref) {
  final routines = ref.watch(allRoutinesProvider);
  final today = DateTime.now();
  final weekday = Weekday.values[today.weekday - 1];
  
  return {
    'total': routines.length,
    'active': routines.where((r) => r.isActive).length,
    'today': routines.where((r) => r.repeatDays.contains(weekday)).length,
    'categories': routines.map((r) => r.category).toSet().length,
  };
}); 