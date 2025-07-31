// lib/features/profile/data/repositories/activity_repository_impl.dart

import 'package:grad_project/features/profile/domain/entities/daily_activity_entity.dart';
import 'package:grad_project/features/profile/domain/entities/user_entity.dart';
import 'package:grad_project/features/profile/domain/entities/user_progress_entity.dart';
import 'package:grad_project/features/profile/domain/repositories/activity_repository.dart';
import 'package:grad_project/features/profile/domain/repositories/user_repository.dart';
import 'package:uuid/uuid.dart'; // Import uuid package for generating unique IDs

class ActivityRepositoryImpl implements ActivityRepository {
  final UserRepository userRepository;
  final Uuid _uuid; // Instance of Uuid for generating IDs

  ActivityRepositoryImpl(this.userRepository) : _uuid = const Uuid(); // Initialize Uuid

  @override
  Future<List<DailyActivityEntity>> getWeeklyLessonsData() async {
    final currentUser = userRepository.getCurrentFirebaseUser();
    if (currentUser == null) {
      throw Exception('No authenticated user to get weekly lessons data.');
    }

    final userProfile = await userRepository.getUserProfile(currentUser.uid);
    if (userProfile == null) {
      return [];
    }

    final now = DateTime.now();
    // Get the start of 7 days ago (inclusive of today)
    final sevenDaysAgo = DateTime(now.year, now.month, now.day).subtract(const Duration(days: 6));

    List<DailyActivityEntity> weeklyActivities = [];

    // Iterate through dailyActivities as a List
    final dailyActivities = userProfile.dailyActivities; // It's already a List

    for (var activity in dailyActivities) {
      // Normalize activity date to start of day for accurate comparison
      final activityDateNormalized = DateTime(activity.date.year, activity.date.month, activity.date.day);
      if (activityDateNormalized.isAfter(sevenDaysAgo.subtract(const Duration(days: 1))) &&
          activityDateNormalized.isBefore(now.add(const Duration(days: 1)))) {
        weeklyActivities.add(activity);
      }
    }

    // Sort by date for consistent display (oldest to newest)
    weeklyActivities.sort((a, b) => a.date.compareTo(b.date));

    return weeklyActivities;
  }

  @override
  Future<Map<String, int>> getDailyAchievements() async {
    final currentUser = userRepository.getCurrentFirebaseUser();
    if (currentUser == null) {
      throw Exception('No authenticated user to get daily achievements.');
    }

    final userProfile = await userRepository.getUserProfile(currentUser.uid);
    if (userProfile == null) {
      return {
        'lessonsCompleted': 0,
        'correctAnswers': 0,
        'pointsEarned': 0,
        'timeSpentMinutes': 0, // Include timeSpentMinutes
      };
    }

    final today = DateTime.now();
    DailyActivityEntity? dailyActivity;

    // Iterate through dailyActivities as a List to find today's activity
    for (var activity in userProfile.dailyActivities) {
      if (activity.date.year == today.year &&
          activity.date.month == today.month &&
          activity.date.day == today.day) {
        dailyActivity = activity;
        break;
      }
    }

    return {
      'lessonsCompleted': dailyActivity?.completedLessons ?? 0,
      'correctAnswers': dailyActivity?.correctAnswers ?? 0,
      'pointsEarned': dailyActivity?.pointsEarned ?? 0,
      'timeSpentMinutes': dailyActivity?.timeSpentMinutes ?? 0, // Return timeSpentMinutes
    };
  }

  @override
  Future<void> addDailyActivity({
    required int lessonsCompleted,
    required int correctAnswers,
    required int pointsEarned,
    int timeSpentMinutes = 0, // FIX: Added timeSpentMinutes parameter to match interface
  }) async {
    final currentUser = userRepository.getCurrentFirebaseUser();
    if (currentUser == null) {
      throw Exception('No authenticated user to add daily activity.');
    }

    UserEntity? userProfile = await userRepository.getUserProfile(currentUser.uid);
    if (userProfile == null) {
      // If user profile doesn't exist, create a basic one.
      await userRepository.createUserProfile(
          currentUser.uid,
          currentUser.email ?? '',
          currentUser.displayName ?? 'User'
      );
      userProfile = await userRepository.getUserProfile(currentUser.uid); // Re-fetch after creation
      if (userProfile == null) {
        throw Exception('Failed to create or retrieve user profile for activity.');
      }
    }

    final today = DateTime.now();
    // Normalize today's date to start of day for consistent matching
    final todayNormalized = DateTime(today.year, today.month, today.day);

    int existingActivityIndex = -1;
    DailyActivityEntity? existingActivity;

    // Find if an activity for today already exists in the list
    for (int i = 0; i < userProfile.dailyActivities.length; i++) {
      final activity = userProfile.dailyActivities[i];
      final activityDateNormalized = DateTime(activity.date.year, activity.date.month, activity.date.day);
      if (activityDateNormalized.isAtSameMomentAs(todayNormalized)) {
        existingActivity = activity;
        existingActivityIndex = i;
        break;
      }
    }

    final updatedActivity = DailyActivityEntity(
      // If updating existing, use its ID. Otherwise, generate a new one.
      id: existingActivity?.id ?? _uuid.v4(),
      date: todayNormalized, // Store normalized date
      completedLessons: (existingActivity?.completedLessons ?? 0) + lessonsCompleted,
      correctAnswers: (existingActivity?.correctAnswers ?? 0) + correctAnswers,
      pointsEarned: (existingActivity?.pointsEarned ?? 0) + pointsEarned,
      timeSpentMinutes: (existingActivity?.timeSpentMinutes ?? 0) + timeSpentMinutes, // Add new time
      achievements: existingActivity?.achievements ?? [], // Preserve existing achievements
    );

    // Create a mutable copy of the dailyActivities list
    final List<DailyActivityEntity> updatedDailyActivities = List.from(userProfile.dailyActivities);

    if (existingActivityIndex != -1) {
      // Update existing activity in the list
      updatedDailyActivities[existingActivityIndex] = updatedActivity;
    } else {
      // Add new activity to the list
      updatedDailyActivities.add(updatedActivity);
    }

    // Update user progress
    final UserProgressEntity currentProgress = userProfile.progress; // progress is now non-nullable

    final updatedProgress = UserProgressEntity(
      totalLessonsCompleted: currentProgress.totalLessonsCompleted + lessonsCompleted,
      totalCorrectAnswers: currentProgress.totalCorrectAnswers + correctAnswers,
      totalPoints: currentProgress.totalPoints + pointsEarned,
      currentStreak: currentProgress.currentStreak, // Preserve existing streak
      completedTasks: currentProgress.completedTasks, // Preserve existing completed tasks
    );

    // Create a new UserEntity with updated activities and progress
    final updatedUserProfile = userProfile.copyWith(
      dailyActivities: updatedDailyActivities,
      progress: updatedProgress,
    );

    await userRepository.updateUserProfile(updatedUserProfile);
  }
}
