// lib/features/quiz/data/models/quiz_model.dart
import 'package:grad_project/features/quiz/data/models/question_model.dart';
import 'package:grad_project/features/quiz/domain/entities/quiz_entity.dart';

class QuizModel {
  final String id;
  final String title;
  final String topic;
  final String difficulty;
  final List<QuestionModel> questions;
  final int totalPoints;
  final int durationMinutes;

  QuizModel({
    required this.id,
    required this.title,
    required this.topic,
    required this.difficulty,
    required this.questions,
    this.totalPoints = 0,
    this.durationMinutes = 0,
  });

  // Factory constructor to create a QuizModel from a JSON map (from backend)
  factory QuizModel.fromJson(Map<String, dynamic> json) {
    return QuizModel(
      id: json['id'] as String,
      title: json['title'] as String,
      topic: json['topic'] as String,
      difficulty: json['difficulty'] as String,
      questions: (json['questions'] as List)
          .map((i) => QuestionModel.fromJson(i as Map<String, dynamic>))
          .toList(),
      totalPoints: json['totalPoints'] as int? ?? 0,
      durationMinutes: json['durationMinutes'] as int? ?? 0,
    );
  }

  // Method to convert a QuizModel to a JSON map (to send to backend)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'topic': topic,
      'difficulty': difficulty,
      'questions': questions.map((q) => q.toJson()).toList(),
      'totalPoints': totalPoints,
      'durationMinutes': durationMinutes,
    };
  }

  // Method to convert QuizModel to QuizEntity
  QuizEntity toEntity() {
    return QuizEntity(
      id: id,
      title: title,
      topic: topic,
      difficulty: difficulty,
      questions: questions.map((q) => q.toEntity()).toList(),
      totalPoints: totalPoints,
      durationMinutes: durationMinutes,
    );
  }

  // Factory to create QuizModel from QuizEntity
  factory QuizModel.fromEntity(QuizEntity entity) {
    return QuizModel(
      id: entity.id,
      title: entity.title,
      topic: entity.topic,
      difficulty: entity.difficulty,
      questions: entity.questions.map((q) => QuestionModel.fromEntity(q)).toList(),
      totalPoints: entity.totalPoints,
      durationMinutes: entity.durationMinutes,
    );
  }
}