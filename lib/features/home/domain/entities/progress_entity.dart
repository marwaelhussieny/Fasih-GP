// lib/features/home/domain/entities/progress_entity.dart
class ProgressEntity {
  final String userId;
  final int totalXP;
  final int completedLessons;
  final int currentLevel;
  final List<String> completedLevels;
  final List<String> achievements;
  final DateTime lastActivity;
  final Map<String, dynamic>? stats;

  const ProgressEntity({
    required this.userId,
    required this.totalXP,
    required this.completedLessons,
    required this.currentLevel,
    this.completedLevels = const [],
    this.achievements = const [],
    required this.lastActivity,
    this.stats,
  });

  factory ProgressEntity.fromJson(Map<String, dynamic> json) {
    return ProgressEntity(
      userId: json['userId'] ?? '',
      totalXP: (json['totalXP'] ?? 0).toInt(),
      completedLessons: (json['completedLessons'] ?? 0).toInt(),
      currentLevel: (json['currentLevel'] ?? 1).toInt(),
      completedLevels: List<String>.from(json['completedLevels'] ?? []),
      achievements: List<String>.from(json['achievements'] ?? []),
      lastActivity: DateTime.tryParse(json['lastActivity'] ?? '') ?? DateTime.now(),
      stats: json['stats'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'totalXP': totalXP,
      'completedLessons': completedLessons,
      'currentLevel': currentLevel,
      'completedLevels': completedLevels,
      'achievements': achievements,
      'lastActivity': lastActivity.toIso8601String(),
      'stats': stats,
    };
  }

  ProgressEntity copyWith({
    String? userId,
    int? totalXP,
    int? completedLessons,
    int? currentLevel,
    List<String>? completedLevels,
    List<String>? achievements,
    DateTime? lastActivity,
    Map<String, dynamic>? stats,
  }) {
    return ProgressEntity(
      userId: userId ?? this.userId,
      totalXP: totalXP ?? this.totalXP,
      completedLessons: completedLessons ?? this.completedLessons,
      currentLevel: currentLevel ?? this.currentLevel,
      completedLevels: completedLevels ?? this.completedLevels,
      achievements: achievements ?? this.achievements,
      lastActivity: lastActivity ?? this.lastActivity,
      stats: stats ?? this.stats,
    );
  }
}