// lib/features/home/domain/usecases/home_usecases.dart

import 'package:grad_project/features/home/domain/entities/lesson_entity.dart';
import 'package:grad_project/features/home/domain/repositories/home_repository.dart';

// --- GetLessons Use Case ---
class GetLessons {
  final HomeRepository repository;

  GetLessons(this.repository);

  Future<List<LessonEntity>> call() async {
    return await repository.getLessons();
  }
}

// --- UpdateLessonActivityCompletion Use Case ---
class UpdateLessonActivityCompletion {
  final HomeRepository repository;

  UpdateLessonActivityCompletion(this.repository);

  Future<void> call({
    required String lessonId,
    required String activityId,
    required bool isCompleted,
  }) async {
    await repository.updateLessonActivityCompletion(lessonId, activityId, isCompleted);
  }
}