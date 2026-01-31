// lib/features/home/domain/usecases/home_usecases.dart

import 'package:grad_project/features/home/domain/repositories/home_repository.dart';
import 'package:grad_project/features/home/domain/entities/lesson_entity.dart';
import 'package:grad_project/features/home/domain/entities/level_entity.dart';
import 'package:grad_project/features/home/domain/entities/progress_entity.dart';
import 'package:grad_project/features/home/domain/entities/streak_entity.dart';
import 'package:grad_project/features/home/domain/entities/lesson_activity_entity.dart';

// Get Levels Use Case
class GetLevelsUseCase {
  final HomeRepository repository;

  GetLevelsUseCase({required this.repository});

  Future<List<LevelEntity>> call() async {
    return await repository.getLevels();
  }
}

// Get Lessons Use Case
class GetLessonsUseCase {
  final HomeRepository repository;

  GetLessonsUseCase({required this.repository});

  Future<List<LessonEntity>> call() async {
    return await repository.getLessons();
  }
}

// Get Lessons For Level Use Case
class GetLessonsForLevelUseCase {
  final HomeRepository repository;

  GetLessonsForLevelUseCase({required this.repository});

  Future<List<LessonEntity>> call(String levelId) async {
    return await repository.getLessonsForLevel(levelId);
  }
}

// Get User Progress Use Case
class GetUserProgressUseCase {
  final HomeRepository repository;

  GetUserProgressUseCase({required this.repository});

  Future<ProgressEntity> call() async {
    return await repository.getUserProgress();
  }
}

// Get Current Streak Use Case
class GetCurrentStreakUseCase {
  final HomeRepository repository;

  GetCurrentStreakUseCase({required this.repository});

  Future<StreakEntity> call() async {
    return await repository.getCurrentStreak();
  }
}

// Get Achievements Use Case
class GetAchievementsUseCase {
  final HomeRepository repository;

  GetAchievementsUseCase({required this.repository});

  Future<Map<String, dynamic>> call() async {
    return await repository.getAchievements();
  }
}

// Complete Lesson Use Case
class CompleteLessonUseCase {
  final HomeRepository repository;

  CompleteLessonUseCase({required this.repository});

  Future<bool> call(String lessonId) async {
    return await repository.completeLesson(lessonId);
  }
}

// Complete Level Use Case
class CompleteLevelUseCase {
  final HomeRepository repository;

  CompleteLevelUseCase({required this.repository});

  Future<bool> call(String levelId) async {
    return await repository.completeLevel(levelId);
  }
}

// Update Streak Use Case
class UpdateStreakUseCase {
  final HomeRepository repository;

  UpdateStreakUseCase({required this.repository});

  Future<StreakEntity> call() async {
    return await repository.updateStreak();
  }
}

// Get Lesson Details Use Case
class GetLessonDetailsUseCase {
  final HomeRepository repository;

  GetLessonDetailsUseCase({required this.repository});

  Future<LessonEntity> call(String lessonId) async {
    return await repository.getLessonDetails(lessonId);
  }
}

// Start Lesson Use Case
class StartLessonUseCase {
  final HomeRepository repository;

  StartLessonUseCase({required this.repository});

  Future<bool> call(String lessonId) async {
    return await repository.startLesson(lessonId);
  }
}

// Get Video Lesson Data Use Case
class GetVideoLessonDataUseCase {
  final HomeRepository repository;

  GetVideoLessonDataUseCase({required this.repository});

  Future<Map<String, dynamic>> call(String lessonId) async {
    return await repository.getVideoLessonData(lessonId);
  }
}

// Complete Activity Use Case
class CompleteActivityUseCase {
  final HomeRepository repository;

  CompleteActivityUseCase({required this.repository});

  Future<bool> call(String lessonId, String activityId) async {
    return await repository.completeActivity(lessonId, activityId);
  }
}

// Get Activities For Lesson Use Case
class GetActivitiesForLessonUseCase {
  final HomeRepository repository;

  GetActivitiesForLessonUseCase({required this.repository});

  Future<List<LessonActivityEntity>> call(String lessonId) async {
    return await repository.getActivitiesForLesson(lessonId);
  }
}

// Update Lesson Activity Completion Use Case
class UpdateLessonActivityCompletionUseCase {
  final HomeRepository repository;

  UpdateLessonActivityCompletionUseCase({required this.repository});

  Future<bool> call(String lessonId, String activityId, bool isCompleted) async {
    return await repository.updateLessonActivityCompletion(lessonId, activityId, isCompleted);
  }
}

// Check Lesson Unlock Status Use Case
class CheckLessonUnlockStatusUseCase {
  final HomeRepository repository;

  CheckLessonUnlockStatusUseCase({required this.repository});

  Future<bool> call(String lessonId) async {
    try {
      final lessons = await repository.getLessons();
      final lesson = lessons.firstWhere((l) => l.id == lessonId);

      // First lesson is always unlocked
      if (lesson.order == 1) return true;

      // Check if previous lesson is completed
      final levelLessons = lessons.where((l) => l.levelId == lesson.levelId).toList();
      final previousLesson = levelLessons
          .where((l) => l.order == lesson.order - 1)
          .firstOrNull;

      return previousLesson?.isCompleted ?? false;
    } catch (e) {
      return false;
    }
  }
}

// Check Level Unlock Status Use Case
class CheckLevelUnlockStatusUseCase {
  final HomeRepository repository;

  CheckLevelUnlockStatusUseCase({required this.repository});

  Future<bool> call(String levelId) async {
    try {
      final levels = await repository.getLevels();
      final level = levels.firstWhere((l) => l.id == levelId);

      // First level is always unlocked
      if (level.order == 1) return true;

      // Check if previous level is completed
      final previousLevel = levels
          .where((l) => l.order == level.order - 1)
          .firstOrNull;

      return previousLevel?.isCompleted ?? false;
    } catch (e) {
      return false;
    }
  }
}

// Get Level Progress Use Case
class GetLevelProgressUseCase {
  final HomeRepository repository;

  GetLevelProgressUseCase({required this.repository});

  Future<double> call(String levelId) async {
    try {
      final lessons = await repository.getLessonsForLevel(levelId);
      if (lessons.isEmpty) return 0.0;

      final completedCount = lessons.where((l) => l.isCompleted).length;
      return completedCount / lessons.length;
    } catch (e) {
      return 0.0;
    }
  }
}

// Get Overall Progress Use Case
class GetOverallProgressUseCase {
  final HomeRepository repository;

  GetOverallProgressUseCase({required this.repository});

  Future<double> call() async {
    try {
      final lessons = await repository.getLessons();
      if (lessons.isEmpty) return 0.0;

      final completedCount = lessons.where((l) => l.isCompleted).length;
      return completedCount / lessons.length;
    } catch (e) {
      return 0.0;
    }
  }
}

// Calculate XP Use Case
class CalculateXPUseCase {
  final HomeRepository repository;

  CalculateXPUseCase({required this.repository});

  Future<int> call() async {
    try {
      final lessons = await repository.getLessons();
      final completedLessons = lessons.where((l) => l.isCompleted);

      int totalXP = 0;
      for (final lesson in completedLessons) {
        totalXP += lesson.xpReward;
        // Add XP from completed activities
        for (final activity in lesson.activities) {
          if (activity.isCompleted) {
            totalXP += activity.xpReward;
          }
        }
      }

      return totalXP;
    } catch (e) {
      return 0;
    }
  }
}

// Get Study Statistics Use Case
class GetStudyStatisticsUseCase {
  final HomeRepository repository;

  GetStudyStatisticsUseCase({required this.repository});

  Future<Map<String, dynamic>> call() async {
    try {
      final lessons = await repository.getLessons();
      final completedLessons = lessons.where((l) => l.isCompleted).toList();

      final totalStudyTime = completedLessons.fold<int>(
        0,
            (sum, lesson) => sum + lesson.duration,
      );

      final averageSessionTime = completedLessons.isNotEmpty
          ? totalStudyTime / completedLessons.length
          : 0.0;

      return {
        'totalLessons': lessons.length,
        'completedLessons': completedLessons.length,
        'totalStudyTime': totalStudyTime, // in minutes
        'averageSessionTime': averageSessionTime, // in minutes
        'completionRate': lessons.isNotEmpty ? completedLessons.length / lessons.length : 0.0,
      };
    } catch (e) {
      return {
        'totalLessons': 0,
        'completedLessons': 0,
        'totalStudyTime': 0,
        'averageSessionTime': 0.0,
        'completionRate': 0.0,
      };
    }
  }
}

// Search Lessons Use Case
class SearchLessonsUseCase {
  final HomeRepository repository;

  SearchLessonsUseCase({required this.repository});

  Future<List<LessonEntity>> call(String query) async {
    try {
      final lessons = await repository.getLessons();

      if (query.isEmpty) return lessons;

      final lowercaseQuery = query.toLowerCase();
      return lessons.where((lesson) {
        return lesson.title.toLowerCase().contains(lowercaseQuery) ||
            lesson.description.toLowerCase().contains(lowercaseQuery);
      }).toList();
    } catch (e) {
      return [];
    }
  }
}

// Get Lessons By Status Use Case
class GetLessonsByStatusUseCase {
  final HomeRepository repository;

  GetLessonsByStatusUseCase({required this.repository});

  Future<List<LessonEntity>> call({required bool isCompleted}) async {
    try {
      final lessons = await repository.getLessons();
      return lessons.where((lesson) => lesson.isCompleted == isCompleted).toList();
    } catch (e) {
      return [];
    }
  }
}

// Get Current Lesson Use Case
class GetCurrentLessonUseCase {
  final HomeRepository repository;

  GetCurrentLessonUseCase({required this.repository});

  Future<LessonEntity?> call() async {
    try {
      final lessons = await repository.getLessons();

      // Find first incomplete lesson
      return lessons
          .where((lesson) => !lesson.isCompleted)
          .firstOrNull;
    } catch (e) {
      return null;
    }
  }
}

// Get Next Lesson Use Case
class GetNextLessonUseCase {
  final HomeRepository repository;

  GetNextLessonUseCase({required this.repository});

  Future<LessonEntity?> call(String currentLessonId) async {
    try {
      final lessons = await repository.getLessons();
      final currentLesson = lessons.firstWhere((l) => l.id == currentLessonId);

      // Find next lesson in the same level
      final levelLessons = lessons
          .where((l) => l.levelId == currentLesson.levelId)
          .toList();

      levelLessons.sort((a, b) => a.order.compareTo(b.order));

      final currentIndex = levelLessons.indexOf(currentLesson);
      if (currentIndex >= 0 && currentIndex < levelLessons.length - 1) {
        return levelLessons[currentIndex + 1];
      }

      // If no next lesson in current level, find first lesson in next level
      final levels = await repository.getLevels();
      final currentLevel = levels.firstWhere((l) => l.id == currentLesson.levelId);
      final nextLevel = levels
          .where((l) => l.order == currentLevel.order + 1)
          .firstOrNull;

      if (nextLevel != null) {
        final nextLevelLessons = await repository.getLessonsForLevel(nextLevel.id);
        nextLevelLessons.sort((a, b) => a.order.compareTo(b.order));
        return nextLevelLessons.firstOrNull;
      }

      return null;
    } catch (e) {
      return null;
    }
  }
}

// Get Previous Lesson Use Case
class GetPreviousLessonUseCase {
  final HomeRepository repository;

  GetPreviousLessonUseCase({required this.repository});

  Future<LessonEntity?> call(String currentLessonId) async {
    try {
      final lessons = await repository.getLessons();
      final currentLesson = lessons.firstWhere((l) => l.id == currentLessonId);

      // Find previous lesson in the same level
      final levelLessons = lessons
          .where((l) => l.levelId == currentLesson.levelId)
          .toList();

      levelLessons.sort((a, b) => a.order.compareTo(b.order));

      final currentIndex = levelLessons.indexOf(currentLesson);
      if (currentIndex > 0) {
        return levelLessons[currentIndex - 1];
      }

      // If no previous lesson in current level, find last lesson in previous level
      final levels = await repository.getLevels();
      final currentLevel = levels.firstWhere((l) => l.id == currentLesson.levelId);
      final previousLevel = levels
          .where((l) => l.order == currentLevel.order - 1)
          .firstOrNull;

      if (previousLevel != null) {
        final previousLevelLessons = await repository.getLessonsForLevel(previousLevel.id);
        previousLevelLessons.sort((a, b) => a.order.compareTo(b.order));
        return previousLevelLessons.lastOrNull;
      }

      return null;
    } catch (e) {
      return null;
    }
  }
}

// Check Activity Unlock Status Use Case
class CheckActivityUnlockStatusUseCase {
  final HomeRepository repository;

  CheckActivityUnlockStatusUseCase({required this.repository});

  Future<bool> call(String lessonId, String activityId) async {
    try {
      final activities = await repository.getActivitiesForLesson(lessonId);
      final activity = activities.firstWhere((a) => a.id == activityId);
      final activityIndex = activities.indexOf(activity);

      // First activity is always unlocked
      if (activityIndex == 0) return true;

      // Check if previous activity is completed
      if (activityIndex > 0) {
        return activities[activityIndex - 1].isCompleted;
      }

      return false;
    } catch (e) {
      return false;
    }
  }
}

// Get User Rank Use Case
class GetUserRankUseCase {
  final HomeRepository repository;

  GetUserRankUseCase({required this.repository});

  Future<String> call() async {
    try {
      final calculateXPUseCase = CalculateXPUseCase(repository: repository);
      final totalXP = await calculateXPUseCase.call();

      if (totalXP >= 10000) return 'خبير';
      if (totalXP >= 5000) return 'متقدم';
      if (totalXP >= 2000) return 'متوسط';
      if (totalXP >= 500) return 'مبتدئ متقدم';
      return 'مبتدئ';
    } catch (e) {
      return 'مبتدئ';
    }
  }
}

// Validate Lesson Sequence Use Case
class ValidateLessonSequenceUseCase {
  final HomeRepository repository;

  ValidateLessonSequenceUseCase({required this.repository});

  Future<bool> call(String lessonId) async {
    try {
      final lessons = await repository.getLessons();
      final lesson = lessons.firstWhere((l) => l.id == lessonId);

      // Get all lessons in the same level
      final levelLessons = lessons
          .where((l) => l.levelId == lesson.levelId)
          .toList();

      levelLessons.sort((a, b) => a.order.compareTo(b.order));

      // Check if all previous lessons are completed
      for (final levelLesson in levelLessons) {
        if (levelLesson.order >= lesson.order) break;
        if (!levelLesson.isCompleted) return false;
      }

      return true;
    } catch (e) {
      return false;
    }
  }
}

// Extension to add firstOrNull method if not available
extension IterableExtension<T> on Iterable<T> {
  T? get firstOrNull {
    try {
      return first;
    } catch (e) {
      return null;
    }
  }

  T? get lastOrNull {
    try {
      return last;
    } catch (e) {
      return null;
    }
  }
}