import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../data/models/routine.dart';
import '../logic/routine_providers.dart';
import '../../../shared/widgets/loading_widget.dart';
import 'create_routine_screen.dart';

class RoutinesListScreen extends ConsumerStatefulWidget {
  const RoutinesListScreen({super.key});

  @override
  ConsumerState<RoutinesListScreen> createState() => _RoutinesListScreenState();
}

class _RoutinesListScreenState extends ConsumerState<RoutinesListScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    // Load routines on screen init
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(routineProvider.notifier).loadRoutines();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final routineState = ref.watch(routineProvider);
    final isLoading = ref.watch(routineLoadingProvider);

    // Listen for errors
    ref.listen(routineProvider, (previous, next) {
      if (next.error != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.error!),
            backgroundColor: AppColors.error,
          ),
        );
      }
    });

    return Scaffold(
      backgroundColor: AppColors.backgroundGray,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        title: Text(
          'My Routines',
          style: AppTextStyles.headlineSmall.copyWith(
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        actions: [
          IconButton(
            onPressed: _navigateToCreateRoutine,
            icon: const Icon(
              Icons.add,
              color: AppColors.primaryBlue,
            ),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.primaryBlue,
          unselectedLabelColor: AppColors.textSecondary,
          indicatorColor: AppColors.primaryBlue,
          tabs: const [
            Tab(text: 'All'),
            Tab(text: 'Active'),
            Tab(text: 'Archived'),
          ],
        ),
      ),
      body: isLoading
          ? const LoadingWidget(message: 'Loading routines...')
          : RefreshIndicator(
              onRefresh: () async {
                await ref.read(routineProvider.notifier).refreshRoutines();
              },
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildRoutinesList(routineState.routines),
                  _buildRoutinesList(routineState.todayRoutines),
                  _buildRoutinesList(routineState.routines.where((r) => !r.isActive).toList()),
                ],
              ),
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _navigateToCreateRoutine,
        backgroundColor: AppColors.primaryBlue,
        foregroundColor: AppColors.white,
        icon: const Icon(Icons.add),
        label: const Text('New Routine'),
      ),
    );
  }

  Widget _buildRoutinesList(List<CreatedRoutine> routines) {
    if (routines.isEmpty) {
      return _buildEmptyState();
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: routines.length,
      itemBuilder: (context, index) {
        final routine = routines[index];
        return _buildRoutineCard(routine);
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: AppColors.lightGray.withOpacity(0.3),
              borderRadius: BorderRadius.circular(60),
            ),
            child: const Icon(
              Icons.schedule_outlined,
              size: 60,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'No routines yet',
            style: AppTextStyles.headlineSmall.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Create your first routine to start building better habits',
            textAlign: TextAlign.center,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: _navigateToCreateRoutine,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryBlue,
              foregroundColor: AppColors.white,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25),
              ),
            ),
            child: const Text('Create Routine'),
          ),
        ],
      ),
    );
  }

  Widget _buildRoutineCard(CreatedRoutine routine) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
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
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      routine.name,
                      style: AppTextStyles.titleMedium.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.access_time,
                          size: 16,
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
                          Icons.category,
                          size: 16,
                          color: AppColors.textSecondary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          routine.category,
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              PopupMenuButton<String>(
                onSelected: (value) => _handleMenuAction(value, routine),
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'edit',
                    child: Row(
                      children: [
                        Icon(Icons.edit, size: 18),
                        SizedBox(width: 8),
                        Text('Edit'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'duplicate',
                    child: Row(
                      children: [
                        Icon(Icons.copy, size: 18),
                        SizedBox(width: 8),
                        Text('Duplicate'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'archive',
                    child: Row(
                      children: [
                        Icon(Icons.archive, size: 18),
                        SizedBox(width: 8),
                        Text('Archive'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: [
                        Icon(Icons.delete, size: 18, color: Colors.red),
                        SizedBox(width: 8),
                        Text('Delete', style: TextStyle(color: Colors.red)),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            '${routine.subtasks.length} subtasks',
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _getRepeatDaysText(routine.repeatDays),
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textSecondary,
            ),
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

  String _getRepeatDaysText(List<Weekday> days) {
    if (days.length == 7) return 'Every day';
    if (days.length == 5 && !days.contains(Weekday.saturday) && !days.contains(Weekday.sunday)) {
      return 'Weekdays';
    }
    if (days.length == 2 && days.contains(Weekday.saturday) && days.contains(Weekday.sunday)) {
      return 'Weekends';
    }
    return days.map((d) => _getWeekdayAbbr(d)).join(', ');
  }

  String _getWeekdayAbbr(Weekday day) {
    switch (day) {
      case Weekday.monday: return 'Mon';
      case Weekday.tuesday: return 'Tue';
      case Weekday.wednesday: return 'Wed';
      case Weekday.thursday: return 'Thu';
      case Weekday.friday: return 'Fri';
      case Weekday.saturday: return 'Sat';
      case Weekday.sunday: return 'Sun';
    }
  }

  bool _isActiveToday(CreatedRoutine routine) {
    final today = DateTime.now().weekday;
    final todayWeekday = Weekday.values[today - 1];
    return routine.repeatDays.contains(todayWeekday);
  }

  void _navigateToCreateRoutine() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const CreateRoutineScreen(),
      ),
    ).then((_) {
      // Refresh routines when returning from create screen
      ref.read(routineProvider.notifier).refreshRoutines();
    });
  }

  void _handleMenuAction(String action, CreatedRoutine routine) async {
    switch (action) {
      case 'edit':
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => CreateRoutineScreen(editingRoutine: routine),
          ),
        ).then((_) {
          ref.read(routineProvider.notifier).refreshRoutines();
        });
        break;
      case 'duplicate':
        await ref.read(routineProvider.notifier).duplicateRoutine(routine.id);
        break;
      case 'archive':
        await ref.read(routineProvider.notifier).toggleRoutineActive(routine.id);
        break;
      case 'delete':
        _showDeleteConfirmation(routine);
        break;
    }
  }

  void _showDeleteConfirmation(CreatedRoutine routine) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Routine'),
        content: Text('Are you sure you want to delete "${routine.name}"? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop();
              await ref.read(routineProvider.notifier).deleteRoutine(routine.id);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
} 