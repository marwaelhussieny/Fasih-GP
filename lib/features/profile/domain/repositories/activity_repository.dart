// lib/features/profile/domain/repositories/activity_repository.dart

import 'package:grad_project/features/profile/domain/entities/daily_activity_entity.dart';

abstract class ActivityRepository {
  /// Get activities for the last 7 days
  Future<List<DailyActivityEntity>> getWeeklyLessonsData();

  /// Get today's achievements summary
  Future<Map<String, int>> getDailyAchievements();

  /// Add a new daily activity (or update today's activity)
  Future<void> addDailyActivity({
    required int lessonsCompleted,
    required int correctAnswers,
    required int pointsEarned,
    int timeSpentMinutes = 0,
    List<String> newAchievements = const [],
  });

  /// Get today's activity if it exists
  Future<DailyActivityEntity?> getTodayActivity();

  /// Get activities within a specific date range
  Future<List<DailyActivityEntity>> getActivitiesInRange({
    required DateTime startDate,
    required DateTime endDate,
  });
}