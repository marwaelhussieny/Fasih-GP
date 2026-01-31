
// lib/features/grammar/domain/usecases/analyze_meaning_usecase.dart

import 'package:grad_project/features/grammar/domain/repositories/grammar_morphology_repository.dart';

class AnalyzeMeaningUseCase {
  final GrammarMorphologyRepository repository;

  AnalyzeMeaningUseCase(this.repository);

  Future<String> call(String word) {
    return repository.analyzeMeaning(word);
  }
}
