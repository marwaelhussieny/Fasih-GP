// lib/features/wordle/data/datasources/wordle_remote_datasource.dart

import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/wordle_model.dart';

abstract class WordleRemoteDataSource {
  Future<WordleModel> getDailyWordle();
  Future<WordleModel> getRandomWordle();
  Future<WordleApiResponse> submitGuess(String wordleId, String guess);
  Future<List<WordleModel>> getWordleHistory();
}

class WordleRemoteDataSourceImpl implements WordleRemoteDataSource {
  final http.Client client;
  static const String baseUrl = 'https://f35f3ddf1acd.ngrok-free.app'; // Replace with actual API URL

  WordleRemoteDataSourceImpl({required this.client});

  @override
  Future<WordleModel> getDailyWordle() async {
    try {
      final response = await client.get(
        Uri.parse('$baseUrl/daily'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = json.decode(response.body);
        return WordleModel.fromJson(jsonData['data']);
      } else {
        throw Exception('Failed to load daily wordle: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  @override
  Future<WordleModel> getRandomWordle() async {
    try {
      final response = await client.get(
        Uri.parse('$baseUrl/random'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = json.decode(response.body);
        return WordleModel.fromJson(jsonData['data']);
      } else {
        throw Exception('Failed to load random wordle: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  @override
  Future<WordleApiResponse> submitGuess(String wordleId, String guess) async {
    try {
      final response = await client.post(
        Uri.parse('$baseUrl/wordle/$wordleId/guess'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: json.encode({
          'guess': guess,
        }),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = json.decode(response.body);
        return WordleApiResponse.fromJson(jsonData);
      } else {
        throw Exception('Failed to submit guess: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  @override
  Future<List<WordleModel>> getWordleHistory() async {
    try {
      final response = await client.get(
        Uri.parse('$baseUrl/history'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = json.decode(response.body);
        final List<dynamic> wordleList = jsonData['data'];
        return wordleList.map((wordle) => WordleModel.fromJson(wordle)).toList();
      } else {
        throw Exception('Failed to load wordle history: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }
}

// Local data source for offline storage
abstract class WordleLocalDataSource {
  Future<WordleModel?> getCachedWordle(String id);
  Future<void> cacheWordle(WordleModel wordle);
  Future<List<WordleModel>> getCachedWordleHistory();
  Future<void> clearCache();
}

class WordleLocalDataSourceImpl implements WordleLocalDataSource {
  static const String _wordleKey = 'cached_wordle_';
  static const String _historyKey = 'wordle_history';

  @override
  Future<WordleModel?> getCachedWordle(String id) async {
    // Implementation depends on your local storage solution (SharedPreferences, Hive, etc.)
    // This is a placeholder implementation
    return null;
  }

  @override
  Future<void> cacheWordle(WordleModel wordle) async {
    // Implementation for caching wordle locally
  }

  @override
  Future<List<WordleModel>> getCachedWordleHistory() async {
    // Implementation for getting cached history
    return [];
  }

  @override
  Future<void> clearCache() async {
    // Implementation for clearing cache
  }
}