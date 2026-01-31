// lib/features/auth/domain/repositories/auth_repository.dart - ACCESS TOKEN ONLY

import 'package:grad_project/features/auth/domain/entities/auth_user_entity.dart';
import 'package:grad_project/core/types/auth_tokens.dart';

abstract class AuthRepository {
  // Returns user data after successful signup
  Future<AuthUserEntity> signUp({
    required String fullName,
    required String email,
    required String password,
    required String confirmPassword,
  });

  // OTP verification - returns void (just verifies)
  Future<void> verifyOTP({
    required String email,
    required String otp,
  });

  // Resend OTP - returns void
  Future<void> resendOTP({
    required String email,
  });

  // Returns tokens after successful login (contains access token)
  Future<AuthTokens> login({
    required String email,
    required String password,
  });

  // Forgot password - returns void (just sends email)
  Future<void> forgotPassword({
    required String email,
  });

  // Reset password - returns void
  Future<void> resetPassword({
    required String token,
    required String newPassword,
  });

  // Logout - returns void
  Future<void> logout();

  // Get current user data
  Future<AuthUserEntity?> getCurrentUser();

  // Check if user is logged in
  Future<bool> isLoggedIn();

  // Get stored access token
  Future<String?> getAccessToken();

  // Save access token locally
  Future<void> saveAccessToken(String accessToken, {DateTime? expiry});

  // Clear stored tokens
  Future<void> clearTokens();
}