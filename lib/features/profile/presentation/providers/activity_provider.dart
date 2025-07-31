// lib/features/profile/data/providers/activity_provider.dart

import 'package:flutter/material.dart';
import 'package:grad_project/features/profile/domain/entities/daily_activity_entity.dart';
// import 'package:grad_project/features/profile/domain/repositories/activity_repository.dart'; // Not directly used in provider
import 'package:grad_project/features/profile/domain/usecases/activity_usecases.dart';
// import 'package:grad_project/features/profile/domain/usecases/profile_usecases.dart'; // Not directly used in provider

class ActivityProvider with ChangeNotifier {
  final GetWeeklyLessonsData _getWeeklyLessonsDataUseCase;
  final GetDailyAchievements _getDailyAchievementsUseCase;
  final AddDailyActivity _addDailyActivityUseCase;

  bool _isLoading = false;
  bool _isLoadingWeekly = false;
  bool _isLoadingAchievements = false;
  String? _error;
  List<DailyActivityEntity> _weeklyActivities = [];
  Map<String, int> _dailyAchievements = {};

  // Getters
  bool get isLoading => _isLoading;
  bool get isLoadingWeekly => _isLoadingWeekly;
  bool get isLoadingAchievements => _isLoadingAchievements;
  String? get error => _error;
  List<DailyActivityEntity> get weeklyActivities => _weeklyActivities;
  // This getter might need adjustment if you want to ensure 7 days of data, even if 0
  List<double> get weeklyLessons => _weeklyActivities
      .map((activity) => activity.completedLessons.toDouble())
      .toList();
  Map<String, int> get dailyAchievements => _dailyAchievements;

  ActivityProvider({
    required GetWeeklyLessonsData getWeeklyLessonsDataUseCase,
    required GetDailyAchievements getDailyAchievementsUseCase,
    required AddDailyActivity addDailyActivityUseCase,
  })  : _getWeeklyLessonsDataUseCase = getWeeklyLessonsDataUseCase,
        _getDailyAchievementsUseCase = getDailyAchievementsUseCase,
        _addDailyActivityUseCase = addDailyActivityUseCase;

  /// Load weekly activities data
  Future<void> loadWeeklyActivities() async {
    _isLoadingWeekly = true;
    _setLoading(true);
    _clearError();
    notifyListeners();

    try {
      _weeklyActivities = await _getWeeklyLessonsDataUseCase();
    } catch (e) {
      _setError('Failed to load weekly activities: ${e.toString()}');
    } finally {
      _isLoadingWeekly = false;
      _setLoading(false);
    }
  }

  /// Load daily achievements
  Future<void> loadDailyAchievements() async {
    _isLoadingAchievements = true;
    _setLoading(true);
    _clearError();
    notifyListeners();

    try {
      _dailyAchievements = await _getDailyAchievementsUseCase();
    } catch (e) {
      _setError('Failed to load daily achievements: ${e.toString()}');
    } finally {
      _isLoadingAchievements = false;
      _setLoading(false);
    }
  }

  /// Add a new daily activity (Renamed from addActivity and added timeSpentMinutes)
  Future<void> addDailyActivity({
    required int lessonsCompleted,
    required int correctAnswers,
    required int pointsEarned,
    int timeSpentMinutes = 0, // FIX: Added timeSpentMinutes parameter
    List<String> newAchievements = const [], // Keep this if you use it
  }) async {
    _setLoading(true);
    _clearError();
    try {
      await _addDailyActivityUseCase(
        lessonsCompleted: lessonsCompleted,
        correctAnswers: correctAnswers,
        pointsEarned: pointsEarned,
        timeSpentMinutes: timeSpentMinutes, // FIX: Pass to use case
        // newAchievements: newAchievements, // Pass if the use case supports it
      );
      // Reload data after adding activity
      await Future.wait([
        loadWeeklyActivities(),
        loadDailyAchievements(),
      ]);
    } catch (e) {
      _setError('Failed to add daily activity: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }

  /// Clear all data
  void clearData() {
    _weeklyActivities.clear();
    _dailyAchievements.clear();
    _clearError();
    notifyListeners();
  }

  /// Private helper methods
  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setError(String message) {
    _error = message;
    notifyListeners();
  }

  void _clearError() {
    _error = null;
  }
}
