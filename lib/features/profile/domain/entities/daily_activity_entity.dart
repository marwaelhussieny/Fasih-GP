// lib/features/profile/domain/entities/daily_activity_entity.dart

import 'package:equatable/equatable.dart';
// import 'package:cloud_firestore/cloud_firestore.dart'; // No longer needed if dates are strings

class DailyActivityEntity extends Equatable {
  final String id;
  final DateTime date;
  final int completedLessons;
  final int correctAnswers;
  final int pointsEarned;
  final int timeSpentMinutes;
  final List<String> achievements;

  const DailyActivityEntity({
    required this.id,
    required this.date,
    this.completedLessons = 0,
    this.correctAnswers = 0,
    this.pointsEarned = 0,
    this.timeSpentMinutes = 0,
    this.achievements = const [],
  });

  factory DailyActivityEntity.fromMap(Map<String, dynamic> map) {
    return DailyActivityEntity(
      id: map['id'] as String? ?? '',
      // FIX: Parse date string if it's a string, otherwise handle as DateTime (Firestore might send DateTime for new entries)
      date: map['date'] is String
          ? DateTime.parse(map['date'] as String)
          : (map['date'] is DateTime
          ? map['date'] as DateTime
          : DateTime.now()), // Fallback to DateTime.now()
      completedLessons: map['completedLessons'] as int? ?? 0,
      correctAnswers: map['correctAnswers'] as int? ?? 0,
      pointsEarned: map['pointsEarned'] as int? ?? 0,
      timeSpentMinutes: map['timeSpentMinutes'] as int? ?? 0,
      achievements: List<String>.from(map['achievements'] as List? ?? []),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      // FIX: Convert DateTime to ISO 8601 String for Firestore
      'date': date.toIso8601String(),
      'completedLessons': completedLessons,
      'correctAnswers': correctAnswers,
      'pointsEarned': pointsEarned,
      'timeSpentMinutes': timeSpentMinutes,
      'achievements': achievements,
    };
  }

  factory DailyActivityEntity.empty() {
    return DailyActivityEntity(
      id: '',
      date: DateTime.now(),
      completedLessons: 0,
      correctAnswers: 0,
      pointsEarned: 0,
      timeSpentMinutes: 0,
      achievements: const [],
    );
  }

  DailyActivityEntity copyWith({
    String? id,
    DateTime? date,
    int? completedLessons,
    int? correctAnswers,
    int? pointsEarned,
    int? timeSpentMinutes,
    List<String>? achievements,
  }) {
    return DailyActivityEntity(
      id: id ?? this.id,
      date: date ?? this.date,
      completedLessons: completedLessons ?? this.completedLessons,
      correctAnswers: correctAnswers ?? this.correctAnswers,
      pointsEarned: pointsEarned ?? this.pointsEarned,
      timeSpentMinutes: timeSpentMinutes ?? this.timeSpentMinutes,
      achievements: achievements ?? this.achievements,
    );
  }

  @override
  List<Object?> get props => [
    id,
    date,
    completedLessons,
    correctAnswers,
    pointsEarned,
    timeSpentMinutes,
    achievements,
  ];

  @override
  String toString() {
    return 'DailyActivityEntity(id: $id, date: $date, completedLessons: $completedLessons, correctAnswers: $correctAnswers, pointsEarned: $pointsEarned, timeSpentMinutes: $timeSpentMinutes, achievements: $achievements)';
  }
}