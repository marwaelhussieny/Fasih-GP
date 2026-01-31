// lib/features/grammar/data/repositories/grammar_morphology_repository_impl.dart - FIXED IMPLEMENTATION

import 'package:grad_project/features/grammar/data/datasources/grammar_morphology_remote_data_source.dart';
import 'package:grad_project/features/grammar/domain/entities/grammar_morphology_entity.dart';
import 'package:grad_project/features/grammar/domain/repositories/grammar_morphology_repository.dart';

class GrammarMorphologyRepositoryImpl implements GrammarMorphologyRepository {
  final GrammarMorphologyRemoteDataSource remoteDataSource;

  GrammarMorphologyRepositoryImpl(this.remoteDataSource);

  @override
  Future<List<ParsingResultEntity>> performParsing(String text) {
    return remoteDataSource.performParsing(text);
  }

  @override
  Future<List<MorphologyResultEntity>> performMorphology(String text, String form) {
    return remoteDataSource.performMorphology(text, form);
  }

  @override
  Future<PoetryGenerationEntity> generatePoetry(String theme, String meterType) async {
    try {
      final generatedPoem = await remoteDataSource.generatePoetry(theme, meterType);

      // Create entity from the generated poem string
      return PoetryGenerationEntity(
        userId: 'current_user', // This should come from auth service
        type: 'poetry',
        inputText: theme,
        generatedPoem: generatedPoem,
        grammarResult: [],
        createdAt: DateTime.now(),
        id: DateTime.now().millisecondsSinceEpoch.toString(),
      );
    } catch (e) {
      throw Exception('فشل في توليد الشعر: $e');
    }
  }

  @override
  Future<List<String>> findAntonyms(String word) {
    return remoteDataSource.findAntonyms(word);
  }

  @override
  Future<List<String>> findSynonyms(String word) {
    return remoteDataSource.findSynonyms(word);
  }

  @override
  Future<String> findPlural(String word) {
    return remoteDataSource.findPlural(word);
  }

  @override
  Future<String> analyzeMeaning(String word) {
    return remoteDataSource.analyzeMeaning(word);
  }

  @override
  Future<PoetryMeterEntity> analyzePoetryMeter(String poem) async {
    try {
      final result = await remoteDataSource.analyzePoetryMeter(poem);

      // Parse the result to extract meter information
      // The API returns format like "البحر المكتشف: الطويل - الثقة: عالية"
      String detectedMeter = 'غير محدد';
      String confidence = 'منخفض';
      String pattern = '';

      if (result.contains('البحر المكتشف:')) {
        final parts = result.split('-');
        if (parts.isNotEmpty) {
          detectedMeter = parts[0].replaceAll('البحر المكتشف:', '').trim();
        }
        if (parts.length > 1) {
          confidence = parts[1].replaceAll('الثقة:', '').trim();
        }
      } else {
        detectedMeter = result;
      }

      return PoetryMeterEntity(
        text: poem,
        detectedMeter: detectedMeter,
        confidence: confidence,
        pattern: pattern,
      );
    } catch (e) {
      throw Exception('فشل في تحليل البحر الشعري: $e');
    }
  }

  @override
  Future<E3rblyServiceStatusEntity> checkServiceStatus() async {
    try {
      final isOnline = await remoteDataSource.checkServiceStatus();

      return E3rblyServiceStatusEntity(
        status: isOnline ? 'success' : 'error',
        service: isOnline ? 'online' : 'offline',
        timestamp: DateTime.now(),
      );
    } catch (e) {
      return E3rblyServiceStatusEntity(
        status: 'error',
        service: 'offline',
        timestamp: DateTime.now(),
      );
    }
  }

  @override
  Future<List<ParsingResultEntity>> performEnhancedParsing(String sentence, {String format = 'structured'}) async {
    // Try to call the enhanced parsing method directly on the data source
    try {
      // We know our data source is the implementation, so we can safely call the method
      return await remoteDataSource.performEnhancedParsing(sentence, format: format);
    } catch (e) {
      // Fallback to regular parsing if enhanced parsing fails
      print('Enhanced parsing failed, falling back to regular parsing: $e');
      return await remoteDataSource.performParsing(sentence);
    }
  }
}