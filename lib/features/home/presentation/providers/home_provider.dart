// lib/features/home/presentation/providers/home_provider.dart

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:grad_project/core/services/auth_service.dart';
import 'package:grad_project/features/home/data/datasources/home_remote_data_source.dart';
import 'package:grad_project/features/home/domain/entities/lesson_entity.dart';
import 'package:grad_project/features/home/domain/entities/level_entity.dart';
import 'package:grad_project/features/home/domain/entities/progress_entity.dart';
import 'package:grad_project/features/home/domain/entities/streak_entity.dart';
import 'package:grad_project/features/home/domain/entities/lesson_activity_entity.dart';

class HomeProvider extends ChangeNotifier {
  final SharedPreferences sharedPreferences;
  final HomeRemoteDataSourceImpl remoteDataSource;
  final AuthService authService;

  HomeProvider({
    required this.sharedPreferences,
    required this.remoteDataSource,
    required this.authService,
  });

  // State management
  bool _isLoading = false;
  bool _hasError = false;
  String? _error;

  // Core data
  List<LevelEntity> _levels = [];
  List<LessonEntity> _lessons = [];
  ProgressEntity? _userProgress;
  StreakEntity? _currentStreak;

  // Current state
  LevelEntity? _currentLevel;
  LessonEntity? _currentLesson;
  int _currentLevelIndex = 0;

  // Statistics
  int _totalXP = 0;
  int _completedLessons = 0;
  int _totalLessons = 0;
  double _overallProgress = 0.0;
  Map<String, dynamic> _achievements = {};

  // Getters
  bool get isLoading => _isLoading;
  bool get hasError => _hasError;
  String? get error => _error;
  List<LevelEntity> get levels => _levels;
  List<LessonEntity> get lessons => _lessons;
  ProgressEntity? get userProgress => _userProgress;
  StreakEntity? get currentStreak => _currentStreak;
  LevelEntity? get currentLevel => _currentLevel;
  LessonEntity? get currentLesson => _currentLesson;
  int get currentLevelIndex => _currentLevelIndex;
  int get totalXP => _totalXP;
  int get completedLessons => _completedLessons;
  int get totalLessons => _totalLessons;
  double get overallProgress => _overallProgress;
  Map<String, dynamic> get achievements => _achievements;

  // Initialize home data
  Future<void> initialize() async {
    await loadAllData();
  }

  // Load all required data
  Future<void> loadAllData() async {
    _setLoading(true);
    try {
      await Future.wait([
        loadLevels(),
        loadLessons(),
        loadUserProgress(),
        loadStreak(),
        loadAchievements(),
      ]);
      _calculateOverallProgress();
      _findCurrentLevel();
      _hasError = false;
      _error = null;
    } catch (e) {
      _setError('Failed to load home data: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }

  // Load levels from backend
  Future<void> loadLevels() async {
    try {
      final levelsData = await remoteDataSource.getLevels();
      _levels = levelsData.map((data) => LevelEntity.fromJson(data)).toList();

      // Sort levels by order
      _levels.sort((a, b) => a.order.compareTo(b.order));

      print('Loaded ${_levels.length} levels');
    } catch (e) {
      print('Error loading levels: $e');
      throw e;
    }
  }

  // Load lessons from backend
  Future<void> loadLessons() async {
    try {
      final lessonsData = await remoteDataSource.getLessons();
      _lessons = lessonsData.map((data) => LessonEntity.fromJson(data)).toList();

      // Sort lessons by level and order
      _lessons.sort((a, b) {
        int levelCompare = a.levelId.compareTo(b.levelId);
        if (levelCompare != 0) return levelCompare;
        return a.order.compareTo(b.order);
      });

      _totalLessons = _lessons.length;
      print('Loaded ${_lessons.length} lessons');
    } catch (e) {
      print('Error loading lessons: $e');
      throw e;
    }
  }

  // Load user progress
  Future<void> loadUserProgress() async {
    try {
      final progressData = await remoteDataSource.getUserProgress();
      _userProgress = ProgressEntity.fromJson(progressData);

      _totalXP = _userProgress?.totalXP ?? 0;
      _completedLessons = _userProgress?.completedLessons ?? 0;

      print('Loaded user progress: $_totalXP XP, $_completedLessons completed lessons');
    } catch (e) {
      print('Error loading user progress: $e');
      // Create default progress if none exists
      _userProgress = ProgressEntity(
        userId: _getCurrentUserId(),
        totalXP: 0,
        completedLessons: 0,
        currentLevel: 1,
        completedLevels: const [],
        achievements: const [],
        lastActivity: DateTime.now(),
      );
    }
  }

  // Load current streak
  Future<void> loadStreak() async {
    try {
      final streakData = await remoteDataSource.getCurrentStreak();
      _currentStreak = StreakEntity.fromJson(streakData);
      print('Current streak: ${_currentStreak?.currentStreak} days');
    } catch (e) {
      print('Error loading streak: $e');
      // Create default streak
      _currentStreak = StreakEntity(
        userId: _getCurrentUserId(),
        currentStreak: 0,
        longestStreak: 0,
        lastActivityDate: DateTime.now(),
      );
    }
  }

  // Load achievements
  Future<void> loadAchievements() async {
    try {
      final achievementsData = await remoteDataSource.getAchievements();
      _achievements = achievementsData;
      print('Loaded ${_achievements.length} achievements');
    } catch (e) {
      print('Error loading achievements: $e');
      _achievements = {};
    }
  }

  // Calculate overall progress
  void _calculateOverallProgress() {
    if (_totalLessons > 0) {
      _overallProgress = _completedLessons / _totalLessons;
    } else {
      _overallProgress = 0.0;
    }
  }

  // Find current level based on progress
  void _findCurrentLevel() {
    if (_levels.isNotEmpty) {
      final userLevel = _userProgress?.currentLevel ?? 1;
      _currentLevelIndex = (userLevel - 1).clamp(0, _levels.length - 1);
      _currentLevel = _levels[_currentLevelIndex];

      // Find current lesson in the current level
      final currentLevelLessons = _lessons
          .where((lesson) => lesson.levelId == _currentLevel?.id)
          .where((lesson) => !lesson.isCompleted)
          .toList();

      if (currentLevelLessons.isNotEmpty) {
        _currentLesson = currentLevelLessons.first;
      }
    }
  }

  // Check if lesson is unlocked
  bool isLessonUnlocked(LessonEntity lesson) {
    // First lesson is always unlocked
    if (lesson.order == 1) return true;

    // Check if previous lesson in the same level is completed
    final previousLesson = _lessons
        .where((l) => l.levelId == lesson.levelId && l.order == lesson.order - 1)
        .firstOrNull;

    return previousLesson?.isCompleted ?? false;
  }

  // Check if level is unlocked
  bool isLevelUnlocked(LevelEntity level) {
    // First level is always unlocked
    if (level.order == 1) return true;

    // Check if previous level is completed
    final previousLevel = _levels
        .where((l) => l.order == level.order - 1)
        .firstOrNull;

    return previousLevel?.isCompleted ?? false;
  }

  // Check if activity is unlocked
  bool isActivityUnlocked(LessonActivityEntity activity, List<LessonActivityEntity> allActivities) {
    final activityIndex = allActivities.indexOf(activity);

    // First activity is always unlocked
    if (activityIndex == 0) return true;

    // Check if previous activity is completed
    if (activityIndex > 0) {
      return allActivities[activityIndex - 1].isCompleted;
    }

    return false;
  }

  // Complete a lesson
  Future<void> completeLesson(String lessonId) async {
    _setLoading(true);
    try {
      final result = await remoteDataSource.completeLesson(lessonId);

      // Update local state
      final lessonIndex = _lessons.indexWhere((l) => l.id == lessonId);
      if (lessonIndex != -1) {
        _lessons[lessonIndex] = _lessons[lessonIndex].copyWith(isCompleted: true);
        _completedLessons++;

        // Handle XP earned - fix the Map to int conversion
        int xpEarned = 0;
        if (result is Map<String, dynamic>) {
          final xpValue = result['xpEarned'];
          if (xpValue is int) {
            xpEarned = xpValue;
          } else if (xpValue is double) {
            xpEarned = xpValue.toInt();
          } else if (xpValue is String) {
            xpEarned = int.tryParse(xpValue) ?? 0;
          }
        }

        _totalXP += xpEarned;
      }

      // Check if level is completed
      await _checkLevelCompletion(lessonId);

      // Update streak
      await updateStreak();

      _calculateOverallProgress();
      _hasError = false;
      _error = null;
    } catch (e) {
      _setError('Failed to complete lesson: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }

  // Complete an activity within a lesson
  Future<void> completeActivity(String lessonId, String activityId) async {
    try {
      // Find the lesson and activity
      final lessonIndex = _lessons.indexWhere((l) => l.id == lessonId);
      if (lessonIndex == -1) return;

      final lesson = _lessons[lessonIndex];
      final activityIndex = lesson.activities.indexWhere((a) => a.id == activityId);
      if (activityIndex == -1) return;

      // Update activity completion status
      final updatedActivities = List<LessonActivityEntity>.from(lesson.activities);
      updatedActivities[activityIndex] = updatedActivities[activityIndex].copyWith(isCompleted: true);

      // Update lesson with new activities
      final updatedLesson = lesson.copyWith(activities: updatedActivities);
      _lessons[lessonIndex] = updatedLesson;

      // Check if all activities in lesson are completed
      final allActivitiesCompleted = updatedActivities.every((activity) => activity.isCompleted);
      if (allActivitiesCompleted) {
        await completeLesson(lessonId);
      }

      notifyListeners();
    } catch (e) {
      print('Error completing activity: $e');
    }
  }

  // Check if level is completed after lesson completion
  Future<void> _checkLevelCompletion(String lessonId) async {
    final lesson = _lessons.firstWhere((l) => l.id == lessonId);
    final levelLessons = _lessons.where((l) => l.levelId == lesson.levelId).toList();

    final completedLevelLessons = levelLessons.where((l) => l.isCompleted).length;

    if (completedLevelLessons == levelLessons.length) {
      // Level completed, unlock next level
      await _completeLevel(lesson.levelId);
    }
  }

  // Complete a level
  Future<void> _completeLevel(String levelId) async {
    try {
      await remoteDataSource.completeLevel(levelId);

      // Update local state
      final levelIndex = _levels.indexWhere((l) => l.id == levelId);
      if (levelIndex != -1) {
        _levels[levelIndex] = _levels[levelIndex].copyWith(isCompleted: true);

        // Move to next level if available
        if (levelIndex + 1 < _levels.length) {
          _currentLevelIndex = levelIndex + 1;
          _currentLevel = _levels[_currentLevelIndex];
        }
      }
    } catch (e) {
      print('Error completing level: $e');
    }
  }

  // Update streak
  Future<void> updateStreak() async {
    try {
      final streakData = await remoteDataSource.updateStreak();
      _currentStreak = StreakEntity.fromJson(streakData);
    } catch (e) {
      print('Error updating streak: $e');
    }
  }

  // Start lesson (navigate to lesson screen)
  Future<void> startLesson(LessonEntity lesson) async {
    if (!isLessonUnlocked(lesson)) {
      _setError('This lesson is not unlocked yet');
      return;
    }

    _currentLesson = lesson;
    notifyListeners();
  }

  // Get lessons for a specific level
  List<LessonEntity> getLessonsForLevel(String levelId) {
    return _lessons.where((lesson) => lesson.levelId == levelId).toList();
  }

  // Get progress for a specific level
  double getLevelProgress(String levelId) {
    final levelLessons = getLessonsForLevel(levelId);
    if (levelLessons.isEmpty) return 0.0;

    final completedCount = levelLessons.where((l) => l.isCompleted).length;
    return completedCount / levelLessons.length;
  }

  // Get activities for a specific lesson
  List<LessonActivityEntity> getActivitiesForLesson(String lessonId) {
    final lesson = _lessons.firstWhere(
          (l) => l.id == lessonId,
      orElse: () => throw Exception('Lesson not found'),
    );
    return lesson.activities;
  }

  // Get progress for a specific lesson
  double getLessonProgress(String lessonId) {
    final activities = getActivitiesForLesson(lessonId);
    if (activities.isEmpty) return 0.0;

    final completedCount = activities.where((a) => a.isCompleted).length;
    return completedCount / activities.length;
  }

  // Update lesson activity completion
  Future<void> updateLessonActivityCompletion(String lessonId, String activityId, bool isCompleted) async {
    try {
      final lessonIndex = _lessons.indexWhere((l) => l.id == lessonId);
      if (lessonIndex == -1) return;

      final lesson = _lessons[lessonIndex];
      final activityIndex = lesson.activities.indexWhere((a) => a.id == activityId);
      if (activityIndex == -1) return;

      // Update activity completion status
      final updatedActivities = List<LessonActivityEntity>.from(lesson.activities);
      updatedActivities[activityIndex] = updatedActivities[activityIndex].copyWith(isCompleted: isCompleted);

      // Update lesson with new activities
      final updatedLesson = lesson.copyWith(activities: updatedActivities);
      _lessons[lessonIndex] = updatedLesson;

      // Recalculate lesson progress
      final lessonProgress = getLessonProgress(lessonId);
      _lessons[lessonIndex] = _lessons[lessonIndex].copyWith(progress: lessonProgress);

      // If all activities completed, mark lesson as completed
      if (lessonProgress == 1.0) {
        await completeLesson(lessonId);
      }

      notifyListeners();
    } catch (e) {
      print('Error updating lesson activity completion: $e');
    }
  }

  // Get user rank based on XP
  String getUserRank() {
    if (_totalXP >= 10000) return 'خبير';
    if (_totalXP >= 5000) return 'متقدم';
    if (_totalXP >= 2000) return 'متوسط';
    if (_totalXP >= 500) return 'مبتدئ متقدم';
    return 'مبتدئ';
  }

  // Get next level for current user
  LevelEntity? getNextLevel() {
    if (_currentLevelIndex + 1 < _levels.length) {
      return _levels[_currentLevelIndex + 1];
    }
    return null;
  }

  // Get current lesson in current level
  LessonEntity? getCurrentLessonInLevel() {
    if (_currentLevel == null) return null;

    final levelLessons = getLessonsForLevel(_currentLevel!.id);
    return levelLessons.firstWhere(
          (lesson) => !lesson.isCompleted,
      orElse: () => levelLessons.last, // Return last lesson if all completed
    );
  }

  // Check if user can access next level
  bool canAccessNextLevel() {
    if (_currentLevel == null) return false;

    final levelLessons = getLessonsForLevel(_currentLevel!.id);
    return levelLessons.every((lesson) => lesson.isCompleted);
  }

  // Get total study time
  Duration getTotalStudyTime() {
    final completedLessonsList = _lessons.where((l) => l.isCompleted).toList();
    final totalMinutes = completedLessonsList.fold<int>(0, (sum, lesson) => sum + lesson.duration);
    return Duration(minutes: totalMinutes);
  }

  // Get average session time
  Duration getAverageSessionTime() {
    if (_completedLessons == 0) return Duration.zero;

    final totalTime = getTotalStudyTime();
    return Duration(milliseconds: totalTime.inMilliseconds ~/ _completedLessons);
  }

  // Refresh data
  Future<void> refresh() async {
    await loadAllData();
  }

  // Reset progress (for testing/development)
  Future<void> resetProgress() async {
    _userProgress = ProgressEntity(
      userId: _getCurrentUserId(),
      totalXP: 0,
      completedLessons: 0,
      currentLevel: 1,
      completedLevels: const [],
      achievements: const [],
      lastActivity: DateTime.now(),
    );

    // Reset all lessons and levels
    _lessons = _lessons.map((lesson) => lesson.copyWith(
      isCompleted: false,
      progress: 0.0,
      activities: lesson.activities.map((activity) => activity.copyWith(isCompleted: false)).toList(),
    )).toList();

    _levels = _levels.map((level) => level.copyWith(isCompleted: false)).toList();

    _totalXP = 0;
    _completedLessons = 0;
    _currentLevelIndex = 0;
    _currentLevel = _levels.isNotEmpty ? _levels[0] : null;

    _calculateOverallProgress();
    notifyListeners();
  }

  // Helper method to get current user ID
  String _getCurrentUserId() {
    try {
      // Replace with your actual user ID getter from auth service
      return authService.toString().hashCode.toString(); // Fallback
    } catch (e) {
      return 'anonymous_user';
    }
  }

  // Helper methods
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _hasError = true;
    _error = error;
    notifyListeners();
  }

  void clearError() {
    _hasError = false;
    _error = null;
    notifyListeners();
  }

  // Search lessons by title or description
  List<LessonEntity> searchLessons(String query) {
    if (query.isEmpty) return _lessons;

    final lowercaseQuery = query.toLowerCase();
    return _lessons.where((lesson) {
      return lesson.title.toLowerCase().contains(lowercaseQuery) ||
          lesson.description.toLowerCase().contains(lowercaseQuery);
    }).toList();
  }

  // Get lessons by completion status
  List<LessonEntity> getLessonsByStatus({required bool isCompleted}) {
    return _lessons.where((lesson) => lesson.isCompleted == isCompleted).toList();
  }

  // Get statistics summary
  Map<String, dynamic> getStatsSummary() {
    return {
      'totalXP': _totalXP,
      'completedLessons': _completedLessons,
      'totalLessons': _totalLessons,
      'overallProgress': _overallProgress,
      'currentStreak': _currentStreak?.currentStreak ?? 0,
      'longestStreak': _currentStreak?.longestStreak ?? 0,
      'totalStudyTime': getTotalStudyTime().inMinutes,
      'averageSessionTime': getAverageSessionTime().inMinutes,
      'userRank': getUserRank(),
      'completedLevels': _levels.where((l) => l.isCompleted).length,
      'totalLevels': _levels.length,
    };
  }
}