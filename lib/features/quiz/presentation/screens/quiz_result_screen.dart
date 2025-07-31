// lib/features/quiz/presentation/pages/quiz_result_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:grad_project/features/quiz/presentation/providers/quiz_provider.dart';
import 'package:grad_project/features/quiz/domain/entities/quiz_entity.dart'; // Import QuizEntity to access question details
import 'package:grad_project/features/quiz/domain/entities/quiz_result_entity.dart'; // <--- ADD THIS LINE


class QuizResultScreen extends StatelessWidget {
  const QuizResultScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quiz Result'),
        centerTitle: true,
      ),
      body: Consumer<QuizProvider>(
        builder: (context, quizProvider, child) {
          final result = quizProvider.lastQuizResult;
          final quiz = quizProvider.currentQuiz; // Get the quiz to display questions

          if (quizProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (result == null || quiz == null) {
            return Center(
              child: Text(
                'No quiz result available. Please complete a quiz first.',
                style: TextStyle(fontSize: 18.sp, color: Colors.grey),
                textAlign: TextAlign.center,
              ),
            );
          }

          return SingleChildScrollView(
            padding: EdgeInsets.all(16.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Text(
                    'Quiz Completed!',
                    style: TextStyle(fontSize: 24.sp, fontWeight: FontWeight.bold, color: Colors.green),
                  ),
                ),
                SizedBox(height: 20.h),
                _buildResultSummary(result),
                SizedBox(height: 30.h),
                Text(
                  'Your Answers:',
                  style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 15.h),
                _buildQuestionResults(result, quiz),
                SizedBox(height: 20.h),
                Center(
                  child: ElevatedButton(
                    onPressed: () {
                      quizProvider.resetQuizState(); // Clear quiz state
                      Navigator.popUntil(context, (route) => route.isFirst); // Go back to main screen or quiz list
                    },
                    child: const Text('Done'),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildResultSummary(QuizResultEntity result) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
      child: Padding(
        padding: EdgeInsets.all(20.w),
        child: Column(
          children: [
            _buildResultRow('Score:', '${result.score}%', result.score >= 50 ? Colors.green : Colors.red),
            SizedBox(height: 10.h),
            _buildResultRow('Total Questions:', result.totalQuestions.toString(), null),
            SizedBox(height: 10.h),
            _buildResultRow('Correct Answers:', result.correctAnswers.toString(), Colors.green),
            SizedBox(height: 10.h),
            _buildResultRow('Incorrect Answers:', result.incorrectAnswers.toString(), Colors.red),
            SizedBox(height: 10.h),
            _buildResultRow('Completed At:', '${result.completedAt.toLocal().toIso8601String().split('T')[0]} ${result.completedAt.toLocal().hour}:${result.completedAt.toLocal().minute}', null),
          ],
        ),
      ),
    );
  }

  Widget _buildResultRow(String label, String value, Color? color) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600),
        ),
        Text(
          value,
          style: TextStyle(fontSize: 16.sp, color: color, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Widget _buildQuestionResults(QuizResultEntity result, QuizEntity quiz) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: result.questionResults.length,
      itemBuilder: (context, index) {
        final qResult = result.questionResults[index];
        final questionId = qResult['questionId'] as String;
        // Find the original question from the quiz
        final originalQuestion = quiz.questions.firstWhere(
              (q) => q.id == questionId,
          orElse: () => throw Exception('Question not found in original quiz'),
        );

        final isCorrect = qResult['isCorrect'] as bool;
        final answeredOption = qResult['answeredOption'] as String?;
        final explanation = qResult['explanation'] as String?;

        return Card(
          margin: EdgeInsets.only(bottom: 15.h),
          elevation: 2,
          color: isCorrect ? Colors.green.shade50 : Colors.red.shade50,
          child: Padding(
            padding: EdgeInsets.all(15.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Question ${index + 1}:',
                  style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 5.h),
                Text(
                  originalQuestion.text,
                  style: TextStyle(fontSize: 15.sp),
                ),
                SizedBox(height: 10.h),
                Text(
                  'Your Answer: ${answeredOption ?? 'Not Answered'}',
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: isCorrect ? Colors.green.shade800 : Colors.red.shade800,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  'Correct Answer: ${originalQuestion.correctAnswer}',
                  style: TextStyle(fontSize: 14.sp, color: Colors.blue.shade800, fontWeight: FontWeight.w500),
                ),
                if (explanation != null && explanation.isNotEmpty)
                  Padding(
                    padding: EdgeInsets.only(top: 8.h),
                    child: Text(
                      'Explanation: $explanation',
                      style: TextStyle(fontSize: 13.sp, color: Colors.grey[700]),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}