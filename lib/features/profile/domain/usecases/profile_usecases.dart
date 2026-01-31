// lib/features/profile/domain/usecases/profile_usecases.dart

import 'dart:io';
import 'package:grad_project/features/profile/domain/entities/profile_user_entity.dart';
import 'package:grad_project/features/profile/domain/entities/user_preferences_entity.dart';
import 'package:grad_project/features/profile/domain/entities/daily_activity_entity.dart';
import 'package:grad_project/features/profile/domain/repositories/profile_repository.dart';

// Profile Management Use Cases
class GetProfileUseCase {
  final ProfileRepository repository;

  GetProfileUseCase({required this.repository});

  Future<ProfileUserEntity> call() async {
    return await repository.getProfile();
  }
}

class UpdateProfileUseCase {
  final ProfileRepository repository;

  UpdateProfileUseCase({required this.repository});

  Future<ProfileUserEntity> call({
    String? fullName,
    String? phoneNumber,
    String? job,
    DateTime? dateOfBirth,
    String? country, // Added country parameter
    String?email
  }) async {
    return await repository.updateProfile(
      fullName: fullName,
      phoneNumber: phoneNumber,
      job: job,
      dateOfBirth: dateOfBirth,
    );
  }
}

class UploadProfileImageUseCase {
  final ProfileRepository repository;

  UploadProfileImageUseCase({required this.repository});

  Future<String> call(File imageFile) async {
    return await repository.uploadProfileImage(imageFile);
  }
}

class UpdateProfileImageUseCase {
  final ProfileRepository repository;

  UpdateProfileImageUseCase({required this.repository});

  Future<ProfileUserEntity> call(String imageUrl) async {
    return await repository.updateProfileImage(imageUrl);
  }
}

// Preferences Use Cases
class GetPreferencesUseCase {
  final ProfileRepository repository;

  GetPreferencesUseCase({required this.repository});

  Future<UserPreferencesEntity?> call() async {
    return await repository.getPreferences();
  }
}

class UpdatePreferencesUseCase {
  final ProfileRepository repository;

  UpdatePreferencesUseCase({required this.repository});

  Future<UserPreferencesEntity> call(UserPreferencesEntity preferences) async {
    return await repository.updatePreferences(preferences);
  }
}

class UpdateAccessibilityPreferenceUseCase {
  final ProfileRepository repository;

  UpdateAccessibilityPreferenceUseCase({required this.repository});

  Future<void> call(String key, bool value) async {
    await repository.updateAccessibilityPreference(key, value);
  }
}

class UpdateGeneralPreferenceUseCase {
  final ProfileRepository repository;

  UpdateGeneralPreferenceUseCase({required this.repository});

  Future<void> call(String key, dynamic value) async {
    await repository.updateGeneralPreference(key, value);
  }
}

// Activity & Progress Use Cases
class GetDailyActivitiesUseCase {
  final ProfileRepository repository;

  GetDailyActivitiesUseCase({required this.repository});

  Future<List<DailyActivityEntity>> call({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    return await repository.getDailyActivities(
      startDate: startDate,
      endDate: endDate,
    );
  }
}

class GetDailyActivityUseCase {
  final ProfileRepository repository;

  GetDailyActivityUseCase({required this.repository});

  Future<DailyActivityEntity?> call(DateTime date) async {
    return await repository.getDailyActivity(date);
  }
}

class GetWeeklyProgressUseCase {
  final ProfileRepository repository;

  GetWeeklyProgressUseCase({required this.repository});

  Future<Map<String, dynamic>> call() async {
    return await repository.getWeeklyProgress();
  }
}

class GetMonthlyStatsUseCase {
  final ProfileRepository repository;

  GetMonthlyStatsUseCase({required this.repository});

  Future<Map<String, dynamic>> call() async {
    return await repository.getMonthlyStats();
  }
}

class GetAchievementsUseCase {
  final ProfileRepository repository;

  GetAchievementsUseCase({required this.repository});

  Future<List<String>> call() async {
    return await repository.getAchievements();
  }
}

// Settings Use Cases
class UpdateNotificationSettingsUseCase {
  final ProfileRepository repository;

  UpdateNotificationSettingsUseCase({required this.repository});

  Future<void> call(bool enabled) async {
    await repository.updateNotificationSettings(enabled);
  }
}

class UpdateLanguagePreferenceUseCase {
  final ProfileRepository repository;

  UpdateLanguagePreferenceUseCase({required this.repository});

  Future<void> call(String language) async {
    await repository.updateLanguagePreference(language);
  }
}

class UpdateThemePreferenceUseCase {
  final ProfileRepository repository;

  UpdateThemePreferenceUseCase({required this.repository});

  Future<void> call(bool darkMode) async {
    await repository.updateThemePreference(darkMode);
  }
}

// Security Use Cases
class ChangePasswordUseCase {
  final ProfileRepository repository;

  ChangePasswordUseCase({required this.repository});

  Future<void> call(String oldPassword, String newPassword) async {
    await repository.changePassword(oldPassword, newPassword);
  }
}

class ChangeEmailUseCase {
  final ProfileRepository repository;

  ChangeEmailUseCase({required this.repository});

  Future<void> call(String newEmail) async {
    await repository.changeEmail(newEmail);
  }
}

class ResetProgressUseCase {
  final ProfileRepository repository;

  ResetProgressUseCase({required this.repository});

  Future<void> call() async {
    await repository.resetProgress();
  }
}

class ExportDataUseCase {
  final ProfileRepository repository;

  ExportDataUseCase({required this.repository});

  Future<void> call() async {
    await repository.exportData();
  }
}

class DeleteAccountUseCase {
  final ProfileRepository repository;

  DeleteAccountUseCase({required this.repository});

  Future<void> call() async {
    await repository.deleteAccount();
  }
}