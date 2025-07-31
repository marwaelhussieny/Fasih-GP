// lib/features/home/presentation/widgets/progress_and_lesson_details.dart

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:grad_project/features/profile/presentation/providers/user_provider.dart';
import 'package:grad_project/features/home/domain/entities/lesson_entity.dart';
import 'package:grad_project/features/home/domain/entities/lesson_activity_entity.dart';
import 'package:grad_project/features/home/presentation/providers/home_provider.dart';
import 'package:grad_project/features/home/presentation/widgets/activity_card.dart'; // Re-use ActivityCard
import 'package:grad_project/features/home/presentation/screens/home_screen.dart'; // Import colors
import 'dart:math' as math;

class ProgressAndLessonDetails extends StatelessWidget {
  final bool isDarkMode;
  final Animation<double>? floatingAnimation; // Made nullable
  final bool isGeneralProgress; // True for header/general popup, false for lesson details
  final dynamic userProgress; // Only for general progress view
  final LessonEntity? lesson; // Only for lesson details view
  final HomeProvider? homeProvider; // Only for lesson details view (to check activity unlocked)
  final Function(BuildContext context, LessonActivityEntity activity, String lessonId) handleActivityTap;
  final Function(LessonEntity lesson)? handleLessonStart;


  const ProgressAndLessonDetails({
    Key? key,
    required this.isDarkMode,
    this.floatingAnimation, // Removed 'required'
    required this.isGeneralProgress,
    this.userProgress, // Nullable
    this.lesson, // Nullable
    this.homeProvider, // Nullable
    required this.handleActivityTap,
    required this.handleLessonStart,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (isGeneralProgress) {
      return _buildModernHeader(context);
    } else {
      return _buildLessonDetailsModal(context);
    }
  }

  // --- Modern Header (General Progress) ---
  Widget _buildModernHeader(BuildContext context) {
    return Consumer<UserProvider>(
      builder: (context, userProvider, child) {
        final currentProgress = userProvider.user?.progress;

        return Container(
          margin: EdgeInsets.all(20.w),
          child: Column(
            mainAxisSize: MainAxisSize.min, // Added MainAxisSize.min
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      mainAxisSize: MainAxisSize.min, // Added MainAxisSize.min
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'مسار التعلم',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 24.sp,
                            color: Colors.white,
                            shadows: [
                              Shadow(
                                offset: const Offset(0, 2),
                                blurRadius: 6,
                                color: (isDarkMode ? nightBlue : primaryOrange).withOpacity(0.5),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 8.h), // Reduced spacing
                        Wrap(
                          spacing: 8.w,
                          runSpacing: 8.h,
                          children: [
                            _buildStatBadge(
                              icon: Icons.school_rounded,
                              value: '${currentProgress?.totalLessonsCompleted ?? 0}',
                              colors: isDarkMode
                                  ? [nightBlue, darkPurple]
                                  : [primaryOrange, lightOrange],
                            ),
                            _buildStatBadge(
                              icon: Icons.local_fire_department_rounded,
                              value: '${currentProgress?.currentStreak ?? 0}',
                              colors: const [Color(0xFFFF6B35), Color(0xFFFF8E53)],
                            ),
                            _buildStatBadge(
                              icon: Icons.stars_rounded,
                              value: '${(currentProgress?.totalPoints ?? 0) > 999 ? '${((currentProgress?.totalPoints ?? 0) / 1000).toStringAsFixed(1)}K' : (currentProgress?.totalPoints ?? 0).toString()}',
                              colors: isDarkMode
                                  ? [starGold, const Color(0xFFFFE082)]
                                  : [warmAmber, softPeach],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: 12.w),
                  GestureDetector(
                    onTap: () => _showGeneralProgressDetailsPopup(context, currentProgress),
                    child: Container(
                      padding: EdgeInsets.all(12.r), // Reduced padding
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Colors.white,
                            Colors.white.withOpacity(0.95),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(20.r), // Reduced border radius
                        boxShadow: [
                          BoxShadow(
                            color: (isDarkMode ? nightBlue : primaryOrange).withOpacity(0.3),
                            spreadRadius: 0,
                            blurRadius: 15, // Reduced blur
                            offset: const Offset(0, 6), // Reduced offset
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.person_rounded,
                        color: isDarkMode ? nightBlue : primaryOrange,
                        size: 22.r, // Reduced icon size
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 18.h), // Reduced spacing
              // Safely use floatingAnimation if it's provided
              if (floatingAnimation != null)
                AnimatedBuilder(
                  animation: floatingAnimation!,
                  builder: (context, child) {
                    return Transform.translate(
                      offset: Offset(0, 4 * math.sin(floatingAnimation!.value * math.pi * 2)),
                      child: Container(
                        padding: EdgeInsets.all(18.w), // Reduced padding
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: isDarkMode ? [
                              nightBlue.withOpacity(0.9),
                              darkPurple.withOpacity(0.8),
                              nightBlue.withOpacity(0.95),
                            ] : [
                              Colors.white,
                              desertSand.withOpacity(0.3),
                              Colors.white.withOpacity(0.95),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(24.r), // Reduced border radius
                          boxShadow: [
                            BoxShadow(
                              color: (isDarkMode ? nightBlue : primaryOrange).withOpacity(0.2),
                              spreadRadius: 0,
                              blurRadius: 20, // Reduced blur
                              offset: const Offset(0, 10), // Reduced offset
                            ),
                          ],
                          border: Border.all(
                            color: (isDarkMode ? starGold : warmAmber).withOpacity(0.3),
                            width: 1.5.w,
                          ),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                mainAxisSize: MainAxisSize.min, // Added MainAxisSize.min
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'إجمالي النقاط',
                                    style: TextStyle(
                                      color: (isDarkMode ? Colors.white : primaryOrange).withOpacity(0.8),
                                      fontSize: 12.sp, // Reduced font size
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  SizedBox(height: 4.h), // Reduced spacing
                                  FittedBox(
                                    fit: BoxFit.scaleDown,
                                    child: Text(
                                      '${currentProgress?.totalPoints ?? 0}',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 24.sp, // Reduced font size
                                        color: isDarkMode ? Colors.white : primaryOrange,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              padding: EdgeInsets.all(14.r), // Reduced padding
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: isDarkMode
                                      ? [starGold, const Color(0xFFFFE082)]
                                      : [lightOrange, primaryOrange],
                                ),
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: (isDarkMode ? starGold : lightOrange).withOpacity(0.4),
                                    spreadRadius: 0,
                                    blurRadius: 20, // Reduced blur
                                    offset: const Offset(0, 8), // Reduced offset
                                  ),
                                ],
                              ),
                              child: Icon(
                                Icons.stars_rounded,
                                color: isDarkMode ? nightBlue : Colors.white,
                                size: 24.r, // Reduced icon size
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatBadge({
    required IconData icon,
    required String value,
    required List<Color> colors,
  }) {
    return Container(
      constraints: BoxConstraints(
        minWidth: 60.w, // Ensure minimum width
        minHeight: 32.h, // Ensure minimum height
      ),
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h), // Increased padding significantly
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: colors,
        ),
        borderRadius: BorderRadius.circular(20.r), // Increased border radius for better shape
        boxShadow: [
          BoxShadow(
            color: colors[0].withOpacity(0.4),
            spreadRadius: 0,
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center, // Center content
        children: [
          Icon(icon, color: Colors.white, size: 18.r), // Increased icon size
          SizedBox(width: 8.w), // Increased spacing
          Container(
            constraints: BoxConstraints(minWidth: 20.w), // Ensure space for numbers
            child: Text(
              value,
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 14.sp, // Increased font size
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.visible, // Changed to visible
            ),
          ),
        ],
      ),
    );
  }

  // --- General Progress Details Popup ---
  void _showGeneralProgressDetailsPopup(BuildContext context, dynamic currentProgress) {
    showDialog(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.black.withOpacity(0.6),
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 20.h), // Increased horizontal padding
          child: ConstrainedBox( // Added ConstrainedBox
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.75, // Reduced max height
            ),
            child: Container(
              padding: EdgeInsets.all(20.w), // Reduced padding
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: isDarkMode ? [
                    nightBlue,
                    darkPurple.withOpacity(0.9),
                    nightBlue,
                  ] : [
                    Colors.white,
                    desertSand.withOpacity(0.3),
                    Colors.white,
                  ],
                ),
                borderRadius: BorderRadius.circular(28.r), // Reduced border radius
                boxShadow: [
                  BoxShadow(
                    color: (isDarkMode ? nightBlue : primaryOrange).withOpacity(0.3),
                    spreadRadius: 0,
                    blurRadius: 40, // Reduced blur
                    offset: const Offset(0, 20), // Reduced offset
                  ),
                ],
                border: Border.all(
                  color: (isDarkMode ? starGold : warmAmber).withOpacity(0.3),
                  width: 2.w,
                ),
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min, // Added MainAxisSize.min
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            'إحصائيات التقدم',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 20.sp, // Reduced font size
                              color: isDarkMode ? Colors.white : primaryOrange,
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: () => Navigator.of(context).pop(),
                          child: Container(
                            padding: EdgeInsets.all(10.r), // Reduced padding
                            decoration: BoxDecoration(
                              color: (isDarkMode ? starGold : primaryOrange).withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.close_rounded,
                              color: isDarkMode ? Colors.white : primaryOrange,
                              size: 20.r, // Reduced icon size
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 20.h), // Reduced spacing
                    GridView.count(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisCount: 2,
                      crossAxisSpacing: 12.w, // Increased spacing
                      mainAxisSpacing: 12.h, // Increased spacing
                      childAspectRatio: 1.2, // Adjusted aspect ratio for better fit
                      children: [
                        ProgressAndLessonDetails._buildStatCard( // Call as static method
                          context,
                          icon: Icons.local_fire_department_rounded,
                          value: '${currentProgress?.currentStreak ?? 0}',
                          label: 'أيام متواصلة',
                          gradient: const [Color(0xFFFF6B35), Color(0xFFFF8E53)],
                        ),
                        ProgressAndLessonDetails._buildStatCard( // Call as static method
                          context,
                          icon: Icons.military_tech_rounded,
                          value: '${currentProgress?.totalLessonsCompleted ?? 0}',
                          label: 'دروس مكتملة',
                          gradient: const [Color(0xFF4CAF50), Color(0xFF66BB6A)],
                        ),
                        ProgressAndLessonDetails._buildStatCard( // Call as static method
                          context,
                          icon: Icons.stars_rounded,
                          value: '${(currentProgress?.totalPoints ?? 0) > 999 ? '${((currentProgress?.totalPoints ?? 0) / 1000).toStringAsFixed(1)}K' : (currentProgress?.totalPoints ?? 0).toString()}',
                          label: 'إجمالي النقاط',
                          gradient: isDarkMode
                              ? [starGold, const Color(0xFFFFE082)]
                              : [lightOrange, primaryOrange],
                        ),
                        ProgressAndLessonDetails._buildStatCard( // Call as static method
                          context,
                          icon: Icons.trending_up_rounded,
                          value: 'المبتدئ',
                          label: 'المستوى الحالي',
                          gradient: isDarkMode
                              ? [nightBlue, darkPurple]
                              : [primaryOrange, lightOrange],
                        ),
                      ],
                    ),
                    SizedBox(height: 20.h), // Reduced spacing
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(18.w), // Reduced padding
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: isDarkMode ? [
                            starGold.withOpacity(0.1),
                            nightBlue.withOpacity(0.05),
                          ] : [
                            primaryOrange.withOpacity(0.1),
                            warmAmber.withOpacity(0.05),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(20.r), // Reduced border radius
                        border: Border.all(
                          color: (isDarkMode ? starGold : primaryOrange).withOpacity(0.3),
                          width: 1.5.w,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: (isDarkMode ? starGold : primaryOrange).withOpacity(0.1),
                            blurRadius: 15, // Reduced blur
                            offset: const Offset(0, 8), // Reduced offset
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min, // Added MainAxisSize.min
                        children: [
                          Container(
                            padding: EdgeInsets.all(14.r), // Reduced padding
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: isDarkMode
                                    ? [starGold, const Color(0xFFFFE082)]
                                    : [lightOrange, primaryOrange],
                              ),
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: (isDarkMode ? starGold : lightOrange).withOpacity(0.4),
                                  blurRadius: 15, // Reduced blur
                                  offset: const Offset(0, 6), // Reduced offset
                                ),
                              ],
                            ),
                            child: Icon(
                              Icons.emoji_events_rounded,
                              color: isDarkMode ? nightBlue : Colors.white,
                              size: 28.r, // Reduced icon size
                            ),
                          ),
                          SizedBox(height: 14.h), // Reduced spacing
                          Text(
                            'استمر في التعلم!',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: isDarkMode ? Colors.white : primaryOrange,
                              fontSize: 16.sp, // Reduced font size
                            ),
                          ),
                          SizedBox(height: 6.h), // Reduced spacing
                          Text(
                            'أنت في المسار الصحيح لإتقان اللغة العربية',
                            style: TextStyle(
                              color: (isDarkMode ? Colors.white : primaryOrange).withOpacity(0.7),
                              fontSize: 12.sp, // Reduced font size
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 18.h), // Reduced spacing
                    Container(
                      width: double.infinity,
                      height: 44.h, // Reduced height
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: isDarkMode
                              ? [starGold, const Color(0xFFFFE082)]
                              : [primaryOrange, lightOrange],
                        ),
                        borderRadius: BorderRadius.circular(22.r), // Reduced border radius
                        boxShadow: [
                          BoxShadow(
                            color: (isDarkMode ? starGold : primaryOrange).withOpacity(0.4),
                            spreadRadius: 0,
                            blurRadius: 15, // Reduced blur
                            offset: const Offset(0, 8), // Reduced offset
                          ),
                        ],
                      ),
                      child: ElevatedButton(
                        onPressed: () => Navigator.of(context).pop(),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(22.r), // Reduced border radius
                          ),
                        ),
                        child: Text(
                          'حسناً',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15.sp, // Reduced font size
                            color: isDarkMode ? nightBlue : Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  // --- Lesson Details Modal Content ---
  Widget _buildLessonDetailsModal(BuildContext context) {
    if (lesson == null || homeProvider == null) {
      return const SizedBox.shrink(); // Should not happen if called correctly
    }

    return DraggableScrollableSheet(
      initialChildSize: 0.75,
      maxChildSize: 0.95,
      minChildSize: 0.5,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: isDarkMode ? [
                nightBlue,
                darkPurple.withOpacity(0.9),
                nightBlue,
              ] : [
                Colors.white,
                desertSand.withOpacity(0.3),
                Colors.white,
              ],
            ),
            borderRadius: BorderRadius.vertical(top: Radius.circular(28.r)), // Reduced border radius
            boxShadow: [
              BoxShadow(
                color: (isDarkMode ? nightBlue : primaryOrange).withOpacity(0.3),
                blurRadius: 30, // Reduced blur
                offset: const Offset(0, -10), // Reduced offset
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min, // Added MainAxisSize.min
            children: [
              Container(
                margin: EdgeInsets.only(top: 10.h), // Reduced margin
                width: 50.w, // Reduced width
                height: 4.h, // Reduced height
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: isDarkMode
                        ? [starGold, const Color(0xFFFFE082)]
                        : [primaryOrange, lightOrange],
                  ),
                  borderRadius: BorderRadius.circular(2.r), // Reduced border radius
                ),
              ),
              Expanded(
                child: ListView(
                  controller: scrollController,
                  padding: EdgeInsets.all(24.w), // Reduced padding
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: EdgeInsets.all(18.r), // Reduced padding
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: isDarkMode
                                  ? [starGold, const Color(0xFFFFE082)]
                                  : [primaryOrange, lightOrange],
                            ),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: (isDarkMode ? starGold : primaryOrange).withOpacity(0.3),
                                blurRadius: 10, // Reduced blur
                                offset: const Offset(0, 4), // Reduced offset
                              ),
                            ],
                          ),
                          child: Icon(
                            Icons.menu_book_rounded,
                            color: isDarkMode ? nightBlue : Colors.white,
                            size: 30.r, // Reduced icon size
                          ),
                        ),
                        SizedBox(width: 18.w), // Reduced spacing
                        Expanded(
                          child: Column(
                            mainAxisSize: MainAxisSize.min, // Added MainAxisSize.min
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'الدرس ${lesson!.order}',
                                style: TextStyle(
                                  color: (isDarkMode ? Colors.white : primaryOrange).withOpacity(0.7),
                                  fontSize: 15.sp, // Reduced font size
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              SizedBox(height: 4.h), // Reduced spacing
                              Text(
                                lesson!.title,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 22.sp, // Reduced font size
                                  color: isDarkMode ? Colors.white : primaryOrange,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 32.h), // Reduced spacing
                    Text(
                      'الأنشطة',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20.sp, // Reduced font size
                        color: isDarkMode ? Colors.white : primaryOrange,
                      ),
                    ),
                    SizedBox(height: 18.h), // Reduced spacing
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 12.w, // Reduced spacing
                        mainAxisSpacing: 12.h, // Reduced spacing
                        childAspectRatio: 1.1, // Kept as is, or adjust if needed
                      ),
                      itemCount: lesson!.activities.length,
                      itemBuilder: (context, index) {
                        final activity = lesson!.activities[index];
                        final isActivityUnlocked = homeProvider!.isActivityUnlocked(lesson!, activity);
                        return ActivityCard(
                          activity: activity,
                          isUnlocked: isActivityUnlocked,
                          lessonId: lesson!.id,
                          isDarkMode: isDarkMode,
                          handleActivityTap: handleActivityTap,
                        );
                      },
                    ),
                    SizedBox(height: 32.h), // Reduced spacing
                    Container(
                      width: double.infinity,
                      height: 56.h, // Reduced height
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: isDarkMode
                              ? [starGold, const Color(0xFFFFE082)]
                              : [primaryOrange, lightOrange],
                        ),
                        borderRadius: BorderRadius.circular(28.r), // Reduced border radius
                        boxShadow: [
                          BoxShadow(
                            color: (isDarkMode ? starGold : primaryOrange).withOpacity(0.4),
                            spreadRadius: 0,
                            blurRadius: 15, // Reduced blur
                            offset: const Offset(0, 8), // Reduced offset
                          ),
                        ],
                      ),
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                          if (handleLessonStart != null) {
                            handleLessonStart!(lesson!);
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(28.r), // Reduced border radius
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.play_arrow_rounded,
                                color: isDarkMode ? nightBlue : Colors.white, size: 24.r), // Reduced icon size
                            SizedBox(width: 10.w), // Reduced spacing
                            Text(
                              'ابدأ الدرس',
                              style: TextStyle(
                                fontSize: 18.sp, // Reduced font size
                                fontWeight: FontWeight.bold,
                                color: isDarkMode ? nightBlue : Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // --- Stat Card Helper (Fixed for better icon visibility) ---
  static Widget _buildStatCard(
      BuildContext context, {
        required IconData icon,
        required String value,
        required String label,
        required List<Color> gradient,
      }) {
    final ThemeData theme = Theme.of(context);

    return Container(
      padding: EdgeInsets.all(12.w), // Increased padding for better spacing
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: gradient,
        ),
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: gradient[0].withOpacity(0.4),
            spreadRadius: 0,
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.all(8.r), // Increased padding for icon container
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: Colors.white, size: 20.r), // Increased icon size
          ),
          SizedBox(height: 8.h), // Increased spacing
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              value,
              style: TextStyle(
                color: Colors.white,
                fontSize: 16.sp, // Increased font size
                fontWeight: FontWeight.bold,
              ),
              maxLines: 1,
            ),
          ),
          SizedBox(height: 4.h), // Added spacing
          Flexible(
            child: Text(
              label,
              style: TextStyle(
                color: Colors.white.withOpacity(0.9),
                fontSize: 10.sp, // Increased font size
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}