// lib/features/grammar/domain/repositories/grammar_morphology_repository.dart - COMPLETE INTERFACE

import 'package:grad_project/features/grammar/domain/entities/grammar_morphology_entity.dart';

abstract class GrammarMorphologyRepository {
  // Core parsing and morphology
  Future<List<ParsingResultEntity>> performParsing(String text);
  Future<List<MorphologyResultEntity>> performMorphology(String text, String form);

  // Meaning analysis features
  Future<List<String>> findSynonyms(String word);
  Future<List<String>> findAntonyms(String word);
  Future<String> findPlural(String word);
  Future<String> analyzeMeaning(String word);

  // Poetry features
  Future<PoetryGenerationEntity> generatePoetry(String theme, String meterType);
  Future<PoetryMeterEntity> analyzePoetryMeter(String poem);

  // Service management
  Future<E3rblyServiceStatusEntity> checkServiceStatus();

  // Enhanced Arabic parsing (using Gemini endpoint)
  Future<List<ParsingResultEntity>> performEnhancedParsing(String sentence, {String format = 'structured'});
}