// lib/features/home/presentation/screens/level_completion_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:grad_project/features/home/presentation/providers/home_provider.dart';
import 'package:grad_project/features/home/domain/entities/level_entity.dart';
import 'dart:math' as math;

class LevelCompletionScreen extends StatefulWidget {
  final String levelId;
  final int xpEarned;
  final List<String> achievements;

  const LevelCompletionScreen({
    Key? key,
    required this.levelId,
    this.xpEarned = 500,
    this.achievements = const [],
  }) : super(key: key);

  @override
  State<LevelCompletionScreen> createState() => _LevelCompletionScreenState();
}

class _LevelCompletionScreenState extends State<LevelCompletionScreen>
    with TickerProviderStateMixin {
  late AnimationController _mainController;
  late AnimationController _bounceController;
  late AnimationController _floatingController;
  late AnimationController _sparkleController;
  late AnimationController _confettiController;

  late Animation<double> _slideAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<double> _bounceAnimation;
  late Animation<double> _floatingAnimation;
  late Animation<double> _sparkleAnimation;
  late Animation<double> _confettiAnimation;

  LevelEntity? _completedLevel;
  bool _showNextLevel = false;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _loadLevelData();
    _startCelebration();
  }

  void _initializeAnimations() {
    _mainController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _bounceController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _floatingController = AnimationController(
      duration: const Duration(milliseconds: 3000),
      vsync: this,
    )..repeat();

    _sparkleController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat();

    _confettiController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );

    _slideAnimation = Tween<double>(
      begin: 1.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _mainController,
      curve: const Interval(0.0, 0.6, curve: Curves.elasticOut),
    ));

    _scaleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _mainController,
      curve: const Interval(0.2, 0.8, curve: Curves.elasticOut),
    ));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _mainController,
      curve: const Interval(0.4, 1.0, curve: Curves.easeIn),
    ));

    _bounceAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _bounceController,
      curve: Curves.bounceOut,
    ));

    _floatingAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _floatingController,
      curve: Curves.easeInOut,
    ));

    _sparkleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _sparkleController,
      curve: Curves.easeInOut,
    ));

    _confettiAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _confettiController,
      curve: Curves.easeOut,
    ));
  }

  void _loadLevelData() {
    final homeProvider = Provider.of<HomeProvider>(context, listen: false);
    try {
      _completedLevel = homeProvider.levels.firstWhere(
            (level) => level.id == widget.levelId,
      );

      // Check if next level is available
      final currentIndex = homeProvider.levels.indexOf(_completedLevel!);
      _showNextLevel = currentIndex < homeProvider.levels.length - 1;
    } catch (e) {
      print('Error loading level data: $e');
      // Create a mock level for display
      _completedLevel = LevelEntity(
        id: widget.levelId,
        title: 'مستوى مكتمل',
        description: 'تم إكمال المستوى بنجاح',
        order: 1,
        requiredXP: 0,
        isCompleted: true,
        isUnlocked: true,
      );
    }
  }

  void _startCelebration() {
    _mainController.forward();
    _bounceController.forward();
    _confettiController.forward();

    // Delay before showing next level option
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        _bounceController.repeat(reverse: true);
      }
    });
  }

  @override
  void dispose() {
    _mainController.dispose();
    _bounceController.dispose();
    _floatingController.dispose();
    _sparkleController.dispose();
    _confettiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: Stack(
        children: [
          // Gradient background
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  colorScheme.primary,
                  colorScheme.tertiary,
                  colorScheme.primary.withOpacity(0.8),
                ],
              ),
            ),
          ),

          // Floating particles
          ...List.generate(15, (index) => _buildFloatingParticle(index)),

          // Sparkle effects
          ...List.generate(20, (index) => _buildSparkle(index)),

          // Confetti effect
          _buildConfetti(),

          // Main content
          SafeArea(
            child: Center(
              child: AnimatedBuilder(
                animation: _mainController,
                builder: (context, child) {
                  return Transform.translate(
                    offset: Offset(0, MediaQuery.of(context).size.height * _slideAnimation.value),
                    child: Transform.scale(
                      scale: _scaleAnimation.value,
                      child: Opacity(
                        opacity: _fadeAnimation.value,
                        child: _buildMainContent(),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFloatingParticle(int index) {
    return AnimatedBuilder(
      animation: _floatingAnimation,
      builder: (context, child) {
        final screenWidth = MediaQuery.of(context).size.width;
        final screenHeight = MediaQuery.of(context).size.height;

        final offset = (index * 0.2) % 1.0;
        final animValue = (_floatingAnimation.value + offset) % 1.0;

        final x = screenWidth * (0.1 + (index % 5) * 0.2) +
            50 * math.sin(animValue * math.pi * 2 + index);
        final y = screenHeight * (0.1 + (index % 4) * 0.25) +
            30 * math.cos(animValue * math.pi * 1.5 + index);

        final size = (10 + index % 8).r;
        final opacity = 0.3 + 0.5 * ((math.sin(animValue * math.pi * 2) + 1) / 2);

        return Positioned(
          left: x,
          top: y,
          child: Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              gradient: RadialGradient(
                colors: [
                  Colors.white.withOpacity(opacity),
                  Colors.white.withOpacity(opacity * 0.3),
                ],
              ),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.white.withOpacity(0.5),
                  blurRadius: 8,
                  spreadRadius: 2,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSparkle(int index) {
    return AnimatedBuilder(
      animation: _sparkleAnimation,
      builder: (context, child) {
        final screenWidth = MediaQuery.of(context).size.width;
        final screenHeight = MediaQuery.of(context).size.height;

        final random = math.Random(index + 42); // Fixed seed for consistency
        final x = screenWidth * random.nextDouble();
        final y = screenHeight * random.nextDouble();

        final sparklePhase = (_sparkleAnimation.value + index * 0.1) % 1.0;
        final opacity = math.sin(sparklePhase * math.pi).clamp(0.0, 1.0);
        final scale = 0.5 + 0.5 * opacity;

        return Positioned(
          left: x,
          top: y,
          child: Transform.scale(
            scale: scale,
            child: Icon(
              Icons.star,
              color: Colors.yellow.withOpacity(opacity),
              size: (8 + index % 6).r,
            ),
          ),
        );
      },
    );
  }

  Widget _buildConfetti() {
    return AnimatedBuilder(
      animation: _confettiAnimation,
      builder: (context, child) {
        if (_confettiAnimation.value == 0) return const SizedBox.shrink();

        return Stack(
          children: List.generate(30, (index) {
            final random = math.Random(index + 100);
            final screenWidth = MediaQuery.of(context).size.width;
            final fallProgress = _confettiAnimation.value;

            final x = screenWidth * random.nextDouble();
            final y = -50 + (MediaQuery.of(context).size.height + 100) * fallProgress;
            final rotation = fallProgress * math.pi * 4 + index;

            final colors = [Colors.red, Colors.blue, Colors.green, Colors.yellow, Colors.purple];
            final color = colors[index % colors.length];

            return Positioned(
              left: x,
              top: y,
              child: Transform.rotate(
                angle: rotation,
                child: Container(
                  width: 8.r,
                  height: 8.r,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            );
          }),
        );
      },
    );
  }

  Widget _buildMainContent() {
    return Padding(
      padding: EdgeInsets.all(32.w),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Trophy icon
          _buildTrophyIcon(),

          SizedBox(height: 32.h),

          // Congratulations text
          _buildCongratulationsText(),

          SizedBox(height: 24.h),

          // Level info
          _buildLevelInfo(),

          SizedBox(height: 32.h),

          // Rewards section
          _buildRewardsSection(),

          SizedBox(height: 24.h),

          // Achievements
          if (widget.achievements.isNotEmpty) ...[
            _buildAchievementsSection(),
            SizedBox(height: 32.h),
          ],

          // Action buttons
          _buildActionButtons(),
        ],
      ),
    );
  }

  Widget _buildTrophyIcon() {
    return AnimatedBuilder(
      animation: Listenable.merge([_bounceAnimation, _floatingAnimation]),
      builder: (context, child) {
        final bounce = _bounceAnimation.value;
        final float = 10 * math.sin(_floatingAnimation.value * math.pi * 2);

        return Transform.translate(
          offset: Offset(0, float),
          child: Transform.scale(
            scale: 0.8 + (bounce * 0.4),
            child: Container(
              padding: EdgeInsets.all(32.r),
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  colors: [
                    Colors.amber,
                    Colors.amber.shade600,
                    Colors.orange.shade700,
                  ],
                  stops: const [0.0, 0.7, 1.0],
                ),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.amber.withOpacity(0.6),
                    blurRadius: 30,
                    spreadRadius: 10,
                  ),
                  BoxShadow(
                    color: Colors.orange.withOpacity(0.4),
                    blurRadius: 60,
                    spreadRadius: 20,
                  ),
                ],
              ),
              child: Icon(
                Icons.emoji_events,
                color: Colors.white,
                size: 80.r,
                shadows: [
                  Shadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 8,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildCongratulationsText() {
    return Column(
      children: [
        Text(
          'مبروك! 🎉',
          style: Theme.of(context).textTheme.headlineLarge?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            shadows: [
              Shadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 8,
              ),
            ],
          ),
          textAlign: TextAlign.center,
        ),

        SizedBox(height: 12.h),

        Text(
          'لقد أكملت المستوى بنجاح!',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            color: Colors.white.withOpacity(0.9),
            shadows: [
              Shadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 4,
              ),
            ],
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildLevelInfo() {
    if (_completedLevel == null) return const SizedBox.shrink();

    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(
          color: Colors.white.withOpacity(0.3),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            _completedLevel!.title,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),

          SizedBox(height: 8.h),

          Text(
            _completedLevel!.description,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: Colors.white.withOpacity(0.9),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildRewardsSection() {
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(
          color: Colors.white.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Text(
            'المكافآت',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),

          SizedBox(height: 16.h),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildRewardItem(
                icon: Icons.star,
                label: 'نقاط الخبرة',
                value: '+${widget.xpEarned}',
                color: Colors.amber,
              ),
              _buildRewardItem(
                icon: Icons.school,
                label: 'مستوى جديد',
                value: _showNextLevel ? 'مفتوح' : 'مكتمل',
                color: Colors.green,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRewardItem({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return AnimatedBuilder(
      animation: _floatingAnimation,
      builder: (context, child) {
        final float = 5 * math.sin(_floatingAnimation.value * math.pi * 2);

        return Transform.translate(
          offset: Offset(0, float),
          child: Column(
            children: [
              Container(
                padding: EdgeInsets.all(16.r),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.2),
                  shape: BoxShape.circle,
                  border: Border.all(color: color.withOpacity(0.5), width: 2),
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 32.r,
                ),
              ),

              SizedBox(height: 8.h),

              Text(
                label,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.8),
                  fontSize: 12.sp,
                ),
                textAlign: TextAlign.center,
              ),

              Text(
                value,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14.sp,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildAchievementsSection() {
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(
          color: Colors.white.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Text(
            'الإنجازات الجديدة',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),

          SizedBox(height: 12.h),

          ...widget.achievements.map((achievement) => Container(
            margin: EdgeInsets.only(bottom: 8.h),
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
            decoration: BoxDecoration(
              color: Colors.amber.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(color: Colors.amber.withOpacity(0.5)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.badge,
                  color: Colors.amber,
                  size: 16.r,
                ),
                SizedBox(width: 8.w),
                Text(
                  achievement,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12.sp,
                  ),
                ),
              ],
            ),
          )).toList(),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        // Continue to next level button
        if (_showNextLevel)
          Container(
            width: double.infinity,
            height: 56.h,
            child: AnimatedBuilder(
              animation: _bounceAnimation,
              builder: (context, child) {
                return Transform.scale(
                  scale: 0.95 + (_bounceAnimation.value * 0.05),
                  child: ElevatedButton(
                    onPressed: _goToNextLevel,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Theme.of(context).colorScheme.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(28.r),
                      ),
                      elevation: 8,
                      shadowColor: Colors.black.withOpacity(0.3),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.arrow_forward,
                          size: 24.r,
                        ),
                        SizedBox(width: 12.w),
                        Text(
                          'المستوى التالي',
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

        SizedBox(height: 16.h),

        // Back to map button
        Container(
          width: double.infinity,
          height: 56.h,
          child: ElevatedButton(
            onPressed: _backToMap,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white.withOpacity(0.2),
              foregroundColor: Colors.white,
              side: BorderSide(color: Colors.white.withOpacity(0.5), width: 2),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(28.r),
              ),
              elevation: 0,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.map,
                  size: 24.r,
                ),
                SizedBox(width: 12.w),
                Text(
                  'العودة للخريطة',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void _goToNextLevel() {
    final homeProvider = Provider.of<HomeProvider>(context, listen: false);
    if (_completedLevel == null) {
      _backToMap();
      return;
    }

    final currentIndex = homeProvider.levels.indexOf(_completedLevel!);

    if (currentIndex >= 0 && currentIndex < homeProvider.levels.length - 1) {
      // Navigate to next level's first lesson
      final nextLevel = homeProvider.levels[currentIndex + 1];
      final nextLevelLessons = homeProvider.getLessonsForLevel(nextLevel.id);

      if (nextLevelLessons.isNotEmpty) {
        Navigator.of(context).pushReplacementNamed(
          '/lesson-details',
          arguments: nextLevelLessons.first.id,
        );
      } else {
        _backToMap();
      }
    } else {
      _backToMap();
    }
  }

  void _backToMap() {
    Navigator.of(context).popUntil((route) => route.isFirst);
  }
}