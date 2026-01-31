// lib/features/grammar/domain/usecases/check_service_status_usecase.dart

import 'package:grad_project/features/grammar/domain/entities/grammar_morphology_entity.dart';
import 'package:grad_project/features/grammar/domain/repositories/grammar_morphology_repository.dart';

class CheckServiceStatusUseCase {
  final GrammarMorphologyRepository repository;

  CheckServiceStatusUseCase(this.repository);

  Future<E3rblyServiceStatusEntity> call() {
    return repository.checkServiceStatus();
  }
}