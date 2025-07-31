// lib/features/grammar_morphology/domain/entities/grammar_morphology_entity.dart

import 'package:equatable/equatable.dart';

// Entity for parsing results (إعراب)
class ParsingResultEntity extends Equatable {
  final String word;
  final String analysis;

  const ParsingResultEntity({
    required this.word,
    required this.analysis,
  });

  @override
  List<Object?> get props => [word, analysis];
}

// Entity for morphology results (صرف)
class MorphologyResultEntity extends Equatable {
  final String pronoun;
  final String conjugatedForm;

  const MorphologyResultEntity({
    required this.pronoun,
    required this.conjugatedForm,
  });

  @override
  List<Object?> get props => [pronoun, conjugatedForm];
}
