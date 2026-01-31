
// lib/features/profile/domain/entities/accessibility_preferences.dart

class AccessibilityPreferences {
  final bool hearingQuestions;
  final bool readingQuestions;
  final bool writingQuestions;
  final bool speakingQuestions;
  final bool soundEffects;
  final bool hapticFeedback;

  const AccessibilityPreferences({
    required this.hearingQuestions,
    required this.readingQuestions,
    required this.writingQuestions,
    required this.speakingQuestions,
    required this.soundEffects,
    required this.hapticFeedback,
  });

  AccessibilityPreferences copyWith({
    bool? hearingQuestions,
    bool? readingQuestions,
    bool? writingQuestions,
    bool? speakingQuestions,
    bool? soundEffects,
    bool? hapticFeedback,
  }) {
    return AccessibilityPreferences(
      hearingQuestions: hearingQuestions ?? this.hearingQuestions,
      readingQuestions: readingQuestions ?? this.readingQuestions,
      writingQuestions: writingQuestions ?? this.writingQuestions,
      speakingQuestions: speakingQuestions ?? this.speakingQuestions,
      soundEffects: soundEffects ?? this.soundEffects,
      hapticFeedback: hapticFeedback ?? this.hapticFeedback,
    );
  }
}