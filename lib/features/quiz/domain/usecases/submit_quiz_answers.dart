// lib/features/quiz/domain/usecases/submit_quiz_answers.dart
import 'package:grad_project/features/quiz/domain/entities/quiz_result_entity.dart';
import 'package:grad_project/features/quiz/domain/repositories/quiz_repository.dart';

class SubmitQuizAnswers {
  final QuizRepository repository;

  SubmitQuizAnswers(this.repository);

  Future<QuizResultEntity> call({
    required String quizId,
    required String userId,
    required Map<String, String> userAnswers,
  }) async {
    return await repository.submitQuizAnswers(
      quizId: quizId,
      userId: userId,
      userAnswers: userAnswers,
    );
  }
}