// lib/features/profile/domain/entities/user_entity.dart

import 'package:equatable/equatable.dart';
// import 'package:cloud_firestore/cloud_firestore.dart'; // No longer needed if dates are strings
import 'package:grad_project/features/profile/domain/entities/user_progress_entity.dart';
import 'package:grad_project/features/profile/domain/entities/daily_activity_entity.dart';

class UserEntity extends Equatable {
  final String id;
  final String name;
  final String email;
  final String? profileImageUrl;
  final String phoneNumber;
  final String job;
  final String level;
  final String status;
  final DateTime? dateOfBirth;
  final DateTime? memberSince;
  final UserProgressEntity progress;
  final List<DailyActivityEntity> dailyActivities;

  const UserEntity({
    required this.id,
    required this.name,
    required this.email,
    this.profileImageUrl,
    this.phoneNumber = '',
    this.job = '',
    this.level = 'مبتدئ',
    this.status = 'نشط',
    this.dateOfBirth,
    this.memberSince,
    required this.progress,
    this.dailyActivities = const [],
  });

  factory UserEntity.fromMap(Map<String, dynamic> map, String uid) {
    // FIX: Parse date string if it's a string, otherwise handle as DateTime
    final DateTime? dateOfBirth = map['dateOfBirth'] is String
        ? DateTime.parse(map['dateOfBirth'] as String)
        : (map['dateOfBirth'] is DateTime ? map['dateOfBirth'] as DateTime : null);

    final DateTime? memberSince = map['memberSince'] is String
        ? DateTime.parse(map['memberSince'] as String)
        : (map['memberSince'] is DateTime ? map['memberSince'] as DateTime : null);

    final List<DailyActivityEntity> dailyActivitiesList = [];
    if (map['dailyActivities'] is List) {
      for (var item in map['dailyActivities']) {
        if (item is Map<String, dynamic>) {
          dailyActivitiesList.add(DailyActivityEntity.fromMap(item));
        }
      }
    }

    final UserProgressEntity userProgress = map['progress'] != null
        ? UserProgressEntity.fromMap(map['progress'] as Map<String, dynamic>)
        : UserProgressEntity.empty();

    return UserEntity(
      id: uid,
      name: map['name'] as String? ?? '',
      email: map['email'] as String? ?? '',
      profileImageUrl: map['profileImageUrl'] as String?,
      phoneNumber: map['phoneNumber'] as String? ?? '',
      job: map['job'] as String? ?? '',
      level: map['level'] as String? ?? 'مبتدئ',
      status: map['status'] as String? ?? 'نشط',
      dateOfBirth: dateOfBirth,
      memberSince: memberSince,
      progress: userProgress,
      dailyActivities: dailyActivitiesList,
    );
  }

  Map<String, dynamic> toMap() {
    final List<Map<String, dynamic>> serializedDailyActivities =
    dailyActivities.map((activity) => activity.toMap()).toList();

    return {
      'name': name,
      'email': email,
      'profileImageUrl': profileImageUrl,
      'phoneNumber': phoneNumber,
      'job': job,
      'level': level,
      'status': status,
      // FIX: Convert DateTime to ISO 8601 String for Firestore
      'dateOfBirth': dateOfBirth?.toIso8601String(),
      'memberSince': memberSince?.toIso8601String(),
      'progress': progress.toMap(),
      'dailyActivities': serializedDailyActivities,
    };
  }

  UserEntity copyWith({
    String? id,
    String? name,
    String? email,
    String? profileImageUrl,
    String? phoneNumber,
    String? job,
    String? level,
    String? status,
    DateTime? dateOfBirth,
    DateTime? memberSince,
    UserProgressEntity? progress,
    List<DailyActivityEntity>? dailyActivities,
  }) {
    return UserEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      job: job ?? this.job,
      level: level ?? this.level,
      status: status ?? this.status,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      memberSince: memberSince ?? this.memberSince,
      progress: progress ?? this.progress,
      dailyActivities: dailyActivities ?? this.dailyActivities,
    );
  }

  @override
  List<Object?> get props => [
    id,
    name,
    email,
    profileImageUrl,
    phoneNumber,
    job,
    level,
    status,
    dateOfBirth,
    memberSince,
    progress,
    dailyActivities,
  ];

  @override
  String toString() {
    return 'UserEntity(id: $id, name: $name, email: $email, profileImageUrl: $profileImageUrl, phoneNumber: $phoneNumber, job: $job, dateOfBirth: $dateOfBirth, memberSince: $memberSince, progress: $progress, dailyActivities: $dailyActivities)';
  }
}