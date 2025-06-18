import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_texts.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../data/models/routine.dart';
import '../logic/routine_runner_controller.dart';
import 'widgets/progress_header.dart';
import 'widgets/timer_widget.dart';
import 'proof_camera_screen.dart';
import 'completion_screen.dart';

class RoutineRunnerScreen extends StatefulWidget {
  final CreatedRoutine routine;

  const RoutineRunnerScreen({
    super.key,
    required this.routine,
  });

  @override
  State<RoutineRunnerScreen> createState() => _RoutineRunnerScreenState();
}

class _RoutineRunnerScreenState extends State<RoutineRunnerScreen> {
  late RoutineRunnerController _controller;

  @override
  void initState() {
    super.initState();
    _controller = RoutineRunnerController(routine: widget.routine);
    _controller.addListener(_onControllerChanged);
  }

  @override
  void dispose() {
    _controller.removeListener(_onControllerChanged);
    _controller.dispose();
    super.dispose();
  }

  void _onControllerChanged() {
    if (_controller.state == RunnerState.requiresProof) {
      _navigateToProofScreen();
    } else if (_controller.state == RunnerState.completed) {
      _navigateToCompletionScreen();
    }
  }

  void _navigateToProofScreen() async {
    final result = await Navigator.push<String>(
      context,
      MaterialPageRoute(
        builder: (context) => ProofCameraScreen(
          subtask: _controller.currentSubtask,
          routineName: widget.routine.name,
        ),
      ),
    );

    if (result != null) {
      _controller.addProofImage(result);
    } else {
      // User cancelled, allow them to skip or retake
      _showProofOptions();
    }
  }

  void _navigateToCompletionScreen() async {
    await Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => CompletionScreen(
          routine: widget.routine,
          results: _controller.results,
          completionRate: _controller.completionRate,
          totalDuration: _controller.totalDurationMinutes,
          motivationalMessage: _controller.motivationalMessage,
        ),
      ),
    );
  }

  void _showProofOptions() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Photo Proof Required'),
        content: const Text(
          'This task requires photo proof. Would you like to take a photo or skip this task?',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _controller.skipCurrentSubtask();
            },
            child: const Text('Skip Task'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _navigateToProofScreen();
            },
            child: const Text('Take Photo'),
          ),
        ],
      ),
    );
  }

  void _showExitConfirmation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Exit Routine?'),
        content: const Text(
          'Are you sure you want to exit? Your progress will be lost.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(AppTexts.cancel),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: const Text('Exit'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundGray,
      body: SafeArea(
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return Column(
              children: [
                // Progress Header
                ProgressHeader(
                  progressText: _controller.progressText,
                  progressPercentage: _controller.progressPercentage,
                  routineName: widget.routine.name,
                  onClose: _showExitConfirmation,
                ),
                
                // Main Content
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        const SizedBox(height: 40),
                        
                        // Current Subtask Info
                        _buildSubtaskInfo(),
                        
                        const SizedBox(height: 40),
                        
                        // Timer
                        TimerWidget(
                          remainingSeconds: _controller.remainingSeconds,
                          totalSeconds: _controller.currentSubtask.totalDurationSeconds,
                          isRunning: _controller.state == RunnerState.running,
                          onTap: _onTimerTap,
                        ),
                        
                        const SizedBox(height: 40),
                        
                        // Action Buttons
                        _buildActionButtons(),
                        
                        const Spacer(),
                        
                        // Bottom Info
                        if (_controller.currentSubtask.requiresPhotoProof)
                          _buildPhotoProofInfo(),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildSubtaskInfo() {
    final subtask = _controller.currentSubtask;
    
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Emoji
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AppColors.primaryBlue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Center(
              child: Text(
                widget.routine.emoji,
                style: const TextStyle(fontSize: 40),
              ),
            ),
          ),
          
          const SizedBox(height: 20),
          
          // Task Name
          Text(
            subtask.name,
            textAlign: TextAlign.center,
            style: AppTextStyles.headlineMedium.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          
          const SizedBox(height: 12),
          
          // Duration Badge
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 8,
            ),
            decoration: BoxDecoration(
              color: AppColors.primaryBlue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '${subtask.durationMinutes} minutes',
              style: AppTextStyles.labelLarge.copyWith(
                color: AppColors.primaryBlue,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        // Primary Action Button
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _getPrimaryAction(),
            style: ElevatedButton.styleFrom(
              backgroundColor: _getPrimaryButtonColor(),
              foregroundColor: AppColors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 0,
            ),
            child: Text(
              _getPrimaryButtonText(),
              style: AppTextStyles.labelLarge.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
        
        const SizedBox(height: 12),
        
        // Secondary Actions
        Row(
          children: [
            // Pause/Resume Button
            if (_controller.state == RunnerState.running ||
                _controller.state == RunnerState.paused) ...[
              Expanded(
                child: OutlinedButton(
                  onPressed: _controller.state == RunnerState.running
                      ? _controller.pauseRoutine
                      : _controller.startRoutine,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primaryBlue,
                    side: const BorderSide(color: AppColors.primaryBlue),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    _controller.state == RunnerState.running ? AppTexts.pauseTimer : AppTexts.resumeTimer,
                    style: AppTextStyles.labelMedium.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
            ],
            
            // Skip Button (only when timer is done)
            if (_controller.canSkip) ...[
              Expanded(
                child: OutlinedButton(
                  onPressed: _controller.skipCurrentSubtask,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.textSecondary,
                    side: const BorderSide(color: AppColors.lightGray),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                                      child: Text(
                      AppTexts.skipTask,
                      style: AppTextStyles.labelMedium.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }

  Widget _buildPhotoProofInfo() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.accentGreen.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.accentGreen.withOpacity(0.3),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.camera_alt,
            color: AppColors.accentGreen,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              AppTexts.photoProofRequired,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.accentGreen,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _onTimerTap() {
    if (_controller.state == RunnerState.ready) {
      _controller.startRoutine();
    } else if (_controller.state == RunnerState.running) {
      _controller.pauseRoutine();
    } else if (_controller.state == RunnerState.paused) {
      _controller.startRoutine();
    }
  }

  VoidCallback? _getPrimaryAction() {
    switch (_controller.state) {
      case RunnerState.ready:
        return _controller.startRoutine;
      case RunnerState.running:
        return null; // Timer is running, wait
      case RunnerState.paused:
        return _controller.startRoutine;
      case RunnerState.requiresProof:
        return _navigateToProofScreen;
      default:
        return () => _controller.completeCurrentSubtask(completed: true);
    }
  }

  String _getPrimaryButtonText() {
    switch (_controller.state) {
      case RunnerState.ready:
        return AppTexts.startTask;
      case RunnerState.running:
        return AppTexts.timerRunning;
      case RunnerState.paused:
        return AppTexts.resumeTimer;
      case RunnerState.requiresProof:
        return AppTexts.takePhoto;
      default:
        return _controller.isLastSubtask ? AppTexts.completeRoutine : AppTexts.nextTask;
    }
  }

  Color _getPrimaryButtonColor() {
    switch (_controller.state) {
      case RunnerState.ready:
      case RunnerState.paused:
        return AppColors.primaryBlue;
      case RunnerState.running:
        return AppColors.lightGray;
      case RunnerState.requiresProof:
        return AppColors.accentGreen;
      default:
        return AppColors.primaryBlue;
    }
  }
} 