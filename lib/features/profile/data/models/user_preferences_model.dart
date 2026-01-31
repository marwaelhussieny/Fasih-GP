// lib/features/profile/data/models/user_preferences_model.dart

import 'package:grad_project/features/profile/domain/entities/user_preferences_entity.dart';
import 'package:grad_project/features/profile/domain/entities/accessibility_preferences.dart';
import 'package:grad_project/features/profile/data/models/accessibility_preferences_model.dart';

class UserPreferencesModel extends UserPreferencesEntity {
const UserPreferencesModel({
required super.accessibility,
required super.darkMode,
required super.language,
required super.rememberMe,
required super.notificationsEnabled,
});

factory UserPreferencesModel.fromMap(Map<String, dynamic> map) {
return UserPreferencesModel(
accessibility: map['accessibility'] != null
? AccessibilityPreferencesModel.fromMap(map['accessibility'])
    : const AccessibilityPreferencesModel(
hearingQuestions: true,
readingQuestions: false,
writingQuestions: false,
speakingQuestions: true,
soundEffects: true,
hapticFeedback: true,
),
darkMode: map['darkMode'] ?? false,
language: map['language'] ?? 'arabic',
rememberMe: map['rememberMe'] ?? true,
notificationsEnabled: map['notificationsEnabled'] ?? true,
);
}

Map<String, dynamic> toMap() {
return {
'accessibility': (accessibility as AccessibilityPreferencesModel).toMap(),
'darkMode': darkMode,
'language': language,
'rememberMe': rememberMe,
'notificationsEnabled': notificationsEnabled,
};
}

@override
UserPreferencesModel copyWith({
AccessibilityPreferences? accessibility,
bool? darkMode,
String? language,
bool? rememberMe,
bool? notificationsEnabled,
}) {
return UserPreferencesModel(
accessibility: accessibility ?? this.accessibility,
darkMode: darkMode ?? this.darkMode,
language: language ?? this.language,
rememberMe: rememberMe ?? this.rememberMe,
notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
);
}
}