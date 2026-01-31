// lib/features/wordle/domain/repositories/wordle_repository.dart

import '../entities/wordle_entity.dart';

abstract class WordleRepository {
  Future<WordleEntity> getDailyWordle();
  Future<WordleEntity> getRandomWordle();
  Future<WordleEntity> submitGuess(String wordleId, String guess);
  Future<List<WordleEntity>> getWordleHistory();
  Future<void> saveWordleProgress(WordleEntity wordle);
}