// lib/features/quiz/presentation/pages/quiz_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:grad_project/features/quiz/presentation/providers/quiz_provider.dart';
import 'package:grad_project/features/quiz/domain/entities/question_entity.dart';
import 'package:grad_project/core/navigation/app_routes.dart'; // Assuming AppRoutes

// Import necessary widgets for question types
import 'package:grad_project/features/quiz/presentation/widgets/multiple_choice_question_widget.dart';
import 'package:grad_project/features/quiz/presentation/widgets/fill_in_the_blank_question_widget.dart';

class QuizScreen extends StatelessWidget {
  final String quizId;

  const QuizScreen({Key? key, required this.quizId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return PopScope( // Use PopScope to handle back button
      canPop: false, // Prevent popping directly without confirmation
      onPopInvoked: (didPop) async {
        if (didPop) return; // If already popped, do nothing
        final shouldPop = await _showExitConfirmationDialog(context);
        if (shouldPop) {
          Provider.of<QuizProvider>(context, listen: false).resetQuizState();
          Navigator.pop(context);
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Consumer<QuizProvider>(
            builder: (context, quizProvider, child) {
              if (quizProvider.currentQuiz != null) {
                return Text(quizProvider.currentQuiz!.title);
              }
              return const Text('Quiz');
            },
          ),
          centerTitle: true,
          automaticallyImplyLeading: false, // Control leading button manually
          leading: Consumer<QuizProvider>(
            builder: (context, quizProvider, child) {
              // Only show back button if not the very first question
              // or if we want to allow going back from the first question to the quiz list.
              // For a typical quiz, you might hide this and rely on exit confirmation.
              if (quizProvider.currentQuestionIndex > 0) {
                return IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: quizProvider.goToPreviousQuestion,
                );
              }
              // Consider a dedicated "Exit Quiz" button or dialog
              return IconButton(
                icon: const Icon(Icons.close), // or Icons.arrow_back
                onPressed: () async {
                  final shouldPop = await _showExitConfirmationDialog(context);
                  if (shouldPop) {
                    Provider.of<QuizProvider>(context, listen: false).resetQuizState();
                    Navigator.pop(context);
                  }
                },
              );
            },
          ),
        ),
        body: Consumer<QuizProvider>(
          builder: (context, quizProvider, child) {
            if (quizProvider.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (quizProvider.errorMessage != null) {
              return Center(
                child: Text('Error: ${quizProvider.errorMessage}', style: TextStyle(color: Colors.red)),
              );
            }

            if (quizProvider.currentQuiz == null || quizProvider.currentQuiz!.questions.isEmpty) {
              return Center(
                child: Text(
                  'No quiz loaded or no questions available.',
                  style: TextStyle(fontSize: 18.sp, color: Colors.grey),
                ),
              );
            }

            final currentQuestion = quizProvider.currentQuestion;
            if (currentQuestion == null) {
              // This state should ideally be handled by navigating to QuizResultScreen immediately after submission.
              // But as a fallback:
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Quiz completed! Tap submit to see results.',
                      style: TextStyle(fontSize: 18.sp, color: Colors.green),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 20.h),
                    ElevatedButton(
                      onPressed: () async {
                        final result = await quizProvider.submitQuiz('1'); // Use actual user ID
                        if (result != null) {
                          Navigator.pushReplacementNamed(context, AppRoutes.quizResult);
                        }
                      },
                      child: const Text('Submit Quiz'),
                    ),
                  ],
                ),
              );
            }

            // Build question widget based on type
            Widget questionWidget;
            switch (currentQuestion.type) {
              case QuestionType.multipleChoice:
                questionWidget = MultipleChoiceQuestionWidget(
                  question: currentQuestion,
                  selectedOption: quizProvider.userAnswers[currentQuestion.id],
                  onOptionSelected: (option) =>
                      quizProvider.answerQuestion(currentQuestion.id, option),
                  showFeedback: quizProvider.showAnswerFeedback, // Pass new state
                );
                break;
              case QuestionType.fillInTheBlank:
                questionWidget = FillInTheBlankQuestionWidget(
                  question: currentQuestion,
                  selectedWords: quizProvider.userFillInTheBlanks[currentQuestion.id] ?? [], // Pass selected words
                  onWordsSelected: (words) => quizProvider.setFillInTheBlankAnswer(currentQuestion.id, words), // New callback
                  showFeedback: quizProvider.showAnswerFeedback, // Pass new state
                );
                break;
              default:
                questionWidget = Center(child: Text('Unsupported question type: ${currentQuestion.type.name}'));
            }

            bool hasAnsweredCurrentQuestion = (quizProvider.userAnswers.containsKey(currentQuestion.id) ||
                quizProvider.userFillInTheBlanks.containsKey(currentQuestion.id));

            return Padding(
              padding: EdgeInsets.all(16.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Question ${quizProvider.currentQuestionIndex + 1} of ${quizProvider.currentQuiz!.questions.length}',
                    style: TextStyle(fontSize: 16.sp, color: Colors.grey),
                  ),
                  SizedBox(height: 10.h),
                  Expanded(child: questionWidget),
                  SizedBox(height: 20.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Previous Button (Always visible if not first question)
                      if (quizProvider.currentQuestionIndex > 0)
                        ElevatedButton(
                          onPressed: quizProvider.goToPreviousQuestion,
                          child: const Text('Previous'),
                        ),
                      const Spacer(),
                      // Next Button (Visible only if question is answered and not last question)
                      if (quizProvider.currentQuestionIndex < quizProvider.currentQuiz!.questions.length - 1)
                        ElevatedButton(
                          onPressed: hasAnsweredCurrentQuestion
                              ? quizProvider.goToNextQuestion
                              : null, // Disable if not answered
                          child: const Text('Next'),
                        ),
                      // Submit Button (Visible only on the last question AND if it's answered)
                      if (quizProvider.currentQuestionIndex == quizProvider.currentQuiz!.questions.length - 1 && hasAnsweredCurrentQuestion)
                        ElevatedButton(
                          onPressed: () async {
                            final result = await quizProvider.submitQuiz('1'); // Use actual user ID
                            if (result != null) {
                              Navigator.pushReplacementNamed(context, AppRoutes.quizResult);
                            }
                          },
                          child: const Text('Submit Quiz'),
                        ),
                    ],
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Future<bool> _showExitConfirmationDialog(BuildContext context) async {
    return await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Exit Quiz?'),
          content: const Text('Are you sure you want to exit? Your current progress will be lost.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('No'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Yes'),
            ),
          ],
        );
      },
    ) ??
        false; // In case dialog is dismissed
  }
}