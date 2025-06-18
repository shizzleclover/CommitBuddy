import 'dart:async';
import 'package:flutter/material.dart';
import '../../../data/models/routine.dart';

enum RunnerState {
  ready,
  running,
  paused,
  completed,
  requiresProof,
  skipped,
}

class RoutineRunnerController extends ChangeNotifier {
  final CreatedRoutine routine;
  
  // Current state
  int _currentSubtaskIndex = 0;
  RunnerState _state = RunnerState.ready;
  int _remainingSeconds = 0;
  Timer? _timer;
  DateTime? _startTime;
  List<SubtaskResult> _results = [];
  
  // Getters
  int get currentSubtaskIndex => _currentSubtaskIndex;
  RunnerState get state => _state;
  int get remainingSeconds => _remainingSeconds;
  double get progress => _currentSubtaskIndex / routine.subtasks.length;
  bool get isLastSubtask => _currentSubtaskIndex >= routine.subtasks.length - 1;
  bool get canSkip => _remainingSeconds <= 0; // Allow skip after timer ends
  
  Subtask get currentSubtask => routine.subtasks[_currentSubtaskIndex];
  List<SubtaskResult> get results => List.unmodifiable(_results);
  
  // Progress indicators
  String get progressText => '${_currentSubtaskIndex + 1} of ${routine.subtasks.length}';
  double get progressPercentage => (_currentSubtaskIndex + 1) / routine.subtasks.length;
  
  RoutineRunnerController({required this.routine}) {
    _initializeController();
  }

  void _initializeController() {
    _currentSubtaskIndex = 0;
    _state = RunnerState.ready;
    _remainingSeconds = routine.subtasks.isNotEmpty 
        ? routine.subtasks[0].totalDurationSeconds 
        : 0;
    _results = [];
  }

  void startRoutine() {
    if (_state != RunnerState.ready && _state != RunnerState.paused) return;
    
    _startTime ??= DateTime.now();
    _state = RunnerState.running;
    _startTimer();
    notifyListeners();
  }

  void pauseRoutine() {
    if (_state != RunnerState.running) return;
    
    _state = RunnerState.paused;
    _timer?.cancel();
    notifyListeners();
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingSeconds > 0) {
        _remainingSeconds--;
        notifyListeners();
      } else {
        _onTimerComplete();
      }
    });
  }

  void _onTimerComplete() {
    _timer?.cancel();
    
    if (currentSubtask.requiresPhotoProof) {
      _state = RunnerState.requiresProof;
    } else {
      // Auto-complete subtask when timer ends
      completeCurrentSubtask(completed: true);
    }
    notifyListeners();
  }

  void completeCurrentSubtask({
    required bool completed,
    String? proofImagePath,
    String? notes,
  }) {
    final result = SubtaskResult(
      subtask: currentSubtask,
      completed: completed,
      duration: currentSubtask.durationMinutes * 60 - _remainingSeconds,
      proofImagePath: proofImagePath,
      notes: notes,
      completedAt: DateTime.now(),
    );
    
    _results.add(result);
    
    if (_currentSubtaskIndex >= routine.subtasks.length - 1) {
      // Routine completed
      _completeRoutine();
    } else {
      // Move to next subtask
      _moveToNextSubtask();
    }
  }

  void _moveToNextSubtask() {
    _currentSubtaskIndex++;
    _remainingSeconds = currentSubtask.totalDurationSeconds;
    _state = RunnerState.ready;
    notifyListeners();
  }

  void _completeRoutine() {
    _timer?.cancel();
    _state = RunnerState.completed;
    notifyListeners();
  }

  void skipCurrentSubtask() {
    if (!canSkip) return;
    
    completeCurrentSubtask(
      completed: false,
      notes: 'Skipped',
    );
  }

  void addProofImage(String imagePath, {String? notes}) {
    completeCurrentSubtask(
      completed: true,
      proofImagePath: imagePath,
      notes: notes,
    );
  }

  void restartRoutine() {
    _timer?.cancel();
    _initializeController();
    notifyListeners();
  }

  // Statistics
  int get completedSubtasks => _results.where((r) => r.completed).length;
  int get skippedSubtasks => _results.where((r) => !r.completed).length;
  int get totalDurationMinutes => _results.fold(0, (sum, r) => sum + (r.duration ~/ 60));
  
  double get completionRate => _results.isEmpty 
      ? 0.0 
      : completedSubtasks / _results.length;

  String get motivationalMessage {
    final rate = completionRate;
    if (rate >= 1.0) return "Perfect! You're unstoppable! 🔥";
    if (rate >= 0.8) return "Amazing work! Keep it up! ⭐";
    if (rate >= 0.6) return "Great progress! You're building discipline! 💪";
    if (rate >= 0.4) return "Good effort! Every step counts! 🌱";
    return "You started, and that's what matters! 🌟";
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}

class SubtaskResult {
  final Subtask subtask;
  final bool completed;
  final int duration; // seconds actually spent
  final String? proofImagePath;
  final String? notes;
  final DateTime completedAt;

  const SubtaskResult({
    required this.subtask,
    required this.completed,
    required this.duration,
    this.proofImagePath,
    this.notes,
    required this.completedAt,
  });

  String get formattedDuration {
    final minutes = duration ~/ 60;
    final seconds = duration % 60;
    return '${minutes}m ${seconds}s';
  }
} 