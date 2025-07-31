// lib/features/quiz/domain/usecases/generate_quiz_questions.dart
import 'package:grad_project/features/quiz/domain/entities/quiz_entity.dart';
import 'package:grad_project/features/quiz/domain/repositories/quiz_repository.dart'; // Using QuizRepository for simplicity now

class GenerateQuizQuestions {
  final QuizRepository repository; // Or a dedicated AIQuestionGeneratorRepository

  GenerateQuizQuestions(this.repository);

  Future<QuizEntity> call({
    required String topic,
    required String difficulty,
    int numberOfQuestions = 10,
    String? language,
    String? specificConcept,
  }) async {
    // This use case orchestrates the AI call via the repository
    return await repository.generateQuiz(
      topic: topic,
      difficulty: difficulty,
      numberOfQuestions: numberOfQuestions,
      language: language,
      specificConcept: specificConcept,
    );
  }
}