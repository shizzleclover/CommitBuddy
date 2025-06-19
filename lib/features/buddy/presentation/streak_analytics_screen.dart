import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/services/analytics_service.dart';

class StreakAnalyticsScreen extends StatefulWidget {
  const StreakAnalyticsScreen({super.key});

  @override
  State<StreakAnalyticsScreen> createState() => _StreakAnalyticsScreenState();
}

class _StreakAnalyticsScreenState extends State<StreakAnalyticsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Real data from Supabase
  Map<String, dynamic> _dashboardData = {};
  List<Map<String, dynamic>> _weeklyCompletions = [];
  List<Map<String, dynamic>> _dailyStreakData = [];
  Map<String, int> _categoryBreakdown = {};
  Map<String, dynamic> _moodTrends = {};
  List<Map<String, dynamic>> _routinePerformanceData = [];
  List<List<int>> _realHeatmapData = [];
  List<Map<String, String>> _personalInsights = [];
  bool _isLoading = true;

  // Week days for heatmap
  final List<String> _weekDays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
  
  // Use real heatmap data instead of dummy data
  List<List<int>> get _habitHeatmap => _realHeatmapData.isNotEmpty 
      ? _realHeatmapData 
      : [
          [0, 0, 0, 0, 0, 0, 0], // Week 1 - empty until data loads
          [0, 0, 0, 0, 0, 0, 0], // Week 2
          [0, 0, 0, 0, 0, 0, 0], // Week 3
          [0, 0, 0, 0, 0, 0, 0], // Week 4
        ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadAnalyticsData();
  }

  Future<void> _loadAnalyticsData() async {
    try {
      final results = await Future.wait([
        AnalyticsService.getUserDashboardData(),
        AnalyticsService.getWeeklyCompletions(),
        AnalyticsService.getDailyStreakData(),
        AnalyticsService.getCategoryBreakdown(),
        AnalyticsService.getMoodAndDifficultyTrends(),
        AnalyticsService.getRoutinePerformanceData(),
        AnalyticsService.getHeatmapData(),
        AnalyticsService.getPersonalInsights(),
      ]);

      if (mounted) {
        setState(() {
          _dashboardData = results[0] as Map<String, dynamic>;
          _weeklyCompletions = results[1] as List<Map<String, dynamic>>;
          _dailyStreakData = results[2] as List<Map<String, dynamic>>;
          _categoryBreakdown = results[3] as Map<String, int>;
          _moodTrends = results[4] as Map<String, dynamic>;
          _routinePerformanceData = results[5] as List<Map<String, dynamic>>;
          _realHeatmapData = results[6] as List<List<int>>;
          _personalInsights = results[7] as List<Map<String, String>>;
          _isLoading = false;
        });
      }
    } catch (e) {
      print('❌ Error loading analytics data: $e');
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Widget _buildCategoryBreakdownCard() {
    if (_categoryBreakdown.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: AppColors.lightGray.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.primaryBlue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.pie_chart,
                    color: AppColors.primaryBlue,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'Category Breakdown',
                  style: AppTextStyles.headlineSmall.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              'No routines yet',
              style: AppTextStyles.bodyLarge.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      );
    }

    final total = _categoryBreakdown.values.fold(0, (a, b) => a + b);
    final categories = _categoryBreakdown.entries.toList();

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.lightGray.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primaryBlue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.pie_chart,
                  color: AppColors.primaryBlue,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Category Breakdown',
                style: AppTextStyles.headlineSmall.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          ...categories.map((entry) {
            final percentage = ((entry.value / total) * 100).round();
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                children: [
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: _getCategoryColor(entry.key),
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      _denormalizeCategoryName(entry.key),
                      style: AppTextStyles.bodyMedium,
                    ),
                  ),
                  Text(
                    '${entry.value} ($percentage%)',
                    style: AppTextStyles.bodyMedium.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  Color _getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'health':
        return AppColors.accentGreen;
      case 'work':
        return AppColors.primaryBlue;
      case 'personal':
        return AppColors.accentOrange;
      case 'learning':
        return AppColors.accentPurple;
      case 'habit':
        return AppColors.lightGray;
      default:
        return AppColors.textSecondary;
    }
  }

  String _denormalizeCategoryName(String category) {
    switch (category.toLowerCase()) {
      case 'health':
        return 'Health & Fitness';
      case 'work':
        return 'Work & Productivity';
      case 'personal':
        return 'Personal & Self Care';
      case 'learning':
        return 'Learning & Growth';
      case 'habit':
        return 'Habits & Lifestyle';
      default:
        return category;
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundGray,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        title: Text(
          'Analytics & Streaks',
          style: AppTextStyles.headlineSmall.copyWith(
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(
            Icons.arrow_back,
            color: AppColors.textSecondary,
          ),
        ),
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.primaryBlue,
          unselectedLabelColor: AppColors.textSecondary,
          indicatorColor: AppColors.primaryBlue,
          tabs: const [
            Tab(text: 'Overview'),
            Tab(text: 'Habits'),
            Tab(text: 'Insights'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildOverviewTab(),
          _buildHabitsTab(),
          _buildInsightsTab(),
        ],
      ),
    );
  }

  Widget _buildOverviewTab() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Current Streak Card
          _buildCurrentStreakCard(),
          
          const SizedBox(height: 16),
          
          // Stats Grid
          _buildStatsGrid(),
          
          const SizedBox(height: 16),
          
          // Weekly Progress
          _buildWeeklyProgressCard(),
          
          const SizedBox(height: 16),
          
          // Category Breakdown
          _buildCategoryBreakdownCard(),
        ],
      ),
    );
  }

  Widget _buildCurrentStreakCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primaryBlue,
            AppColors.primaryBlue.withOpacity(0.8),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryBlue.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.local_fire_department,
                  color: AppColors.white,
                  size: 32,
                ),
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Current Streak',
                    style: AppTextStyles.bodyLarge.copyWith(
                      color: AppColors.white.withOpacity(0.9),
                    ),
                  ),
                  Text(
                    '${_dashboardData['current_streak'] ?? 0} Days',
                    style: AppTextStyles.headlineLarge.copyWith(
                      color: AppColors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          Row(
            children: [
              Expanded(
                child: _buildStreakStat(
                  'Best Streak',
                  '${_dashboardData['longest_streak'] ?? 0} days',
                  Icons.emoji_events,
                ),
              ),
              Container(
                width: 1,
                height: 40,
                color: AppColors.white.withOpacity(0.3),
              ),
              Expanded(
                child: _buildStreakStat(
                  'Total Routines',
                  '${_dashboardData['total_routines'] ?? 0}',
                  Icons.assignment,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStreakStat(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(
          icon,
          color: AppColors.white.withOpacity(0.8),
          size: 20,
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: AppTextStyles.titleMedium.copyWith(
            color: AppColors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: AppTextStyles.bodySmall.copyWith(
            color: AppColors.white.withOpacity(0.8),
          ),
        ),
      ],
    );
  }

  Widget _buildStatsGrid() {
    final totalRoutines = _dashboardData['total_routines'] ?? 0;
    final completedToday = _dashboardData['completed_today'] ?? 0;
    final activeRoutines = _dashboardData['active_routines'] ?? 0;
    final totalCompletions = _dashboardData['total_completions'] ?? 0;
    
    // Calculate completion rate
    final completionRate = totalRoutines > 0 
        ? ((totalCompletions / (totalRoutines * 30)) * 100).clamp(0, 100).round()
        : 0;

    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            title: 'Completion Rate',
            value: '$completionRate%',
            subtitle: 'Last 30 days',
            icon: Icons.trending_up,
            color: AppColors.accentGreen,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            title: 'Active Routines',
            value: '$activeRoutines',
            subtitle: 'Currently running',
            icon: Icons.play_circle,
            color: AppColors.accentOrange,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required String subtitle,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: color,
              size: 20,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: AppTextStyles.headlineMedium.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w500,
            ),
          ),
          Text(
            subtitle,
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeeklyProgressCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Weekly Progress',
            style: AppTextStyles.titleLarge.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: _weekDays.map((day) {
              final dayIndex = _weekDays.indexOf(day);
              final isCompleted = _habitHeatmap.last[dayIndex] == 1;
              final isToday = dayIndex == DateTime.now().weekday - 1;
              
              return Column(
                children: [
                  Text(
                    day,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: isCompleted 
                          ? AppColors.accentGreen
                          : isToday
                              ? AppColors.primaryBlue.withOpacity(0.2)
                              : AppColors.lightGray.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(16),
                      border: isToday
                          ? Border.all(color: AppColors.primaryBlue, width: 2)
                          : null,
                    ),
                    child: isCompleted
                        ? const Icon(
                            Icons.check,
                            color: AppColors.white,
                            size: 16,
                          )
                        : null,
                  ),
                ],
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentAchievements() {
    List<Map<String, String>> achievements = [];
    
    // Generate achievements based on real data
    final currentStreak = _dashboardData['current_streak'] ?? 0;
    final totalRoutines = _dashboardData['total_routines'] ?? 0;
    final completedToday = _dashboardData['completed_today'] ?? 0;
    final totalCompletions = _dashboardData['total_completions'] ?? 0;
    
    if (currentStreak >= 7) {
      achievements.add({
        'emoji': '🔥',
        'title': '${currentStreak}-Day Streak',
        'description': 'Maintained consistency for $currentStreak days',
        'time': 'Current streak',
      });
    }
    
    if (completedToday >= 3) {
      achievements.add({
        'emoji': '⚡',
        'title': 'Power User',
        'description': 'Completed $completedToday routines today',
        'time': 'Today',
      });
    }
    
    if (totalRoutines >= 5) {
      achievements.add({
        'emoji': '🎯',
        'title': 'Routine Builder',
        'description': 'Created $totalRoutines routines',
        'time': 'Total',
      });
    }
    
    if (totalCompletions >= 20) {
      achievements.add({
        'emoji': '🏆',
        'title': 'Habit Master',
        'description': 'Completed $totalCompletions routine sessions',
        'time': 'Lifetime',
      });
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Recent Achievements',
            style: AppTextStyles.titleLarge.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          if (achievements.isEmpty)
            Column(
              children: [
                Icon(
                  Icons.emoji_events_outlined,
                  size: 48,
                  color: AppColors.textSecondary,
                ),
                const SizedBox(height: 12),
                Text(
                  'No achievements yet',
                  style: AppTextStyles.bodyLarge.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Complete more routines to unlock achievements!',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            )
          else
            ...achievements.map((achievement) => _buildAchievementItem(
              achievement['emoji']!,
              achievement['title']!,
              achievement['description']!,
              achievement['time']!,
            )).toList(),
        ],
      ),
    );
  }

  Widget _buildAchievementItem(
    String emoji,
    String title,
    String description,
    String time,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.backgroundGray,
              borderRadius: BorderRadius.circular(24),
            ),
            child: Center(
              child: Text(
                emoji,
                style: const TextStyle(fontSize: 24),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTextStyles.titleMedium.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  description,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                Text(
                  time,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHabitsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Habit Heatmap',
            style: AppTextStyles.titleLarge.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          _buildHeatmapCard(),
          const SizedBox(height: 24),
          Text(
            'Routine Performance',
            style: AppTextStyles.titleLarge.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          _buildRoutinePerformanceList(),
        ],
      ),
    );
  }

  Widget _buildHeatmapCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Last 4 Weeks',
                style: AppTextStyles.titleMedium.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const Spacer(),
              Row(
                children: [
                  _buildLegendItem(AppColors.lightGray.withOpacity(0.3), 'Missed'),
                  const SizedBox(width: 8),
                  _buildLegendItem(AppColors.accentGreen, 'Completed'),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // Week days header
          Row(
            children: [
              const SizedBox(width: 40), // Space for week labels
              ..._weekDays.map((day) => Expanded(
                child: Center(
                  child: Text(
                    day,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
              )),
            ],
          ),
          
          const SizedBox(height: 8),
          
          // Heatmap grid
          ..._habitHeatmap.asMap().entries.map((entry) {
            final weekIndex = entry.key;
            final weekData = entry.value;
            
            return Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Row(
                children: [
                  SizedBox(
                    width: 40,
                    child: Text(
                      'W${weekIndex + 1}',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                  ...weekData.map((value) => Expanded(
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 2),
                      height: 24,
                      decoration: BoxDecoration(
                        color: value == 1
                            ? AppColors.accentGreen
                            : AppColors.lightGray.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  )),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildLegendItem(Color color, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: AppTextStyles.bodySmall.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildRoutinePerformanceList() {
    if (_routinePerformanceData.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: AppColors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Icon(
              Icons.assignment_outlined,
              size: 48,
              color: AppColors.textSecondary,
            ),
            const SizedBox(height: 16),
            Text(
              'No routine data available',
              style: AppTextStyles.bodyLarge.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Complete some routines to see performance data',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      children: _routinePerformanceData.map((routine) {
        final completion = (routine['completion'] as double?) ?? 0.0;
        final streak = (routine['streak'] as int?) ?? 0;
        final name = routine['name'] as String? ?? 'Unknown Routine';
        final emoji = routine['emoji'] as String? ?? '📝';
        
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: AppColors.black.withOpacity(0.04),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    emoji,
                    style: const TextStyle(fontSize: 24),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      name,
                      style: AppTextStyles.titleMedium.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                  Text(
                    '$streak day streak',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.accentOrange,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Text(
                    'Completion Rate: ${(completion * 100).toInt()}%',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const Spacer(),
                ],
              ),
              const SizedBox(height: 8),
              LinearProgressIndicator(
                value: completion,
                backgroundColor: AppColors.lightGray.withOpacity(0.3),
                valueColor: AlwaysStoppedAnimation<Color>(
                  completion > 0.8 ? AppColors.accentGreen : AppColors.accentOrange,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildInsightsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Personal Insights',
            style: AppTextStyles.titleLarge.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          if (_personalInsights.isEmpty)
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.black.withOpacity(0.04),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Icon(
                    Icons.lightbulb_outlined,
                    size: 48,
                    color: AppColors.textSecondary,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No insights available yet',
                    style: AppTextStyles.bodyLarge.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Complete more routines to generate personalized insights',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textSecondary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            )
          else
            ..._personalInsights.map((insight) => _buildInsightCard(
              insight['emoji'] ?? '💡',
              insight['title'] ?? 'Insight',
              insight['insight'] ?? 'No insight available',
              insight['subtitle'] ?? '',
            )).toList(),
        ],
      ),
    );
  }

  Widget _buildInsightCard(
    String emoji,
    String title,
    String insight,
    String subtitle,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: AppColors.backgroundGray,
              borderRadius: BorderRadius.circular(28),
            ),
            child: Center(
              child: Text(
                emoji,
                style: const TextStyle(fontSize: 28),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTextStyles.titleMedium.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  insight,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
} 