import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../shared/theme/app_colors.dart';
import '../../../shared/theme/app_text_styles.dart';
import '../../../data/models/routine.dart';
import '../../../core/services/routine_service.dart';
import 'dart:async';

class RoutineDetailScreen extends ConsumerStatefulWidget {
  final CreatedRoutine routine;

  const RoutineDetailScreen({
    super.key,
    required this.routine,
  });

  @override
  ConsumerState<RoutineDetailScreen> createState() => _RoutineDetailScreenState();
}

class _RoutineDetailScreenState extends ConsumerState<RoutineDetailScreen> {
  Timer? _timer;
  int _currentSubtaskIndex = 0;
  int _elapsedSeconds = 0;
  bool _isRunning = false;
  bool _isPaused = false;
  List<int> _subtaskTimes = [];
  int _totalTime = 0;

  @override
  void initState() {
    super.initState();
    _subtaskTimes = List.filled(widget.routine.subtasks.length, 0);
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    setState(() {
      _isRunning = true;
      _isPaused = false;
    });

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _elapsedSeconds++;
        _subtaskTimes[_currentSubtaskIndex]++;
        _totalTime++;
      });
    });
  }

  void _pauseTimer() {
    _timer?.cancel();
    setState(() {
      _isPaused = true;
      _isRunning = false;
    });
  }

  void _resumeTimer() {
    _startTimer();
  }

  void _nextSubtask() {
    if (_currentSubtaskIndex < widget.routine.subtasks.length - 1) {
      setState(() {
        _currentSubtaskIndex++;
        _elapsedSeconds = 0;
      });
    } else {
      _completeRoutine();
    }
  }

  void _previousSubtask() {
    if (_currentSubtaskIndex > 0) {
      setState(() {
        _currentSubtaskIndex--;
        _elapsedSeconds = _subtaskTimes[_currentSubtaskIndex];
      });
    }
  }

  void _resetTimer() {
    _timer?.cancel();
    setState(() {
      _isRunning = false;
      _isPaused = false;
      _elapsedSeconds = 0;
      _currentSubtaskIndex = 0;
      _subtaskTimes = List.filled(widget.routine.subtasks.length, 0);
      _totalTime = 0;
    });
  }

  void _completeRoutine() async {
    _timer?.cancel();
    
    try {
      await RoutineService.completeRoutine(
        routineId: widget.routine.id,
        completedSubtasks: widget.routine.subtasks.map((s) => s.id).toList(),
        notes: 'Completed in ${_formatTime(_totalTime)}',
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('🎉 Routine completed in ${_formatTime(_totalTime)}!'),
            backgroundColor: AppColors.success,
          ),
        );
        Navigator.of(context).pop(true); // Return true to indicate completion
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error completing routine: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  String _formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final currentSubtask = widget.routine.subtasks.isNotEmpty 
        ? widget.routine.subtasks[_currentSubtaskIndex] 
        : null;
    
    final estimatedTime = currentSubtask?.durationMinutes ?? 0;
    final estimatedSeconds = estimatedTime * 60;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          widget.routine.name,
          style: AppTextStyles.headlineMedium,
        ),
        actions: [
          Text(
            widget.routine.emoji,
            style: const TextStyle(fontSize: 24),
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: widget.routine.subtasks.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.assignment_outlined,
                    size: 64,
                    color: AppColors.textSecondary,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No subtasks available',
                    style: AppTextStyles.bodyLarge.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            )
          : Column(
              children: [
                // Progress indicator
                Container(
                  margin: const EdgeInsets.all(16),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppColors.cardBackground,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.shadow.withOpacity(0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Progress',
                            style: AppTextStyles.labelLarge,
                          ),
                          Text(
                            '${_currentSubtaskIndex + 1}/${widget.routine.subtasks.length}',
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      LinearProgressIndicator(
                        value: (_currentSubtaskIndex + 1) / widget.routine.subtasks.length,
                        backgroundColor: AppColors.border,
                        valueColor: AlwaysStoppedAnimation(AppColors.primary),
                        minHeight: 8,
                      ),
                    ],
                  ),
                ),

                // Current subtask
                Expanded(
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: AppColors.cardBackground,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.shadow.withOpacity(0.1),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          currentSubtask?.name ?? 'Unknown Task',
                          style: AppTextStyles.displaySmall,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 24),

                        // Timer display
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 32,
                            vertical: 24,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Column(
                            children: [
                              Text(
                                _formatTime(_elapsedSeconds),
                                style: AppTextStyles.displayLarge.copyWith(
                                  fontSize: 48,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primary,
                                ),
                              ),
                              if (estimatedTime > 0) ...[
                                const SizedBox(height: 8),
                                Text(
                                  'Target: ${_formatTime(estimatedSeconds)}',
                                  style: AppTextStyles.bodyMedium.copyWith(
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                LinearProgressIndicator(
                                  value: _elapsedSeconds / estimatedSeconds,
                                  backgroundColor: AppColors.border,
                                  valueColor: AlwaysStoppedAnimation(
                                    _elapsedSeconds <= estimatedSeconds
                                        ? AppColors.success
                                        : AppColors.warning,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),

                        const SizedBox(height: 32),

                        // Timer controls
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            // Previous button
                            IconButton(
                              onPressed: _currentSubtaskIndex > 0 ? _previousSubtask : null,
                              icon: const Icon(Icons.skip_previous),
                              iconSize: 32,
                              style: IconButton.styleFrom(
                                backgroundColor: AppColors.cardBackground,
                                foregroundColor: _currentSubtaskIndex > 0
                                    ? AppColors.textPrimary
                                    : AppColors.textSecondary,
                                padding: const EdgeInsets.all(16),
                              ),
                            ),

                            // Play/Pause button
                            IconButton(
                              onPressed: _isRunning ? _pauseTimer : _resumeTimer,
                              icon: Icon(
                                _isRunning ? Icons.pause : Icons.play_arrow,
                              ),
                              iconSize: 48,
                              style: IconButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                foregroundColor: AppColors.background,
                                padding: const EdgeInsets.all(20),
                              ),
                            ),

                            // Next button
                            IconButton(
                              onPressed: _nextSubtask,
                              icon: Icon(
                                _currentSubtaskIndex < widget.routine.subtasks.length - 1
                                    ? Icons.skip_next
                                    : Icons.check,
                              ),
                              iconSize: 32,
                              style: IconButton.styleFrom(
                                backgroundColor: _currentSubtaskIndex < widget.routine.subtasks.length - 1
                                    ? AppColors.cardBackground
                                    : AppColors.success,
                                foregroundColor: _currentSubtaskIndex < widget.routine.subtasks.length - 1
                                    ? AppColors.textPrimary
                                    : AppColors.background,
                                padding: const EdgeInsets.all(16),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                // Bottom info
                Container(
                  margin: const EdgeInsets.all(16),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.cardBackground,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Total Time',
                            style: AppTextStyles.labelSmall,
                          ),
                          Text(
                            _formatTime(_totalTime),
                            style: AppTextStyles.bodyLarge.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      TextButton.icon(
                        onPressed: _resetTimer,
                        icon: const Icon(Icons.refresh, size: 16),
                        label: const Text('Reset'),
                        style: TextButton.styleFrom(
                          foregroundColor: AppColors.textSecondary,
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