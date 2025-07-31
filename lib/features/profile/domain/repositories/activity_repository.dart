// lib/features/profile/domain/repositories/activity_repository.dart

import 'package:grad_project/features/profile/domain/entities/daily_activity_entity.dart';

abstract class ActivityRepository {
  Future<List<DailyActivityEntity>> getWeeklyLessonsData(); // Return List<DailyActivityEntity>
  Future<Map<String, int>> getDailyAchievements(); // Return Map<String, int>
  Future<void> addDailyActivity({
    required int lessonsCompleted,
    required int correctAnswers,
    required int pointsEarned,
    int timeSpentMinutes, // FIX: Added timeSpentMinutes parameter
  });
}
