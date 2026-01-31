// lib/features/profile/data/datasources/profile_local_datasource.dart

import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:grad_project/features/profile/data/models/profile_user_model.dart';
import 'package:grad_project/features/profile/domain/entities/user_preferences_entity.dart';
import 'package:grad_project/features/profile/domain/entities/daily_activity_entity.dart';

import '../models/user_preferences_model.dart';

abstract class ProfileLocalDataSource {
  Future<void> saveProfile(ProfileUserModel profile);
  Future<ProfileUserModel?> getProfile();
  Future<void> clearProfile();

  Future<void> savePreferences(UserPreferencesEntity preferences);
  Future<UserPreferencesEntity?> getPreferences();
  Future<void> clearPreferences();

  Future<void> saveDailyActivities(List<DailyActivityEntity> activities);
  Future<List<DailyActivityEntity>> getDailyActivities();
  Future<void> addDailyActivity(DailyActivityEntity activity);
  Future<void> clearDailyActivities();

  Future<void> saveWeeklyProgress(Map<String, dynamic> weeklyProgress);
  Future<Map<String, dynamic>?> getWeeklyProgress();

  Future<void> saveAchievements(List<String> achievements);
  Future<List<String>> getAchievements();

  Future<void> clearAllData();
}

class ProfileLocalDataSourceImpl implements ProfileLocalDataSource {
  static const String _profileKey = 'user_profile';
  static const String _preferencesKey = 'user_preferences';
  static const String _dailyActivitiesKey = 'daily_activities';
  static const String _weeklyProgressKey = 'weekly_progress';
  static const String _achievementsKey = 'achievements';

  final SharedPreferences sharedPreferences;

  ProfileLocalDataSourceImpl({required this.sharedPreferences});

  @override
  Future<void> saveProfile(ProfileUserModel profile) async {
    final profileJson = jsonEncode(profile.toMap());
    await sharedPreferences.setString(_profileKey, profileJson);
  }

  @override
  Future<ProfileUserModel?> getProfile() async {
    final profileJson = sharedPreferences.getString(_profileKey);
    if (profileJson == null) return null;

    try {
      final profileMap = jsonDecode(profileJson) as Map<String, dynamic>;
      return ProfileUserModel.fromMap(profileMap);
    } catch (e) {
      // If profile data is corrupted, clear it
      await clearProfile();
      return null;
    }
  }

  @override
  Future<void> clearProfile() async {
    await sharedPreferences.remove(_profileKey);
  }

  @override
  Future<void> savePreferences(UserPreferencesEntity preferences) async {
    final preferencesJson = jsonEncode((preferences as UserPreferencesModel).toMap());
    await sharedPreferences.setString(_preferencesKey, preferencesJson);
  }

  @override
  Future<UserPreferencesEntity?> getPreferences() async {
    final preferencesJson = sharedPreferences.getString(_preferencesKey);
    if (preferencesJson == null) return null;

    try {
      final preferencesMap = jsonDecode(preferencesJson) as Map<String, dynamic>;
      return UserPreferencesModel.fromMap(preferencesMap);
    } catch (e) {
      // If preferences data is corrupted, clear it
      await clearPreferences();
      return null;
    }
  }

  @override
  Future<void> clearPreferences() async {
    await sharedPreferences.remove(_preferencesKey);
  }

  @override
  Future<void> saveDailyActivities(List<DailyActivityEntity> activities) async {
    final activitiesJson = jsonEncode(
      activities.map((activity) => activity.toMap()).toList(),
    );
    await sharedPreferences.setString(_dailyActivitiesKey, activitiesJson);
  }

  @override
  Future<List<DailyActivityEntity>> getDailyActivities() async {
    final activitiesJson = sharedPreferences.getString(_dailyActivitiesKey);
    if (activitiesJson == null) return [];

    try {
      final activitiesList = jsonDecode(activitiesJson) as List<dynamic>;
      return activitiesList
          .map((item) => DailyActivityEntity.fromMap(item as Map<String, dynamic>))
          .toList();
    } catch (e) {
      // If activities data is corrupted, clear it
      await clearDailyActivities();
      return [];
    }
  }

  @override
  Future<void> addDailyActivity(DailyActivityEntity activity) async {
    final activities = await getDailyActivities();

    // Remove existing activity for the same date if it exists
    final existingIndex = activities.indexWhere(
          (existing) => _isSameDay(existing.date, activity.date),
    );

    if (existingIndex != -1) {
      activities[existingIndex] = activity;
    } else {
      activities.add(activity);
    }

    // Keep only last 30 days of activities
    activities.sort((a, b) => b.date.compareTo(a.date));
    if (activities.length > 30) {
      activities.removeRange(30, activities.length);
    }

    await saveDailyActivities(activities);
  }

  @override
  Future<void> clearDailyActivities() async {
    await sharedPreferences.remove(_dailyActivitiesKey);
  }

  @override
  Future<void> saveWeeklyProgress(Map<String, dynamic> weeklyProgress) async {
    final progressJson = jsonEncode(weeklyProgress);
    await sharedPreferences.setString(_weeklyProgressKey, progressJson);
  }

  @override
  Future<Map<String, dynamic>?> getWeeklyProgress() async {
    final progressJson = sharedPreferences.getString(_weeklyProgressKey);
    if (progressJson == null) return null;

    try {
      return jsonDecode(progressJson) as Map<String, dynamic>;
    } catch (e) {
      return null;
    }
  }

  @override
  Future<void> saveAchievements(List<String> achievements) async {
    final achievementsJson = jsonEncode(achievements);
    await sharedPreferences.setString(_achievementsKey, achievementsJson);
  }

  @override
  Future<List<String>> getAchievements() async {
    final achievementsJson = sharedPreferences.getString(_achievementsKey);
    if (achievementsJson == null) return [];

    try {
      final achievementsList = jsonDecode(achievementsJson) as List<dynamic>;
      return achievementsList.map((item) => item.toString()).toList();
    } catch (e) {
      return [];
    }
  }

  @override
  Future<void> clearAllData() async {
    await Future.wait([
      clearProfile(),
      clearPreferences(),
      clearDailyActivities(),
      sharedPreferences.remove(_weeklyProgressKey),
      sharedPreferences.remove(_achievementsKey),
    ]);
  }

  // Helper method to check if two dates are the same day
  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }
}