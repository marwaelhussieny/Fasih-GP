// lib/features/profile/data/datasources/activity_remote_data_source.dart

import 'package:grad_project/core/services/api_service.dart';
import 'package:grad_project/features/profile/domain/entities/daily_activity_entity.dart';
import 'package:flutter/foundation.dart';

abstract class ActivityRemoteDataSource {
  Future<List<DailyActivityEntity>> getWeeklyActivities();
  Future<Map<String, int>> getTodayAchievements();
  Future<DailyActivityEntity?> getTodayActivity();
  Future<void> addDailyActivity(DailyActivityEntity activity);
  Future<List<DailyActivityEntity>> getActivitiesInRange({
    required DateTime startDate,
    required DateTime endDate,
  });
}

class ActivityRemoteDataSourceImpl implements ActivityRemoteDataSource {
  final ApiService apiService;

  ActivityRemoteDataSourceImpl({required this.apiService});

  @override
  Future<List<DailyActivityEntity>> getWeeklyActivities() async {
    debugPrint('ActivityRemoteDataSource: getWeeklyActivities called');

    try {
      final response = await apiService.get('/profile/activities/weekly');

      // ApiService returns Map<String, dynamic> directly
      final List<dynamic> activitiesJson = response['activities'] ?? [];
      final activities = activitiesJson
          .map((json) => DailyActivityEntity.fromMap(json as Map<String, dynamic>))
          .toList();

      debugPrint('ActivityRemoteDataSource: Retrieved ${activities.length} weekly activities');
      return activities;
    } catch (e) {
      debugPrint('ActivityRemoteDataSource: Error getting weekly activities: $e');
      rethrow;
    }
  }

  @override
  Future<Map<String, int>> getTodayAchievements() async {
    debugPrint('ActivityRemoteDataSource: getTodayAchievements called');

    try {
      final response = await apiService.get('/profile/activities/today/achievements');

      final achievements = Map<String, int>.from(response['achievements'] ?? {});
      debugPrint('ActivityRemoteDataSource: Retrieved today\'s achievements: $achievements');
      return achievements;
    } catch (e) {
      debugPrint('ActivityRemoteDataSource: Error getting today\'s achievements: $e');
      rethrow;
    }
  }

  @override
  Future<DailyActivityEntity?> getTodayActivity() async {
    debugPrint('ActivityRemoteDataSource: getTodayActivity called');

    try {
      final response = await apiService.get('/profile/activities/today');

      final activityData = response['activity'];
      if (activityData != null) {
        final activity = DailyActivityEntity.fromMap(activityData as Map<String, dynamic>);
        debugPrint('ActivityRemoteDataSource: Retrieved today\'s activity: ${activity.id}');
        return activity;
      }

      debugPrint('ActivityRemoteDataSource: No activity found for today');
      return null;
    } catch (e) {
      // Check if it's a 404 error (no activity for today)
      if (e.toString().contains('404')) {
        debugPrint('ActivityRemoteDataSource: No activity found for today');
        return null;
      }
      debugPrint('ActivityRemoteDataSource: Error getting today\'s activity: $e');
      rethrow;
    }
  }

  @override
  Future<void> addDailyActivity(DailyActivityEntity activity) async {
    debugPrint('ActivityRemoteDataSource: addDailyActivity called');

    try {
      await apiService.post(
        '/profile/activities/daily',
        body: activity.toMap(),
      );

      debugPrint('ActivityRemoteDataSource: Daily activity added successfully');
    } catch (e) {
      debugPrint('ActivityRemoteDataSource: Error adding daily activity: $e');
      rethrow;
    }
  }

  @override
  Future<List<DailyActivityEntity>> getActivitiesInRange({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    debugPrint('ActivityRemoteDataSource: getActivitiesInRange called from $startDate to $endDate');

    try {
      // Build URL with query parameters manually since ApiService doesn't support queryParameters
      final startDateStr = startDate.toIso8601String();
      final endDateStr = endDate.toIso8601String();
      final url = '/profile/activities/range?startDate=$startDateStr&endDate=$endDateStr';

      final response = await apiService.get(url);

      final List<dynamic> activitiesJson = response['activities'] ?? [];
      final activities = activitiesJson
          .map((json) => DailyActivityEntity.fromMap(json as Map<String, dynamic>))
          .toList();

      debugPrint('ActivityRemoteDataSource: Retrieved ${activities.length} activities in range');
      return activities;
    } catch (e) {
      debugPrint('ActivityRemoteDataSource: Error getting activities in range: $e');
      rethrow;
    }
  }
}