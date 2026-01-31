// lib/features/auth/domain/usecases/auth_usecases.dart - UPDATED

import 'package:grad_project/features/auth/domain/entities/auth_user_entity.dart';
import 'package:grad_project/features/auth/domain/repositories/auth_repository.dart';
import 'package:grad_project/core/types/auth_tokens.dart';

class SignUpUseCase {
  final AuthRepository repository;

  SignUpUseCase({required this.repository});

  Future<AuthUserEntity> call({
    required String fullName,
    required String email,
    required String password,
    required String confirmPassword,
  }) async {
    return await repository.signUp(
      fullName: fullName,
      email: email,
      password: password,
      confirmPassword: confirmPassword,
    );
  }
}

class VerifyOTPUseCase {
  final AuthRepository repository;

  VerifyOTPUseCase({required this.repository});

  Future<void> call({
    required String email,
    required String otp,
  }) async {
    await repository.verifyOTP(
      email: email,
      otp: otp,
    );
  }
}

class ResendOTPUseCase {
  final AuthRepository repository;

  ResendOTPUseCase({required this.repository});

  Future<void> call({required String email}) async {
    await repository.resendOTP(email: email);
  }
}

class LoginUseCase {
  final AuthRepository repository;

  LoginUseCase({required this.repository});

  Future<AuthTokens> call({
    required String email,
    required String password,
  }) async {
    return await repository.login(
      email: email,
      password: password,
    );
  }
}

class ForgotPasswordUseCase {
  final AuthRepository repository;

  ForgotPasswordUseCase({required this.repository});

  Future<void> call({required String email}) async {
    await repository.forgotPassword(email: email);
  }
}

class ResetPasswordUseCase {
  final AuthRepository repository;

  ResetPasswordUseCase({required this.repository});

  Future<void> call({
    required String token,
    required String newPassword,
  }) async {
    await repository.resetPassword(
      token: token,
      newPassword: newPassword,
    );
  }
}

class LogoutUseCase {
  final AuthRepository repository;

  LogoutUseCase({required this.repository});

  Future<void> call() async {
    await repository.logout();
  }
}

class GetCurrentUserUseCase {
  final AuthRepository repository;

  GetCurrentUserUseCase({required this.repository});

  Future<AuthUserEntity?> call() async {
    return await repository.getCurrentUser();
  }
}

class IsLoggedInUseCase {
  final AuthRepository repository;

  IsLoggedInUseCase({required this.repository});

  Future<bool> call() async {
    return await repository.isLoggedIn();
  }
}