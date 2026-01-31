// lib/features/profile/data/repositories/profile_repository_impl.dart - FIXED

import 'dart:io';
import 'package:grad_project/features/profile/domain/entities/profile_user_entity.dart';
import 'package:grad_project/features/profile/domain/entities/user_preferences_entity.dart';
import 'package:grad_project/features/profile/domain/entities/daily_activity_entity.dart';
import 'package:grad_project/features/profile/domain/repositories/profile_repository.dart';
import 'package:grad_project/features/profile/data/datasources/profile_remote_datasource.dart';
import 'package:grad_project/features/profile/data/datasources/profile_local_datasource.dart';
import 'package:grad_project/features/profile/data/models/profile_user_model.dart';
import 'package:grad_project/core/services/auth_service.dart';
import 'package:grad_project/features/profile/domain/entities/accessibility_preferences.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  final ProfileRemoteDataSource remoteDataSource;
  final ProfileLocalDataSource localDataSource;
  final AuthService authService;

  ProfileRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
    required this.authService,
  });

  @override
  Future<ProfileUserEntity> getProfile() async {
    try {
      // Try to get profile from remote first
      final remoteProfile = await remoteDataSource.getUserData();

      // Save to local storage
      await localDataSource.saveProfile(remoteProfile);

      return remoteProfile.toEntity();
    } catch (e) {
      // If remote fails, try local storage
      try {
        final localProfile = await localDataSource.getProfile();
        if (localProfile != null) {
          return localProfile.toEntity();
        }
      } catch (localError) {
        // Both failed, rethrow original error
        rethrow;
      }
      rethrow;
    }
  }

  @override
  Future<ProfileUserEntity> updateProfile({
    String? fullName,
    String? phoneNumber,
    String? job,
    DateTime? dateOfBirth,
    String? country,
  }) async {
    try {
      final updatedProfile = await remoteDataSource.updateProfile(
        fullName: fullName,
        mobileNumber: phoneNumber,
        dateOfBirth: dateOfBirth,
        country: country,
      );

      // Save updated profile to local storage
      await localDataSource.saveProfile(updatedProfile);

      return updatedProfile.toEntity();
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<String> uploadProfileImage(File imageFile) async {
    throw UnimplementedError(
      'Image upload not implemented - use updateProfileImage with URL',
    );
  }

  @override
  Future<ProfileUserEntity> updateProfileImage(String imageUrl) async {
    try {
      await remoteDataSource.updateAvatar(imageUrl);
      final updatedProfile = await remoteDataSource.getUserData();
      await localDataSource.saveProfile(updatedProfile);
      return updatedProfile.toEntity();
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<UserPreferencesEntity> getPreferences() async {
    try {
      final preferences = await remoteDataSource.getPreferences();

      if (preferences != null) {
        // Save to local storage
        await localDataSource.savePreferences(preferences);
        return preferences;
      } else {
        // Try local storage if remote returns null
        final localPreferences = await localDataSource.getPreferences();
        if (localPreferences != null) {
          return localPreferences;
        }
        throw Exception('No preferences found');
      }
    } catch (e) {
      // Try local storage if remote fails
      final localPreferences = await localDataSource.getPreferences();
      if (localPreferences != null) {
        return localPreferences;
      }
      rethrow;
    }
  }

  @override
  Future<UserPreferencesEntity> updatePreferences(
      UserPreferencesEntity preferences,
      ) async {
    try {
      final updatedPreferences = await remoteDataSource.updatePreferences(
        preferences,
      );

      // Save to local storage
      await localDataSource.savePreferences(updatedPreferences);

      return updatedPreferences;
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> updateAccessibilityPreference(String key, bool value) async {
    try {
      // Get the current preferences
      final currentPreferences = await localDataSource.getPreferences();
      if (currentPreferences == null) {
        throw Exception('No local preferences found to update.');
      }

      final updatedAccessibility = _updateAccessibilityInPreferences(
        currentPreferences.accessibility,
        key,
        value,
      );

      // Create a map for the remote update
      final accessibilityMap = {
        'hearingQuestions': updatedAccessibility.hearingQuestions,
        'readingQuestions': updatedAccessibility.readingQuestions,
        'writingQuestions': updatedAccessibility.writingQuestions,
        'speakingQuestions': updatedAccessibility.speakingQuestions,
        'soundEffects': updatedAccessibility.soundEffects,
        'hapticFeedback': updatedAccessibility.hapticFeedback,
      };

      // Update on remote
      await remoteDataSource.updateAccessibility(accessibilityMap);

      // Update local preferences
      final updatedPreferences = currentPreferences.copyWith(
        accessibility: updatedAccessibility,
      );
      await localDataSource.savePreferences(updatedPreferences);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> updateGeneralPreference(String key, dynamic value) async {
    try {
      if (key == 'notificationsEnabled' && value is bool) {
        await remoteDataSource.updateNotifications(value);
      }

      // Update local preferences
      final currentPreferences = await localDataSource.getPreferences();
      if (currentPreferences != null) {
        UserPreferencesEntity updatedPreferences;

        switch (key) {
          case 'notificationsEnabled':
            updatedPreferences = currentPreferences.copyWith(
              notificationsEnabled: value as bool,
            );
            break;
          case 'darkMode':
            updatedPreferences = currentPreferences.copyWith(
              darkMode: value as bool,
            );
            break;
          case 'rememberMe':
            updatedPreferences = currentPreferences.copyWith(
              rememberMe: value as bool,
            );
            break;
          default:
            return;
        }

        await localDataSource.savePreferences(updatedPreferences);
      }
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> changePassword(String oldPassword, String newPassword) async {
    try {
      await remoteDataSource.changePassword(oldPassword, newPassword);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> changeEmail(String newEmail) async {
    try {
      await remoteDataSource.changeEmail(newEmail);
      // Refresh user data after email change
      await getProfile();
    } catch (e) {
      rethrow;
    }
  }

  // Helper method to update accessibility preferences
  AccessibilityPreferences _updateAccessibilityInPreferences(
      AccessibilityPreferences current,
      String key,
      bool value,
      ) {
    switch (key) {
      case 'hearingQuestions':
        return current.copyWith(hearingQuestions: value);
      case 'readingQuestions':
        return current.copyWith(readingQuestions: value);
      case 'writingQuestions':
        return current.copyWith(writingQuestions: value);
      case 'speakingQuestions':
        return current.copyWith(speakingQuestions: value);
      case 'soundEffects':
        return current.copyWith(soundEffects: value);
      case 'hapticFeedback':
        return current.copyWith(hapticFeedback: value);
      default:
        return current;
    }
  }

  @override
  Future<List<DailyActivityEntity>> getDailyActivities({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    return await localDataSource.getDailyActivities();
  }

  @override
  Future<DailyActivityEntity?> getDailyActivity(DateTime date) async {
    final activities = await localDataSource.getDailyActivities();
    try {
      return activities.firstWhere(
            (activity) => _isSameDay(activity.date, date),
      );
    } catch (e) {
      return null;
    }
  }

  @override
  Future<Map<String, dynamic>> getWeeklyProgress() async {
    return await localDataSource.getWeeklyProgress() ?? {};
  }

  @override
  Future<Map<String, dynamic>> getMonthlyStats() async {
    return {
      'totalDays': 30,
      'activeDays': 15,
      'averageScore': 85,
      'totalMinutes': 450,
      'completedLessons': 25,
    };
  }

  @override
  Future<List<String>> getAchievements() async {
    return await localDataSource.getAchievements();
  }

  @override
  Future<void> updateNotificationSettings(bool enabled) async {
    await updateGeneralPreference('notificationsEnabled', enabled);
  }

  @override
  Future<void> updateLanguagePreference(String language) async {
    final currentPreferences = await localDataSource.getPreferences();
    if (currentPreferences != null) {
      final updatedPreferences = currentPreferences.copyWith(
        language: language,
      );
      await localDataSource.savePreferences(updatedPreferences);
    }
  }

  @override
  Future<void> updateThemePreference(bool darkMode) async {
    await updateGeneralPreference('darkMode', darkMode);
  }

  @override
  Future<void> resetProgress() async {
    await localDataSource.clearDailyActivities();
  }

  @override
  Future<void> exportData() async {
    throw UnimplementedError('Export data not implemented');
  }

  @override
  Future<void> deleteAccount() async {
    await remoteDataSource.logout();
    await localDataSource.clearAllData();
    // FIXED: Use the correct method name from AuthService
    await authService.clearAll();
  }

  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }
}