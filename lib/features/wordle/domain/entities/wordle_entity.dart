// lib/features/wordle/domain/entities/wordle_entity.dart

class WordleEntity {
  final String id;
  final String word;
  final String hint;
  final int maxAttempts;
  final List<String> attempts;
  final WordleStatus status;
  final int currentAttempt;
  final DateTime createdAt;

  const WordleEntity({
    required this.id,
    required this.word,
    required this.hint,
    required this.maxAttempts,
    required this.attempts,
    required this.status,
    required this.currentAttempt,
    required this.createdAt,
  });

  WordleEntity copyWith({
    String? id,
    String? word,
    String? hint,
    int? maxAttempts,
    List<String>? attempts,
    WordleStatus? status,
    int? currentAttempt,
    DateTime? createdAt,
  }) {
    return WordleEntity(
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

  bool get isCompleted => status == WordleStatus.won || status == WordleStatus.lost;
  bool get isWon => status == WordleStatus.won;
  int get remainingAttempts => maxAttempts - currentAttempt;
}

enum WordleStatus {
  playing,
  won,
  lost,
}

class WordleLetterResult {
  final String letter;
  final LetterStatus status;

  const WordleLetterResult({
    required this.letter,
    required this.status,
  });
}

enum LetterStatus {
  correct,    // Green - correct letter in correct position
  present,    // Yellow - correct letter in wrong position
  absent,     // Gray - letter not in word
  unknown,    // Default state
}