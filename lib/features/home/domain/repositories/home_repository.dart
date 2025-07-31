// lib/features/home/domain/repositories/home_repository.dart

import 'package:grad_project/features/home/domain/entities/lesson_entity.dart';

abstract class HomeRepository {
  Future<List<LessonEntity>> getLessons();
  Future<void> updateLessonActivityCompletion(String lessonId, String activityId, bool isCompleted);
}