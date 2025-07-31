// lib/features/quiz/domain/entities/quiz_entity.dart
import 'package:equatable/equatable.dart';
import 'package:grad_project/features/quiz/domain/entities/question_entity.dart';

class QuizEntity extends Equatable {
  final String id;
  final String title;
  final String topic;
  final String difficulty; // e.g., 'easy', 'medium', 'hard'
  final List<QuestionEntity> questions;
  final int totalPoints; // Total points possible for this quiz
  final int durationMinutes; // Optional: how long the quiz should take

  const QuizEntity({
    required this.id,
    required this.title,
    required this.topic,
    required this.difficulty,
    required this.questions,
    this.totalPoints = 0, // Default to 0, calculate based on questions
    this.durationMinutes = 0,
  });

  @override
  List<Object?> get props => [
    id,
    title,
    topic,
    difficulty,
    questions,
    totalPoints,
    durationMinutes,
  ];
}