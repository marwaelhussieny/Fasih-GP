// ============================================
// 1. UPDATED ProfileUserModel - Fixed for your backend structure
// ============================================

// lib/features/profile/data/models/profile_user_model.dart
import 'package:grad_project/features/profile/domain/entities/profile_user_entity.dart';
import 'package:grad_project/features/profile/data/models/user_preferences_model.dart';
import '../../domain/entities/user_preferences_entity.dart';

class ProfileUserModel extends ProfileUserEntity {
  const ProfileUserModel({
    required super.id,
    super.fullName,
    super.email,
    super.avatarUrl,
    super.job,
    super.country,
    super.dateOfBirth,
    super.mobileNumber,
    super.isVerified,
    super.createdAt,
    super.preferences,
    super.progress,
  });

  factory ProfileUserModel.fromMap(Map<String, dynamic> json) {
    // Handle the nested structure from your backend
    final data = json['data'] ?? json;

    return ProfileUserModel(
      id: data['id'] ?? data['_id'], // Handle both id formats
      fullName: data['fullName'], // Direct from backend
      email: data['email'], // Direct from backend
      avatarUrl: data['avatarUrl'] ?? data['profile']?['avatar'], // Handle both formats
      job: data['job'] ?? data['profile']?['job'], // Optional field
      country: data['country'], // Direct from backend
      dateOfBirth: data['dateOfBirth'] != null
          ? DateTime.parse(data['dateOfBirth'] as String)
          : null,
      mobileNumber: data['mobileNumber'] ?? data['profile']?['mobileNumber'],
      isVerified: data['isVerified'] as bool?,
      createdAt: data['createdAt'] != null
          ? DateTime.parse(data['createdAt'] as String)
          : null,
      preferences: data['preferences'] != null
          ? UserPreferencesModel.fromMap(data['preferences'] as Map<String, dynamic>)
          : null,
      progress: data['progress'] as double?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'fullName': fullName,
      'email': email,
      'avatarUrl': avatarUrl,
      'job': job,
      'country': country,
      'dateOfBirth': dateOfBirth?.toIso8601String(),
      'mobileNumber': mobileNumber,
      'isVerified': isVerified,
      'createdAt': createdAt?.toIso8601String(),
      'preferences': preferences != null
          ? (preferences as UserPreferencesModel).toMap()
          : null,
      'progress': progress,
    };
  }

  @override
  ProfileUserEntity toEntity() {
    return ProfileUserEntity(
      id: id,
      fullName: fullName,
      email: email,
      avatarUrl: avatarUrl,
      job: job,
      country: country,
      dateOfBirth: dateOfBirth,
      mobileNumber: mobileNumber,
      isVerified: isVerified,
      createdAt: createdAt,
      preferences: preferences,
      progress: progress,
    );
  }

  factory ProfileUserModel.fromEntity(ProfileUserEntity entity) {
    return ProfileUserModel(
      id: entity.id,
      fullName: entity.fullName,
      email: entity.email,
      avatarUrl: entity.avatarUrl,
      job: entity.job,
      country: entity.country,
      dateOfBirth: entity.dateOfBirth,
      mobileNumber: entity.mobileNumber,
      isVerified: entity.isVerified,
      createdAt: entity.createdAt,
      preferences: entity.preferences,
      progress: entity.progress,
    );
  }

  @override
  ProfileUserModel copyWith({
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
    return ProfileUserModel(
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