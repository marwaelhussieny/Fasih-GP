// lib/features/quiz/domain/repositories/quiz_repository.dart
import 'package:grad_project/features/quiz/domain/entities/quiz_entity.dart';
import 'package:grad_project/features/quiz/domain/entities/quiz_result_entity.dart';

abstract class QuizRepository {
  /// Fetches a quiz by its ID.
  Future<QuizEntity> getQuiz(String quizId);

  /// Fetches a list of quizzes by topic or difficulty.
  Future<List<QuizEntity>> getQuizzes({String? topic, String? difficulty});

  /// Submits the user's answers for a quiz and returns the result.
  Future<QuizResultEntity> submitQuizAnswers({
    required String quizId,
    required String userId,
    required Map<String, String> userAnswers, // Map of questionId to user's answer
  });

  /// Gets past quiz results for a specific user.
  Future<List<QuizResultEntity>> getUserQuizResults(String userId);

  // Future work for AI-generated quizzes
  /// Generates a new quiz based on specific criteria using an AI model.
  /// The AI model would be called through a data source in the implementation.
  Future<QuizEntity> generateQuiz({
    required String topic,
    required String difficulty,
    int numberOfQuestions = 10,
    String? language,
    String? specificConcept,
  });
}