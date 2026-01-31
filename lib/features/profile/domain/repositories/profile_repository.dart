// lib/features/profile/domain/repositories/profile_repository.dart

import 'dart:io';
import 'package:grad_project/features/profile/domain/entities/profile_user_entity.dart';
import 'package:grad_project/features/profile/domain/entities/user_preferences_entity.dart';
import 'package:grad_project/features/profile/domain/entities/daily_activity_entity.dart';

abstract class ProfileRepository {
  // User Profile Management
  Future<ProfileUserEntity> getProfile();
  Future<ProfileUserEntity> updateProfile({
    String? fullName,
    String? phoneNumber,
    String? job,
    DateTime? dateOfBirth,
    String? country,
  });
  Future<String> uploadProfileImage(File imageFile);
  Future<ProfileUserEntity> updateProfileImage(String imageUrl);

  // Preferences Management
  Future<UserPreferencesEntity> getPreferences();
  Future<UserPreferencesEntity> updatePreferences(UserPreferencesEntity preferences);
  Future<void> updateAccessibilityPreference(String key, bool value);
  Future<void> updateGeneralPreference(String key, dynamic value);
  Future<void> updateNotificationSettings(bool enabled);
  Future<void> updateLanguagePreference(String language);
  Future<void> updateThemePreference(bool darkMode);

  // Security Management
  Future<void> changePassword(String oldPassword, String newPassword);
  Future<void> changeEmail(String newEmail);

  // Activity & Progress Management
  Future<List<DailyActivityEntity>> getDailyActivities({
    DateTime? startDate,
    DateTime? endDate,
  });
  Future<DailyActivityEntity?> getDailyActivity(DateTime date);
  Future<Map<String, dynamic>> getWeeklyProgress();
  Future<Map<String, dynamic>> getMonthlyStats();
  Future<List<String>> getAchievements();

  // Utility Methods
  Future<void> resetProgress();
  Future<void> exportData();
  Future<void> deleteAccount();
}