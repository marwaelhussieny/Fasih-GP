// lib/features/wordle/presentation/widgets/wordle_widgets.dart

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../domain/entities/wordle_entity.dart';

class WordleHeader extends StatelessWidget {
  final WordleEntity wordle;
  final bool isDailyWordle;
  final VoidCallback onBackPressed;
  final VoidCallback onHintPressed;

  const WordleHeader({
    Key? key,
    required this.wordle,
    required this.isDailyWordle,
    required this.onBackPressed,
    required this.onHintPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(20.w),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              GestureDetector(
                onTap: onBackPressed,
                child: Container(
                  padding: EdgeInsets.all(12.r),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Icon(
                    Icons.arrow_back_ios_rounded,
                    color: Colors.white,
                    size: 20.r,
                  ),
                ),
              ),
              Column(
                children: [
                  Text(
                    isDailyWordle ? 'ووردل اليوم' : 'ووردل عشوائي',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFFFFD700), Color(0xFFFFE082)],
                      ),
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: Text(
                      '${wordle.currentAttempt}/${wordle.maxAttempts}',
                      style: TextStyle(
                        color: const Color(0xFF1A0F3A),
                        fontSize: 14.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              GestureDetector(
                onTap: onHintPressed,
                child: Container(
                  padding: EdgeInsets.all(12.r),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFFFFD700), Color(0xFFFFE082)],
                    ),
                    borderRadius: BorderRadius.circular(12.r),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFFFD700).withOpacity(0.3),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.lightbulb_rounded,
                    color: const Color(0xFF1A0F3A),
                    size: 20.r,
                  ),
                ),
              ),
            ],
          ),
          if (wordle.isCompleted) ...[
            SizedBox(height: 20.h),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: wordle.isWon
                      ? [Colors.green, Colors.green.shade600]
                      : [Colors.red, Colors.red.shade600],
                ),
                borderRadius: BorderRadius.circular(20.r),
                boxShadow: [
                  BoxShadow(
                    color: (wordle.isWon ? Colors.green : Colors.red).withOpacity(0.3),
                    blurRadius: 15,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    wordle.isWon ? Icons.celebration_rounded : Icons.sentiment_dissatisfied_rounded,
                    color: Colors.white,
                    size: 20.r,
                  ),
                  SizedBox(width: 8.w),
                  Text(
                    wordle.isWon ? 'أحسنت! لقد فزت!' : 'لم تتمكن من الحل',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class WordleGrid extends StatelessWidget {
  final WordleEntity wordle;
  final String currentGuess;
  final List<List<WordleLetterResult>> guessResults;

  const WordleGrid({
    Key? key,
    required this.wordle,
    required this.currentGuess,
    required this.guessResults,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: Column(
        children: List.generate(
          wordle.maxAttempts,
              (rowIndex) => Padding(
            padding: EdgeInsets.only(bottom: 8.h),
            child: _buildGuessRow(rowIndex),
          ),
        ),
      ),
    );
  }

  Widget _buildGuessRow(int rowIndex) {
    List<String> letters;
    List<LetterStatus> letterStatuses;

    if (rowIndex < guessResults.length) {
      // Completed guess with results
      letters = guessResults[rowIndex].map((r) => r.letter).toList();
      letterStatuses = guessResults[rowIndex].map((r) => r.status).toList();
    } else if (rowIndex == wordle.currentAttempt && currentGuess.isNotEmpty) {
      // Current guess being typed
      letters = currentGuess.split('');
      while (letters.length < 5) letters.add('');
      letterStatuses = List.generate(5, (index) => LetterStatus.unknown);
    } else {
      // Empty row
      letters = List.generate(5, (index) => '');
      letterStatuses = List.generate(5, (index) => LetterStatus.unknown);
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        5,
            (colIndex) => Padding(
          padding: EdgeInsets.only(right: colIndex < 4 ? 8.w : 0),
          child: _buildLetterTile(
            letters[colIndex],
            letterStatuses[colIndex],
            rowIndex == wordle.currentAttempt && colIndex == currentGuess.length - 1,
          ),
        ),
      ),
    );
  }

  Widget _buildLetterTile(String letter, LetterStatus status, bool isActive) {
    Color backgroundColor;
    Color borderColor;
    Color textColor = Colors.white;

    switch (status) {
      case LetterStatus.correct:
        backgroundColor = Colors.green;
        borderColor = Colors.green;
        break;
      case LetterStatus.present:
        backgroundColor = Colors.orange;
        borderColor = Colors.orange;
        break;
      case LetterStatus.absent:
        backgroundColor = Colors.grey.shade600;
        borderColor = Colors.grey.shade600;
        break;
      case LetterStatus.unknown:
      default:
        if (letter.isNotEmpty) {
          backgroundColor = Colors.white.withOpacity(0.1);
          borderColor = Colors.white.withOpacity(0.3);
        } else {
          backgroundColor = Colors.transparent;
          borderColor = Colors.white.withOpacity(0.2);
        }
        break;
    }

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: 60.w,
      height: 60.w,
      decoration: BoxDecoration(
        color: backgroundColor,
        border: Border.all(
          color: isActive ? const Color(0xFFFFD700) : borderColor,
          width: isActive ? 3.w : 2.w,
        ),
        borderRadius: BorderRadius.circular(8.r),
        boxShadow: isActive
            ? [
          BoxShadow(
            color: const Color(0xFFFFD700).withOpacity(0.5),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ]
            : null,
      ),
      child: Center(
        child: Text(
          letter,
          style: TextStyle(
            color: textColor,
            fontSize: 24.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}

class WordleKeyboard extends StatelessWidget {
  final Function(String) onLetterTap;
  final VoidCallback onBackspace;
  final VoidCallback onSubmit;
  final LetterStatus Function(String) getLetterStatus;
  final bool canSubmit;
  final bool isSubmitting;

  const WordleKeyboard({
    Key? key,
    required this.onLetterTap,
    required this.onBackspace,
    required this.onSubmit,
    required this.getLetterStatus,
    required this.canSubmit,
    required this.isSubmitting,
  }) : super(key: key);

  static const List<List<String>> arabicKeyboard = [
    ['ض', 'ص', 'ث', 'ق', 'ف', 'غ', 'ع', 'ه', 'خ', 'ح', 'ج', 'د'],
    ['ش', 'س', 'ي', 'ب', 'ل', 'ا', 'ت', 'ن', 'م', 'ك', 'ط'],
    ['ئ', 'ء', 'ؤ', 'ر', 'لا', 'ى', 'ة', 'و', 'ز', 'ظ'],
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 8.w),
      child: Column(
        children: [
          ...arabicKeyboard.map((row) => _buildKeyboardRow(row)),
          SizedBox(height: 8.h),
          _buildActionRow(),
        ],
      ),
    );
  }

  Widget _buildKeyboardRow(List<String> letters) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: letters
            .map((letter) => Padding(
          padding: EdgeInsets.only(right: 4.w),
          child: _buildKeyTile(letter),
        ))
            .toList(),
      ),
    );
  }

  Widget _buildKeyTile(String letter) {
    final status = getLetterStatus(letter);
    Color backgroundColor;
    Color textColor = Colors.white;

    switch (status) {
      case LetterStatus.correct:
        backgroundColor = Colors.green;
        break;
      case LetterStatus.present:
        backgroundColor = Colors.orange;
        break;
      case LetterStatus.absent:
        backgroundColor = Colors.grey.shade600;
        break;
      case LetterStatus.unknown:
      default:
        backgroundColor = Colors.white.withOpacity(0.1);
        break;
    }

    return GestureDetector(
      onTap: () => onLetterTap(letter),
      child: Container(
        width: 28.w,
        height: 42.h,
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(6.r),
          border: Border.all(
            color: Colors.white.withOpacity(0.2),
            width: 1.w,
          ),
        ),
        child: Center(
          child: Text(
            letter,
            style: TextStyle(
              color: textColor,
              fontSize: 16.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActionRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        // Backspace button
        GestureDetector(
          onTap: onBackspace,
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
            decoration: BoxDecoration(
              color: Colors.red.withOpacity(0.8),
              borderRadius: BorderRadius.circular(8.r),
              border: Border.all(
                color: Colors.white.withOpacity(0.2),
                width: 1.w,
              ),
            ),
            child: Icon(
              Icons.backspace_rounded,
              color: Colors.white,
              size: 20.r,
            ),
          ),
        ),

        // Submit button
        GestureDetector(
          onTap: canSubmit ? onSubmit : null,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
            decoration: BoxDecoration(
              gradient: canSubmit
                  ? const LinearGradient(
                colors: [Color(0xFFFFD700), Color(0xFFFFE082)],
              )
                  : LinearGradient(
                colors: [Colors.grey.shade600, Colors.grey.shade500],
              ),
              borderRadius: BorderRadius.circular(8.r),
              boxShadow: canSubmit
                  ? [
                BoxShadow(
                  color: const Color(0xFFFFD700).withOpacity(0.3),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ]
                  : null,
            ),
            child: isSubmitting
                ? SizedBox(
              width: 16.w,
              height: 16.w,
              child: const CircularProgressIndicator(
                color: Color(0xFF1A0F3A),
                strokeWidth: 2,
              ),
            )
                : Text(
              'إرسال',
              style: TextStyle(
                color: canSubmit ? const Color(0xFF1A0F3A) : Colors.white,
                fontSize: 16.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class WordleGameOverDialog extends StatelessWidget {
  final WordleEntity wordle;
  final VoidCallback onPlayAgain;
  final VoidCallback onBackToMenu;

  const WordleGameOverDialog({
    Key? key,
    required this.wordle,
    required this.onPlayAgain,
    required this.onBackToMenu,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        padding: EdgeInsets.all(24.w),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: wordle.isWon
                ? [
              Colors.green.shade700,
              Colors.green.shade800,
              Colors.green.shade900,
            ]
                : [
              Colors.red.shade700,
              Colors.red.shade800,
              Colors.red.shade900,
            ],
          ),
          borderRadius: BorderRadius.circular(20.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 30,
              offset: const Offset(0, 15),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Icon and title
            Container(
              padding: EdgeInsets.all(20.r),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(
                wordle.isWon ? Icons.celebration_rounded : Icons.sentiment_dissatisfied_rounded,
                color: Colors.white,
                size: 60.r,
              ),
            ),
            SizedBox(height: 20.h),
            Text(
              wordle.isWon ? 'تهانينا!' : 'انتهت اللعبة',
              style: TextStyle(
                color: Colors.white,
                fontSize: 28.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 12.h),
            Text(
              wordle.isWon
                  ? 'لقد حللت الكلمة في ${wordle.currentAttempt} محاولات!'
                  : 'الكلمة كانت: ${wordle.word}',
              style: TextStyle(
                color: Colors.white.withOpacity(0.9),
                fontSize: 16.sp,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 30.h),

            // Stats
            Container(
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildStatItem(
                    'المحاولات',
                    '${wordle.currentAttempt}/${wordle.maxAttempts}',
                    Icons.quiz_rounded,
                  ),
                  Container(
                    width: 1.w,
                    height: 40.h,
                    color: Colors.white.withOpacity(0.3),
                  ),
                  _buildStatItem(
                    'النتيجة',
                    wordle.isWon ? 'فوز' : 'خسارة',
                    wordle.isWon ? Icons.check_circle_rounded : Icons.cancel_rounded,
                  ),
                ],
              ),
            ),
            SizedBox(height: 30.h),

            // Action buttons
            Row(
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: TextButton(
                      onPressed: onBackToMenu,
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 16.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                      ),
                      child: Text(
                        'القائمة الرئيسية',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFFFFD700), Color(0xFFFFE082)],
                      ),
                      borderRadius: BorderRadius.circular(12.r),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFFFD700).withOpacity(0.3),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: TextButton(
                      onPressed: onPlayAgain,
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 16.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                      ),
                      child: Text(
                        'العب مرة أخرى',
                        style: TextStyle(
                          color: const Color(0xFF1A0F3A),
                          fontSize: 16.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(
          icon,
          color: Colors.white,
          size: 24.r,
        ),
        SizedBox(height: 8.h),
        Text(
          value,
          style: TextStyle(
            color: Colors.white,
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 4.h),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withOpacity(0.8),
            fontSize: 12.sp,
          ),
        ),
      ],
    );
  }
}