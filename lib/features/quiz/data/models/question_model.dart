// lib/features/quiz/data/models/question_model.dart
import 'package:grad_project/features/quiz/domain/entities/question_entity.dart';

class QuestionModel {
  final String id;
  final String text;
  final String type; // Stored as String, converted to enum in entity
  final List<String> options;
  final String correctAnswer;
  final String? imageUrl;
  final String? audioUrl;
  final String? explanation;

  QuestionModel({
    required this.id,
    required this.text,
    required this.type,
    this.options = const [],
    required this.correctAnswer,
    this.imageUrl,
    this.audioUrl,
    this.explanation,
  });

  // Factory constructor to create a QuestionModel from a JSON map (from backend)
  factory QuestionModel.fromJson(Map<String, dynamic> json) {
    return QuestionModel(
      id: json['id'] as String,
      text: json['text'] as String,
      type: json['type'] as String,
      options: List<String>.from(json['options'] as List? ?? []),
      correctAnswer: json['correctAnswer'] as String,
      imageUrl: json['imageUrl'] as String?,
      audioUrl: json['audioUrl'] as String?,
      explanation: json['explanation'] as String?,
    );
  }

  // Method to convert a QuestionModel to a JSON map (to send to backend)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'text': text,
      'type': type,
      'options': options,
      'correctAnswer': correctAnswer,
      'imageUrl': imageUrl,
      'audioUrl': audioUrl,
      'explanation': explanation,
    };
  }

  // Method to convert QuestionModel to QuestionEntity
  QuestionEntity toEntity() {
    return QuestionEntity(
      id: id,
      text: text,
      type: QuestionType.values.firstWhere(
            (e) => e.toString().split('.').last == type,
        orElse: () => QuestionType.multipleChoice, // Default if not found
      ),
      options: options,
      correctAnswer: correctAnswer,
      imageUrl: imageUrl,
      audioUrl: audioUrl,
      explanation: explanation,
    );
  }

  // Factory to create QuestionModel from QuestionEntity
  factory QuestionModel.fromEntity(QuestionEntity entity) {
    return QuestionModel(
      id: entity.id,
      text: entity.text,
      type: entity.type.toString().split('.').last,
      options: entity.options,
      correctAnswer: entity.correctAnswer,
      imageUrl: entity.imageUrl,
      audioUrl: entity.audioUrl,
      explanation: entity.explanation,
    );
  }
}