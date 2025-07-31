// lib/features/quiz/presentation/widgets/fill_in_the_blank_question_widget.dart
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:grad_project/features/quiz/domain/entities/question_entity.dart';
import 'package:just_audio/just_audio.dart';

class FillInTheBlankQuestionWidget extends StatefulWidget {
  final QuestionEntity question;
  final List<String> selectedWords; // <--- CHANGED: List of selected words
  final ValueChanged<List<String>> onWordsSelected; // <--- CHANGED: Callback for list
  final bool showFeedback; // <--- CHANGED from isAttempted

  const FillInTheBlankQuestionWidget({
    Key? key,
    required this.question,
    required this.selectedWords, // Now a required list
    required this.onWordsSelected,
    required this.showFeedback, // <--- CHANGED
  }) : super(key: key);

  @override
  State<FillInTheBlankQuestionWidget> createState() => _FillInTheBlankQuestionWidgetState();
}

class _FillInTheBlankQuestionWidgetState extends State<FillInTheBlankQuestionWidget> {
  late List<String> _currentSelectedWords; // Mutable list for current selections
  late List<String> _availableOptions; // Options not yet selected
  AudioPlayer? _audioPlayer;

  @override
  void initState() {
    super.initState();
    _currentSelectedWords = List.from(widget.selectedWords);
    _availableOptions = List.from(widget.question.options);
    // Remove already selected words from available options to prevent duplicates in the bank
    for (var word in _currentSelectedWords) {
      _availableOptions.remove(word);
    }
    if (widget.question.audioUrl != null) {
      _audioPlayer = AudioPlayer();
    }
  }

  @override
  void didUpdateWidget(covariant FillInTheBlankQuestionWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selectedWords != oldWidget.selectedWords || widget.question != oldWidget.question) {
      // Re-initialize if question or selected words change (e.g., navigating back/forth)
      _currentSelectedWords = List.from(widget.selectedWords);
      _availableOptions = List.from(widget.question.options);
      for (var word in _currentSelectedWords) {
        _availableOptions.remove(word);
      }
    }
  }

  Future<void> _playAudio() async {
    if (_audioPlayer != null && widget.question.audioUrl != null) {
      try {
        await _audioPlayer!.setUrl(widget.question.audioUrl!);
        _audioPlayer!.play();
      } catch (e) {
        if (kDebugMode) {
          print("Error playing audio: $e");
        }
      }
    }
  }

  @override
  void dispose() {
    _audioPlayer?.dispose();
    super.dispose();
  }

  void _addWordToAnswer(String word) {
    if (widget.showFeedback) return; // Cannot modify if feedback is shown
    setState(() {
      _currentSelectedWords.add(word);
      _availableOptions.remove(word);
      widget.onWordsSelected(_currentSelectedWords);
    });
  }

  void _removeWordFromAnswer(String word) {
    if (widget.showFeedback) return; // Cannot modify if feedback is shown
    setState(() {
      _currentSelectedWords.remove(word);
      _availableOptions.insert(0, word); // Add back to available options, perhaps sorted later
      widget.onWordsSelected(_currentSelectedWords);
    });
  }

  // Helper to determine if a selected word is correct at its position
  bool _isWordCorrectAtPosition(int index, String word) {
    final correctAnswerParts = widget.question.correctAnswer.trim().toLowerCase().split(' ');
    if (index < correctAnswerParts.length && word.trim().toLowerCase() == correctAnswerParts[index]) {
      return true;
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Text(
                widget.question.text,
                style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w500),
              ),
            ),
            if (widget.question.audioUrl != null)
              IconButton(
                icon: const Icon(Icons.volume_up),
                onPressed: _playAudio,
              ),
          ],
        ),
        SizedBox(height: 20.h),
        if (widget.question.imageUrl != null)
          Padding(
            padding: EdgeInsets.only(bottom: 15.h),
            child: Image.network(
              widget.question.imageUrl!,
              height: 150.h,
              width: double.infinity,
              fit: BoxFit.contain,
            ),
          ),
        SizedBox(height: 20.h),
        // Display selected words (the blanks)
        Wrap(
          spacing: 8.w,
          runSpacing: 8.h,
          children: _currentSelectedWords.asMap().entries.map((entry) {
            final index = entry.key;
            final word = entry.value;
            bool isCorrectFeedback = widget.showFeedback && _isWordCorrectAtPosition(index, word);
            bool isWrongFeedback = widget.showFeedback && !isCorrectFeedback;

            return GestureDetector(
              onTap: () => _removeWordFromAnswer(word),
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 8.h, horizontal: 12.w),
                decoration: BoxDecoration(
                  color: isCorrectFeedback
                      ? Colors.green.shade100
                      : (isWrongFeedback ? Colors.red.shade100 : Colors.blue.shade100),
                  borderRadius: BorderRadius.circular(8.r),
                  border: Border.all(
                    color: isCorrectFeedback
                        ? Colors.green.shade400
                        : (isWrongFeedback ? Colors.red.shade400 : Colors.blue),
                    width: 1.5,
                  ),
                ),
                child: Text(
                  word,
                  style: TextStyle(
                    fontSize: 16.sp,
                    color: isCorrectFeedback
                        ? Colors.green.shade900
                        : (isWrongFeedback ? Colors.red.shade900 : Colors.blue.shade900),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
        SizedBox(height: 20.h),
        Text(
          'Available Words:',
          style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 10.h),
        // Display available options (word bank)
        Wrap(
          spacing: 8.w,
          runSpacing: 8.h,
          children: _availableOptions.map((option) {
            return GestureDetector(
              onTap: () => _addWordToAnswer(option),
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 8.h, horizontal: 12.w),
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(8.r),
                  border: Border.all(color: Colors.grey.shade400),
                ),
                child: Text(
                  option,
                  style: TextStyle(fontSize: 16.sp, color: Colors.black87),
                ),
              ),
            );
          }).toList(),
        ),
        if (widget.showFeedback && _currentSelectedWords.join(' ').trim().toLowerCase() != widget.question.correctAnswer.trim().toLowerCase())
          Padding(
            padding: EdgeInsets.only(top: 15.h),
            child: Text(
              'Correct Answer: ${widget.question.correctAnswer}',
              style: TextStyle(
                fontSize: 14.sp,
                color: Colors.blue.shade800,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        if (widget.showFeedback && widget.question.explanation != null && widget.question.explanation!.isNotEmpty)
          Padding(
            padding: EdgeInsets.only(top: 8.h),
            child: Text(
              'Explanation: ${widget.question.explanation!}',
              style: TextStyle(fontSize: 13.sp, color: Colors.grey[700]),
            ),
          ),
      ],
    );
  }
}