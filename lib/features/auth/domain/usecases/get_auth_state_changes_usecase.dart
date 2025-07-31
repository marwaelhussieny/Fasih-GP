// lib/features/auth/domain/usecases/get_auth_state_changes_usecase.dart

import 'package:firebase_auth/firebase_auth.dart';
import 'package:grad_project/features/auth/domain/repositories/auth_repository.dart';

class GetAuthStateChangesUseCase {
  final AuthRepository repository;

  GetAuthStateChangesUseCase({required this.repository});

  Stream<User?> call() {
    return repository.authStateChanges;
  }
}