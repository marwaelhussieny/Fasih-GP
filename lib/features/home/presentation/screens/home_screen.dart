// lib/features/home/presentation/screens/home_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:grad_project/features/home/presentation/providers/home_provider.dart';
import 'package:grad_project/features/home/domain/entities/lesson_entity.dart';
import 'package:grad_project/features/home/domain/entities/lesson_activity_entity.dart';
import 'package:grad_project/features/profile/presentation/providers/user_provider.dart';
import 'package:grad_project/features/profile/presentation/providers/activity_provider.dart';
import 'dart:math' as math;
import 'dart:ui'; // Required for PathMetrics

// Import the new consolidated widgets
import 'package:grad_project/features/home/presentation/widgets/background_layer.dart';
import 'package:grad_project/features/home/presentation/widgets/learning_map_layer.dart';
import 'package:grad_project/features/home/presentation/widgets/progress_lessons_details.dart';
import 'package:grad_project/features/home/presentation/widgets/state_widget.dart'; // Still needed for loading/error states

// Define theme colors here as they are used across multiple widgets
// Enhanced desert theme colors for day/night modes
const Color primaryOrange = Color(0xFFB8860B); // Goldenrod/DarkGoldenrod
const Color lightOrange = Color(0xFFDAA520); // Goldenrod
const Color warmAmber = Color(0xFFFFB347); // Light Amber
const Color softPeach = Color(0xFFFFDAB9); // Peach Puff
const Color desertSand = Color(0xFFF4E4BC); // Cornsilk

// Night mode colors
const Color nightBlue = Color(0xFF1A237E); // Dark Indigo
const Color darkPurple = Color(0xFF311B92); // Dark Purple
const Color starGold = Color(0xFFFFD700); // Gold
const Color moonSilver = Color(0xFFC0C0C0); // Silver

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  late AnimationController _headerController;
  late AnimationController _mapController;
  late AnimationController _floatingController;
  late AnimationController _cloudController;
  late AnimationController _starController;
  late AnimationController _sunsetController;
  late Animation<double> _headerAnimation;
  late Animation<double> _mapAnimation;
  late Animation<double> _floatingAnimation;
  late Animation<double> _cloudAnimation;
  late Animation<double> _starAnimation;
  late Animation<double> _sunsetAnimation;

  ScrollController _scrollController = ScrollController();
  bool _isDarkMode = false; // Initial state for day/night mode

  @override
  void initState() {
    super.initState();

    _headerController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _mapController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _floatingController = AnimationController(
      duration: const Duration(milliseconds: 3000),
      vsync: this,
    );

    _cloudController = AnimationController(
      duration: const Duration(milliseconds: 10000),
      vsync: this,
    );

    _starController = AnimationController(
      duration: const Duration(milliseconds: 4000),
      vsync: this,
    );

    _sunsetController = AnimationController(
      duration: const Duration(milliseconds: 8000),
      vsync: this,
    );

    _headerAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _headerController, curve: Curves.easeOutBack),
    );

    _mapAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _mapController, curve: Curves.easeOutCubic),
    );

    _floatingAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _floatingController, curve: Curves.easeInOut),
    );

    _cloudAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _cloudController, curve: Curves.linear),
    );

    _starAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _starController, curve: Curves.easeInOut),
    );

    _sunsetAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _sunsetController, curve: Curves.easeInOut),
    );

    // Initial load and animation start
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Check system brightness for initial mode
      final brightness = MediaQuery.of(context).platformBrightness;
      setState(() {
        _isDarkMode = brightness == Brightness.dark;
      });

      Provider.of<HomeProvider>(context, listen: false).loadLessons();
      Provider.of<UserProvider>(context, listen: false).loadUser();

      _startAnimations();
    });

    _floatingController.repeat(reverse: true); // Continuous floating
    _cloudController.repeat(); // Continuous cloud movement
    _starController.repeat(reverse: true); // Twinkling stars
    _sunsetController.repeat(reverse: true); // Sunset/sunrise cycle

    // Listen to scroll for parallax effects and day/night transition
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    final scrollOffset = _scrollController.offset;
    final maxScroll = _scrollController.hasClients ? _scrollController.position.maxScrollExtent : 1.0; // Avoid division by zero
    final scrollProgress = (scrollOffset / maxScroll).clamp(0.0, 1.0);

    // Drive sunset animation based on scroll progress
    _sunsetController.value = scrollProgress;

    // Toggle dark mode based on scroll progress (e.g., after 70% scroll, switch to night)
    setState(() {
      _isDarkMode = scrollProgress > 0.7; // Adjust threshold as needed
    });
  }

  void _startAnimations() {
    _headerController.forward();
    Future.delayed(const Duration(milliseconds: 300), () {
      _mapController.forward();
    });
  }

  @override
  void dispose() {
    _headerController.dispose();
    _mapController.dispose();
    _floatingController.dispose();
    _cloudController.dispose();
    _starController.dispose();
    _sunsetController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: _buildDynamicGradient(), // Dynamic background gradient
        ),
        child: Stack(
          children: [
            // Background Layer
            BackgroundLayer(
              isDarkMode: _isDarkMode,
              sunsetAnimation: _sunsetAnimation,
              starAnimation: _starAnimation,
              cloudAnimation: _cloudAnimation,
              starController: _starController,
              floatingAnimation: _floatingAnimation, // Pass floating for sand footer
              onDayNightToggle: (value) {
                setState(() {
                  _isDarkMode = value;
                });
              },
            ),

            // Main content (Header and Learning Map)
            SafeArea(
              child: CustomScrollView(
                controller: _scrollController,
                physics: const BouncingScrollPhysics(), // Smooth scrolling
                reverse: false, // Changed to false to scroll from top to bottom
                slivers: [
                  // Animated Header (part of ProgressAndLessonDetails) - now at the top of the scroll view
                  SliverToBoxAdapter(
                    child: AnimatedBuilder(
                      animation: _headerAnimation,
                      builder: (context, child) {
                        return Transform.translate(
                          offset: Offset(0, 30 * (1 - _headerAnimation.value)), // Slide down
                          child: Opacity(
                            opacity: _headerAnimation.value, // Fade in
                            child: ProgressAndLessonDetails(
                              isDarkMode: _isDarkMode,
                              floatingAnimation: _floatingAnimation,
                              isGeneralProgress: true, // This is the general header
                              handleActivityTap: _handleActivityTap, // Pass down for potential use in popup
                              handleLessonStart: _handleLessonStart, // Pass down for potential use in popup
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                  // Learning Map Layer
                  Consumer<HomeProvider>(
                    builder: (context, homeProvider, child) {
                      if (homeProvider.isLoading && homeProvider.lessons.isEmpty) {
                        return SliverFillRemaining(
                          child: LoadingState(isDarkMode: _isDarkMode),
                        );
                      }

                      if (homeProvider.error != null) {
                        return SliverFillRemaining(
                          child: ErrorState(
                            isDarkMode: _isDarkMode,
                            error: homeProvider.error,
                            onRetry: () {
                              homeProvider.loadLessons();
                              _startAnimations();
                            },
                          ),
                        );
                      }

                      if (homeProvider.lessons.isEmpty) {
                        return SliverFillRemaining(
                          child: EmptyState(isDarkMode: _isDarkMode),
                        );
                      }

                      return LearningMapLayer(
                        mapAnimation: _mapAnimation,
                        lessons: homeProvider.lessons,
                        isDarkMode: _isDarkMode,
                        isLessonUnlocked: homeProvider.isLessonUnlocked,
                        floatingAnimation: _floatingAnimation,
                        showLessonDetails: (lesson) => _showLessonDetails(context, lesson, homeProvider),
                        // Pass homeProvider directly to showLessonDetails
                      );
                    },
                  ),

                  // Bottom padding with sand effect (now part of BackgroundLayer)
                  SliverToBoxAdapter(
                    child: SizedBox(height: 200.h), // Just a spacer here, actual sand is in BackgroundLayer
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- Dynamic Background Gradient (remains in HomeScreen as it controls the Scaffold background) ---
  LinearGradient _buildDynamicGradient() {
    final scrollOffset = _scrollController.hasClients ? _scrollController.offset : 0.0;
    final maxScroll = _scrollController.hasClients ? _scrollController.position.maxScrollExtent : 1000.0;
    final scrollProgress = (scrollOffset / maxScroll).clamp(0.0, 1.0);

    // Interpolate colors based on sunset animation value
    // 0.0 = full day, 1.0 = full night
    final double animValue = _sunsetAnimation.value;

    // Sunset to Night transition
    final Color topColor = Color.lerp(const Color(0xFFCD853F), nightBlue, animValue)!; // SaddleBrown to DarkIndigo
    final Color midColor1 = Color.lerp(const Color(0xFFDAA520), darkPurple, animValue)!; // Goldenrod to DarkPurple
    final Color midColor2 = Color.lerp(const Color(0xFFFFDAB9), const Color(0xFF3F51B5), animValue)!; // PeachPuff to Indigo
    final Color bottomColor = Color.lerp(const Color(0xFFF5F5DC), const Color(0xFF795548), animValue)!; // Beige to Brown

    return LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        topColor,
        midColor1,
        midColor2,
        bottomColor,
      ],
      stops: const [0.0, 0.3, 0.7, 1.0],
    );
  }

  // --- Lesson Details Modal (now uses ProgressAndLessonDetails) ---
  void _showLessonDetails(BuildContext context, LessonEntity lesson, HomeProvider homeProvider) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true, // Allows sheet to take full height
      backgroundColor: Colors.transparent, // For custom background
      builder: (context) => ProgressAndLessonDetails(
        isDarkMode: _isDarkMode,
        lesson: lesson, // Pass the specific lesson
        homeProvider: homeProvider, // Pass homeProvider for activity unlocking logic
        isGeneralProgress: false, // This is a lesson details popup
        handleActivityTap: _handleActivityTap,
        handleLessonStart: _handleLessonStart,
      ),
    );
  }

  // --- Event Handlers (remain in HomeScreen as they interact with providers) ---
  void _handleLessonStart(LessonEntity lesson) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('بدء ${lesson.title}'), // Starting X
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
        backgroundColor: _isDarkMode ? starGold : primaryOrange,
        margin: EdgeInsets.all(16.w),
      ),
    );
  }

  void _handleActivityTap(BuildContext context, LessonActivityEntity activity, String lessonId) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('بدء نشاط: ${activity.title} (النوع: ${activity.type.name})')), // Starting activity: X (Type: Y)
    );

    // Navigate based on activity type
    switch (activity.type) {
      case LessonActivityType.quiz:
        if (activity.associatedRoute != null && activity.associatedDataId != null) {
          Navigator.pushNamed(
            context,
            activity.associatedRoute!,
            arguments: activity.associatedDataId, // Pass quizId as argument
          ).then((result) {
            // Assuming the quiz screen returns true on successful completion
            if (result == true) {
              // Mark activity as completed in HomeProvider
              Provider.of<HomeProvider>(context, listen: false).updateActivityCompletion(
                lessonId: lessonId,
                activityId: activity.id,
                isCompleted: true,
              );
              // Update daily activity/progress
              Provider.of<ActivityProvider>(context, listen: false).addDailyActivity(
                lessonsCompleted: 1, // Count quiz completion as 1 lesson
                correctAnswers: 5, // Example - replace with actual quiz results
                pointsEarned: 10, // Example - replace with actual quiz results
                timeSpentMinutes: 5, // Example - replace with actual quiz results
              );
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('تم إكمال نشاط: ${activity.title} بنجاح!'), // Activity completed successfully!
                  backgroundColor: Colors.green,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
                  margin: EdgeInsets.all(16.w),
                ),
              );
            }
          });
        }
        break;

      case LessonActivityType.writing:
        _simulateActivityCompletion(context, activity, lessonId, 5, 3);
        break;

      case LessonActivityType.speaking:
        _simulateActivityCompletion(context, activity, lessonId, 7, 4);
        break;

      case LessonActivityType.flashcards:
        _simulateActivityCompletion(context, activity, lessonId, 3, 2);
        break;

      case LessonActivityType.grammar:
        _simulateActivityCompletion(context, activity, lessonId, 8, 6);
        break;

      default:
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('نوع النشاط غير معروف.'), // Unknown activity type.
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
            backgroundColor: Colors.orange,
            margin: EdgeInsets.all(16.w),
          ),
        );
        break;
    }
  }

  void _simulateActivityCompletion(BuildContext context, LessonActivityEntity activity,
      String lessonId, int points, int minutes) {
    Future.delayed(const Duration(seconds: 1), () {
      Provider.of<HomeProvider>(context, listen: false).updateActivityCompletion(
        lessonId: lessonId,
        activityId: activity.id,
        isCompleted: true,
      );
      Provider.of<ActivityProvider>(context, listen: false).addDailyActivity(
        lessonsCompleted: 0,
        correctAnswers: 0,
        pointsEarned: points,
        timeSpentMinutes: minutes,
      );
    });
  }
}
