import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_texts.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../shared/widgets/routine_card.dart';
import '../../../shared/widgets/loading_widget.dart';
import '../../../data/models/routine.dart';
import '../../routine/logic/routine_providers.dart';
import '../../profile/logic/profile_providers.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  bool _isInitialized = false;
  
  @override
  void initState() {
    super.initState();
    _setupAnimations();
    // Load data on screen init
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadDataSafely();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Refresh data when dependencies change (e.g., when returning from other screens)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _refreshData();
      }
    });
  }

  Future<void> _refreshData() async {
    if (!mounted) return;
    
    try {
      await Future.wait([
        ref.read(routineProvider.notifier).loadTodayRoutines(),
        ref.read(routineProvider.notifier).loadRoutines(fromCache: false),
      ]);
    } catch (e) {
      print('Error refreshing home screen data: $e');
    }
  }

  void _setupAnimations() {
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));

    // Start animations safely
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && !_isInitialized) {
        _isInitialized = true;
        _fadeController.forward();
        _slideController.forward();
      }
    });
  }

  Future<void> _loadDataSafely() async {
    if (!mounted) return;
    
    try {
      // Load data with error handling
      await Future.wait([
        ref.read(routineProvider.notifier).loadTodayRoutines().catchError((e) {
          print('Error loading today\'s routines: $e');
          return null;
        }),
        ref.read(profileProvider.notifier).loadProfile().catchError((e) {
          print('Error loading profile: $e');
          return null;
        }),
      ]);
    } catch (e) {
      print('Error loading home screen data: $e');
      // App should still work even if data loading fails
    }
  }

  void _setupErrorListeners() {
    // Skip error listeners that could cause assertion errors
    // We'll handle errors through try-catch in data loading methods instead
  }

  @override
  void dispose() {
    if (_isInitialized) {
      _fadeController.stop();
      _slideController.stop();
      _fadeController.dispose();
      _slideController.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final routineState = ref.watch(routineProvider);
    final profileState = ref.watch(profileProvider);
    final isLoadingRoutines = ref.watch(routineLoadingProvider);
    final isLoadingProfile = ref.watch(profileLoadingProvider);

    // Listen for errors - moved to separate method for safety
    _setupErrorListeners();

    final isLoading = isLoadingRoutines || isLoadingProfile;

    return Scaffold(
      backgroundColor: AppColors.backgroundGray,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _refreshData,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(profileState.profile?['display_name'] ?? 'User'),
                const SizedBox(height: 24),
                _buildQuoteCard(),
                const SizedBox(height: 24),
                _buildStatsSection(profileState.stats),
                const SizedBox(height: 24),
                _buildPinnedRoutinesSection(routineState.todayRoutines, isLoading),
                const SizedBox(height: 100), // Bottom padding for nav bar
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(String userName) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Hello, $userName!',
              style: AppTextStyles.displaySmall.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              _getCurrentDate(),
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.lightGray.withOpacity(0.5)),
          ),
          child: Icon(
            PhosphorIcons.bell(),
            color: AppColors.textSecondary,
            size: 24,
          ),
        ),
      ],
    );
  }

    Widget _buildQuoteCard() {
    return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppColors.primaryBlue,
                AppColors.primaryBlue.withOpacity(0.8),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: AppColors.primaryBlue.withOpacity(0.3),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                Icons.format_quote,
                color: AppColors.white.withOpacity(0.8),
                size: 32,
              ),
              const SizedBox(height: 8),
              Text(
                _getMotivationalQuote(),
                style: AppTextStyles.titleLarge.copyWith(
                  color: AppColors.white,
                  fontWeight: FontWeight.w600,
                  height: 1.3,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                '— Your CommitBuddy',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.white.withOpacity(0.9),
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ),
        );
  }

  Widget _buildStatsSection(dynamic stats) {
    return Container(
          padding: const EdgeInsets.all(20),
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
              Text(
                'Your Progress',
                style: AppTextStyles.titleLarge.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _buildStatCard(
                      icon: Icons.local_fire_department,
                      value: '${stats?['current_streak'] ?? 0}',
                      label: 'Current Streak',
                      color: AppColors.accentOrange,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildStatCard(
                      icon: Icons.task_alt,
                      value: '${stats?['total_routines'] ?? 0}',
                      label: 'Total Routines',
                      color: AppColors.primaryBlue,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _buildStatCard(
                      icon: Icons.people,
                      value: '${stats?['buddies_count'] ?? 0}',
                      label: 'Buddies',
                      color: AppColors.accentGreen,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildStatCard(
                      icon: Icons.trending_up,
                      value: '${((stats?['completion_rate'] ?? 0) as num).toStringAsFixed(0)}%',
                      label: 'Completion Rate',
                      color: AppColors.accentPurple,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String value,
    required String label,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: color,
            size: 24,
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: AppTextStyles.headlineSmall.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildPinnedRoutinesSection(List<CreatedRoutine> routines, bool isLoading) {
    // Filter to show only pinned routines first, then today's routines
    final pinnedRoutines = routines.where((r) => r.isPinned).toList();
    final todayRoutines = routines.where((r) => !r.isPinned).toList();
    final displayRoutines = [...pinnedRoutines, ...todayRoutines];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              pinnedRoutines.isNotEmpty ? 'Pinned Routines' : 'Today\'s Routines',
              style: AppTextStyles.titleLarge.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            TextButton(
              onPressed: () {
                // Navigate to routines list
                DefaultTabController.of(context)?.animateTo(1);
              },
              child: Text(
                'View All',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.primaryBlue,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        if (isLoading)
          const LoadingWidget(message: 'Loading routines...')
        else if (displayRoutines.isEmpty)
          _buildEmptyRoutinesState()
        else
          Column(
            children: displayRoutines.map((routine) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _buildRoutineCard(routine),
            )).toList(),
          ),
      ],
    );
  }

  Widget _buildEmptyRoutinesState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.lightGray.withOpacity(0.3),
        ),
      ),
      child: Column(
        children: [
          Icon(
            Icons.push_pin_outlined,
            size: 48,
            color: AppColors.textSecondary.withOpacity(0.7),
          ),
          const SizedBox(height: 16),
          Text(
            'No pinned routines',
            style: AppTextStyles.titleMedium.copyWith(
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Pin routines to your homescreen to see them here every day!',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: () {
                  // Navigate to routines list
                  DefaultTabController.of(context)?.animateTo(1);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryBlue,
                  foregroundColor: AppColors.white,
                ),
                child: const Text('View Routines'),
              ),
              const SizedBox(width: 12),
              OutlinedButton(
                onPressed: () {
                  // Navigate to create routine
                  DefaultTabController.of(context)?.animateTo(1);
                },
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.primaryBlue,
                ),
                child: const Text('Create New'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRoutineCard(CreatedRoutine routine) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: routine.isPinned ? Border.all(color: AppColors.primaryBlue, width: 2) : null,
        boxShadow: [
          BoxShadow(
            color: AppColors.lightGray.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Stack(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: _getCategoryColor(routine.category).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(
                    routine.emoji,
                    style: const TextStyle(fontSize: 24),
                  ),
                ),
              ),
              if (routine.isPinned)
                Positioned(
                  top: -2,
                  right: -2,
                  child: Container(
                    width: 16,
                    height: 16,
                    decoration: const BoxDecoration(
                      color: AppColors.primaryBlue,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.push_pin,
                      size: 10,
                      color: AppColors.white,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        routine.name,
                        style: AppTextStyles.titleMedium.copyWith(
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                    if (routine.isPinned)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.primaryBlue.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          'PINNED',
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.primaryBlue,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(
                      Icons.access_time,
                      size: 14,
                      color: AppColors.textSecondary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      routine.time,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Icon(
                      Icons.task_alt,
                      size: 14,
                      color: AppColors.textSecondary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${routine.subtasks.length} tasks',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: () => _startRoutine(routine),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryBlue,
              foregroundColor: AppColors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('Start'),
          ),
        ],
      ),
    );
  }

  Color _getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'self care':
        return AppColors.accentGreen;
      case 'fitness':
        return AppColors.accentOrange;
      case 'mindfulness':
        return AppColors.primaryBlue;
      case 'learning':
        return AppColors.accentPurple;
      default:
        return AppColors.primaryBlue;
    }
  }

  String _getCurrentDate() {
    final now = DateTime.now();
    final weekdays = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    
    return '${weekdays[now.weekday - 1]}, ${months[now.month - 1]} ${now.day}';
  }

  String _getMotivationalQuote() {
    final quotes = [
      'Every journey begins with a single step.',
      'Consistency is the key to success.',
      'You are capable of amazing things.',
      'Progress, not perfection.',
      'Small steps lead to big changes.',
      'Believe in yourself and keep going.',
      'Today is a new opportunity to grow.',
    ];
    
    final now = DateTime.now();
    return quotes[now.day % quotes.length];
  }

  void _startRoutine(CreatedRoutine routine) {
    // Navigate to routine runner screen
    Navigator.pushNamed(
      context,
      '/routine-runner',
      arguments: routine,
    );
  }
} 