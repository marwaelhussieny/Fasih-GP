// lib/features/home/domain/entities/lesson_activity_entity.dart

import 'package:equatable/equatable.dart';

enum LessonActivityType {
  quiz,
  writing,
  speaking,
  flashcards,
  grammar, // For 'اعربلي و اصرفلي' type activities
  unknown,
}

class LessonActivityEntity extends Equatable {
  final String id; // Added id to LessonActivityEntity
  final String title;
  final LessonActivityType type;
  final bool isCompleted;
  final String? associatedRoute; // e.g., AppRoutes.quiz, AppRoutes.flashcards
  final String? associatedDataId; // e.g., quizId, flashcardSetId

  const LessonActivityEntity({
    required this.id, // Required id
    required this.title,
    required this.type,
    this.isCompleted = false,
    this.associatedRoute,
    this.associatedDataId,
  });

  factory LessonActivityEntity.fromMap(Map<String, dynamic> map, String id) { // Expects id
    return LessonActivityEntity(
      id: id, // Use the provided ID
      title: map['title'] as String? ?? '',
      type: LessonActivityType.values.firstWhere(
            (e) => e.toString() == 'LessonActivityType.${map['type']}',
        orElse: () => LessonActivityType.unknown,
      ),
      isCompleted: map['isCompleted'] as bool? ?? false,
      associatedRoute: map['associatedRoute'] as String?,
      associatedDataId: map['associatedDataId'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id, // Include id in toMap
      'title': title,
      'type': type.toString().split('.').last, // Store enum name as string
      'isCompleted': isCompleted,
      'associatedRoute': associatedRoute,
      'associatedDataId': associatedDataId,
    };
  }

  LessonActivityEntity copyWith({
    String? id,
    String? title,
    LessonActivityType? type,
    bool? isCompleted,
    String? associatedRoute,
    String? associatedDataId,
  }) {
    return LessonActivityEntity(
      id: id ?? this.id,
      title: title ?? this.title,
      type: type ?? this.type,
      isCompleted: isCompleted ?? this.isCompleted,
      associatedRoute: associatedRoute ?? this.associatedRoute,
      associatedDataId: associatedDataId ?? this.associatedDataId,
    );
  }

  @override
  List<Object?> get props => [
    id,
    title,
    type,
    isCompleted,
    associatedRoute,
    associatedDataId,
  ];
}
