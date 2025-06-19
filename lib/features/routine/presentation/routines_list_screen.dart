import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../data/models/routine.dart';
import '../logic/routine_providers.dart';
import '../../../shared/widgets/loading_widget.dart';
import 'create_routine_screen.dart';
import 'routine_detail_screen.dart';

class RoutinesListScreen extends ConsumerStatefulWidget {
  const RoutinesListScreen({super.key});

  @override
  ConsumerState<RoutinesListScreen> createState() => _RoutinesListScreenState();
}

class _RoutinesListScreenState extends ConsumerState<RoutinesListScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  List<CreatedRoutine> _archivedRoutines = [];
  List<CreatedRoutine> _allRoutines = [];
  bool _isLoadingArchived = false;
  bool _isLoadingAll = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    // Load routines on screen init
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(routineProvider.notifier).loadRoutines();
      _loadAllRoutines(); // Load all routines for the "All" tab
    });
    
    // Listen for tab changes to load data when needed
    _tabController.addListener(() {
      if (_tabController.index == 0 && _allRoutines.isEmpty && !_isLoadingAll) {
        _loadAllRoutines();
      } else if (_tabController.index == 2 && _archivedRoutines.isEmpty && !_isLoadingArchived) {
        _loadArchivedRoutines();
      }
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
                // Refresh based on current tab
                switch (_tabController.index) {
                  case 0: // All tab
                    await _loadAllRoutines();
                    break;
                  case 1: // Active tab  
                    await ref.read(routineProvider.notifier).refreshRoutines();
                    await ref.read(routineProvider.notifier).loadTodayRoutines();
                    break;
                  case 2: // Archived tab
                    await _loadArchivedRoutines();
                    break;
                }
              },
              child: TabBarView(
                controller: _tabController,
                children: [
                  _isLoadingAll
                      ? const LoadingWidget(message: 'Loading all routines...')
                      : _buildRoutinesList(_allRoutines),
                  _buildRoutinesList(routineState.todayRoutines),
                  _isLoadingArchived
                      ? const LoadingWidget(message: 'Loading archived routines...')
                      : _buildRoutinesList(_archivedRoutines),
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
    return GestureDetector(
      onTap: () => _navigateToRoutineDetail(routine),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
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
                    PopupMenuItem(
                      value: 'pin',
                      child: Row(
                        children: [
                          Icon(routine.isPinned ? Icons.push_pin : Icons.push_pin_outlined, size: 18),
                          const SizedBox(width: 8),
                          Text(routine.isPinned ? 'Unpin' : 'Pin to Home'),
                        ],
                      ),
                    ),
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

  void _navigateToRoutineDetail(CreatedRoutine routine) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => RoutineDetailScreen(routine: routine),
      ),
    );
  }

  void _handleMenuAction(String action, CreatedRoutine routine) async {
    switch (action) {
      case 'pin':
        final success = await ref.read(routineProvider.notifier).toggleRoutinePin(routine.id);
        if (success) {
          final message = routine.isPinned ? 'Routine unpinned from home screen' : 'Routine pinned to home screen';
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(message),
              backgroundColor: AppColors.primaryBlue,
            ),
          );
        }
        break;
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

  Future<void> _loadAllRoutines() async {
    if (_isLoadingAll) return;
    
    setState(() {
      _isLoadingAll = true;
    });
    
    try {
      _allRoutines = await ref.read(routineProvider.notifier).loadRoutines(includeArchived: true);
    } catch (e) {
      print('Error loading all routines: $e');
    } finally {
      setState(() {
        _isLoadingAll = false;
      });
    }
  }

  Future<void> _loadArchivedRoutines() async {
    if (_isLoadingArchived) return;
    
    setState(() {
      _isLoadingArchived = true;
    });
    
    try {
      final allRoutines = await ref.read(routineProvider.notifier).loadRoutines(includeArchived: true);
      // Filter for archived routines (those that are not active)
      _archivedRoutines = allRoutines.where((r) => !r.isActive).toList();
    } catch (e) {
      print('Error loading archived routines: $e');
    } finally {
      setState(() {
        _isLoadingArchived = false;
      });
    }
  }
} 