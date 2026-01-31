// lib/features/home/presentation/screens/lesson_details_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:grad_project/features/home/presentation/providers/home_provider.dart';
import 'package:grad_project/features/home/domain/entities/lesson_entity.dart';
import 'package:grad_project/features/home/domain/entities/lesson_activity_entity.dart';
import 'package:grad_project/features/home/presentation/screens/video_lesson_screen.dart';
import 'package:grad_project/core/navigation/app_routes.dart';
import 'dart:math' as math;

class LessonDetailsScreen extends StatefulWidget {
  final String lessonId;

  const LessonDetailsScreen({
    Key? key,
    required this.lessonId,
  }) : super(key: key);

  @override
  State<LessonDetailsScreen> createState() => _LessonDetailsScreenState();
}

class _LessonDetailsScreenState extends State<LessonDetailsScreen>
    with TickerProviderStateMixin {
  late AnimationController _slideController;
  late AnimationController _floatingController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _floatingAnimation;

  bool _isLoading = true;
  bool _hasError = false;
  String? _errorMessage;
  Map<String, dynamic>? _lessonDetails;
  LessonEntity? _lesson;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _loadLessonDetails();
  }

  void _initializeAnimations() {
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _floatingController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat();

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.elasticOut,
    ));

    _floatingAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _floatingController,
      curve: Curves.easeInOut,
    ));

    _slideController.forward();
  }

  Future<void> _loadLessonDetails() async {
    try {
      final homeProvider = Provider.of<HomeProvider>(context, listen: false);

      // Get lesson from provider
      _lesson = homeProvider.lessons.firstWhere(
            (lesson) => lesson.id == widget.lessonId,
        orElse: () => throw Exception('Lesson not found'),
      );

      // Get detailed lesson data
      final details = await homeProvider.remoteDataSource.getLessonDetails(widget.lessonId);

      setState(() {
        _lessonDetails = details;
        _isLoading = false;
        _hasError = false;
      });
    } catch (e) {
      setState(() {
        _hasError = true;
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _startActivity(LessonActivityEntity activity) async {
    try {
      final homeProvider = Provider.of<HomeProvider>(context, listen: false);
      await homeProvider.startLesson(_lesson!);

      switch (activity.type) {
        case LessonActivityType.video:
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => VideoLessonScreen(lessonId: widget.lessonId),
            ),
          );
          break;
        case LessonActivityType.quiz:
          Navigator.pushNamed(context, AppRoutes.quiz);
          break;
        case LessonActivityType.grammar:
          Navigator.pushNamed(context, AppRoutes.grammarParsing);
          break;
        default:
          _showComingSoonDialog(activity.type.name);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('خطأ في بدء النشاط: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showComingSoonDialog(String activityType) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('قريباً'),
        content: Text('نشاط $activityType سيتوفر قريباً'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('حسناً'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _slideController.dispose();
    _floatingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: Stack(
        children: [
          // Background Gradient
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  colorScheme.primary.withOpacity(0.1),
                  colorScheme.background,
                  colorScheme.tertiary.withOpacity(0.05),
                ],
              ),
            ),
          ),

          // Floating particles
          ...List.generate(6, (index) => _buildFloatingParticle(index)),

          // Main content
          SafeArea(
            child: _isLoading
                ? _buildLoadingState()
                : _hasError
                ? _buildErrorState()
                : _buildLessonContent(),
          ),
        ],
      ),
    );
  }

  Widget _buildFloatingParticle(int index) {
    return AnimatedBuilder(
      animation: _floatingAnimation,
      builder: (context, child) {
        final offset = (index * 0.3) % 1.0;
        final animValue = (_floatingAnimation.value + offset) % 1.0;

        final screenWidth = MediaQuery.of(context).size.width;
        final screenHeight = MediaQuery.of(context).size.height;

        final x = 50.w + (screenWidth - 100.w) *
            ((index / 6 + animValue * 0.1 + math.sin(animValue * math.pi * 2) * 0.1) % 1.0);
        final y = 100.h + (screenHeight * 0.7) *
            (animValue + math.sin(animValue * math.pi * 3 + index) * 0.1);

        final size = (8 + index % 4).r;
        final opacity = 0.3 + 0.4 * ((math.sin(animValue * math.pi * 2) + 1) / 2);

        return Positioned(
          left: x,
          top: y,
          child: Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              gradient: RadialGradient(
                colors: [
                  Theme.of(context).colorScheme.primary.withOpacity(opacity),
                  Theme.of(context).colorScheme.primary.withOpacity(opacity * 0.3),
                ],
              ),
              shape: BoxShape.circle,
            ),
          ),
        );
      },
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: AnimatedBuilder(
        animation: _floatingAnimation,
        builder: (context, child) {
          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Transform.rotate(
                angle: _floatingAnimation.value * math.pi * 2,
                child: Container(
                  padding: EdgeInsets.all(20.r),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Theme.of(context).colorScheme.primary,
                        Theme.of(context).colorScheme.tertiary,
                      ],
                    ),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
                        blurRadius: 20,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.school,
                    color: Colors.white,
                    size: 32.r,
                  ),
                ),
              ),
              SizedBox(height: 24.h),
              Text(
                'جاري تحميل تفاصيل الدرس...',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onBackground,
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(24.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              color: Colors.red,
              size: 64.r,
            ),
            SizedBox(height: 24.h),
            Text(
              'خطأ في تحميل الدرس',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: Theme.of(context).colorScheme.onBackground,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 12.h),
            Text(
              _errorMessage ?? 'حدث خطأ غير متوقع',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onBackground.withOpacity(0.7),
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 32.h),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _isLoading = true;
                  _hasError = false;
                });
                _loadLessonDetails();
              },
              child: const Text('إعادة المحاولة'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLessonContent() {
    if (_lesson == null) return _buildErrorState();

    return SlideTransition(
      position: _slideAnimation,
      child: Column(
        children: [
          // Header
          _buildHeader(),

          // Content
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(20.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildLessonInfo(),
                  SizedBox(height: 24.h),
                  _buildProgressSection(),
                  SizedBox(height: 24.h),
                  _buildActivitiesSection(),
                  SizedBox(height: 24.h),
                  _buildStartButton(),
                  SizedBox(height: 40.h),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      height: 200.h,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            colorScheme.primary,
            colorScheme.tertiary,
          ],
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(30.r),
          bottomRight: Radius.circular(30.r),
        ),
      ),
      child: Stack(
        children: [
          // Background pattern
          Positioned.fill(
            child: CustomPaint(
              painter: HeaderPatternPainter(),
            ),
          ),

          // Content
          Padding(
            padding: EdgeInsets.all(20.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: Icon(
                        Icons.arrow_back,
                        color: Colors.white,
                        size: 28.r,
                      ),
                    ),
                    const Spacer(),
                    if (_lesson!.isCompleted)
                      AnimatedBuilder(
                        animation: _floatingAnimation,
                        builder: (context, child) {
                          return Transform.scale(
                            scale: 1.0 + 0.1 * math.sin(_floatingAnimation.value * math.pi * 2),
                            child: Container(
                              padding: EdgeInsets.all(8.r),
                              decoration: BoxDecoration(
                                color: Colors.green,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.green.withOpacity(0.5),
                                    blurRadius: 10,
                                    spreadRadius: 2,
                                  ),
                                ],
                              ),
                              child: Icon(
                                Icons.check,
                                color: Colors.white,
                                size: 20.r,
                              ),
                            ),
                          );
                        },
                      ),
                  ],
                ),

                const Spacer(),

                Text(
                  _lesson!.title,
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                SizedBox(height: 8.h),

                Text(
                  _lesson!.description,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),

                SizedBox(height: 16.h),

                Row(
                  children: [
                    _buildInfoChip(
                      icon: Icons.access_time,
                      label: '${_lesson!.duration} دقيقة',
                    ),
                    SizedBox(width: 12.w),
                    _buildInfoChip(
                      icon: Icons.star,
                      label: '${_lesson!.xpReward} نقطة',
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoChip({required IconData icon, required String label}) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: Colors.white.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: Colors.white,
            size: 16.r,
          ),
          SizedBox(width: 6.w),
          Text(
            label,
            style: TextStyle(
              color: Colors.white,
              fontSize: 12.sp,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLessonInfo() {
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'معلومات الدرس',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 16.h),
          _buildInfoRow(
            icon: Icons.school,
            title: 'المستوى',
            value: 'المبتدئ',
          ),
          _buildInfoRow(
            icon: Icons.category,
            title: 'النوع',
            value: _lesson!.activities.isNotEmpty
                ? _getActivityTypeText(_lesson!.activities.first.type)
                : 'متنوع',
          ),
          _buildInfoRow(
            icon: Icons.assignment,
            title: 'الأنشطة',
            value: '${_lesson!.activities.length} نشاط',
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12.h),
      child: Row(
        children: [
          Icon(
            icon,
            color: Theme.of(context).colorScheme.primary,
            size: 20.r,
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Text(
              title,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
              ),
            ),
          ),
          Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressSection() {
    final progress = _lesson!.progress;

    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'التقدم',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                '${(progress * 100).round()}%',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),

          SizedBox(height: 16.h),

          AnimatedBuilder(
            animation: _slideController,
            builder: (context, child) {
              return LinearProgressIndicator(
                value: progress * _slideController.value,
                backgroundColor: Theme.of(context).colorScheme.outline.withOpacity(0.2),
                valueColor: AlwaysStoppedAnimation<Color>(
                  Theme.of(context).colorScheme.primary,
                ),
                minHeight: 8.h,
              );
            },
          ),

          SizedBox(height: 12.h),

          Text(
            _lesson!.isCompleted
                ? 'تم إكمال الدرس بنجاح! 🎉'
                : progress > 0
                ? 'تقدم جيد، واصل التعلم!'
                : 'ابدأ رحلة التعلم',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActivitiesSection() {
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'أنشطة الدرس',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 16.h),

          if (_lesson!.activities.isEmpty)
            Center(
              child: Column(
                children: [
                  Icon(
                    Icons.assignment_outlined,
                    size: 48.r,
                    color: Theme.of(context).colorScheme.outline,
                  ),
                  SizedBox(height: 12.h),
                  Text(
                    'لا توجد أنشطة متاحة حالياً',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                    ),
                  ),
                ],
              ),
            )
          else
            ...List.generate(
              _lesson!.activities.length,
                  (index) => _buildActivityCard(_lesson!.activities[index], index),
            ),
        ],
      ),
    );
  }

  Widget _buildActivityCard(LessonActivityEntity activity, int index) {
    final isCompleted = activity.isCompleted;
    final isUnlocked = index == 0 || _lesson!.activities[index - 1].isCompleted;

    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      child: AnimatedBuilder(
        animation: _floatingAnimation,
        builder: (context, child) {
          final float = isUnlocked ? 3 * math.sin(_floatingAnimation.value * math.pi * 2 + index) : 0.0;

          return Transform.translate(
            offset: Offset(0, float),
            child: GestureDetector(
              onTap: isUnlocked ? () => _startActivity(activity) : null,
              child: Container(
                padding: EdgeInsets.all(16.w),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: isCompleted
                        ? [Colors.green.shade100, Colors.green.shade50]
                        : isUnlocked
                        ? [
                      _getActivityColor(activity.type).withOpacity(0.1),
                      _getActivityColor(activity.type).withOpacity(0.05),
                    ]
                        : [
                      Colors.grey.shade100,
                      Colors.grey.shade50,
                    ],
                  ),
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(
                    color: isCompleted
                        ? Colors.green.shade300
                        : isUnlocked
                        ? _getActivityColor(activity.type).withOpacity(0.3)
                        : Colors.grey.shade300,
                    width: 1.5,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(12.r),
                      decoration: BoxDecoration(
                        color: isCompleted
                            ? Colors.green
                            : isUnlocked
                            ? _getActivityColor(activity.type)
                            : Colors.grey.shade400,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        isCompleted
                            ? Icons.check
                            : _getActivityIcon(activity.type),
                        color: Colors.white,
                        size: 20.r,
                      ),
                    ),

                    SizedBox(width: 16.w),

                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            activity.title,
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: isUnlocked
                                  ? Theme.of(context).colorScheme.onSurface
                                  : Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
                            ),
                          ),
                          SizedBox(height: 4.h),
                          Text(
                            activity.description,
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: isUnlocked
                                  ? Theme.of(context).colorScheme.onSurface.withOpacity(0.7)
                                  : Theme.of(context).colorScheme.onSurface.withOpacity(0.4),
                            ),
                          ),
                          SizedBox(height: 8.h),
                          Row(
                            children: [
                              Icon(
                                Icons.access_time,
                                size: 14.r,
                                color: isUnlocked ? Colors.amber : Colors.grey,
                              ),
                              SizedBox(width: 4.w),
                              Text(
                                '${activity.duration} دقيقة',
                                style: TextStyle(
                                  fontSize: 12.sp,
                                  color: isUnlocked ? Colors.amber.shade700 : Colors.grey,
                                ),
                              ),
                              SizedBox(width: 16.w),
                              Icon(
                                Icons.star,
                                size: 14.r,
                                color: isUnlocked ? Colors.orange : Colors.grey,
                              ),
                              SizedBox(width: 4.w),
                              Text(
                                '${activity.xpReward} نقطة',
                                style: TextStyle(
                                  fontSize: 12.sp,
                                  color: isUnlocked ? Colors.orange.shade700 : Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    if (isCompleted)
                      Icon(
                        Icons.check_circle,
                        color: Colors.green,
                        size: 24.r,
                      )
                    else if (!isUnlocked)
                      Icon(
                        Icons.lock,
                        color: Colors.grey,
                        size: 24.r,
                      )
                    else
                      Icon(
                        Icons.play_circle_fill,
                        color: _getActivityColor(activity.type),
                        size: 24.r,
                      ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildStartButton() {
    final canStart = !_lesson!.isCompleted &&
        Provider.of<HomeProvider>(context, listen: false).isLessonUnlocked(_lesson!);

    return AnimatedBuilder(
      animation: _floatingAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: canStart ? 1.0 + 0.02 * math.sin(_floatingAnimation.value * math.pi * 2) : 1.0,
          child: Container(
            width: double.infinity,
            height: 56.h,
            child: ElevatedButton(
              onPressed: canStart ? () => _startFirstActivity() : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: canStart
                    ? Theme.of(context).colorScheme.primary
                    : Colors.grey.shade400,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(28.r),
                ),
                elevation: canStart ? 8 : 0,
                shadowColor: canStart
                    ? Theme.of(context).colorScheme.primary.withOpacity(0.3)
                    : Colors.transparent,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    _lesson!.isCompleted
                        ? Icons.check_circle
                        : canStart
                        ? Icons.play_arrow
                        : Icons.lock,
                    color: Colors.white,
                    size: 24.r,
                  ),
                  SizedBox(width: 12.w),
                  Text(
                    _lesson!.isCompleted
                        ? 'تم إكمال الدرس'
                        : canStart
                        ? 'بدء الدرس'
                        : 'الدرس مقفل',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _startFirstActivity() {
    if (_lesson!.activities.isNotEmpty) {
      _startActivity(_lesson!.activities.first);
    }
  }

  Color _getActivityColor(LessonActivityType type) {
    switch (type) {
      case LessonActivityType.video:
        return Colors.red;
      case LessonActivityType.quiz:
        return Colors.purple;
      case LessonActivityType.writing:
        return Colors.blue;
      case LessonActivityType.speaking:
        return Colors.pink;
      case LessonActivityType.flashcards:
        return Colors.green;
      case LessonActivityType.grammar:
        return Colors.orange;
      case LessonActivityType.wordle:
        return Colors.indigo;
      case LessonActivityType.reading:
        return Colors.teal;
      case LessonActivityType.listening:
        return Colors.cyan;
      default:
        return Colors.grey;
    }
  }

  IconData _getActivityIcon(LessonActivityType type) {
    switch (type) {
      case LessonActivityType.video:
        return Icons.play_circle_fill;
      case LessonActivityType.quiz:
        return Icons.quiz;
      case LessonActivityType.writing:
        return Icons.edit;
      case LessonActivityType.speaking:
        return Icons.mic;
      case LessonActivityType.flashcards:
        return Icons.layers;
      case LessonActivityType.grammar:
        return Icons.menu_book;
      case LessonActivityType.wordle:
        return Icons.games;
      case LessonActivityType.reading:
        return Icons.chrome_reader_mode;
      case LessonActivityType.listening:
        return Icons.headphones;
      default:
        return Icons.assignment;
    }
  }

  String _getActivityTypeText(LessonActivityType type) {
    switch (type) {
      case LessonActivityType.video:
        return 'فيديو تعليمي';
      case LessonActivityType.quiz:
        return 'اختبار';
      case LessonActivityType.writing:
        return 'كتابة';
      case LessonActivityType.speaking:
        return 'تحدث';
      case LessonActivityType.flashcards:
        return 'بطاقات تعليمية';
      case LessonActivityType.grammar:
        return 'قواعد';
      case LessonActivityType.wordle:
        return 'لعبة كلمات';
      case LessonActivityType.reading:
        return 'قراءة';
      case LessonActivityType.listening:
        return 'استماع';
      default:
        return 'نشاط';
    }
  }
}

// Custom painter for header background pattern
class HeaderPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.1)
      ..style = PaintingStyle.fill;

    // Create subtle geometric pattern
    for (double i = 0; i < size.width + 50; i += 50) {
      for (double j = 0; j < size.height + 50; j += 50) {
        final path = Path();
        path.addOval(Rect.fromCircle(
          center: Offset(i, j),
          radius: 3,
        ));
        canvas.drawPath(path, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}