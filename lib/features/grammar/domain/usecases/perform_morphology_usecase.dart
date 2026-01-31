import 'package:grad_project/features/grammar/domain/entities/grammar_morphology_entity.dart';
import 'package:grad_project/features/grammar/domain/repositories/grammar_morphology_repository.dart';

class PerformMorphologyUseCase {
  final GrammarMorphologyRepository repository;

  PerformMorphologyUseCase(this.repository);

  Future<List<MorphologyResultEntity>> call(String text, String form) {
    return repository.performMorphology(text, form);
  }
}