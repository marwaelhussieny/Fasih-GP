
// lib/features/profile/data/models/accessibility_preferences_model.dart

import 'package:grad_project/features/profile/domain/entities/accessibility_preferences.dart';

class AccessibilityPreferencesModel extends AccessibilityPreferences {
  const AccessibilityPreferencesModel({
    required super.hearingQuestions,
    required super.readingQuestions,
    required super.writingQuestions,
    required super.speakingQuestions,
    required super.soundEffects,
    required super.hapticFeedback,
  });

  factory AccessibilityPreferencesModel.fromMap(Map<String, dynamic> map) {
    return AccessibilityPreferencesModel(
      hearingQuestions: map['hearingQuestions'] ?? true,
      readingQuestions: map['readingQuestions'] ?? false,
      writingQuestions: map['writingQuestions'] ?? false,
      speakingQuestions: map['speakingQuestions'] ?? true,
      soundEffects: map['soundEffects'] ?? true,
      hapticFeedback: map['hapticFeedback'] ?? true,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'hearingQuestions': hearingQuestions,
      'readingQuestions': readingQuestions,
      'writingQuestions': writingQuestions,
      'speakingQuestions': speakingQuestions,
      'soundEffects': soundEffects,
      'hapticFeedback': hapticFeedback,
    };
  }

  @override
  AccessibilityPreferencesModel copyWith({
    bool? hearingQuestions,
    bool? readingQuestions,
    bool? writingQuestions,
    bool? speakingQuestions,
    bool? soundEffects,
    bool? hapticFeedback,
  }) {
    return AccessibilityPreferencesModel(
      hearingQuestions: hearingQuestions ?? this.hearingQuestions,
      readingQuestions: readingQuestions ?? this.readingQuestions,
      writingQuestions: writingQuestions ?? this.writingQuestions,
      speakingQuestions: speakingQuestions ?? this.speakingQuestions,
      soundEffects: soundEffects ?? this.soundEffects,
      hapticFeedback: hapticFeedback ?? this.hapticFeedback,
    );
  }
}
