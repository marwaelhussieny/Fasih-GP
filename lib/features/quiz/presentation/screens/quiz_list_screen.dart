// lib/features/quiz/presentation/pages/quiz_list_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:grad_project/features/quiz/presentation/providers/quiz_provider.dart';
import 'package:grad_project/core/navigation/app_routes.dart'; // Assuming you have AppRoutes for navigation

class QuizListScreen extends StatefulWidget {
  const QuizListScreen({Key? key}) : super(key: key);

  @override
  State<QuizListScreen> createState() => _QuizListScreenState();
}

class _QuizListScreenState extends State<QuizListScreen> {
  @override
  void initState() {
    super.initState();
    // Fetch quizzes when the screen initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<QuizProvider>(context, listen: false).fetchAvailableQuizzes();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Available Quizzes'),
        centerTitle: true,
      ),
      body: Consumer<QuizProvider>(
        builder: (context, quizProvider, child) {
          if (quizProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (quizProvider.errorMessage != null) {
            return Center(
              child: Padding(
                padding: EdgeInsets.all(20.w),
                child: Text(
                  'Error: ${quizProvider.errorMessage}',
                  style: TextStyle(color: Colors.red, fontSize: 16.sp),
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }

          if (quizProvider.availableQuizzes.isEmpty) {
            return Center(
              child: Text(
                'No quizzes available. Try refreshing or generating one.',
                style: TextStyle(fontSize: 18.sp, color: Colors.grey),
                textAlign: TextAlign.center,
              ),
            );
          }

          return ListView.builder(
            padding: EdgeInsets.all(16.w),
            itemCount: quizProvider.availableQuizzes.length,
            itemBuilder: (context, index) {
              final quiz = quizProvider.availableQuizzes[index];
              return Card(
                margin: EdgeInsets.only(bottom: 12.h),
                elevation: 3,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
                child: InkWell(
                  onTap: () async {
                    await quizProvider.selectAndLoadQuiz(quiz.id);
                    if (quizProvider.currentQuiz != null) {
                      Navigator.pushNamed(context, AppRoutes.quiz); // Navigate to quiz screen
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Failed to load quiz: ${quizProvider.errorMessage ?? "Unknown error"}')),
                      );
                    }
                  },
                  child: Padding(
                    padding: EdgeInsets.all(16.w),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          quiz.title,
                          style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 8.h),
                        Text(
                          'Topic: ${quiz.topic}',
                          style: TextStyle(fontSize: 14.sp, color: Colors.grey[700]),
                        ),
                        Text(
                          'Difficulty: ${quiz.difficulty}',
                          style: TextStyle(fontSize: 14.sp, color: Colors.grey[700]),
                        ),
                        Text(
                          'Questions: ${quiz.questions.length}',
                          style: TextStyle(fontSize: 14.sp, color: Colors.grey[700]),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          // Example of AI generated quiz
          await Provider.of<QuizProvider>(context, listen: false).generateAndLoadQuiz(
            topic: 'Arabic Vocab',
            difficulty: 'medium',
            numberOfQuestions: 5,
          );
          if (Provider.of<QuizProvider>(context, listen: false).currentQuiz != null) {
            Navigator.pushNamed(context, AppRoutes.quiz); // Navigate to quiz screen
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Failed to generate quiz: ${Provider.of<QuizProvider>(context, listen: false).errorMessage ?? "Unknown error"}')),
            );
          }
        },
        label: const Text('Generate AI Quiz'),
        icon: const Icon(Icons.psychology),
      ),
    );
  }
}