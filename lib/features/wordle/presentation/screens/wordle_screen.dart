// lib/features/wordle/presentation/screens/wordle_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import '../providers/wordle_provider.dart';
// import '../widgets/wordle_grid.dart';
// import '../widgets/wordle_keyboard.dart';
// import '../widgets/wordle_header.dart';
// import '../widgets/wordle_game_over_dialog.dart';
import '../widgets/wordle_widgets.dart';
// import '../widgets/wordle_header';
import '../../domain/entities/wordle_entity.dart';

class WordleScreen extends StatefulWidget {
  final bool isDailyWordle;

  const WordleScreen({
    Key? key,
    this.isDailyWordle = true,
  }) : super(key: key);

  @override
  State<WordleScreen> createState() => _WordleScreenState();
}

class _WordleScreenState extends State<WordleScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();

    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _slideController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));

    // Start animations
    _fadeController.forward();
    _slideController.forward();

    // Load wordle
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<WordleProvider>(context, listen: false);
      if (widget.isDailyWordle) {
        provider.loadDailyWordle();
      } else {
        provider.loadRandomWordle();
      }
    });
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              const Color(0xFF2E1B69),
              const Color(0xFF1A0F3A),
              const Color(0xFF0D0625),
            ],
          ),
        ),
        child: SafeArea(
          child: Consumer<WordleProvider>(
            builder: (context, provider, child) {
              // Show game over dialog when game is completed
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (provider.isGameCompleted && provider.currentWordle != null) {
                  _showGameOverDialog(context, provider);
                }
              });

              if (provider.isLoading) {
                return _buildLoadingState();
              }

              if (provider.error != null) {
                return _buildErrorState(provider);
              }

              if (provider.currentWordle == null) {
                return _buildEmptyState();
              }

              return FadeTransition(
                opacity: _fadeAnimation,
                child: SlideTransition(
                  position: _slideAnimation,
                  child: Column(
                    children: [
                      // Header
                      WordleHeader(
                        wordle: provider.currentWordle!,
                        isDailyWordle: widget.isDailyWordle,
                        onBackPressed: () => Navigator.of(context).pop(),
                        onHintPressed: () => _showHintDialog(context, provider.currentWordle!),
                      ),

                      SizedBox(height: 20.h),

                      // Game Grid
                      Expanded(
                        flex: 3,
                        child: WordleGrid(
                          wordle: provider.currentWordle!,
                          currentGuess: provider.currentGuess,
                          guessResults: provider.guessResults,
                        ),
                      ),

                      SizedBox(height: 20.h),

                      // Keyboard
                      Expanded(
                        flex: 2,
                        child: WordleKeyboard(
                          onLetterTap: provider.addLetter,
                          onBackspace: provider.removeLetter,
                          onSubmit: provider.submitGuess,
                          getLetterStatus: provider.getLetterStatus,
                          canSubmit: provider.canSubmitGuess,
                          isSubmitting: provider.isSubmittingGuess,
                        ),
                      ),

                      SizedBox(height: 20.h),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80.r,
            height: 80.r,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFFFD700), Color(0xFFFFE082)],
              ),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFFFD700).withOpacity(0.4),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Center(
              child: CircularProgressIndicator(
                color: const Color(0xFF1A0F3A),
                strokeWidth: 4.w,
              ),
            ),
          ),
          SizedBox(height: 30.h),
          Text(
            'جاري تحميل ووردل...',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(WordleProvider provider) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(32.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(30.r),
              decoration: BoxDecoration(
                color: Colors.red.shade100,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.red.withOpacity(0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Icon(
                Icons.error_outline_rounded,
                size: 60.r,
                color: Colors.red.shade600,
              ),
            ),
            SizedBox(height: 30.h),
            Text(
              'خطأ في تحميل اللعبة',
              style: TextStyle(
                color: Colors.white,
                fontSize: 22.sp,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 16.h),
            Text(
              provider.error ?? 'حدث خطأ غير متوقع',
              style: TextStyle(
                color: Colors.white.withOpacity(0.8),
                fontSize: 16.sp,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 30.h),
            Container(
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFFFD700), Color(0xFFFFE082)],
                ),
                borderRadius: BorderRadius.circular(25.r),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFFFD700).withOpacity(0.4),
                    blurRadius: 15,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: ElevatedButton.icon(
                onPressed: () {
                  if (widget.isDailyWordle) {
                    provider.loadDailyWordle();
                  } else {
                    provider.loadRandomWordle();
                  }
                },
                icon: Icon(Icons.refresh_rounded,
                    color: const Color(0xFF1A0F3A), size: 24.r),
                label: Text(
                  'إعادة المحاولة',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF1A0F3A),
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  padding: EdgeInsets.symmetric(horizontal: 30.w, vertical: 16.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25.r),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.all(40.r),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Colors.white, Color(0xFFF5F5F5)],
              ),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 30,
                  offset: const Offset(0, 15),
                ),
              ],
            ),
            child: Icon(
              Icons.quiz_rounded,
              size: 80.r,
              color: const Color(0xFF2E1B69),
            ),
          ),
          SizedBox(height: 40.h),
          Text(
            'لا توجد لعبة متاحة',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 16.h),
          Text(
            'يرجى المحاولة مرة أخرى لاحقاً',
            style: TextStyle(
              color: Colors.white.withOpacity(0.8),
              fontSize: 16.sp,
            ),
          ),
        ],
      ),
    );
  }

  void _showGameOverDialog(BuildContext context, WordleProvider provider) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => WordleGameOverDialog(
        wordle: provider.currentWordle!,
        onPlayAgain: () {
          Navigator.of(context).pop();
          if (widget.isDailyWordle) {
            provider.loadDailyWordle();
          } else {
            provider.loadRandomWordle();
          }
        },
        onBackToMenu: () {
          Navigator.of(context).pop();
          Navigator.of(context).pop();
        },
      ),
    );
  }

  void _showHintDialog(BuildContext context, WordleEntity wordle) {
    showDialog(
      context: context,
      builder: (context) =>
          AlertDialog(
            backgroundColor: const Color(0xFF2E1B69),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20.r),
            ),
            title: Row(
              children: [
                Icon(
                  Icons.lightbulb_rounded,
                  color: const Color(0xFFFFD700),
                  size: 24.r,
                ),
                SizedBox(width: 12.w),
                Text(
                  'تلميح',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            content: Text(
              wordle.hint,
              style: TextStyle(
                color: Colors.white.withOpacity(0.9),
                fontSize: 16.sp,
                height: 1.5,
              ),
            ),
            actions: [
              Container(
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFFFD700), Color(0xFFFFE082)],
                  ),
                  borderRadius: BorderRadius.circular(20.r),
                ),
                child: TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.symmetric(
                        horizontal: 24.w, vertical: 12.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20.r),
                    ),
                  ),
                  child: Text(
                    'حسناً',
                    style: TextStyle(
                      color: const Color(0xFF1A0F3A),
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
    );
  }}