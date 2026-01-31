// lib/features/wordle/domain/usecases/wordle_usecases.dart

import '../entities/wordle_entity.dart';
import '../repositories/wordle_repository.dart';

class GetDailyWordleUseCase {
  final WordleRepository repository;

  GetDailyWordleUseCase({required this.repository});

  Future<WordleEntity> call() async {
    return await repository.getDailyWordle();
  }
}

class GetRandomWordleUseCase {
  final WordleRepository repository;

  GetRandomWordleUseCase({required this.repository});

  Future<WordleEntity> call() async {
    return await repository.getRandomWordle();
  }
}

class SubmitGuessUseCase {
  final WordleRepository repository;

  SubmitGuessUseCase({required this.repository});

  Future<WordleEntity> call(String wordleId, String guess) async {
    if (guess.length != 5) {
      throw ArgumentError('Guess must be exactly 5 letters');
    }

    if (!_isValidArabicWord(guess)) {
      throw ArgumentError('Guess must contain only Arabic letters');
    }

    return await repository.submitGuess(wordleId, guess);
  }

  bool _isValidArabicWord(String word) {
    final arabicRegex = RegExp(r'^[\u0600-\u06FF\u0750-\u077F]+$');
    return arabicRegex.hasMatch(word);
  }
}

class GetWordleHistoryUseCase {
  final WordleRepository repository;

  GetWordleHistoryUseCase({required this.repository});

  Future<List<WordleEntity>> call() async {
    return await repository.getWordleHistory();
  }
}

class SaveWordleProgressUseCase {
  final WordleRepository repository;

  SaveWordleProgressUseCase({required this.repository});

  Future<void> call(WordleEntity wordle) async {
    return await repository.saveWordleProgress(wordle);
  }
}