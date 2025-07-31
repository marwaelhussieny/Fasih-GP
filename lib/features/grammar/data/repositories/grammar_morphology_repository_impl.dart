// lib/features/grammar_morphology/data/repositories/grammar_morphology_repository_impl.dart

import 'package:grad_project/features/grammar/data/datasources/grammar_morphology_remote_data_source.dart';
import 'package:grad_project/features/grammar/domain/entities/grammar_morphology_entity.dart';
import 'package:grad_project/features/grammar/domain/repositories/grammar_morphology_repository.dart';

class GrammarMorphologyRepositoryImpl implements GrammarMorphologyRepository {
  final GrammarMorphologyRemoteDataSource remoteDataSource;

  GrammarMorphologyRepositoryImpl(this.remoteDataSource);

  @override
  Future<List<ParsingResultEntity>> performParsing(String text) {
    return remoteDataSource.performParsing(text);
  }

  @override
  Future<List<MorphologyResultEntity>> performMorphology(String text, String form) {
    return remoteDataSource.performMorphology(text, form);
  }
}
