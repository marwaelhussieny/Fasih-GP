// lib/features/grammar/domain/usecases/find_synonyms_usecase.dart

import 'package:grad_project/features/grammar/domain/repositories/grammar_morphology_repository.dart';

class FindSynonymsUseCase {
  final GrammarMorphologyRepository repository;

  FindSynonymsUseCase(this.repository);

  Future<List<String>> call(String word) {
    return repository.findSynonyms(word);
  }
}