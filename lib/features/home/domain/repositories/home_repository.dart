// lib/features/home/domain/repositories/home_repository.dart

import 'package:grad_project/features/home/domain/entities/lesson_entity.dart';
import 'package:grad_project/features/home/domain/entities/level_entity.dart';
import 'package:grad_project/features/home/domain/entities/progress_entity.dart';
import 'package:grad_project/features/home/domain/entities/streak_entity.dart';
import 'package:grad_project/features/home/domain/entities/lesson_activity_entity.dart';

abstract class HomeRepository {
  // Level operations
  Future<List<LevelEntity>> getLevels();
  Future<bool> completeLevel(String levelId);

  // Lesson operations
  Future<List<LessonEntity>> getLessons();
  Future<List<LessonEntity>> getLessonsForLevel(String levelId);
  Future<LessonEntity> getLessonDetails(String lessonId);
  Future<bool> completeLesson(String lessonId);
  Future<bool> startLesson(String lessonId);

  // Activity operations
  Future<List<LessonActivityEntity>> getActivitiesForLesson(String lessonId);
  Future<bool> completeActivity(String lessonId, String activityId);
  Future<bool> updateLessonActivityCompletion(String lessonId, String activityId, bool isCompleted);

  // Progress and analytics
  Future<ProgressEntity> getUserProgress();
  Future<StreakEntity> getCurrentStreak();
  Future<StreakEntity> updateStreak();
  Future<Map<String, dynamic>> getAchievements();

  // Video content
  Future<Map<String, dynamic>> getVideoLessonData(String lessonId);
}