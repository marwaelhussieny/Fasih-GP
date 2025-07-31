// lib/features/profile/domain/entities/daily_activity_entity.dart

import 'package:equatable/equatable.dart';

class DailyActivityEntity extends Equatable {
  final int lessonsCompleted; // This likely maps to ProfileScreen's 'completedLessons'
  final int correctAnswers;
  final int pointsEarned;

  const DailyActivityEntity({
    this.lessonsCompleted = 0,
    this.correctAnswers = 0,
    this.pointsEarned = 0,
  });

  factory DailyActivityEntity.fromMap(Map<String, dynamic> map) {
    return DailyActivityEntity(
      lessonsCompleted: map['lessonsCompleted'] as int? ?? 0,
      correctAnswers: map['correctAnswers'] as int? ?? 0,
      pointsEarned: map['pointsEarned'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'lessonsCompleted': lessonsCompleted,
      'correctAnswers': correctAnswers,
      'pointsEarned': pointsEarned,
    };
  }

  @override
  List<Object?> get props => [lessonsCompleted, correctAnswers, pointsEarned];
}