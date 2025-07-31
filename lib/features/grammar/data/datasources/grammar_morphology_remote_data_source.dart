// lib/features/grammar_morphology/data/datasources/grammar_morphology_remote_data_source.dart

import 'package:grad_project/features/grammar/domain/entities/grammar_morphology_entity.dart';

abstract class GrammarMorphologyRemoteDataSource {
  Future<List<ParsingResultEntity>> performParsing(String text);
  Future<List<MorphologyResultEntity>> performMorphology(String text, String form);
}
