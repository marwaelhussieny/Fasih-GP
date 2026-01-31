// lib/features/wordle/data/repositories/wordle_repository_impl.dart

import '../../domain/entities/wordle_entity.dart';
import '../../domain/repositories/wordle_repository.dart';
import '../datasources/wordle_remote_datasource.dart';
import '../models/wordle_model.dart';

class WordleRepositoryImpl implements WordleRepository {
  final WordleRemoteDataSource remoteDataSource;
  final WordleLocalDataSource localDataSource;

  WordleRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  });

  @override
  Future<WordleEntity> getDailyWordle() async {
    try {
      final wordle = await remoteDataSource.getDailyWordle();
      await localDataSource.cacheWordle(wordle);
      return wordle;
    } catch (e) {
      // Try to get cached version if network fails
      final cachedWordle = await localDataSource.getCachedWordle('daily');
      if (cachedWordle != null) {
        return cachedWordle;
      }
      rethrow;
    }
  }

  @override
  Future<WordleEntity> getRandomWordle() async {
    try {
      final wordle = await remoteDataSource.getRandomWordle();
      await localDataSource.cacheWordle(wordle);
      return wordle;
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<WordleEntity> submitGuess(String wordleId, String guess) async {
    try {
      final response = await remoteDataSource.submitGuess(wordleId, guess);
      if (response.success && response.data != null) {
        await localDataSource.cacheWordle(response.data!);
        return response.data!;
      } else {
        throw Exception(response.message);
      }
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<List<WordleEntity>> getWordleHistory() async {
    try {
      final history = await remoteDataSource.getWordleHistory();
      return history;
    } catch (e) {
      // Return cached history if network fails
      final cachedHistory = await localDataSource.getCachedWordleHistory();
      return cachedHistory;
    }
  }

  @override
  Future<void> saveWordleProgress(WordleEntity wordle) async {
    try {
      final wordleModel = WordleModel.fromEntity(wordle);
      await localDataSource.cacheWordle(wordleModel);
    } catch (e) {
      rethrow;
    }
  }
}