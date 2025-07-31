// lib/features/profile/domain/usecases/activity_usecases.dart

import 'package:grad_project/features/profile/domain/entities/daily_activity_entity.dart';
import 'package:grad_project/features/profile/domain/repositories/activity_repository.dart';

// --- GetWeeklyLessonsData Use Case ---
class GetWeeklyLessonsData {
  final ActivityRepository repository;
  GetWeeklyLessonsData(this.repository);

  Future<List<DailyActivityEntity>> call() async {
    return await repository.getWeeklyLessonsData();
  }
}

// --- GetDailyAchievements Use Case ---
class GetDailyAchievements {
  final ActivityRepository repository;
  GetDailyAchievements(this.repository);

  Future<Map<String, int>> call() async {
    return await repository.getDailyAchievements();
  }
}

// --- AddDailyActivity Use Case ---
class AddDailyActivity {
  final ActivityRepository repository;
  AddDailyActivity(this.repository);

  Future<void> call({
    required int lessonsCompleted,
    required int correctAnswers,
    required int pointsEarned,
    int timeSpentMinutes = 0, // Added timeSpentMinutes parameter
  }) async {
    await repository.addDailyActivity(
      lessonsCompleted: lessonsCompleted,
      correctAnswers: correctAnswers,
      pointsEarned: pointsEarned,
      timeSpentMinutes: timeSpentMinutes, // Pass to repository
    );
  }
}
