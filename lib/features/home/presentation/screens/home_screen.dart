// lib/features/home/presentation/screens/home_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:grad_project/features/home/presentation/providers/home_provider.dart';
import 'package:grad_project/features/home/domain/entities/lesson_entity.dart';
import 'package:grad_project/features/profile/presentation/providers/user_provider.dart';
import 'package:grad_project/features/home/presentation/widgets/background_layer.dart';
import 'package:grad_project/features/home/presentation/widgets/learning_map_layer.dart';
import 'package:grad_project/features/home/presentation/widgets/progress_lessons_details.dart';
import 'package:grad_project/features/home/presentation/widgets/state_widget.dart';

const Color primaryOrange = Color(0xFFB8860B);
const Color lightOrange = Color(0xFFDAA520);
const Color warmAmber = Color(0xFFFFB347);
const Color softPeach = Color(0xFFFFDAB9);
const Color desertSand = Color(0xFFF4E4BC);

const Color nightBlue = Color(0xFF1A237E);
const Color darkPurple = Color(0xFF311B92);
const Color starGold = Color(0xFFFFD700);
const Color moonSilver = Color(0xFFC0C0C0);

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

  final ScrollController _scrollController = ScrollController();
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

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final brightness = MediaQuery.of(context).platformBrightness;
      setState(() {
        _isDarkMode = brightness == Brightness.dark;
      });

      Provider.of<HomeProvider>(context, listen: false).initialize();
      Provider.of<UserProvider>(context, listen: false).loadUser();

      _startAnimations();
    });

    _floatingController.repeat(reverse: true);
    _cloudController.repeat();
    _starController.repeat(reverse: true);
    _sunsetController.repeat(reverse: true);

    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    final scrollOffset = _scrollController.offset;
    final maxScroll = _scrollController.hasClients ? _scrollController.position.maxScrollExtent : 1.0;
    final scrollProgress = (scrollOffset / maxScroll).clamp(0.0, 1.0);

    _sunsetController.value = scrollProgress;

    setState(() {
      _isDarkMode = scrollProgress > 0.7;
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
    return Scaffold(
      body: Stack(
        children: [
          // Enhanced BackgroundLayer
          BackgroundLayer(
            isDarkMode: _isDarkMode,
            sunsetAnimation: _sunsetAnimation,
            starAnimation: _starAnimation,
            cloudAnimation: _cloudAnimation,
            starController: _starController,
            floatingAnimation: _floatingAnimation,
            onDayNightToggle: (value) {
              setState(() {
                _isDarkMode = value;
              });
            },
          ),
          SafeArea(
            child: CustomScrollView(
              controller: _scrollController,
              physics: const BouncingScrollPhysics(),
              slivers: [
                // Progress Header
                SliverToBoxAdapter(
                  child: AnimatedBuilder(
                    animation: _headerAnimation,
                    builder: (context, child) {
                      double offset = 0.0;
                      double maxExtent = 0.0;

                      if (_scrollController.hasClients) {
                        final position = _scrollController.position;

                        if (position.hasPixels && position.maxScrollExtent > 0) {
                          offset = position.pixels;
                          maxExtent = position.maxScrollExtent;
                        } else {
                          offset = 0.0;
                          maxExtent = 0.0;
                        }
                      }

                      return Transform.translate(
                        offset: Offset(0, 30 * (1 - _headerAnimation.value)),
                        child: Opacity(
                          opacity: _headerAnimation.value.clamp(0.0, 1.0),
                          child: ProgressLessonsDetails(
                            onScrollUpTap: () => _scrollPage(up: true),
                            onScrollDownTap: () => _scrollPage(up: false),
                            onScrollToCurrentTap: _scrollToCurrentLesson,
                            isAtStart: offset <= 0,
                            isAtEnd: maxExtent > 0 ? offset >= (maxExtent - 10) : false,
                            isAtCurrent: false,
                            homeProvider: Provider.of<HomeProvider>(context, listen: false),
                            floatingAnimation: _floatingAnimation,
                          ),
                        ),
                      );
                    },
                  ),
                ),

                Consumer<HomeProvider>(
                  builder: (context, homeProvider, child) {
                    if (homeProvider.isLoading && homeProvider.lessons.isEmpty) {
                      return SliverFillRemaining(
                        child: LoadingState(isDarkMode: _isDarkMode),
                      );
                    }
                    if (homeProvider.hasError) {
                      return SliverFillRemaining(
                        child: ErrorState(
                          isDarkMode: _isDarkMode,
                          error: homeProvider.error,
                          onRetry: () {
                            homeProvider.refresh();
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
                      isLessonUnlocked: (lesson) => homeProvider.isLessonUnlocked(lesson),
                      floatingAnimation: _floatingAnimation,
                      showLessonDetails: (lesson) => _showLessonDetails(context, lesson, homeProvider),
                    );
                  },
                ),
                SliverToBoxAdapter(child: SizedBox(height: 200.h)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showLessonDetails(BuildContext context, LessonEntity lesson, HomeProvider homeProvider) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.8,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20.r),
            topRight: Radius.circular(20.r),
          ),
        ),
        child: Column(
          children: [
            // Handle
            Container(
              margin: EdgeInsets.only(top: 12.h),
              width: 40.w,
              height: 4.h,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.outline.withOpacity(0.3),
                borderRadius: BorderRadius.circular(2.r),
              ),
            ),

            // Content
            Expanded(
              child: Padding(
                padding: EdgeInsets.all(20.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      lesson.title,
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      lesson.description,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                      ),
                    ),
                    SizedBox(height: 24.h),

                    // Lesson info
                    Row(
                      children: [
                        Icon(Icons.access_time, size: 16.r),
                        SizedBox(width: 8.w),
                        Text('${lesson.duration} دقيقة'),
                        SizedBox(width: 24.w),
                        Icon(Icons.star, size: 16.r),
                        SizedBox(width: 8.w),
                        Text('${lesson.xpReward} نقطة'),
                      ],
                    ),

                    SizedBox(height: 32.h),

                    // Start button
                    SizedBox(
                      width: double.infinity,
                      height: 56.h,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                          // Navigate to lesson details screen
                          Navigator.pushNamed(
                            context,
                            '/lesson-details',
                            arguments: lesson.id,
                          );
                        },
                        child: Text(
                          lesson.isCompleted ? 'مراجعة الدرس' : 'بدء الدرس',
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _scrollPage({required bool up}) {
    if (!_scrollController.hasClients) return;
    final scrollAmount = 250.0 * 2; // Roughly two lessons per page
    final newOffset = (_scrollController.offset + (up ? -scrollAmount : scrollAmount))
        .clamp(0.0, _scrollController.position.maxScrollExtent);
    _scrollController.animateTo(
      newOffset,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
    );
  }

  void _scrollToCurrentLesson() {
    if (!_scrollController.hasClients) return;
    // Scroll to the first incomplete lesson
    final lessons = Provider.of<HomeProvider>(context, listen: false).lessons;
    int firstIncomplete = 0;
    for (int i = 0; i < lessons.length; i++) {
      if (!lessons[i].isCompleted) {
        firstIncomplete = i;
        break;
      }
    }
    final offset = (firstIncomplete * 250.0).clamp(0.0, _scrollController.position.maxScrollExtent);
    _scrollController.animateTo(
      offset,
      duration: const Duration(milliseconds: 700),
      curve: Curves.easeInOut,
    );
  }
}