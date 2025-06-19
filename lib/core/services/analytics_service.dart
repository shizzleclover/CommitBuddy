import 'package:supabase_flutter/supabase_flutter.dart';

class AnalyticsService {
  static final SupabaseClient _supabase = Supabase.instance.client;

  // Get user dashboard analytics
  static Future<Map<String, dynamic>> getUserDashboardData() async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) throw Exception('User not authenticated');

      print('📊 Fetching dashboard data for user: ${user.id}');

      final response = await _supabase.rpc('get_user_dashboard_data', params: {
        'user_id_param': user.id,
      });

      print('✅ Dashboard data fetched successfully');
      return _ensureMapStringDynamic(response);
    } catch (e) {
      print('❌ Error fetching dashboard data: $e');
      
      // Return fallback data based on actual database queries
      return await _getFallbackDashboardData();
    }
  }

  // Fallback dashboard data using direct queries
  static Future<Map<String, dynamic>> _getFallbackDashboardData() async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) return {};

      // Get basic stats
      final routines = await _supabase
          .from('routines')
          .select('*')
          .eq('user_id', user.id);

      final completions = await _supabase
          .from('routine_completions')
          .select('*')
          .eq('user_id', user.id);

      final todayCompletions = await _supabase
          .from('routine_completions')
          .select('*')
          .eq('user_id', user.id)
          .gte('completed_at', DateTime.now().toIso8601String().split('T')[0]);

      final userProfile = await _supabase
          .from('user_profiles')
          .select('streak_count, total_completed_routines')
          .eq('id', user.id)
          .single();

      final buddyCount = await _supabase
          .from('buddy_relationships')
          .count(CountOption.exact)
          .eq('user_id', user.id)
          .eq('status', 'active');

      return {
        'current_streak': userProfile['streak_count'] ?? 0,
        'total_routines': routines.length,
        'completed_today': todayCompletions.length,
        'total_completions': userProfile['total_completed_routines'] ?? 0,
        'active_routines': routines.where((r) => r['is_active'] == true).length,
        'buddy_count': buddyCount,
      };
    } catch (e) {
      print('❌ Error fetching fallback dashboard data: $e');
      return {
        'current_streak': 0,
        'total_routines': 0,
        'completed_today': 0,
        'total_completions': 0,
        'active_routines': 0,
        'buddy_count': 0,
      };
    }
  }

  // Get routine-specific analytics
  static Future<Map<String, dynamic>> getRoutineAnalytics(String routineId, {int days = 30}) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) throw Exception('User not authenticated');

      print('📊 Fetching analytics for routine: $routineId');

      final response = await _supabase.rpc('get_routine_analytics', params: {
        'routine_id_param': routineId,
        'user_id_param': user.id,
        'days_param': days,
      });

      print('✅ Routine analytics fetched successfully');
      return _ensureMapStringDynamic(response);
    } catch (e) {
      print('❌ Error fetching routine analytics: $e');
      return await _getFallbackRoutineAnalytics(routineId, days);
    }
  }

  // Fallback routine analytics
  static Future<Map<String, dynamic>> _getFallbackRoutineAnalytics(String routineId, int days) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) return {};

      final completions = await _supabase
          .from('routine_completions')
          .select('*')
          .eq('user_id', user.id)
          .eq('routine_id', routineId)
          .gte('completed_at', DateTime.now().subtract(Duration(days: days)).toIso8601String());

      final routine = await _supabase
          .from('routines')
          .select('streak_count, best_streak, completion_rate')
          .eq('id', routineId)
          .eq('user_id', user.id)
          .single();

      final avgDuration = completions.isNotEmpty
          ? completions
              .where((c) => c['total_duration'] != null)
              .map((c) => c['total_duration'] as int)
              .fold(0, (a, b) => a + b) / completions.length
          : 0.0;

      return {
        'total_completions': completions.length,
        'streak_count': routine['streak_count'] ?? 0,
        'best_streak': routine['best_streak'] ?? 0,
        'completion_rate': routine['completion_rate'] ?? 0.0,
        'average_duration': avgDuration.round(),
      };
    } catch (e) {
      print('❌ Error fetching fallback routine analytics: $e');
      return {};
    }
  }

  // Get weekly completion data for charts
  static Future<List<Map<String, dynamic>>> getWeeklyCompletions({int weeks = 4}) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) throw Exception('User not authenticated');

      print('📊 Fetching weekly completions for user: ${user.id}');

      final startDate = DateTime.now().subtract(Duration(days: weeks * 7));
      
      final response = await _supabase
          .from('routine_completions')
          .select('completed_at, routine_id')
          .eq('user_id', user.id)
          .gte('completed_at', startDate.toIso8601String())
          .order('completed_at');

      // Ensure proper type handling for response
      final completions = _ensureListOfMaps(response);

      // Group by week
      final Map<String, int> weeklyData = {};
      
      for (final completion in completions) {
        final date = DateTime.parse(completion['completed_at']);
        final weekStart = date.subtract(Duration(days: date.weekday - 1));
        final weekKey = '${weekStart.month}/${weekStart.day}';
        
        weeklyData[weekKey] = (weeklyData[weekKey] ?? 0) + 1;
      }

      final result = weeklyData.entries.map((entry) => {
        'week': entry.key,
        'completions': entry.value,
      }).toList();

      print('✅ Weekly completions fetched: ${result.length} weeks');
      return result;
    } catch (e) {
      print('❌ Error fetching weekly completions: $e');
      return [];
    }
  }

  // Get daily completion streak data
  static Future<List<Map<String, dynamic>>> getDailyStreakData({int days = 30}) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) throw Exception('User not authenticated');

      print('📊 Fetching daily streak data for user: ${user.id}');

      final startDate = DateTime.now().subtract(Duration(days: days));
      
      final response = await _supabase
          .from('routine_completions')
          .select('completed_at')
          .eq('user_id', user.id)
          .gte('completed_at', startDate.toIso8601String())
          .order('completed_at');

      // Ensure proper type handling for response
      final completions = _ensureListOfMaps(response);

      // Group by day
      final Map<String, bool> dailyData = {};
      
      // Initialize all days as false
      for (int i = 0; i < days; i++) {
        final date = DateTime.now().subtract(Duration(days: i));
        final dayKey = '${date.month}/${date.day}';
        dailyData[dayKey] = false;
      }

      // Mark days with completions as true
      for (final completion in completions) {
        final date = DateTime.parse(completion['completed_at']);
        final dayKey = '${date.month}/${date.day}';
        dailyData[dayKey] = true;
      }

      final result = dailyData.entries.map((entry) => {
        'day': entry.key,
        'completed': entry.value,
      }).toList();

      print('✅ Daily streak data fetched: ${result.length} days');
      return result.reversed.toList(); // Most recent first
    } catch (e) {
      print('❌ Error fetching daily streak data: $e');
      return [];
    }
  }

  // Get category breakdown
  static Future<Map<String, int>> getCategoryBreakdown() async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) throw Exception('User not authenticated');

      print('📊 Fetching category breakdown for user: ${user.id}');

      final routines = await _supabase
          .from('routines')
          .select('category')
          .eq('user_id', user.id)
          .eq('is_active', true);

      final Map<String, int> categoryCount = {};
      
      for (final routine in routines) {
        final category = routine['category'] as String;
        categoryCount[category] = (categoryCount[category] ?? 0) + 1;
      }

      print('✅ Category breakdown fetched: ${categoryCount.length} categories');
      return categoryCount;
    } catch (e) {
      print('❌ Error fetching category breakdown: $e');
      return {};
    }
  }

  // Get completion times analysis
  static Future<Map<String, dynamic>> getCompletionTimesAnalysis() async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) throw Exception('User not authenticated');

      print('📊 Fetching completion times analysis for user: ${user.id}');

      final completions = await _supabase
          .from('routine_completions')
          .select('completed_at, total_duration')
          .eq('user_id', user.id)
          .not('total_duration', 'is', null)
          .limit(100); // Last 100 completions

      if (completions.isEmpty) {
        return {
          'average_duration': 0,
          'total_time_spent': 0,
          'preferred_times': [],
        };
      }

      // Calculate average duration
      final durations = completions
          .map((c) => c['total_duration'] as int)
          .toList();
      final avgDuration = durations.fold(0, (a, b) => a + b) / durations.length;

      // Calculate total time spent
      final totalTime = durations.fold(0, (a, b) => a + b);

      // Analyze preferred completion times
      final Map<int, int> hourCount = {};
      for (final completion in completions) {
        final hour = DateTime.parse(completion['completed_at']).hour;
        hourCount[hour] = (hourCount[hour] ?? 0) + 1;
      }

      final preferredTimes = hourCount.entries
          .toList()
          ..sort((a, b) => b.value.compareTo(a.value))
          ..take(3);

      final result = {
        'average_duration': avgDuration.round(),
        'total_time_spent': totalTime,
        'preferred_times': preferredTimes.map((e) => {
          'hour': e.key,
          'count': e.value,
          'time': '${e.key.toString().padLeft(2, '0')}:00',
        }).toList(),
      };

      print('✅ Completion times analysis fetched');
      return result;
    } catch (e) {
      print('❌ Error fetching completion times analysis: $e');
      return {
        'average_duration': 0,
        'total_time_spent': 0,
        'preferred_times': [],
      };
    }
  }

  // Get mood and difficulty trends
  static Future<Map<String, dynamic>> getMoodAndDifficultyTrends({int days = 30}) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) throw Exception('User not authenticated');

      print('📊 Fetching mood and difficulty trends for user: ${user.id}');

      final startDate = DateTime.now().subtract(Duration(days: days));
      
      final completions = await _supabase
          .from('routine_completions')
          .select('completed_at, mood_rating, difficulty_rating')
          .eq('user_id', user.id)
          .gte('completed_at', startDate.toIso8601String())
          .order('completed_at');

      final moodRatings = completions
          .where((c) => c['mood_rating'] != null)
          .map((c) => c['mood_rating'] as int)
          .toList();

      final difficultyRatings = completions
          .where((c) => c['difficulty_rating'] != null)
          .map((c) => c['difficulty_rating'] as int)
          .toList();

      final avgMood = moodRatings.isNotEmpty
          ? moodRatings.fold(0, (a, b) => a + b) / moodRatings.length
          : 0.0;

      final avgDifficulty = difficultyRatings.isNotEmpty
          ? difficultyRatings.fold(0, (a, b) => a + b) / difficultyRatings.length
          : 0.0;

      final result = {
        'average_mood': avgMood,
        'average_difficulty': avgDifficulty,
        'mood_trend': _calculateTrend(moodRatings),
        'difficulty_trend': _calculateTrend(difficultyRatings),
        'total_ratings': completions.length,
      };

      print('✅ Mood and difficulty trends fetched');
      return result;
    } catch (e) {
      print('❌ Error fetching mood and difficulty trends: $e');
      return {
        'average_mood': 0.0,
        'average_difficulty': 0.0,
        'mood_trend': 'stable',
        'difficulty_trend': 'stable',
        'total_ratings': 0,
      };
    }
  }

  // Helper method to calculate trend
  static String _calculateTrend(List<int> values) {
    if (values.length < 2) return 'stable';
    
    final firstHalf = values.take(values.length ~/ 2).toList();
    final secondHalf = values.skip(values.length ~/ 2).toList();
    
    final firstAvg = firstHalf.fold(0, (a, b) => a + b) / firstHalf.length;
    final secondAvg = secondHalf.fold(0, (a, b) => a + b) / secondHalf.length;
    
    if (secondAvg > firstAvg + 0.2) return 'improving';
    if (secondAvg < firstAvg - 0.2) return 'declining';
    return 'stable';
  }

  // Get routine performance data
  static Future<List<Map<String, dynamic>>> getRoutinePerformanceData() async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) throw Exception('User not authenticated');

      print('📊 Fetching routine performance data for user: ${user.id}');

      // Get all active routines with their stats
      final routines = await _supabase
          .from('routines')
          .select('id, title, emoji, streak_count, completion_rate, best_streak')
          .eq('user_id', user.id)
          .eq('is_active', true);

      final List<Map<String, dynamic>> performanceData = [];

      for (final routine in routines) {
        // Get completion data for the last 30 days
        final completions = await _supabase
            .from('routine_completions')
            .select('completed_at')
            .eq('user_id', user.id)
            .eq('routine_id', routine['id'])
            .gte('completed_at', DateTime.now().subtract(const Duration(days: 30)).toIso8601String());

        final completionRate = routine['completion_rate'] ?? 0.0;
        final streakCount = routine['streak_count'] ?? 0;

        performanceData.add({
          'id': routine['id'],
          'name': routine['title'],
          'emoji': routine['emoji'],
          'completion': completionRate / 100.0, // Convert percentage to decimal
          'streak': streakCount,
          'recent_completions': completions.length,
        });
      }

      print('✅ Routine performance data fetched: ${performanceData.length} routines');
      return performanceData;
    } catch (e) {
      print('❌ Error fetching routine performance data: $e');
      return [];
    }
  }

  // Get heatmap data for the last 4 weeks
  static Future<List<List<int>>> getHeatmapData() async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) throw Exception('User not authenticated');

      print('📊 Fetching heatmap data for user: ${user.id}');

      final now = DateTime.now();
      final startDate = now.subtract(const Duration(days: 28)); // 4 weeks ago

      // Get all completions for the last 4 weeks
      final completions = await _supabase
          .from('routine_completions')
          .select('completed_at')
          .eq('user_id', user.id)
          .gte('completed_at', startDate.toIso8601String());

      // Create a set of completion dates
      final completionDates = <String>{};
      for (final completion in completions) {
        final date = DateTime.parse(completion['completed_at']);
        final dateKey = '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
        completionDates.add(dateKey);
      }

      // Build 4 weeks x 7 days heatmap
      final List<List<int>> heatmap = [];
      
      for (int week = 0; week < 4; week++) {
        final List<int> weekData = [];
        
        for (int day = 0; day < 7; day++) {
          final targetDate = startDate.add(Duration(days: week * 7 + day));
          final dateKey = '${targetDate.year}-${targetDate.month.toString().padLeft(2, '0')}-${targetDate.day.toString().padLeft(2, '0')}';
          
          // 1 if completed, 0 if not
          weekData.add(completionDates.contains(dateKey) ? 1 : 0);
        }
        
        heatmap.add(weekData);
      }

      print('✅ Heatmap data generated: 4 weeks');
      return heatmap;
    } catch (e) {
      print('❌ Error fetching heatmap data: $e');
      // Return empty heatmap on error
      return List.generate(4, (_) => List.generate(7, (_) => 0));
    }
  }

  // Get insights based on user data
  static Future<List<Map<String, String>>> getPersonalInsights() async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) throw Exception('User not authenticated');

      print('📊 Generating personal insights for user: ${user.id}');

      final insights = <Map<String, String>>[];

      // Get completion data for analysis
      final completions = await _supabase
          .from('routine_completions')
          .select('completed_at, routine_id')
          .eq('user_id', user.id)
          .gte('completed_at', DateTime.now().subtract(const Duration(days: 30)).toIso8601String())
          .order('completed_at');

      if (completions.isEmpty) {
        insights.add({
          'emoji': '🌱',
          'title': 'Getting Started',
          'insight': 'Start building your routine habit today!',
          'subtitle': 'Consistency is key to success',
        });
        return insights;
      }

      // Analyze completion times
      final Map<int, int> hourCounts = {};
      for (final completion in completions) {
        final hour = DateTime.parse(completion['completed_at']).hour;
        hourCounts[hour] = (hourCounts[hour] ?? 0) + 1;
      }

      // Find most productive hour
      if (hourCounts.isNotEmpty) {
        final bestHour = hourCounts.entries.reduce((a, b) => a.value > b.value ? a : b).key;
        final timeOfDay = bestHour < 12 ? 'morning' : bestHour < 17 ? 'afternoon' : 'evening';
        
        insights.add({
          'emoji': '⏰',
          'title': 'Peak Performance Time',
          'insight': 'You\'re most consistent in the $timeOfDay (${bestHour}:00)',
          'subtitle': 'Based on your completion patterns',
        });
      }

      // Analyze weekly patterns
      final Map<int, int> dayCounts = {};
      for (final completion in completions) {
        final weekday = DateTime.parse(completion['completed_at']).weekday;
        dayCounts[weekday] = (dayCounts[weekday] ?? 0) + 1;
      }

      if (dayCounts.isNotEmpty) {
        final bestDay = dayCounts.entries.reduce((a, b) => a.value > b.value ? a : b).key;
        final dayNames = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
        
        insights.add({
          'emoji': '📅',
          'title': 'Best Day of Week',
          'insight': '${dayNames[bestDay - 1]} is your most productive day',
          'subtitle': 'Schedule important routines on this day',
        });
      }

      // Calculate streak analysis
      final recentCompletions = completions.take(10).toList();
      if (recentCompletions.length >= 3) {
        insights.add({
          'emoji': '🔥',
          'title': 'Consistency Building',
          'insight': 'You\'ve completed ${recentCompletions.length} routines recently',
          'subtitle': 'Keep the momentum going!',
        });
      }

      // Add motivational insight
      final totalCompletions = completions.length;
      if (totalCompletions >= 10) {
        insights.add({
          'emoji': '🎯',
          'title': 'Habit Builder',
          'insight': 'You\'ve completed $totalCompletions routines this month',
          'subtitle': 'You\'re building strong habits!',
        });
      }

      print('✅ Generated ${insights.length} personal insights');
      return insights;
    } catch (e) {
      print('❌ Error generating personal insights: $e');
      return [
        {
          'emoji': '🌱',
          'title': 'Getting Started',
          'insight': 'Start building your routine habit today!',
          'subtitle': 'Consistency is key to success',
        }
      ];
    }
  }

  // Helper method to safely convert to Map<String, dynamic>
  static Map<String, dynamic> _ensureMapStringDynamic(dynamic data) {
    try {
      if (data is Map<String, dynamic>) {
        return data;
      } else if (data is Map) {
        return Map<String, dynamic>.from(data);
      } else {
        throw Exception('Data is not a map: ${data.runtimeType}');
      }
    } catch (e) {
      print('❌ Error converting map data: $e');
      return {};
    }
  }

  // Helper method to safely convert to List<Map<String, dynamic>>
  static List<Map<String, dynamic>> _ensureListOfMaps(dynamic data) {
    try {
      if (data is List<Map<String, dynamic>>) {
        return data;
      } else if (data is List) {
        return data.map((item) {
          if (item is Map<String, dynamic>) {
            return item;
          } else if (item is Map) {
            return Map<String, dynamic>.from(item);
          } else {
            throw Exception('Invalid item type in list: ${item.runtimeType}');
          }
        }).toList();
      } else {
        throw Exception('Data is not a list: ${data.runtimeType}');
      }
    } catch (e) {
      print('❌ Error converting list data: $e');
      return [];
    }
  }
} 