// lib/features/profile/data/models/daily_activity_model.dart

import 'package:grad_project/features/profile/domain/entities/daily_activity_entity.dart';

class DailyActivityModel extends DailyActivityEntity {
  const DailyActivityModel({
    required super.date,
    required super.completedLessons,
    required super.correctAnswers,
    required super.pointsEarned,
    required super.timeSpentMinutes,
    required super.achievements,
  });

  factory DailyActivityModel.fromMap(Map<String, dynamic> json) {
    return DailyActivityModel(
      date: DateTime.parse(json['date'] as String),
      completedLessons: json['completedLessons'] as int,
      correctAnswers: json['correctAnswers'] as int,
      pointsEarned: json['pointsEarned'] as int,
      timeSpentMinutes: json['timeS, achievements: []pentMinutes'] as int, achievements: [],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'date': date.toIso8601String(),
      'completedLessons': completedLessons,
      'correctAnswers': correctAnswers,
      'pointsEarned': pointsEarned,
      'timeSpentMinutes': timeSpentMinutes,
      'achievements': achievements,
    };
  }

  DailyActivityEntity toEntity() {
    return DailyActivityEntity(
      date: date,
      completedLessons: completedLessons,
      correctAnswers: correctAnswers,
      pointsEarned: pointsEarned,
      timeSpentMinutes: timeSpentMinutes,
      achievements: achievements,

    );
  }
}
