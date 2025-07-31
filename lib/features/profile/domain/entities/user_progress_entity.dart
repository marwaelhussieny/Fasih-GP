// lib/features/profile/domain/entities/user_progress_entity.dart

import 'package:equatable/equatable.dart';

class UserProgressEntity extends Equatable {
  final int totalLessonsCompleted;
  final int totalCorrectAnswers;
  final int totalPoints;
  final int currentStreak;
  final int completedTasks; // Distinct from totalCorrectAnswers

  const UserProgressEntity({
    this.totalLessonsCompleted = 0,
    this.totalCorrectAnswers = 0,
    this.totalPoints = 0,
    this.currentStreak = 0,
    this.completedTasks = 0, // Default value
  });

  // Convenience getter for backward compatibility or specific UI needs
  int get completedLessons => totalLessonsCompleted;

  factory UserProgressEntity.fromMap(Map<String, dynamic> map) {
    return UserProgressEntity(
      totalLessonsCompleted: map['totalLessonsCompleted'] as int? ?? 0,
      totalCorrectAnswers: map['totalCorrectAnswers'] as int? ?? 0,
      totalPoints: map['totalPoints'] as int? ?? 0,
      currentStreak: map['currentStreak'] as int? ?? 0,
      completedTasks: map['completedTasks'] as int? ?? 0, // FIX: No fallback to totalCorrectAnswers
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'totalLessonsCompleted': totalLessonsCompleted,
      'totalCorrectAnswers': totalCorrectAnswers,
      'totalPoints': totalPoints,
      'currentStreak': currentStreak,
      'completedTasks': completedTasks,
      // Backward compatibility if needed, but 'completedLessons' is a getter
      // 'completedLessons': totalLessonsCompleted, // Not needed as it's a getter
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

  UserProgressEntity copyWith({
    int? totalLessonsCompleted,
    int? totalCorrectAnswers,
    int? totalPoints,
    int? currentStreak,
    int? completedTasks,
  }) {
    return UserProgressEntity(
      totalLessonsCompleted: totalLessonsCompleted ?? this.totalLessonsCompleted,
      totalCorrectAnswers: totalCorrectAnswers ?? this.totalCorrectAnswers,
      totalPoints: totalPoints ?? this.totalPoints,
      currentStreak: currentStreak ?? this.currentStreak,
      completedTasks: completedTasks ?? this.completedTasks,
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

  @override
  String toString() {
    return 'UserProgressEntity(totalLessonsCompleted: $totalLessonsCompleted, totalCorrectAnswers: $totalCorrectAnswers, totalPoints: $totalPoints, currentStreak: $currentStreak, completedTasks: $completedTasks)';
  }
}