// lib/features/auth/domain/usecases/login_usecase.dart

import 'package:firebase_auth/firebase_auth.dart';
import 'package:grad_project/features/auth/domain/repositories/auth_repository.dart';

class LoginUseCase {
  final AuthRepository repository;

  LoginUseCase({required this.repository});

  Future<User?> call({required String email, required String password}) async {
    return await repository.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }
}