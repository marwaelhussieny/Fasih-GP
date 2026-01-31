// lib/features/profile/data/repositories/activity_repository_impl.dart

import 'package:grad_project/core/services/auth_service.dart';
import 'package:grad_project/features/profile/domain/entities/daily_activity_entity.dart';
import 'package:grad_project/features/profile/domain/repositories/activity_repository.dart';
import 'package:grad_project/features/profile/data/datasources/activity_remote_data_source.dart';
import 'package:flutter/foundation.dart';

class ActivityRepositoryImpl implements ActivityRepository {
  final ActivityRemoteDataSource remoteDataSource;
  final AuthService authService;

  ActivityRepositoryImpl({
    required this.remoteDataSource,
    required this.authService,
  });

  bool get _isAuthenticated {
    return authService.isLoggedIn();
  }

  @override
  Future<List<DailyActivityEntity>> getWeeklyLessonsData() async {
    debugPrint('ActivityRepository: getWeeklyLessonsData called');

    if (!_isAuthenticated) {
      throw Exception('User not authenticated to get weekly lessons data.');
    }

    try {
      final activities = await remoteDataSource.getWeeklyActivities();
      debugPrint('ActivityRepository: Retrieved ${activities.length} weekly activities');

      // Sort by date for consistent display (oldest to newest)
      activities.sort((a, b) => a.date.compareTo(b.date));

      return activities;
    } catch (e) {
      debugPrint('ActivityRepository: Error getting weekly lessons data: $e');
      rethrow;
    }
  }

  @override
  Future<Map<String, int>> getDailyAchievements() async {
    debugPrint('ActivityRepository: getDailyAchievements called');

    if (!_isAuthenticated) {
      throw Exception('User not authenticated to get daily achievements.');
    }

    try {
      final achievements = await remoteDataSource.getTodayAchievements();
      debugPrint('ActivityRepository: Retrieved daily achievements: $achievements');

      // Ensure all expected keys are present with default values
      return {
        'lessonsCompleted': achievements['lessonsCompleted'] ?? 0,
        'correctAnswers': achievements['correctAnswers'] ?? 0,
        'pointsEarned': achievements['pointsEarned'] ?? 0,
        'timeSpentMinutes': achievements['timeSpentMinutes'] ?? 0,
      };
    } catch (e) {
      debugPrint('ActivityRepository: Error getting daily achievements: $e');
      // Return default values in case of error
      return {
        'lessonsCompleted': 0,
        'correctAnswers': 0,
        'pointsEarned': 0,
        'timeSpentMinutes': 0,
      };
    }
  }

  @override
  Future<void> addDailyActivity({
    required int lessonsCompleted,
    required int correctAnswers,
    required int pointsEarned,
    int timeSpentMinutes = 0,
    List<String> newAchievements = const [],
  }) async {
    debugPrint('ActivityRepository: addDailyActivity called with: lessons=$lessonsCompleted, answers=$correctAnswers, points=$pointsEarned, time=$timeSpentMinutes');

    if (!_isAuthenticated) {
      throw Exception('User not authenticated to add daily activity.');
    }

    try {
      final activity = DailyActivityEntity(
        date: DateTime.now(),
        completedLessons: lessonsCompleted,
        correctAnswers: correctAnswers,
        pointsEarned: pointsEarned,
        timeSpentMinutes: timeSpentMinutes,
        achievements: newAchievements,
      );

      await remoteDataSource.addDailyActivity(activity);
      debugPrint('ActivityRepository: Daily activity added successfully');
    } catch (e) {
      debugPrint('ActivityRepository: Error adding daily activity: $e');
      rethrow;
    }
  }

  @override
  Future<DailyActivityEntity?> getTodayActivity() async {
    debugPrint('ActivityRepository: getTodayActivity called');

    if (!_isAuthenticated) {
      throw Exception('User not authenticated to get today\'s activity.');
    }

    try {
      final activity = await remoteDataSource.getTodayActivity();
      debugPrint('ActivityRepository: Retrieved today\'s activity: ${activity?.id}');
      return activity;
    } catch (e) {
      debugPrint('ActivityRepository: Error getting today\'s activity: $e');
      return null;
    }
  }

  @override
  Future<List<DailyActivityEntity>> getActivitiesInRange({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    debugPrint('ActivityRepository: getActivitiesInRange called from $startDate to $endDate');

    if (!_isAuthenticated) {
      throw Exception('User not authenticated to get activities in range.');
    }

    try {
      final activities = await remoteDataSource.getActivitiesInRange(
        startDate: startDate,
        endDate: endDate,
      );

      debugPrint('ActivityRepository: Retrieved ${activities.length} activities in range');

      // Sort by date for consistent display
      activities.sort((a, b) => a.date.compareTo(b.date));

      return activities;
    } catch (e) {
      debugPrint('ActivityRepository: Error getting activities in range: $e');
      rethrow;
    }
  }
}