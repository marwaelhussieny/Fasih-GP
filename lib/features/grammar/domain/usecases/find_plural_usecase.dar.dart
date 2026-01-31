// lib/features/grammar/domain/usecases/find_plural_usecase.dart

import 'package:grad_project/features/grammar/domain/repositories/grammar_morphology_repository.dart';

class FindPluralUseCase {
  final GrammarMorphologyRepository repository;

  FindPluralUseCase(this.repository);

  Future<String> call(String word) {
    return repository.findPlural(word);
  }
}