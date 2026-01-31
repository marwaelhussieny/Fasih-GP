// lib/features/auth/data/models/auth_user_model.dart

import 'package:grad_project/features/auth/domain/entities/auth_user_entity.dart';

class AuthUserModel extends AuthUserEntity {
  const AuthUserModel({
    required super.id,
    required super.fullName,
    required super.email,
    super.avatar,
    super.avatarUrl,
    super.bio,
    required super.isVerified,
    required super.role,
    required super.createdAt,
    required super.updatedAt,
    required super.preferences,
    required super.profile,
  });

  factory AuthUserModel.fromJson(Map<String, dynamic> json) {
    return AuthUserModel(
      id: json['_id']?.toString() ?? json['id']?.toString() ?? '',
      fullName: json['fullName']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      avatar: json['avatar']?.toString(),
      avatarUrl: json['avatarUrl']?.toString(),
      bio: json['bio']?.toString() ?? '',
      isVerified: json['isVerified'] == true,
      role: json['role']?.toString() ?? 'learner',
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString()) ?? DateTime.now()
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.tryParse(json['updatedAt'].toString()) ?? DateTime.now()
          : DateTime.now(),
      preferences: AuthPreferencesModel.fromJson(
        json['preferences'] as Map<String, dynamic>? ?? {},
      ),
      profile: AuthProfileModel.fromJson(
        json['profile'] as Map<String, dynamic>? ?? {},
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'fullName': fullName,
      'email': email,
      'avatar': avatar,
      'avatarUrl': avatarUrl,
      'bio': bio,
      'isVerified': isVerified,
      'role': role,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'preferences': (preferences as AuthPreferencesModel).toJson(),
      'profile': (profile as AuthProfileModel).toJson(),
    };
  }

  factory AuthUserModel.fromEntity(AuthUserEntity entity) {
    return AuthUserModel(
      id: entity.id,
      fullName: entity.fullName,
      email: entity.email,
      avatar: entity.avatar,
      avatarUrl: entity.avatarUrl,
      bio: entity.bio,
      isVerified: entity.isVerified,
      role: entity.role,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
      preferences: entity.preferences,
      profile: entity.profile,
    );
  }

  AuthUserEntity toEntity() {
    return AuthUserEntity(
      id: id,
      fullName: fullName,
      email: email,
      avatar: avatar,
      avatarUrl: avatarUrl,
      bio: bio,
      isVerified: isVerified,
      role: role,
      createdAt: createdAt,
      updatedAt: updatedAt,
      preferences: preferences,
      profile: profile,
    );
  }
}

class AuthPreferencesModel extends AuthPreferences {
  const AuthPreferencesModel({
    required super.accessibility,
    required super.language,
    required super.darkMode,
    required super.notificationsEnabled,
    required super.rememberMe,
  });

  factory AuthPreferencesModel.fromJson(Map<String, dynamic> json) {
    return AuthPreferencesModel(
      accessibility: AuthAccessibilityModel.fromJson(
        json['accessibility'] as Map<String, dynamic>? ?? {},
      ),
      language: json['language']?.toString() ?? 'arabic',
      darkMode: json['darkMode'] == true,
      notificationsEnabled: json['notificationsEnabled'] == true,
      rememberMe: json['rememberMe'] == true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'accessibility': (accessibility as AuthAccessibilityModel).toJson(),
      'language': language,
      'darkMode': darkMode,
      'notificationsEnabled': notificationsEnabled,
      'rememberMe': rememberMe,
    };
  }
}

class AuthAccessibilityModel extends AuthAccessibility {
  const AuthAccessibilityModel({
    required super.hearingQuestions,
    required super.readingQuestions,
    required super.writingQuestions,
    required super.speakingQuestions,
    required super.soundEffects,
    required super.hapticFeedback,
  });

  factory AuthAccessibilityModel.fromJson(Map<String, dynamic> json) {
    return AuthAccessibilityModel(
      hearingQuestions: json['hearingQuestions'] == true,
      readingQuestions: json['readingQuestions'] == true,
      writingQuestions: json['writingQuestions'] == true,
      speakingQuestions: json['speakingQuestions'] == true,
      soundEffects: json['soundEffects'] == true,
      hapticFeedback: json['hapticFeedback'] == true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'hearingQuestions': hearingQuestions,
      'readingQuestions': readingQuestions,
      'writingQuestions': writingQuestions,
      'speakingQuestions': speakingQuestions,
      'soundEffects': soundEffects,
      'hapticFeedback': hapticFeedback,
    };
  }
}

class AuthProfileModel extends AuthProfile {
  const AuthProfileModel({super.avatar});

  factory AuthProfileModel.fromJson(Map<String, dynamic> json) {
    return AuthProfileModel(
      avatar: json['avatar']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'avatar': avatar,
    };
  }
}