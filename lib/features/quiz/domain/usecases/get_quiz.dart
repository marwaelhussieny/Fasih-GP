// lib/features/quiz/domain/usecases/get_quiz.dart
import 'package:grad_project/features/quiz/domain/entities/quiz_entity.dart';
import 'package:grad_project/features/quiz/domain/repositories/quiz_repository.dart';

class GetQuiz {
  final QuizRepository repository;

  GetQuiz(this.repository);

  Future<QuizEntity> call(String quizId) async {
    return await repository.getQuiz(quizId);
  }
}