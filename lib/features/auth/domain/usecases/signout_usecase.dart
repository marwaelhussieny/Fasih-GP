// lib/features/auth/domain/usecases/signout_usecase.dart

import 'package:grad_project/features/auth/domain/repositories/auth_repository.dart';

class SignOutUseCase {
  final AuthRepository repository;

  SignOutUseCase({required this.repository});

  Future<void> call() async {
    await repository.signOut();
  }
}