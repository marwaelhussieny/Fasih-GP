// lib/features/grammar/domain/usecases/analyze_poetry_meter_usecase.dart

import 'package:grad_project/features/grammar/domain/entities/grammar_morphology_entity.dart';
import 'package:grad_project/features/grammar/domain/repositories/grammar_morphology_repository.dart';

class AnalyzePoetryMeterUseCase {
  final GrammarMorphologyRepository repository;

  AnalyzePoetryMeterUseCase(this.repository);

  Future<PoetryMeterEntity> call(String poem) {
    return repository.analyzePoetryMeter(poem);
  }
}
