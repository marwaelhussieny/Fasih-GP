// lib/features/grammar/domain/usecases/generate_poetry_usecase.dart

import 'package:grad_project/features/grammar/domain/entities/grammar_morphology_entity.dart';
import 'package:grad_project/features/grammar/domain/repositories/grammar_morphology_repository.dart';

class GeneratePoetryUseCase {
  final GrammarMorphologyRepository repository;

  GeneratePoetryUseCase(this.repository);

  Future<PoetryGenerationEntity> call(String theme, String meterType) {
    return repository.generatePoetry(theme, meterType);
  }
}