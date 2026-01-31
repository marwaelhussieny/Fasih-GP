// lib/features/home/data/models/progress_model.dart - CORRECTED

class ProgressModel {
  final String id;
  final String userId;
  final String? lessonId;
  final bool isCompleted;
  final DateTime completedAt;
  final int streak;
  final DateTime lastStreakDate;
  final List<String> videosWatched;
  final String type; // 'lesson' or 'streak'
  final DateTime date;
  final DateTime createdAt;
  final DateTime updatedAt;

  const ProgressModel({
    required this.id,
    required this.userId,
    this.lessonId,
    required this.isCompleted,
    required this.completedAt,
    required this.streak,
    required this.lastStreakDate,
    required this.videosWatched,
    required this.type,
    required this.date,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ProgressModel.fromJson(Map<String, dynamic> json) {
    return ProgressModel(
      id: json['_id'] as String,
      userId: json['userId'] as String,
      lessonId: json['lessonId'] as String?,
      isCompleted: json['isCompleted'] as bool,
      completedAt: DateTime.parse(json['completedAt'] as String),
      streak: json['streak'] as int,
      lastStreakDate: DateTime.parse(json['lastStreakDate'] as String),
      videosWatched: List<String>.from(json['videosWatched'] as List? ?? []),
      type: json['type'] as String,
      date: DateTime.parse(json['date'] as String),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'userId': userId,
      'lessonId': lessonId,
      'isCompleted': isCompleted,
      'completedAt': completedAt.toIso8601String(),
      'streak': streak,
      'lastStreakDate': lastStreakDate.toIso8601String(),
      'videosWatched': videosWatched,
      'type': type,
      'date': date.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  // Helper methods for progress calculation
  bool get isLessonCompleted => isCompleted && type == 'lesson';
  bool get isStreakRecord => type == 'streak';

  // Get progress percentage (0-100)
  int get progressPercentage => isCompleted ? 100 : 0;

  // Copy with method for immutability
  ProgressModel copyWith({
    String? id,
    String? userId,
    String? lessonId,
    bool? isCompleted,
    DateTime? completedAt,
    int? streak,
    DateTime? lastStreakDate,
    List<String>? videosWatched,
    String? type,
    DateTime? date,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ProgressModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      lessonId: lessonId ?? this.lessonId,
      isCompleted: isCompleted ?? this.isCompleted,
      completedAt: completedAt ?? this.completedAt,
      streak: streak ?? this.streak,
      lastStreakDate: lastStreakDate ?? this.lastStreakDate,
      videosWatched: videosWatched ?? this.videosWatched,
      type: type ?? this.type,
      date: date ?? this.date,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

// Additional model for aggregated statistics
class ProgressStatsModel {
  final int completedLessons;
  final int highestStreak;
  final int currentStreak;
  final DateTime? lastActive;
  final int totalPoints;
  final Map<String, dynamic> additionalStats;

  const ProgressStatsModel({
    required this.completedLessons,
    required this.highestStreak,
    required this.currentStreak,
    this.lastActive,
    required this.totalPoints,
    this.additionalStats = const {},
  });

  factory ProgressStatsModel.fromJson(Map<String, dynamic> json) {
    // Handle nested data structure from API
    final data = json['data'] ?? json;

    return ProgressStatsModel(
      completedLessons: data['completedLessons'] as int? ?? 0,
      highestStreak: data['highestStreak'] as int? ?? 0,
      currentStreak: data['currentStreak'] as int? ?? 0,
      lastActive: data['lastActive'] != null
          ? DateTime.parse(data['lastActive'] as String)
          : null,
      totalPoints: data['totalPoints'] as int? ?? 0,
      additionalStats: Map<String, dynamic>.from(data),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'completedLessons': completedLessons,
      'highestStreak': highestStreak,
      'currentStreak': currentStreak,
      'lastActive': lastActive?.toIso8601String(),
      'totalPoints': totalPoints,
      ...additionalStats,
    };
  }
}