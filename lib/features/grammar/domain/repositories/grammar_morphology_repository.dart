// lib/features/grammar_morphology/domain/repositories/grammar_morphology_repository.dart

import 'package:grad_project/features/grammar/domain/entities/grammar_morphology_entity.dart';

abstract class GrammarMorphologyRepository {
  Future<List<ParsingResultEntity>> performParsing(String text);
  Future<List<MorphologyResultEntity>> performMorphology(String text, String form);
}
