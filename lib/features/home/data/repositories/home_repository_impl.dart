// lib/features/home/data/repositories/home_repository_impl.dart

import 'package:grad_project/features/home/domain/repositories/home_repository.dart';
import 'package:grad_project/features/home/domain/entities/lesson_entity.dart';
import 'package:grad_project/features/home/domain/entities/level_entity.dart';
import 'package:grad_project/features/home/domain/entities/progress_entity.dart';
import 'package:grad_project/features/home/domain/entities/streak_entity.dart';
import 'package:grad_project/features/home/domain/entities/lesson_activity_entity.dart';
import 'package:grad_project/features/home/data/datasources/home_remote_data_source.dart';

class HomeRepositoryImpl implements HomeRepository {
  final HomeRemoteDataSource remoteDataSource;

  HomeRepositoryImpl({required this.remoteDataSource});

  @override
  Future<List<LevelEntity>> getLevels() async {
    try {
      final levelsData = await remoteDataSource.getLevels();
      return levelsData.map((data) => LevelEntity.fromJson(data)).toList();
    } catch (e) {
      throw Exception('Failed to get levels: $e');
    }
  }

  @override
  Future<List<LessonEntity>> getLessons() async {
    try {
      final lessonsData = await remoteDataSource.getLessons();
      return lessonsData.map((data) => LessonEntity.fromJson(data)).toList();
    } catch (e) {
      throw Exception('Failed to get lessons: $e');
    }
  }

  @override
  Future<List<LessonEntity>> getLessonsForLevel(String levelId) async {
    try {
      final lessonsData = await remoteDataSource.getLessonsForLevel(levelId);
      return lessonsData.map((data) => LessonEntity.fromJson(data)).toList();
    } catch (e) {
      throw Exception('Failed to get lessons for level: $e');
    }
  }

  @override
  Future<ProgressEntity> getUserProgress() async {
    try {
      final progressData = await remoteDataSource.getUserProgress();
      return ProgressEntity.fromJson(progressData);
    } catch (e) {
      throw Exception('Failed to get user progress: $e');
    }
  }

  @override
  Future<StreakEntity> getCurrentStreak() async {
    try {
      final streakData = await remoteDataSource.getCurrentStreak();
      return StreakEntity.fromJson(streakData);
    } catch (e) {
      throw Exception('Failed to get current streak: $e');
    }
  }

  @override
  Future<Map<String, dynamic>> getAchievements() async {
    try {
      return await remoteDataSource.getAchievements();
    } catch (e) {
      throw Exception('Failed to get achievements: $e');
    }
  }

  @override
  Future<bool> completeLesson(String lessonId) async {
    try {
      final result = await remoteDataSource.completeLesson(lessonId);
      return result['success'] == true || result.containsKey('xpEarned');
    } catch (e) {
      throw Exception('Failed to complete lesson: $e');
    }
  }

  @override
  Future<bool> completeLevel(String levelId) async {
    try {
      final result = await remoteDataSource.completeLevel(levelId);
      return result['success'] == true || result.containsKey('xpEarned');
    } catch (e) {
      throw Exception('Failed to complete level: $e');
    }
  }

  @override
  Future<StreakEntity> updateStreak() async {
    try {
      final streakData = await remoteDataSource.updateStreak();
      return StreakEntity.fromJson(streakData);
    } catch (e) {
      throw Exception('Failed to update streak: $e');
    }
  }

  @override
  Future<LessonEntity> getLessonDetails(String lessonId) async {
    try {
      final lessonData = await remoteDataSource.getLessonDetails(lessonId);
      return LessonEntity.fromJson(lessonData);
    } catch (e) {
      throw Exception('Failed to get lesson details: $e');
    }
  }

  @override
  Future<bool> startLesson(String lessonId) async {
    try {
      final result = await remoteDataSource.startLesson(lessonId);
      return result['success'] == true;
    } catch (e) {
      throw Exception('Failed to start lesson: $e');
    }
  }

  @override
  Future<Map<String, dynamic>> getVideoLessonData(String lessonId) async {
    try {
      return await remoteDataSource.getVideoLessonData(lessonId);
    } catch (e) {
      throw Exception('Failed to get video lesson data: $e');
    }
  }

  @override
  Future<bool> completeActivity(String lessonId, String activityId) async {
    try {
      // For now, we'll use the complete lesson endpoint
      // You can extend this to have a specific activity completion endpoint
      final result = await remoteDataSource.completeLesson(lessonId);
      return result['success'] == true || result.containsKey('xpEarned');
    } catch (e) {
      throw Exception('Failed to complete activity: $e');
    }
  }

  @override
  Future<List<LessonActivityEntity>> getActivitiesForLesson(String lessonId) async {
    try {
      final lessonData = await remoteDataSource.getLessonDetails(lessonId);
      final lesson = LessonEntity.fromJson(lessonData);
      return lesson.activities;
    } catch (e) {
      throw Exception('Failed to get activities for lesson: $e');
    }
  }

  @override
  Future<bool> updateLessonActivityCompletion(String lessonId, String activityId, bool isCompleted) async {
    try {
      // This method handles updating individual activity completion status
      // For now, we'll simulate this by updating the lesson data locally
      // In a real implementation, you'd call a specific API endpoint

      final result = await remoteDataSource.completeLesson(lessonId);
      return result['success'] == true || result.containsKey('xpEarned');
    } catch (e) {
      throw Exception('Failed to update lesson activity completion: $e');
    }
  }
}