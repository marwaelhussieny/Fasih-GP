// lib/features/home/data/repositories/home_repository_impl.dart

import 'package:grad_project/features/home/domain/repositories/home_repository.dart';
import 'package:grad_project/features/home/domain/entities/lesson_entity.dart';
import 'package:grad_project/features/home/data/datasources/home_remote_data_source.dart';

class HomeRepositoryImpl implements HomeRepository {
  final HomeRemoteDataSource remoteDataSource;

  HomeRepositoryImpl({required this.remoteDataSource});

  @override
  Future<List<LessonEntity>> getLessons() async {
    try {
      return await remoteDataSource.getLessons();
    } catch (e) {
      throw Exception('Failed to fetch lessons from repository: $e');
    }
  }

  @override
  Future<void> updateLessonActivityCompletion(String lessonId, String activityId, bool isCompleted) async {
    try {
      await remoteDataSource.updateLessonActivityCompletion(lessonId, activityId, isCompleted);
    } catch (e) {
      throw Exception('Failed to update lesson activity completion in repository: $e');
    }
  }
}