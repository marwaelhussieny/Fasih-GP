// lib/features/quiz/domain/entities/quiz_result_entity.dart
import 'package:equatable/equatable.dart';

class QuizResultEntity extends Equatable {
  final String quizId;
  final String userId;
  final DateTime completedAt;
  final int score;
  final int totalQuestions;
  final int correctAnswers;
  final int incorrectAnswers;
  final List<Map<String, dynamic>>
  questionResults; // Stores per-question outcome (questionId, answeredOption, isCorrect, explanation)

  const QuizResultEntity({
    required this.quizId,
    required this.userId,
    required this.completedAt,
    required this.score,
    required this.totalQuestions,
    required this.correctAnswers,
    required this.incorrectAnswers,
    this.questionResults = const [],
  });

  @override
  List<Object?> get props => [
    quizId,
    userId,
    completedAt,
    score,
    totalQuestions,
    correctAnswers,
    incorrectAnswers,
    questionResults,
  ];
}