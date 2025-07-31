// lib/features/home/presentation/providers/home_provider.dart

import 'package:flutter/material.dart';
import 'package:grad_project/features/home/domain/entities/lesson_entity.dart';
import 'package:grad_project/features/home/domain/entities/lesson_activity_entity.dart';
import 'package:grad_project/features/home/domain/usecases/home_usecases.dart';
import 'package:grad_project/core/services/seed_data_service.dart';
import 'package:grad_project/features/profile/presentation/utils/app_helpers.dart'; // FIX: Import app_helpers for firstWhereOrNull

class HomeProvider extends ChangeNotifier {
  final GetLessons getLessonsUseCase;
  final UpdateLessonActivityCompletion updateLessonActivityCompletionUseCase;
  final SeedDataService _seedDataService;

  HomeProvider({
    required this.getLessonsUseCase,
    required this.updateLessonActivityCompletionUseCase,
    required SeedDataService seedDataService,
  }) : _seedDataService = seedDataService;

  List<LessonEntity> _lessons = [];
  List<LessonEntity> get lessons => _lessons;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _error;
  String? get error => _error;

  // --- Load Lessons ---
  Future<void> loadLessons() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // FIX: Call initializeLessons to ensure data exists before fetching
      await _seedDataService.initializeLessons();

      _lessons = await getLessonsUseCase();
      _lessons.sort((a, b) => a.order.compareTo(b.order)); // Ensure lessons are sorted by order
    } catch (e) {
      _error = e.toString();
      debugPrint('HomeProvider error loading lessons: $_error');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // --- Update Activity Completion ---
  Future<void> updateActivityCompletion({
    required String lessonId,
    required String activityId,
    required bool isCompleted,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await updateLessonActivityCompletionUseCase(
        lessonId: lessonId,
        activityId: activityId,
        isCompleted: isCompleted,
      );
      // After successful update, reload lessons to reflect changes
      await loadLessons();
    } catch (e) {
      _error = e.toString();
      debugPrint('HomeProvider error updating activity: $_error');
      _isLoading = false; // Ensure loading state is reset even on error
      notifyListeners();
    }
  }

  // Helper to get the next unlocked lesson or activity for Duolingo-like progression
  LessonActivityEntity? getNextActivityToUnlock() {
    for (final lesson in _lessons) {
      for (final activity in lesson.activities) {
        if (!activity.isCompleted) {
          // Found the first incomplete activity
          return activity;
        }
      }
    }
    return null; // All activities completed
  }

  // Helper to check if a lesson is unlocked (e.g., previous lesson is completed)
  bool isLessonUnlocked(LessonEntity lesson) {
    if (lesson.order == 1) {
      return true; // First lesson is always unlocked
    }
    // FIX: Use firstWhereOrNull to avoid error if previous lesson doesn't exist (though it should)
    final previousLesson = _lessons.firstWhereOrNull(
          (l) => l.order == lesson.order - 1,
    );
    // A lesson is unlocked if the previous one is completed or if there's no previous lesson (e.g., it's the first)
    return previousLesson?.isCompleted ?? false; // If previousLesson is null, it's not unlocked unless it's the first lesson (handled above)
  }

  // Helper to check if an activity within a lesson is unlocked
  bool isActivityUnlocked(LessonEntity lesson, LessonActivityEntity activity) {
    if (!isLessonUnlocked(lesson)) {
      return false; // Lesson itself is not unlocked
    }
    // If it's the first activity in the lesson, it's unlocked if the lesson is.
    if (lesson.activities.indexOf(activity) == 0) {
      return true;
    }
    // Otherwise, it's unlocked if the previous activity in the same lesson is completed.
    final int activityIndex = lesson.activities.indexOf(activity);
    if (activityIndex > 0) {
      final previousActivity = lesson.activities[activityIndex - 1];
      return previousActivity.isCompleted;
    }
    return false; // Should not happen for valid activities
  }
}
