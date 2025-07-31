// lib/features/home/domain/entities/lesson_entity.dart

import 'package:equatable/equatable.dart';
import 'package:grad_project/features/home/domain/entities/lesson_activity_entity.dart'; // Import LessonActivityEntity

class LessonEntity extends Equatable {
  final String id;
  final String title;
  final String description;
  final int order; // To define the sequence in the map
  final bool isCompleted;
  final List<LessonActivityEntity> activities; // Nodes within the lesson

  const LessonEntity({
    required this.id,
    required this.title,
    required this.description,
    required this.order,
    this.isCompleted = false,
    this.activities = const [],
  });

  // This fromMap expects two arguments: the map data and the document ID (id)
  factory LessonEntity.fromMap(Map<String, dynamic> map, String id) {
    return LessonEntity(
      id: id, // Use the provided ID
      title: map['title'] as String? ?? '',
      description: map['description'] as String? ?? '',
      order: map['order'] as int? ?? 0,
      isCompleted: map['isCompleted'] as bool? ?? false,
      activities: (map['activities'] as List<dynamic>?)
          ?.map((e) => LessonActivityEntity.fromMap(e as Map<String, dynamic>, e['id'] as String? ?? '')) // Pass activity ID
          .toList() ??
          const [],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'order': order,
      'isCompleted': isCompleted,
      'activities': activities.map((e) => e.toMap()).toList(),
    };
  }

  LessonEntity copyWith({
    String? id,
    String? title,
    String? description,
    int? order,
    bool? isCompleted,
    List<LessonActivityEntity>? activities,
  }) {
    return LessonEntity(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      order: order ?? this.order,
      isCompleted: isCompleted ?? this.isCompleted,
      activities: activities ?? this.activities,
    );
  }

  @override
  List<Object?> get props => [
    id,
    title,
    description,
    order,
    isCompleted,
    activities,
  ];
}