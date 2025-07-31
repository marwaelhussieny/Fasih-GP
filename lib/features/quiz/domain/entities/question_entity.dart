// lib/features/quiz/domain/entities/question_entity.dart
import 'package:equatable/equatable.dart';

enum QuestionType {
  multipleChoice,
  fillInTheBlank,
  // Add more types as needed, e.g., matching, trueFalse
}

class QuestionEntity extends Equatable {
  final String id;
  final String text; // The question text
  final QuestionType type;
  final List<String> options; // For multiple choice questions
  final String correctAnswer; // The single correct answer (for simplicity)
  final String? imageUrl; // Optional: for image-based questions
  final String? audioUrl; // Optional: for audio-based questions
  final String? explanation; // Optional: explanation for the answer

  const QuestionEntity({
    required this.id,
    required this.text,
    required this.type,
    this.options = const [], // Default to empty list for non-multiple choice types
    required this.correctAnswer,
    this.imageUrl,
    this.audioUrl,
    this.explanation,
  });

  @override
  List<Object?> get props => [
    id,
    text,
    type,
    options,
    correctAnswer,
    imageUrl,
    audioUrl,
    explanation,
  ];

  // Helper to convert from a map (e.g., for initial AI/backend integration)
  // This factory is usually in the data layer (model), but for initial setup, it's here.
  factory QuestionEntity.fromMap(Map<String, dynamic> map) {
    return QuestionEntity(
      id: map['id'] as String,
      text: map['text'] as String,
      type: QuestionType.values.firstWhere(
            (e) => e.toString().split('.').last == map['type'],
        orElse: () => QuestionType.multipleChoice, // Default type
      ),
      options: List<String>.from(map['options'] as List? ?? []),
      correctAnswer: map['correctAnswer'] as String,
      imageUrl: map['imageUrl'] as String?,
      audioUrl: map['audioUrl'] as String?,
      explanation: map['explanation'] as String?,
    );
  }

  // Helper to convert to a map (e.g., for sending to backend)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'text': text,
      'type': type.toString().split('.').last, // Convert enum to string
      'options': options,
      'correctAnswer': correctAnswer,
      'imageUrl': imageUrl,
      'audioUrl': audioUrl,
      'explanation': explanation,
    };
  }
}