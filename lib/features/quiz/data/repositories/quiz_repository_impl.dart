// lib/features/quiz/data/repositories/quiz_repository_impl.dart
import 'package:grad_project/features/quiz/domain/repositories/quiz_repository.dart';
import 'package:grad_project/features/quiz/domain/entities/quiz_entity.dart';
import 'package:grad_project/features/quiz/domain/entities/quiz_result_entity.dart';
import 'package:grad_project/features/quiz/data/datasources/quiz_remote_data_source.dart';
// import 'package:grad_project/features/quiz/data/datasources/quiz_local_data_source.dart'; // Uncomment if you add local data source

class QuizRepositoryImpl implements QuizRepository {
  final QuizRemoteDataSource remoteDataSource;
  // final QuizLocalDataSource localDataSource; // Uncomment if you add local data source

  QuizRepositoryImpl({
    required this.remoteDataSource,
    // this.localDataSource, // Uncomment if you add local data source
  });

  @override
  Future<QuizEntity> getQuiz(String quizId) async {
    try {
      final quizModel = await remoteDataSource.getQuiz(quizId);
      return quizModel.toEntity();
    } catch (e) {
      // Handle errors (e.g., network error, quiz not found)
      rethrow;
    }
  }

  @override
  Future<List<QuizEntity>> getQuizzes({String? topic, String? difficulty}) async {
    try {
      final quizModels = await remoteDataSource.getQuizzes(topic: topic, difficulty: difficulty);
      return quizModels.map((model) => model.toEntity()).toList();
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<QuizResultEntity> submitQuizAnswers({
    required String quizId,
    required String userId,
    required Map<String, String> userAnswers,
  }) async {
    try {
      final quizResultModel = await remoteDataSource.submitQuizAnswers(
        quizId: quizId,
        userId: userId,
        userAnswers: userAnswers,
      );
      return quizResultModel.toEntity();
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<List<QuizResultEntity>> getUserQuizResults(String userId) async {
    try {
      final quizResultModels = await remoteDataSource.getUserQuizResults(userId);
      return quizResultModels.map((model) => model.toEntity()).toList();
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<QuizEntity> generateQuiz({
    required String topic,
    required String difficulty,
    int numberOfQuestions = 10,
    String? language,
    String? specificConcept,
  }) async {
    try {
      final quizModel = await remoteDataSource.generateQuiz(
        topic: topic,
        difficulty: difficulty,
        numberOfQuestions: numberOfQuestions,
        language: language,
        specificConcept: specificConcept,
      );
      return quizModel.toEntity();
    } catch (e) {
      rethrow;
    }
  }
}