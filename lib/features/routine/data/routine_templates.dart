import '../../../data/models/routine.dart';
import '../../../core/constants/app_texts.dart';

class RoutineTemplates {
  static List<RoutineTemplate> get allTemplates => [
    morningRoutine,
    workoutRoutine,
    nightRoutine,
    studyRoutine,
  ];

  static const RoutineTemplate morningRoutine = RoutineTemplate(
    id: 'morning_routine',
    name: AppTexts.morningRoutineTemplate,
    emoji: '🌅',
    description: 'Start your day with intention and energy',
    category: AppTexts.wellness,
    defaultDays: [
      Weekday.monday,
      Weekday.tuesday,
      Weekday.wednesday,
      Weekday.thursday,
      Weekday.friday,
    ],
    defaultTime: '07:00',
    subtasks: [
      SubtaskTemplate(
        name: 'Make bed',
        durationMinutes: 2,
        requiresPhotoProof: true,
      ),
      SubtaskTemplate(
        name: 'Drink water',
        durationMinutes: 1,
        requiresPhotoProof: false,
      ),
      SubtaskTemplate(
        name: 'Stretch',
        durationMinutes: 10,
        requiresPhotoProof: false,
      ),
      SubtaskTemplate(
        name: 'Journal',
        durationMinutes: 5,
        requiresPhotoProof: false,
      ),
    ],
  );

  static const RoutineTemplate workoutRoutine = RoutineTemplate(
    id: 'workout_routine',
    name: AppTexts.workoutRoutineTemplate,
    emoji: '💪',
    description: 'Build strength and endurance consistently',
    category: AppTexts.fitness,
    defaultDays: [
      Weekday.monday,
      Weekday.wednesday,
      Weekday.friday,
    ],
    defaultTime: '18:00',
    subtasks: [
      SubtaskTemplate(
        name: 'Warm up',
        durationMinutes: 10,
        requiresPhotoProof: false,
      ),
      SubtaskTemplate(
        name: 'Strength training',
        durationMinutes: 30,
        requiresPhotoProof: true,
      ),
      SubtaskTemplate(
        name: 'Cardio',
        durationMinutes: 15,
        requiresPhotoProof: false,
      ),
      SubtaskTemplate(
        name: 'Cool down & stretch',
        durationMinutes: 10,
        requiresPhotoProof: false,
      ),
    ],
  );

  static const RoutineTemplate nightRoutine = RoutineTemplate(
    id: 'night_routine',
    name: AppTexts.nightRoutineTemplate,
    emoji: '🌙',
    description: 'Wind down and prepare for restful sleep',
    category: AppTexts.selfCare,
    defaultDays: [
      Weekday.sunday,
      Weekday.monday,
      Weekday.tuesday,
      Weekday.wednesday,
      Weekday.thursday,
      Weekday.friday,
      Weekday.saturday,
    ],
    defaultTime: '21:00',
    subtasks: [
      SubtaskTemplate(
        name: 'Skincare routine',
        durationMinutes: 10,
        requiresPhotoProof: false,
      ),
      SubtaskTemplate(
        name: 'Read',
        durationMinutes: 20,
        requiresPhotoProof: true,
      ),
      SubtaskTemplate(
        name: 'Meditation',
        durationMinutes: 10,
        requiresPhotoProof: false,
      ),
      SubtaskTemplate(
        name: 'Prepare for tomorrow',
        durationMinutes: 5,
        requiresPhotoProof: false,
      ),
    ],
  );

  static const RoutineTemplate studyRoutine = RoutineTemplate(
    id: 'study_routine',
    name: AppTexts.studyRoutineTemplate,
    emoji: '📚',
    description: 'Focused learning and skill development',
    category: AppTexts.learning,
    defaultDays: [
      Weekday.monday,
      Weekday.tuesday,
      Weekday.wednesday,
      Weekday.thursday,
      Weekday.friday,
    ],
    defaultTime: '19:00',
    subtasks: [
      SubtaskTemplate(
        name: 'Review notes',
        durationMinutes: 15,
        requiresPhotoProof: false,
      ),
      SubtaskTemplate(
        name: 'Focused study',
        durationMinutes: 45,
        requiresPhotoProof: true,
      ),
      SubtaskTemplate(
        name: 'Practice problems',
        durationMinutes: 30,
        requiresPhotoProof: false,
      ),
      SubtaskTemplate(
        name: 'Summarize learnings',
        durationMinutes: 10,
        requiresPhotoProof: false,
      ),
    ],
  );

  static List<String> get categories => [
    AppTexts.wellness,
    AppTexts.fitness,
    AppTexts.productivity,
    AppTexts.selfCare,
    AppTexts.learning,
    AppTexts.mindfulness,
  ];

  static String getCategoryEmoji(String category) {
    switch (category) {
      case AppTexts.wellness:
        return '🌱';
      case AppTexts.fitness:
        return '💪';
      case AppTexts.productivity:
        return '🎯';
      case AppTexts.selfCare:
        return '✨';
      case AppTexts.learning:
        return '📚';
      case AppTexts.mindfulness:
        return '🧘';
      default:
        return '📝';
    }
  }
} 