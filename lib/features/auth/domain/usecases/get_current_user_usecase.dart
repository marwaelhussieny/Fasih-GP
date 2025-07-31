// lib/features/auth/domain/usecases/get_current_user_usecase.dart

import 'package:firebase_auth/firebase_auth.dart';
import 'package:grad_project/features/auth/domain/repositories/auth_repository.dart';

class GetCurrentUserUseCase {
  final AuthRepository repository;

  GetCurrentUserUseCase({required this.repository});

  User? call() {
    return repository.getCurrentUser();
  }
}