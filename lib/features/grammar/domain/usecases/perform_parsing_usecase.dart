// lib/features/grammar_morphology/domain/usecases/perform_parsing_usecase.dart

import 'package:grad_project/features/grammar/domain/entities/grammar_morphology_entity.dart';
import 'package:grad_project/features/grammar/domain/repositories/grammar_morphology_repository.dart';

class PerformParsingUseCase {
  final GrammarMorphologyRepository repository;

  PerformParsingUseCase(this.repository);

  Future<List<ParsingResultEntity>> call(String text) {
    return repository.performParsing(text);
  }
}
