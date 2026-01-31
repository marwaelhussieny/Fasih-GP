// lib/features/auth/domain/entities/auth_user_entity.dart
// This is a lightweight auth-specific user entity that maps to your backend response

class AuthUserEntity {
  final String id;
  final String fullName;
  final String email;
  final String? avatar;
  final String? avatarUrl;
  final String? bio;
  final bool isVerified;
  final String role;
  final DateTime createdAt;
  final DateTime updatedAt;
  final AuthPreferences preferences;
  final AuthProfile profile;

  const AuthUserEntity({
    required this.id,
    required this.fullName,
    required this.email,
    this.avatar,
    this.avatarUrl,
    this.bio,
    required this.isVerified,
    required this.role,
    required this.createdAt,
    required this.updatedAt,
    required this.preferences,
    required this.profile,
  });

  AuthUserEntity copyWith({
    String? id,
    String? fullName,
    String? email,
    String? avatar,
    String? avatarUrl,
    String? bio,
    bool? isVerified,
    String? role,
    DateTime? createdAt,
    DateTime? updatedAt,
    AuthPreferences? preferences,
    AuthProfile? profile,
  }) {
    return AuthUserEntity(
      id: id ?? this.id,
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      avatar: avatar ?? this.avatar,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      bio: bio ?? this.bio,
      isVerified: isVerified ?? this.isVerified,
      role: role ?? this.role,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      preferences: preferences ?? this.preferences,
      profile: profile ?? this.profile,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AuthUserEntity && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'AuthUserEntity(id: $id, fullName: $fullName, email: $email)';
  }
}

class AuthPreferences {
  final AuthAccessibility accessibility;
  final String language;
  final bool darkMode;
  final bool notificationsEnabled;
  final bool rememberMe;

  const AuthPreferences({
    required this.accessibility,
    required this.language,
    required this.darkMode,
    required this.notificationsEnabled,
    required this.rememberMe,
  });
}

class AuthAccessibility {
  final bool hearingQuestions;
  final bool readingQuestions;
  final bool writingQuestions;
  final bool speakingQuestions;
  final bool soundEffects;
  final bool hapticFeedback;

  const AuthAccessibility({
    required this.hearingQuestions,
    required this.readingQuestions,
    required this.writingQuestions,
    required this.speakingQuestions,
    required this.soundEffects,
    required this.hapticFeedback,
  });
}

class AuthProfile {
  final String? avatar;

  const AuthProfile({this.avatar});
}