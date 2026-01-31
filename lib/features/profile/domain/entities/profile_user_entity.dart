// lib/features/profile/domain/entities/profile_user_entity.dart

import 'package:grad_project/features/profile/domain/entities/user_preferences_entity.dart';

class ProfileUserEntity {
  final String id;
  final String? fullName;
  final String? email;
  final String? avatarUrl;
  final String? job;
  final String? country;
  final DateTime? dateOfBirth;
  final String? mobileNumber;
  final bool? isVerified;
  final DateTime? createdAt;
  final UserPreferencesEntity? preferences;
  final double? progress;

  const ProfileUserEntity({
    required this.id,
    this.fullName,
    this.email,
    this.avatarUrl,
    this.job,
    this.country,
    this.dateOfBirth,
    this.mobileNumber,
    this.isVerified,
    this.createdAt,
    this.preferences,
    this.progress,
  });

  // Helper getters
  String get name => fullName ?? '';
  String get phoneNumber => mobileNumber ?? '';

  ProfileUserEntity copyWith({
    String? id,
    String? fullName,
    String? email,
    String? avatarUrl,
    String? job,
    String? country,
    DateTime? dateOfBirth,
    String? mobileNumber,
    bool? isVerified,
    DateTime? createdAt,
    UserPreferencesEntity? preferences,
    double? progress,
  }) {
    return ProfileUserEntity(
      id: id ?? this.id,
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      job: job ?? this.job,
      country: country ?? this.country,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      mobileNumber: mobileNumber ?? this.mobileNumber,
      isVerified: isVerified ?? this.isVerified,
      createdAt: createdAt ?? this.createdAt,
      preferences: preferences ?? this.preferences,
      progress: progress ?? this.progress,
    );
  }
}