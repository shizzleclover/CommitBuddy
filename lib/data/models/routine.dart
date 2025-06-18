import 'package:flutter/material.dart';

class Routine {
  final String id;
  final String name;
  final String time;
  final double progress;
  final String category;
  final bool isCompleted;
  final String? emoji;

  const Routine({
    required this.id,
    required this.name,
    required this.time,
    required this.progress,
    required this.category,
    this.isCompleted = false,
    this.emoji,
  });

  Routine copyWith({
    String? id,
    String? name,
    String? time,
    double? progress,
    String? category,
    bool? isCompleted,
    String? emoji,
  }) {
    return Routine(
      id: id ?? this.id,
      name: name ?? this.name,
      time: time ?? this.time,
      progress: progress ?? this.progress,
      category: category ?? this.category,
      isCompleted: isCompleted ?? this.isCompleted,
      emoji: emoji ?? this.emoji,
    );
  }
}

class RoutineFolder {
  final String id;
  final String name;
  final String emoji;
  final List<Routine> routines;
  final double overallProgress;

  const RoutineFolder({
    required this.id,
    required this.name,
    required this.emoji,
    required this.routines,
    required this.overallProgress,
  });

  RoutineFolder copyWith({
    String? id,
    String? name,
    String? emoji,
    List<Routine>? routines,
    double? overallProgress,
  }) {
    return RoutineFolder(
      id: id ?? this.id,
      name: name ?? this.name,
      emoji: emoji ?? this.emoji,
      routines: routines ?? this.routines,
      overallProgress: overallProgress ?? this.overallProgress,
    );
  }
}

// Enhanced models for routine creation
class Subtask {
  final String id;
  final String name;
  final int durationMinutes;
  final bool requiresPhotoProof;
  final int order;
  final bool isCompleted;

  const Subtask({
    required this.id,
    required this.name,
    required this.durationMinutes,
    required this.requiresPhotoProof,
    required this.order,
    this.isCompleted = false,
  });

  Subtask copyWith({
    String? id,
    String? name,
    int? durationMinutes,
    bool? requiresPhotoProof,
    int? order,
    bool? isCompleted,
  }) {
    return Subtask(
      id: id ?? this.id,
      name: name ?? this.name,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      requiresPhotoProof: requiresPhotoProof ?? this.requiresPhotoProof,
      order: order ?? this.order,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }

  int get totalDurationSeconds => durationMinutes * 60;
}

class RoutineTemplate {
  final String id;
  final String name;
  final String emoji;
  final String description;
  final String category;
  final List<Weekday> defaultDays;
  final String defaultTime;
  final List<SubtaskTemplate> subtasks;

  const RoutineTemplate({
    required this.id,
    required this.name,
    required this.emoji,
    required this.description,
    required this.category,
    required this.defaultDays,
    required this.defaultTime,
    required this.subtasks,
  });

  // Helper getter for suggested time
  TimeOfDay get suggestedTime {
    final parts = defaultTime.split(':');
    if (parts.length == 2) {
      final hour = int.tryParse(parts[0]) ?? 9;
      final minute = int.tryParse(parts[1]) ?? 0;
      return TimeOfDay(hour: hour, minute: minute);
    }
    return const TimeOfDay(hour: 9, minute: 0); // Default to 9 AM
  }
}

class SubtaskTemplate {
  final String name;
  final int durationMinutes;
  final bool requiresPhotoProof;

  const SubtaskTemplate({
    required this.name,
    required this.durationMinutes,
    required this.requiresPhotoProof,
  });
}

class CreatedRoutine {
  final String id;
  final String name;
  final String emoji;
  final String category;
  final String time; // Format: "HH:mm"
  final List<Weekday> repeatDays;
  final List<Subtask> subtasks;
  final DateTime createdAt;
  final DateTime? startDate;
  final bool isActive;

  const CreatedRoutine({
    required this.id,
    required this.name,
    required this.emoji,
    required this.category,
    required this.time,
    required this.repeatDays,
    required this.subtasks,
    required this.createdAt,
    this.startDate,
    this.isActive = true,
  });

  CreatedRoutine copyWith({
    String? id,
    String? name,
    String? emoji,
    String? category,
    String? time,
    List<Weekday>? repeatDays,
    List<Subtask>? subtasks,
    DateTime? createdAt,
    DateTime? startDate,
    bool? isActive,
  }) {
    return CreatedRoutine(
      id: id ?? this.id,
      name: name ?? this.name,
      emoji: emoji ?? this.emoji,
      category: category ?? this.category,
      time: time ?? this.time,
      repeatDays: repeatDays ?? this.repeatDays,
      subtasks: subtasks ?? this.subtasks,
      createdAt: createdAt ?? this.createdAt,
      startDate: startDate ?? this.startDate,
      isActive: isActive ?? this.isActive,
    );
  }

  int get totalDurationMinutes => subtasks.fold(0, (sum, task) => sum + task.durationMinutes);
  
  double get progress {
    if (subtasks.isEmpty) return 0.0;
    final completedTasks = subtasks.where((task) => task.isCompleted).length;
    return completedTasks / subtasks.length;
  }
}

enum Weekday {
  monday,
  tuesday,
  wednesday,
  thursday,
  friday,
  saturday,
  sunday;

  String get displayName {
    switch (this) {
      case Weekday.monday:
        return 'Mon';
      case Weekday.tuesday:
        return 'Tue';
      case Weekday.wednesday:
        return 'Wed';
      case Weekday.thursday:
        return 'Thu';
      case Weekday.friday:
        return 'Fri';
      case Weekday.saturday:
        return 'Sat';
      case Weekday.sunday:
        return 'Sun';
    }
  }

  String get fullName {
    switch (this) {
      case Weekday.monday:
        return 'Monday';
      case Weekday.tuesday:
        return 'Tuesday';
      case Weekday.wednesday:
        return 'Wednesday';
      case Weekday.thursday:
        return 'Thursday';
      case Weekday.friday:
        return 'Friday';
      case Weekday.saturday:
        return 'Saturday';
      case Weekday.sunday:
        return 'Sunday';
    }
  }
}

enum RoutineCategory {
  morning,
  workout,
  work,
  evening,
  health,
  productivity,
  mindfulness,
  learning,
  social,
  other;
} 