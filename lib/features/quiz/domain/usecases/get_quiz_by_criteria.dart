// lib/features/quiz/domain/usecases/get_quizzes_by_criteria.dart
import 'package:grad_project/features/quiz/domain/entities/quiz_entity.dart';
import 'package:grad_project/features/quiz/domain/repositories/quiz_repository.dart';

class GetQuizzesByCriteria {
  final QuizRepository repository;

  GetQuizzesByCriteria(this.repository);

  Future<List<QuizEntity>> call({String? topic, String? difficulty}) async {
    return await repository.getQuizzes(topic: topic, difficulty: difficulty);
  }
}