// lib/features/grammar/domain/usecases/find_antonyms_usecase.dart

import 'package:grad_project/features/grammar/domain/repositories/grammar_morphology_repository.dart';

class FindAntonymsUseCase {
  final GrammarMorphologyRepository repository;

  FindAntonymsUseCase(this.repository);

  Future<List<String>> call(String word) {
    return repository.findAntonyms(word);
  }
}