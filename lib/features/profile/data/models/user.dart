// lib/features/profile/domain/entities/daily_activity_entity.dart

import 'package:equatable/equatable.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // For Timestamp

class DailyActivityEntity extends Equatable {
  final DateTime date; // NEW: Added date field
  final int lessonsCompleted;
  final int correctAnswers;
  final int pointsEarned;
  // Note: 'completedTasks' and 'totalPoints' are not part of this entity
  // as per the current structure. They belong to UserProgressEntity.

  const DailyActivityEntity({
    required this.date, // Date is now required
    this.lessonsCompleted = 0,
    this.correctAnswers = 0,
    this.pointsEarned = 0,
  });

  factory DailyActivityEntity.fromMap(Map<String, dynamic> map) {
    return DailyActivityEntity(
      date: (map['date'] as Timestamp).toDate(), // Convert Timestamp to DateTime
      lessonsCompleted: map['lessonsCompleted'] as int? ?? 0,
      correctAnswers: map['correctAnswers'] as int? ?? 0,
      pointsEarned: map['pointsEarned'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'date': Timestamp.fromDate(date), // Convert DateTime to Timestamp for Firestore
      'lessonsCompleted': lessonsCompleted,
      'correctAnswers': correctAnswers,
      'pointsEarned': pointsEarned,
    };
  }

  @override
  List<Object?> get props => [date, lessonsCompleted, correctAnswers, pointsEarned];
}