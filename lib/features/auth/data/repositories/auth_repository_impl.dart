
// lib/features/auth/data/repositories/auth_repository_impl.dart - FIXED ERROR CHAIN

import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:grad_project/features/auth/domain/entities/auth_user_entity.dart';
import 'package:grad_project/features/auth/domain/repositories/auth_repository.dart';
import 'package:grad_project/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:grad_project/features/auth/data/models/auth_user_model.dart';
import 'package:grad_project/core/services/auth_service.dart';
import 'package:grad_project/core/types/auth_tokens.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;
  final AuthService authService;

  AuthRepositoryImpl({
    required this.remoteDataSource,
    required this.authService,
  });

  @override
  Future<AuthUserEntity> signUp({
    required String fullName,
    required String email,
    required String password,
    required String confirmPassword,
  }) async {
    try {
      final user = await remoteDataSource.signUp(
        fullName: fullName,
        email: email,
        password: password,
        confirmPassword: confirmPassword,
      );

      return user.toEntity();
    } on ApiException catch (e) {
      throw Exception(_handleApiException(e));
    } on SocketException {
      throw Exception('لا يوجد اتصال بالإنترنت');
    } catch (e) {
      throw Exception('فشل في إنشاء الحساب: ${e.toString()}');
    }
  }

  @override
  Future<void> verifyOTP({
    required String email,
    required String otp,
  }) async {
    try {
      await remoteDataSource.verifyOTP(email: email, otp: otp);
    } on ApiException catch (e) {
      throw Exception(_handleApiException(e));
    } on SocketException {
      throw Exception('لا يوجد اتصال بالإنترنت');
    } catch (e) {
      throw Exception('فشل في التحقق من الرمز: ${e.toString()}');
    }
  }

  @override
  Future<void> resendOTP({required String email}) async {
    try {
      await remoteDataSource.resendOTP(email: email);
    } on ApiException catch (e) {
      throw Exception(_handleApiException(e));
    } on SocketException {
      throw Exception('لا يوجد اتصال بالإنترنت');
    } catch (e) {
      throw Exception('فشل في إعادة إرسال الرمز: ${e.toString()}');
    }
  }

  @override
  Future<AuthTokens> login({
    required String email,
    required String password,
  }) async {
    try {
      final tokens = await remoteDataSource.login(email: email, password: password);

      try {
        final user = await remoteDataSource.getCurrentUser();
        await authService.saveAuthSession(
          accessToken: tokens.accessToken,
          user: user,
          expiry: tokens.expiry,
        );
      } catch (e) {
        print('Failed to get user info after login: $e');
        await authService.saveAccessToken(
          accessToken: tokens.accessToken,
          expiry: tokens.expiry,
        );
      }

      return tokens;
    } on ApiException catch (e) {
      // CRITICAL FIX: Don't wrap the error message, pass it through directly
      throw Exception(e.message);
    } on SocketException {
      throw Exception('لا يوجد اتصال بالإنترنت');
    } catch (e) {
      throw Exception('فشل في تسجيل الدخول: ${e.toString()}');
    }
  }

  @override
  Future<void> forgotPassword({required String email}) async {
    try {
      await remoteDataSource.forgotPassword(email: email);
    } on ApiException catch (e) {
      throw Exception(_handleApiException(e));
    } on SocketException {
      throw Exception('لا يوجد اتصال بالإنترنت');
    } catch (e) {
      throw Exception('فشل في إرسال بريد إعادة التعيين: ${e.toString()}');
    }
  }

  @override
  Future<void> resetPassword({
    required String token,
    required String newPassword,
  }) async {
    try {
      await remoteDataSource.resetPassword(token: token, newPassword: newPassword);
    } on ApiException catch (e) {
      throw Exception(_handleApiException(e));
    } on SocketException {
      throw Exception('لا يوجد اتصال بالإنترنت');
    } catch (e) {
      throw Exception('فشل في إعادة تعيين كلمة المرور: ${e.toString()}');
    }
  }

  @override
  Future<void> logout() async {
    try {
      await remoteDataSource.logout();
    } catch (e) {
      print('Remote logout failed: $e');
    }
  }

  @override
  Future<AuthUserEntity?> getCurrentUser() async {
    try {
      final localUser = authService.getUser();
      if (localUser != null && authService.hasValidToken()) {
        return localUser.toEntity();
      }

      if (await isLoggedIn()) {
        try {
          final remoteUser = await remoteDataSource.getCurrentUser();
          return remoteUser.toEntity();
        } catch (e) {
          print('Failed to get remote user, clearing session: $e');
          await logout();
          return null;
        }
      }

      return null;
    } catch (e) {
      print('getCurrentUser error: $e');
      return null;
    }
  }

  @override
  Future<bool> isLoggedIn() async {
    try {
      return authService.isLoggedIn();
    } catch (e) {
      print('isLoggedIn error: $e');
      return false;
    }
  }

  @override
  Future<String?> getAccessToken() async {
    try {
      return authService.getAccessToken();
    } catch (e) {
      print('getAccessToken error: $e');
      return null;
    }
  }

  @override
  Future<void> saveAccessToken(String accessToken, {DateTime? expiry}) async {
    try {
      await authService.saveAccessToken(accessToken: accessToken, expiry: expiry);
    } catch (e) {
      print('saveAccessToken error: $e');
      rethrow;
    }
  }

  @override
  Future<void> clearTokens() async {
    try {
      await authService.clearAll();
    } catch (e) {
      print('clearTokens error: $e');
      rethrow;
    }
  }

  String _handleApiException(ApiException e) {
    // For login errors, pass through the exact message from backend
    if (e.message.contains('البريد الإلكتروني أو كلمة المرور غير صحيحة')) {
      return e.message;
    }

    switch (e.statusCode) {
      case 400:
        if (e.message.contains('OTP') || e.message.contains('غير صالح')) {
          return e.message;
        }
        return 'بيانات غير صحيحة';
      case 401:
        return 'البريد الإلكتروني أو كلمة المرور غير صحيحة';
      case 403:
        return 'غير مسموح لك بالوصول';
      case 404:
        return 'المستخدم غير موجود';
      case 422:
        return e.message.isNotEmpty ? e.message : 'خطأ في التحقق من البيانات';
      case 429:
        return 'تم تجاوز عدد المحاولات المسموحة';
      case 500:
        return 'خطأ في الخادم، يرجى المحاولة لاحقاً';
      default:
        return e.message.isNotEmpty ? e.message : 'حدث خطأ غير متوقع';
    }
  }
}