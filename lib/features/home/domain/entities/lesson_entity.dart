// lib/features/home/domain/entities/lesson_entity.dart

import 'package:grad_project/features/home/domain/entities/lesson_activity_entity.dart';

class LessonEntity {
  final String id;
  final String title;
  final String description;
  final String? imageUrl;
  final String levelId;
  final int order;
  final int duration; // in minutes
  final int xpReward;
  final bool isCompleted;
  final bool isRequired;
  final double progress; // 0.0 to 1.0
  final List<LessonActivityEntity> activities;
  final Map<String, dynamic>? metadata;
  final DateTime? completedAt;
  final DateTime? lastAccessed;

  const LessonEntity({
    required this.id,
    required this.title,
    required this.description,
    this.imageUrl,
    required this.levelId,
    required this.order,
    this.duration = 0,
    this.xpReward = 0,
    this.isCompleted = false,
    this.isRequired = true,
    this.progress = 0.0,
    this.activities = const [],
    this.metadata,
    this.completedAt,
    this.lastAccessed,
  });

  factory LessonEntity.fromJson(Map<String, dynamic> json) {
    return LessonEntity(
      id: json['_id'] ?? json['id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      imageUrl: json['image'] ?? json['imageUrl'],
      levelId: json['levelId'] ?? json['level'] ?? '',
      order: json['order'] ?? 0,
      duration: json['duration'] ?? 0,
      xpReward: json['xpReward'] ?? 0,
      isCompleted: json['isCompleted'] ?? false,
      isRequired: json['isRequired'] ?? true,
      progress: (json['progress'] ?? 0.0).toDouble(),
      activities: _parseActivities(json['activities'] ?? []),
      metadata: json['metadata'],
      completedAt: json['completedAt'] != null
          ? DateTime.tryParse(json['completedAt'].toString())
          : null,
      lastAccessed: json['lastAccessed'] != null
          ? DateTime.tryParse(json['lastAccessed'].toString())
          : null,
    );
  }

  static List<LessonActivityEntity> _parseActivities(dynamic activitiesData) {
    if (activitiesData is! List) return [];

    return activitiesData
        .map((activity) => LessonActivityEntity.fromJson(
        activity is Map<String, dynamic> ? activity : {}))
        .toList();
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'imageUrl': imageUrl,
      'levelId': levelId,
      'order': order,
      'duration': duration,
      'xpReward': xpReward,
      'isCompleted': isCompleted,
      'isRequired': isRequired,
      'progress': progress,
      'activities': activities.map((a) => a.toJson()).toList(),
      'metadata': metadata,
      'completedAt': completedAt?.toIso8601String(),
      'lastAccessed': lastAccessed?.toIso8601String(),
    };
  }

  LessonEntity copyWith({
    String? id,
    String? title,
    String? description,
    String? imageUrl,
    String? levelId,
    int? order,
    int? duration,
    int? xpReward,
    bool? isCompleted,
    bool? isRequired,
    double? progress,
    List<LessonActivityEntity>? activities,
    Map<String, dynamic>? metadata,
    DateTime? completedAt,
    DateTime? lastAccessed,
  }) {
    return LessonEntity(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      imageUrl: imageUrl ?? this.imageUrl,
      levelId: levelId ?? this.levelId,
      order: order ?? this.order,
      duration: duration ?? this.duration,
      xpReward: xpReward ?? this.xpReward,
      isCompleted: isCompleted ?? this.isCompleted,
      isRequired: isRequired ?? this.isRequired,
      progress: progress ?? this.progress,
      activities: activities ?? this.activities,
      metadata: metadata ?? this.metadata,
      completedAt: completedAt ?? this.completedAt,
      lastAccessed: lastAccessed ?? this.lastAccessed,
    );
  }

  // Helper methods
  bool get hasVideoActivity {
    return activities.any((activity) => activity.type == LessonActivityType.video);
  }

  bool get hasQuizActivity {
    return activities.any((activity) => activity.type == LessonActivityType.quiz);
  }

  int get completedActivitiesCount {
    return activities.where((activity) => activity.isCompleted).length;
  }

  int get totalActivitiesCount {
    return activities.length;
  }

  double get activitiesProgress {
    if (activities.isEmpty) return 0.0;
    return completedActivitiesCount / totalActivitiesCount;
  }

  LessonActivityEntity? get firstIncompleteActivity {
    return activities
        .where((activity) => !activity.isCompleted)
        .first;
  }

  bool get canStart {
    return !isCompleted && activities.isNotEmpty;
  }

  String get statusText {
    if (isCompleted) return 'مكتمل';
    if (progress > 0) return 'قيد التقدم';
    return 'جديد';
  }

  Duration get estimatedDuration {
    return Duration(minutes: duration);
  }

  String get formattedDuration {
    if (duration < 60) {
      return '$duration دقيقة';
    } else {
      final hours = duration ~/ 60;
      final minutes = duration % 60;
      if (minutes == 0) {
        return '$hours ساعة';
      } else {
        return '$hours ساعة و $minutes دقيقة';
      }
    }
  }
}