// lib/features/wordle/data/models/wordle_model.dart

import '../../domain/entities/wordle_entity.dart';

class WordleModel extends WordleEntity {
  const WordleModel({
    required super.id,
    required super.word,
    required super.hint,
    required super.maxAttempts,
    required super.attempts,
    required super.status,
    required super.currentAttempt,
    required super.createdAt,
  });

  factory WordleModel.fromJson(Map<String, dynamic> json) {
    return WordleModel(
      id: json['id'] ?? '',
      word: json['word'] ?? '',
      hint: json['hint'] ?? '',
      maxAttempts: json['max_attempts'] ?? 6,
      attempts: List<String>.from(json['attempts'] ?? []),
      status: WordleStatus.values.firstWhere(
            (status) => status.name == json['status'],
        orElse: () => WordleStatus.playing,
      ),
      currentAttempt: json['current_attempt'] ?? 0,
      createdAt: DateTime.parse(json['created_at'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'word': word,
      'hint': hint,
      'max_attempts': maxAttempts,
      'attempts': attempts,
      'status': status.name,
      'current_attempt': currentAttempt,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory WordleModel.fromEntity(WordleEntity entity) {
    return WordleModel(
      id: entity.id,
      word: entity.word,
      hint: entity.hint,
      maxAttempts: entity.maxAttempts,
      attempts: entity.attempts,
      status: entity.status,
      currentAttempt: entity.currentAttempt,
      createdAt: entity.createdAt,
    );
  }

  WordleModel copyWith({
    String? id,
    String? word,
    String? hint,
    int? maxAttempts,
    List<String>? attempts,
    WordleStatus? status,
    int? currentAttempt,
    DateTime? createdAt,
  }) {
    return WordleModel(
      id: id ?? this.id,
      word: word ?? this.word,
      hint: hint ?? this.hint,
      maxAttempts: maxAttempts ?? this.maxAttempts,
      attempts: attempts ?? this.attempts,
      status: status ?? this.status,
      currentAttempt: currentAttempt ?? this.currentAttempt,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

class WordleApiResponse {
  final bool success;
  final String message;
  final WordleModel? data;
  final List<WordleLetterResult>? letterResults;

  const WordleApiResponse({
    required this.success,
    required this.message,
    this.data,
    this.letterResults,
  });

  factory WordleApiResponse.fromJson(Map<String, dynamic> json) {
    return WordleApiResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      data: json['data'] != null ? WordleModel.fromJson(json['data']) : null,
      letterResults: json['letter_results'] != null
          ? (json['letter_results'] as List)
          .map((result) => WordleLetterResult(
        letter: result['letter'] ?? '',
        status: LetterStatus.values.firstWhere(
              (status) => status.name == result['status'],
          orElse: () => LetterStatus.unknown,
        ),
      ))
          .toList()
          : null,
    );
  }
}