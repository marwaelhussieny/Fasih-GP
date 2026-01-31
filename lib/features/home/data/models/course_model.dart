// lib/features/home/domain/entities/lesson_activity_entity.dart

import 'package:equatable/equatable.dart';

/// Defines the different types of activities available within a lesson.
///
/// This enum is used to determine the type of activity to launch
/// when a user interacts with a lesson activity.
enum LessonActivityType {
  quiz,
  writing,
  speaking,
  flashcards,
  grammar, // For 'اعربلي و اصرفلي' type activities
  wordle, // New activity type for Wordle game
  unknown,
}

/// Represents a single activity within a lesson.
///
/// This class holds all the necessary data for a lesson activity,
/// including its type, completion status, and associated data for navigation.
class LessonActivityEntity extends Equatable {
  final String id; // Unique identifier for the activity
  final String title;
  final LessonActivityType type;
  final bool isCompleted;
  final String? associatedRoute; // e.g., AppRoutes.quiz, AppRoutes.flashcards
  final String? associatedDataId; // e.g., quizId, flashcardSetId

  const LessonActivityEntity({
    required this.id,
    required this.title,
    required this.type,
    this.isCompleted = false,
    this.associatedRoute,
    this.associatedDataId,
  });

  /// Creates a [LessonActivityEntity] from a Firestore map.
  ///
  /// The `id` is passed separately as it's the document ID.
  factory LessonActivityEntity.fromMap(Map<String, dynamic> map, String id) {
    return LessonActivityEntity(
      id: id,
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

  /// Converts the [LessonActivityEntity] to a map for Firestore.
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'type': type.toString().split('.').last, // Store enum name as string
      'isCompleted': isCompleted,
      'associatedRoute': associatedRoute,
      'associatedDataId': associatedDataId,
    };
  }

  /// Creates a new instance of [LessonActivityEntity] with updated values.
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
