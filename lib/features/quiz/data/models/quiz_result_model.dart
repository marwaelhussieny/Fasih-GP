// lib/features/quiz/data/models/quiz_result_model.dart
import 'package:grad_project/features/quiz/domain/entities/quiz_result_entity.dart';

class QuizResultModel {
  final String quizId;
  final String userId;
  final DateTime completedAt;
  final int score;
  final int totalQuestions;
  final int correctAnswers;
  final int incorrectAnswers;
  final List<Map<String, dynamic>> questionResults;

  QuizResultModel({
    required this.quizId,
    required this.userId,
    required this.completedAt,
    required this.score,
    required this.totalQuestions,
    required this.correctAnswers,
    required this.incorrectAnswers,
    this.questionResults = const [],
  });

  // Factory constructor to create a QuizResultModel from a JSON map (from backend)
  factory QuizResultModel.fromJson(Map<String, dynamic> json) {
    return QuizResultModel(
      quizId: json['quizId'] as String,
      userId: json['userId'] as String,
      completedAt: DateTime.parse(json['completedAt'] as String),
      score: json['score'] as int,
      totalQuestions: json['totalQuestions'] as int,
      correctAnswers: json['correctAnswers'] as int,
      incorrectAnswers: json['incorrectAnswers'] as int,
      questionResults: List<Map<String, dynamic>>.from(json['questionResults'] as List? ?? []),
    );
  }

  // Method to convert a QuizResultModel to a JSON map (to send to backend)
  Map<String, dynamic> toJson() {
    return {
      'quizId': quizId,
      'userId': userId,
      'completedAt': completedAt.toIso8601String(),
      'score': score,
      'totalQuestions': totalQuestions,
      'correctAnswers': correctAnswers,
      'incorrectAnswers': incorrectAnswers,
      'questionResults': questionResults,
    };
  }

  // Method to convert QuizResultModel to QuizResultEntity
  QuizResultEntity toEntity() {
    return QuizResultEntity(
      quizId: quizId,
      userId: userId,
      completedAt: completedAt,
      score: score,
      totalQuestions: totalQuestions,
      correctAnswers: correctAnswers,
      incorrectAnswers: incorrectAnswers,
      questionResults: questionResults,
    );
  }

  // Factory to create QuizResultModel from QuizResultEntity
  factory QuizResultModel.fromEntity(QuizResultEntity entity) {
    return QuizResultModel(
      quizId: entity.quizId,
      userId: entity.userId,
      completedAt: entity.completedAt,
      score: entity.score,
      totalQuestions: entity.totalQuestions,
      correctAnswers: entity.correctAnswers,
      incorrectAnswers: entity.incorrectAnswers,
      questionResults: entity.questionResults,
    );
  }
}