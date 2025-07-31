// lib/features/quiz/presentation/widgets/multiple_choice_question_widget.dart
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:grad_project/features/quiz/domain/entities/question_entity.dart';
import 'package:just_audio/just_audio.dart';

class MultipleChoiceQuestionWidget extends StatefulWidget {
  final QuestionEntity question;
  final String? selectedOption;
  final ValueChanged<String> onOptionSelected;
  final bool showFeedback; // <--- CHANGED from isAttempted

  const MultipleChoiceQuestionWidget({
    Key? key,
    required this.question,
    this.selectedOption,
    required this.onOptionSelected,
    required this.showFeedback, // <--- CHANGED
  }) : super(key: key);

  @override
  State<MultipleChoiceQuestionWidget> createState() => _MultipleChoiceQuestionWidgetState();
}

class _MultipleChoiceQuestionWidgetState extends State<MultipleChoiceQuestionWidget> {
  AudioPlayer? _audioPlayer;

  @override
  void initState() {
    super.initState();
    if (widget.question.audioUrl != null) {
      _audioPlayer = AudioPlayer();
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
        ...widget.question.options.map((option) {
          bool isSelected = option == widget.selectedOption;
          Color? backgroundColor;
          Color? textColor = Colors.black87;
          Color borderColor = Colors.grey.shade300;

          if (widget.showFeedback) { // Use showFeedback
            // If feedback is shown, highlight correct/wrong answers
            if (option == widget.question.correctAnswer) {
              backgroundColor = Colors.green.shade100;
              textColor = Colors.green.shade900;
              borderColor = Colors.green.shade400;
            } else if (isSelected) {
              backgroundColor = Colors.red.shade100;
              textColor = Colors.red.shade900;
              borderColor = Colors.red.shade400;
            }
          } else if (isSelected) {
            // Only highlight selected if no feedback is shown yet
            backgroundColor = Colors.blue.shade100;
            borderColor = Colors.blue;
          }


          return GestureDetector(
            onTap: widget.showFeedback ? null : () => widget.onOptionSelected(option), // Disable tapping if feedback is shown
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 16.w),
              margin: EdgeInsets.only(bottom: 10.h),
              decoration: BoxDecoration(
                color: backgroundColor ?? Colors.grey.shade100, // Default to light grey
                borderRadius: BorderRadius.circular(8.r),
                border: Border.all(
                  color: borderColor,
                  width: 1.5,
                ),
              ),
              child: Text(
                option,
                style: TextStyle(fontSize: 16.sp, color: textColor),
              ),
            ),
          );
        }).toList(),
        if (widget.showFeedback && widget.selectedOption != widget.question.correctAnswer && widget.question.explanation != null && widget.question.explanation!.isNotEmpty)
          Padding(
            padding: EdgeInsets.only(top: 15.h),
            child: Text(
              'Explanation: ${widget.question.explanation!}',
              style: TextStyle(fontSize: 14.sp, color: Colors.grey[700]),
            ),
          ),
      ],
    );
  }
}