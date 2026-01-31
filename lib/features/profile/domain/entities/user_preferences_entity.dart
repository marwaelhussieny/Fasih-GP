// lib/features/profile/domain/entities/user_preferences_entity.dart

import 'package:grad_project/features/profile/domain/entities/accessibility_preferences.dart';

class UserPreferencesEntity {
  final AccessibilityPreferences accessibility;
  final bool darkMode;
  final String language;
  final bool rememberMe;
  final bool notificationsEnabled;

  const UserPreferencesEntity({
    required this.accessibility,
    required this.darkMode,
    required this.language,
    required this.rememberMe,
    required this.notificationsEnabled,
  });

  UserPreferencesEntity copyWith({
    AccessibilityPreferences? accessibility,
    bool? darkMode,
    String? language,
    bool? rememberMe,
    bool? notificationsEnabled,
  }) {
    return UserPreferencesEntity(
      accessibility: accessibility ?? this.accessibility,
      darkMode: darkMode ?? this.darkMode,
      language: language ?? this.language,
      rememberMe: rememberMe ?? this.rememberMe,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
    );
  }
}