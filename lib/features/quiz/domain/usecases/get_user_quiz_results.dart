// lib/features/quiz/domain/usecases/get_user_quiz_results.dart
import 'package:grad_project/features/quiz/domain/entities/quiz_result_entity.dart';
import 'package:grad_project/features/quiz/domain/repositories/quiz_repository.dart';

class GetUserQuizResults {
  final QuizRepository repository;

  GetUserQuizResults(this.repository);

  Future<List<QuizResultEntity>> call(String userId) async {
    return await repository.getUserQuizResults(userId);
  }
}