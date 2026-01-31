// lib/features/profile/presentation/providers/activity_provider.dart

import 'package:flutter/material.dart';
import 'package:grad_project/features/profile/domain/entities/daily_activity_entity.dart';
import 'package:grad_project/features/profile/domain/usecases/activity_usecases.dart';
import 'package:grad_project/features/profile/domain/usecases/profile_usecases.dart'; // Import Profile use cases for related activity methods

class ActivityProvider extends ChangeNotifier {
  final GetWeeklyLessonsData _getWeeklyLessonsDataUseCase;
  final GetDailyAchievements _getDailyAchievementsUseCase;
  final AddDailyActivity _addDailyActivityUseCase;
  final GetDailyActivitiesUseCase _getDailyActivitiesUseCase;
  final GetDailyActivityUseCase _getDailyActivityUseCase;
  final GetMonthlyStatsUseCase _getMonthlyStatsUseCase;

  ActivityProvider({
    required GetWeeklyLessonsData getWeeklyLessonsDataUseCase,
    required GetDailyAchievements getDailyAchievementsUseCase,
    required AddDailyActivity addDailyActivityUseCase,
    required GetDailyActivitiesUseCase getDailyActivitiesUseCase,
    required GetDailyActivityUseCase getDailyActivityUseCase,
    required GetMonthlyStatsUseCase getMonthlyStatsUseCase,
  })  : _getWeeklyLessonsDataUseCase = getWeeklyLessonsDataUseCase,
        _getDailyAchievementsUseCase = getDailyAchievementsUseCase,
        _addDailyActivityUseCase = addDailyActivityUseCase,
        _getDailyActivitiesUseCase = getDailyActivitiesUseCase,
        _getDailyActivityUseCase = getDailyActivityUseCase,
        _getMonthlyStatsUseCase = getMonthlyStatsUseCase;

  // Activity data
  List<DailyActivityEntity> _dailyActivities = [];
  Map<String, dynamic> _monthlyStats = {};
  Map<String, int> _dailyAchievements = {};
  List<double> _weeklyLessons = [];

  // Loading states
  bool _isLoadingDaily = false;
  bool _isLoadingWeekly = false;
  bool _isLoadingMonthly = false;
  bool _isLoadingAchievements = false;

  // Error handling
  String? _error;

  // Getters
  List<DailyActivityEntity> get dailyActivities => _dailyActivities;
  Map<String, dynamic> get monthlyStats => _monthlyStats;
  Map<String, int> get dailyAchievements => _dailyAchievements;
  List<double> get weeklyLessons => _weeklyLessons;
  bool get isLoadingDaily => _isLoadingDaily;
  bool get isLoadingWeekly => _isLoadingWeekly;
  bool get isLoadingMonthly => _isLoadingMonthly;
  bool get isLoadingAchievements => _isLoadingAchievements;
  String? get error => _error;

  // Load daily activities
  Future<void> loadDailyActivities({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    _isLoadingDaily = true;
    _clearError();
    notifyListeners();

    try {
      _dailyActivities = await _getDailyActivitiesUseCase(
        startDate: startDate,
        endDate: endDate,
      );
    } catch (e) {
      _setError('Failed to load daily activities: ${e.toString()}');
    } finally {
      _isLoadingDaily = false;
      notifyListeners();
    }
  }

  // Load weekly activities
  Future<void> loadWeeklyActivities() async {
    _isLoadingWeekly = true;
    _clearError();
    notifyListeners();

    try {
      _weeklyLessons = (await _getWeeklyLessonsDataUseCase()).map((e) => e.completedLessons.toDouble()).toList();
      notifyListeners();
    } catch (e) {
      _setError('Failed to load weekly activities: ${e.toString()}');
      _weeklyLessons = [2, 1, 3, 0, 2, 4, 1]; // Fallback data
    } finally {
      _isLoadingWeekly = false;
      notifyListeners();
    }
  }

  // Load monthly stats
  Future<void> loadMonthlyStats() async {
    _isLoadingMonthly = true;
    _clearError();
    notifyListeners();

    try {
      _monthlyStats = await _getMonthlyStatsUseCase();
    } catch (e) {
      _setError('Failed to load monthly stats: ${e.toString()}');
      _monthlyStats = {
        'totalDays': 30,
        'activeDays': 15,
        'averageScore': 85,
        'totalMinutes': 450,
        'completedLessons': 25,
      };
    } finally {
      _isLoadingMonthly = false;
      notifyListeners();
    }
  }

  // Load daily achievements
  Future<void> loadDailyAchievements() async {
    _isLoadingAchievements = true;
    _clearError();
    notifyListeners();

    try {
      _dailyAchievements = await _getDailyAchievementsUseCase();
      notifyListeners();
    } catch (e) {
      _setError('Failed to load achievements: ${e.toString()}');
      _dailyAchievements = {
        'أكملت 3 دروس اليوم': 0,
        'حصلت على 85% في الاختبار': 0,
        'ذاكرت لمدة 30 دقيقة': 0,
      };
    } finally {
      _isLoadingAchievements = false;
      notifyListeners();
    }
  }

  // Get activity for specific date
  Future<DailyActivityEntity?> getActivityForDate(DateTime date) async {
    try {
      return await _getDailyActivityUseCase(date);
    } catch (e) {
      _setError('Failed to get activity for date: ${e.toString()}');
      return null;
    }
  }

  // Add daily activity
  Future<void> addDailyActivity({
    required int lessonsCompleted,
    required int correctAnswers,
    required int pointsEarned,
    int timeSpentMinutes = 0,
  }) async {
    _isLoadingDaily = true;
    _clearError();
    notifyListeners();
    try {
      await _addDailyActivityUseCase(
        lessonsCompleted: lessonsCompleted,
        correctAnswers: correctAnswers,
        pointsEarned: pointsEarned,
        timeSpentMinutes: timeSpentMinutes,
      );
      await loadAllData(); // Refresh data after adding
    } catch (e) {
      _setError('Failed to add daily activity: ${e.toString()}');
    } finally {
      _isLoadingDaily = false;
      notifyListeners();
    }
  }

  // Check if user has activity on specific date
  bool hasActivityOnDate(DateTime date) {
    return _dailyActivities.any((activity) => _isSameDay(activity.date, date));
  }

  // Get activity count for specific date
  int getActivityCountForDate(DateTime date) {
    final activity = _dailyActivities.where(
          (activity) => _isSameDay(activity.date, date),
    );
    return activity.isEmpty ? 0 : activity.first.correctAnswers;
  }

  // Load all data
  Future<void> loadAllData() async {
    await Future.wait([
      loadDailyActivities(),
      loadWeeklyActivities(),
      loadMonthlyStats(),
      loadDailyAchievements(),
    ]);
  }

  // Refresh all data
  Future<void> refreshData() async {
    _clearError();
    await loadAllData();
  }

  // Helper methods
  void _setError(String error) {
    _error = error;
  }

  void _clearError() {
    _error = null;
  }

  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  // Clear data (for logout)
  void clearData() {
    _dailyActivities = [];
    _monthlyStats = {};
    _dailyAchievements = {};
    _weeklyLessons = [];
    _clearError();
    notifyListeners();
  }
}