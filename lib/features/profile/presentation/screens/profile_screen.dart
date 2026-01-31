// lib/features/profile/presentation/screens/profile_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

// Corrected import paths for providers based on our consolidated structure
import 'package:grad_project/features/profile/presentation/providers/user_provider.dart';
import 'package:grad_project/features/profile/presentation/providers/activity_provider.dart';
import 'package:grad_project/features/profile/domain/entities/profile_user_entity.dart';

// FIX: Corrected import paths for individual profile widgets to reflect 'profile_widgets' subfolder
import 'package:grad_project/features/profile/presentation/widgets/profile_widgets/profile_app_bar.dart';
import 'package:grad_project/features/profile/presentation/widgets/profile_widgets/profile_card.dart';
import 'package:grad_project/features/profile/presentation/widgets/profile_widgets/stats_card.dart';
import 'package:grad_project/features/profile/presentation/widgets/profile_widgets/weekly_lessons_card.dart';
import 'package:grad_project/features/profile/presentation/widgets/profile_widgets/calendar_card.dart';
import 'package:grad_project/features/profile/presentation/widgets/profile_widgets/daily_achievements_card.dart';
import 'package:grad_project/features/profile/presentation/widgets/profile_widgets/error_widget.dart'; // Correct import
import 'package:grad_project/features/profile/presentation/widgets/profile_widgets/no_data_widget.dart'; // Correct import (fixed double slash)
import 'package:grad_project/core/navigation/app_routes.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadInitialData();
    });
  }

  void _loadInitialData() {
    if (!mounted) return;

    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final activityProvider = Provider.of<ActivityProvider>(
      context,
      listen: false,
    );

    // Ensure user is loaded first, then activities
    userProvider
        .loadUser()
        .then((_) {
          if (!mounted) return;
          final String? userId = userProvider.user?.id;
          if (userId != null) {
            activityProvider.loadWeeklyActivities();
            activityProvider
                .loadDailyAchievements(); // Always load daily for today's achievements
          } else {
            debugPrint(
              "ProfileScreen: User ID not available after initial load, cannot fetch activity data.",
            );
          }
        })
        .catchError((error) {
          debugPrint("ProfileScreen: Error loading initial data: $error");
        });
  }

  void onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    if (!mounted) return;

    setState(() {
      _selectedDay = selectedDay;
      _focusedDay = focusedDay;
    });

    // When day is selected, reload daily achievements for that specific day
    // Note: DailyAchievementsCard currently loads for "today". If you want it to show
    // achievements for `selectedDay`, you'd need to pass `selectedDay` to its
    // `loadDailyAchievements` method or modify the use case.
    // For now, it will still show today's achievements.
    final activityProvider = Provider.of<ActivityProvider>(
      context,
      listen: false,
    );
    activityProvider
        .loadDailyAchievements(); // This will load for today by default
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    // Use theme colors for background
    final Color backgroundColor = theme.scaffoldBackgroundColor;
    final Color primaryColor = theme.primaryColor;

    return Scaffold(
      backgroundColor: backgroundColor, // Themed background
      body: Consumer<UserProvider>(
        builder: (context, userProvider, child) {
          final ProfileUserEntity? currentUser = userProvider.user;

          // Use themed CircularProgressIndicator
          if (userProvider.isLoading && currentUser == null) {
            return Center(
              child: CircularProgressIndicator(
                color: primaryColor, // Use theme's primary color
                strokeWidth: 3.w,
              ),
            );
          }

          // Use ProfileErrorWidget from consolidated widgets
          if (userProvider.error != null) {
            return ProfileErrorWidget(
              // Use the widget directly
              error: userProvider.error!,
              onRetry: () => userProvider.loadUser(),
            );
          }

          // Use ProfileNoDataWidget from consolidated widgets
          if (currentUser == null) {
            return const ProfileNoDataWidget(); // Use the widget directly
          }

          return _buildProfileContent(currentUser, theme);
        },
      ),
    );
  }

  Widget _buildProfileContent(ProfileUserEntity currentUser, ThemeData theme) {
    return CustomScrollView(
      slivers: [
        // Use ProfileAppBar from consolidated widgets
        SliverToBoxAdapter(
          child: ProfileAppBar(
            onSettingsPressed:
                () => Navigator.pushNamed(context, AppRoutes.settings),
          ),
        ),
        SliverPadding(
          padding: EdgeInsets.all(16.w),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              // Use ProfileCard from consolidated widgets
              ProfileCard(user: currentUser),
              SizedBox(height: 16.h),
              // Use StatsCard from consolidated widgets
              SizedBox(height: 16.h),
              // Use WeeklyLessonsCard from consolidated widgets
              const WeeklyLessonsCard(),
              SizedBox(height: 16.h),
              SizedBox(height: 16.h),
              DailyAchievementsCard(selectedDay: _selectedDay),
              SizedBox(height: 80.h), // Extra space for bottom navigation
            ]),
          ),
        ),
      ],
    );
  }
}
