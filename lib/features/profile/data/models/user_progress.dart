// lib/features/profile/domain/entities/user_progress_entity.dart

import 'package:equatable/equatable.dart';

class UserProgressEntity extends Equatable {
  final int totalLessonsCompleted;
  final int totalCorrectAnswers;
  final int totalPoints;
  final int currentStreak; // NEW: Added for ProfileScreen
  final int completedTasks; // NEW: Added for ProfileScreen (assuming tasks are different from lessons)

  const UserProgressEntity({
    this.totalLessonsCompleted = 0,
    this.totalCorrectAnswers = 0,
    this.totalPoints = 0,
    this.currentStreak = 0, // Default value
    this.completedTasks = 0, // Default value
  });

  factory UserProgressEntity.fromMap(Map<String, dynamic> map) {
    return UserProgressEntity(
      totalLessonsCompleted: map['totalLessonsCompleted'] as int? ?? 0,
      totalCorrectAnswers: map['totalCorrectAnswers'] as int? ?? 0,
      totalPoints: map['totalPoints'] as int? ?? 0,
      currentStreak: map['currentStreak'] as int? ?? 0, // Read from map
      completedTasks: map['completedTasks'] as int? ?? 0, // Read from map
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'totalLessonsCompleted': totalLessonsCompleted,
      'totalCorrectAnswers': totalCorrectAnswers,
      'totalPoints': totalPoints,
      'currentStreak': currentStreak, // Add to map
      'completedTasks': completedTasks, // Add to map
    };
  }

  factory UserProgressEntity.empty() {
    return const UserProgressEntity(
      totalLessonsCompleted: 0,
      totalCorrectAnswers: 0,
      totalPoints: 0,
      currentStreak: 0,
      completedTasks: 0,
    );
  }

  @override
  List<Object?> get props => [
    totalLessonsCompleted,
    totalCorrectAnswers,
    totalPoints,
    currentStreak,
    completedTasks,
  ];
}