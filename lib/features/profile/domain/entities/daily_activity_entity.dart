
// lib/features/profile/domain/entities/daily_activity_entity.dart

class DailyActivityEntity {
  final String? id;
  final DateTime date;
  final int completedLessons;
  final int correctAnswers;
  final int pointsEarned;
  final int timeSpentMinutes;
  final List<String> achievements;

  const DailyActivityEntity({
    this.id,
    required this.date,
    required this.completedLessons,
    required this.correctAnswers,
    required this.pointsEarned,
    required this.timeSpentMinutes,
    required this.achievements,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'date': date.toIso8601String(),
      'completedLessons': completedLessons,
      'correctAnswers': correctAnswers,
      'pointsEarned': pointsEarned,
      'timeSpentMinutes': timeSpentMinutes,
      'achievements': achievements,
    };
  }

  factory DailyActivityEntity.fromMap(Map<String, dynamic> map) {
    return DailyActivityEntity(
      id: map['id'],
      date: DateTime.parse(map['date']),
      completedLessons: map['completedLessons'] ?? 0,
      correctAnswers: map['correctAnswers'] ?? 0,
      pointsEarned: map['pointsEarned'] ?? 0,
      timeSpentMinutes: map['timeSpentMinutes'] ?? 0,
      achievements: List<String>.from(map['achievements'] ?? []),
    );
  }
}