// lib/features/grammar/domain/usecases/perform_parsing_usecase.dart

import 'package:grad_project/features/grammar/domain/entities/grammar_morphology_entity.dart';
import 'package:grad_project/features/grammar/domain/repositories/grammar_morphology_repository.dart';

class PerformParsingUseCase {
  final GrammarMorphologyRepository repository;

  PerformParsingUseCase(this.repository);

  Future<List<ParsingResultEntity>> call(String text) {
    return repository.performParsing(text);
  }

  // Enhanced parsing using Gemini endpoint
  Future<List<ParsingResultEntity>> callEnhanced(String sentence, {String format = 'structured'}) {
    return repository.performEnhancedParsing(sentence, format: format);
  }
}