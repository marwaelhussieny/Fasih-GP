// lib/features/grammar/data/datasources/grammar_morphology_remote_data_source.dart - COMPLETE INTERFACE

import 'package:grad_project/features/grammar/domain/entities/grammar_morphology_entity.dart';

abstract class GrammarMorphologyRemoteDataSource {
  // Core grammar features
  Future<List<ParsingResultEntity>> performParsing(String text);
  Future<List<MorphologyResultEntity>> performMorphology(String text, String form);

  // Additional E3rbly API features
  Future<String> generatePoetry(String theme, String meterType);
  Future<List<String>> findSynonyms(String word);
  Future<List<String>> findAntonyms(String word);
  Future<String> findPlural(String word);
  Future<String> analyzeMeaning(String word);
  Future<String> analyzePoetryMeter(String poem);
  Future<bool> checkServiceStatus();

  // Enhanced Arabic parsing using Gemini endpoint
  Future<List<ParsingResultEntity>> performEnhancedParsing(String sentence, {String format = 'structured'});
}