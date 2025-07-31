// lib/features/home/data/datasources/home_remote_data_source.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:grad_project/features/home/domain/entities/lesson_entity.dart';
import 'package:grad_project/features/home/domain/entities/lesson_activity_entity.dart';

abstract class HomeRemoteDataSource {
  Future<List<LessonEntity>> getLessons();
  Future<void> updateLessonActivityCompletion(String lessonId, String activityId, bool isCompleted);
}

class HomeRemoteDataSourceImpl implements HomeRemoteDataSource {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _firebaseAuth;

  HomeRemoteDataSourceImpl({
    FirebaseFirestore? firestore,
    FirebaseAuth? firebaseAuth,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance;

  @override
  Future<List<LessonEntity>> getLessons() async {
    try {
      // Fetch lessons, ordered by their 'order' field
      final querySnapshot = await _firestore.collection('lessons').orderBy('order').get();

      return querySnapshot.docs.map((doc) {
        // FIX: Pass both doc.data() and doc.id to LessonEntity.fromMap
        return LessonEntity.fromMap(doc.data(), doc.id);
      }).toList();
    } catch (e) {
      throw Exception('Failed to get lessons: $e');
    }
  }

  @override
  Future<void> updateLessonActivityCompletion(String lessonId, String activityId, bool isCompleted) async {
    final user = _firebaseAuth.currentUser;
    if (user == null) {
      throw Exception('User not authenticated.');
    }

    try {
      final lessonRef = _firestore.collection('lessons').doc(lessonId);
      final lessonDoc = await lessonRef.get();

      if (!lessonDoc.exists) {
        throw Exception('Lesson with ID $lessonId not found.');
      }

      final lessonData = lessonDoc.data()!;
      List<dynamic> activitiesData = lessonData['activities'] ?? [];

      // Find and update the specific activity
      bool activityFound = false;
      List<Map<String, dynamic>> updatedActivitiesData = [];
      for (var activityMap in activitiesData) {
        if (activityMap['id'] == activityId) {
          activityMap['isCompleted'] = isCompleted;
          activityFound = true;
        }
        updatedActivitiesData.add(activityMap);
      }

      if (!activityFound) {
        throw Exception('Activity with ID $activityId not found in lesson $lessonId.');
      }

      // Check if all activities in the lesson are now completed
      bool allActivitiesCompleted = updatedActivitiesData.every((activityMap) => activityMap['isCompleted'] == true);

      // Update the lesson document
      await lessonRef.update({
        'activities': updatedActivitiesData,
        'isCompleted': allActivitiesCompleted, // Update lesson completion status
      });

      // Optionally, you might want to update user-specific progress here as well
      // For a Duolingo-like map, you'd typically have a user_progress collection
      // that tracks which lessons/activities a specific user has completed.
      // For now, we're just updating the 'lessons' collection.
      // If you need user-specific progress (e.g., user_lessons_completed_status),
      // we'll need to define that data structure and update it here.

    } catch (e) {
      throw Exception('Failed to update lesson activity completion: $e');
    }
  }
}