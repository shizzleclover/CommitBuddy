import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';

class StreakAnalyticsScreen extends StatefulWidget {
  const StreakAnalyticsScreen({super.key});

  @override
  State<StreakAnalyticsScreen> createState() => _StreakAnalyticsScreenState();
}

class _StreakAnalyticsScreenState extends State<StreakAnalyticsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Mock data for analytics
  final List<String> _weekDays = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
  final List<List<int>> _habitHeatmap = [
    [1, 0, 1, 1, 0, 1, 1], // Week 1
    [1, 1, 0, 1, 1, 1, 0], // Week 2
    [0, 1, 1, 1, 1, 0, 1], // Week 3
    [1, 1, 1, 0, 1, 1, 1], // Week 4
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
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
          
          // Recent Achievements
          _buildRecentAchievements(),
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
                    '12 Days',
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
                  'Longest Streak',
                  '28 days',
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
                  'This Week',
                  '5/7 days',
                  Icons.calendar_today,
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
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            title: 'Completion Rate',
            value: '85%',
            subtitle: 'This month',
            icon: Icons.trending_up,
            color: AppColors.accentGreen,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            title: 'Active Routines',
            value: '3',
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
          _buildAchievementItem(
            '🔥',
            '10-Day Streak',
            'Maintained consistency for 10 days',
            '2 days ago',
          ),
          _buildAchievementItem(
            '🏆',
            'Week Warrior',
            'Completed all routines this week',
            '1 week ago',
          ),
          _buildAchievementItem(
            '⭐',
            'Early Bird',
            'Completed morning routine 5 days in a row',
            '2 weeks ago',
          ),
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
    final routines = [
      {'name': 'Morning Routine', 'completion': 0.9, 'streak': 12},
      {'name': 'Workout', 'completion': 0.75, 'streak': 8},
      {'name': 'Night Routine', 'completion': 0.85, 'streak': 15},
    ];

    return Column(
      children: routines.map((routine) {
        final completion = routine['completion'] as double;
        final streak = routine['streak'] as int;
        
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
                    routine['name'] as String,
                    style: AppTextStyles.titleMedium.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const Spacer(),
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
          _buildInsightCard(
            '🌅',
            'Best Time to Exercise',
            'You\'re 40% more likely to complete workouts in the morning',
            'Based on your last 30 days',
          ),
          _buildInsightCard(
            '📈',
            'Consistency Trend',
            'Your completion rate has improved by 15% this month',
            'Keep up the great work!',
          ),
          _buildInsightCard(
            '🔥',
            'Streak Recovery',
            'You typically bounce back within 2 days after missing a routine',
            'Your resilience is improving',
          ),
          _buildInsightCard(
            '🎯',
            'Weekly Pattern',
            'You\'re most consistent on weekdays, especially Tuesday-Thursday',
            'Consider lighter weekend goals',
          ),
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