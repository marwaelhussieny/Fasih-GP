// lib/features/grammar/domain/entities/grammar_morphology_entity.dart - FIXED TO MATCH API

import 'package:equatable/equatable.dart';

// Entity for parsing results (إعراب) - Updated to match /arabic endpoint
class ParsingResultEntity extends Equatable {
  final String word;
  final String parsing; // Changed from 'analysis' to 'parsing' to match API

  const ParsingResultEntity({
    required this.word,
    required this.parsing,
  });

  @override
  List<Object?> get props => [word, parsing];

  @override
  String toString() => 'ParsingResult(word: $word, parsing: $parsing)';
}

// Entity for morphology results (صرف) - Updated to match /morphology endpoint
class MorphologyResultEntity extends Equatable {
  final String word;
  final String type;
  final String state;
  final String root;

  const MorphologyResultEntity({
    required this.word,
    required this.type,
    required this.state,
    required this.root,
  });

  // Computed property for display
  String get fullAnalysis => '$type${state.isNotEmpty ? ' - $state' : ''}${root != 'N/A' && root.isNotEmpty ? ' - الجذر: $root' : ''}';

  @override
  List<Object?> get props => [word, type, state, root];

  @override
  String toString() => 'MorphologyResult(word: $word, type: $type, state: $state, root: $root)';
}

// Entity for meaning analysis results - Updated to match /analyze-meaning endpoint
class MeaningAnalysisEntity extends Equatable {
  final String word;
  final String meaningType; // synonyms, antonyms, plural, meaning
  final String result;

  const MeaningAnalysisEntity({
    required this.word,
    required this.meaningType,
    required this.result,
  });

  @override
  List<Object?> get props => [word, meaningType, result];

  @override
  String toString() => 'MeaningAnalysis(word: $word, type: $meaningType, result: $result)';
}

// Entity for poetry generation results - Updated to match /poetry endpoint
class PoetryGenerationEntity extends Equatable {
  final String userId;
  final String type;
  final String inputText;
  final String generatedPoem;
  final List<dynamic> grammarResult;
  final DateTime createdAt;
  final String id;

  const PoetryGenerationEntity({
    required this.userId,
    required this.type,
    required this.inputText,
    required this.generatedPoem,
    required this.grammarResult,
    required this.createdAt,
    required this.id,
  });

  @override
  List<Object?> get props => [userId, type, inputText, generatedPoem, grammarResult, createdAt, id];

  @override
  String toString() => 'PoetryGeneration(id: $id, poem: ${generatedPoem.length} chars)';
}

// Entity for poetry meter detection results
class PoetryMeterEntity extends Equatable {
  final String text;
  final String detectedMeter;
  final String confidence;
  final String pattern;

  const PoetryMeterEntity({
    required this.text,
    required this.detectedMeter,
    required this.confidence,
    required this.pattern,
  });

  @override
  List<Object?> get props => [text, detectedMeter, confidence, pattern];

  @override
  String toString() => 'PoetryMeter(meter: $detectedMeter, confidence: $confidence)';
}

// Entity for service status
class E3rblyServiceStatusEntity extends Equatable {
  final String status;
  final String service;
  final DateTime timestamp;

  const E3rblyServiceStatusEntity({
    required this.status,
    required this.service,
    required this.timestamp,
  });

  bool get isOnline => status == 'success' && service == 'online';

  @override
  List<Object?> get props => [status, service, timestamp];

  @override
  String toString() => 'E3rblyServiceStatus(status: $status, service: $service, online: $isOnline)';
}