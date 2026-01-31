// lib/features/auth/data/datasources/auth_remote_data_source.dart
// ENHANCED IMPLEMENTATION WITH JSON VALIDATION AND BETTER ERROR HANDLING

import 'dart:io';
import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:grad_project/core/navigation/app_routes.dart';
import 'package:grad_project/core/services/api_service.dart';
import 'package:grad_project/core/services/auth_service.dart';
import 'package:grad_project/features/auth/data/models/auth_user_model.dart';
import 'package:grad_project/core/types/auth_tokens.dart';
// import 'package:grad_project/core/utils/quick_json_test.dart';
class ApiException implements Exception {
  final String message;
  final int statusCode;

  ApiException(this.message, {this.statusCode = 0});

  @override
  String toString() => 'ApiException: $message (Status: $statusCode)';
}

abstract class AuthRemoteDataSource {
  Future<AuthUserModel> signUp({
    required String fullName,
    required String email,
    required String password,
    required String confirmPassword,
  });

  Future<void> verifyOTP({
    required String email,
    required String otp,
  });

  Future<void> resendOTP({
    required String email,
  });

  Future<AuthTokens> login({
    required String email,
    required String password,
    // required BuildContext context,
  });

  Future<void> forgotPassword({
    required String email,
  });

  Future<void> resetPassword({
    required String token,
    required String newPassword,
  });

  Future<void> logout();

  Future<AuthUserModel> getCurrentUser();
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final ApiService apiService;
  final AuthService authService;

  AuthRemoteDataSourceImpl({
    required this.apiService,
    required this.authService,
  });

  // Enhanced input validation and sanitization
  Map<String, dynamic> _validateAndSanitizeSignUpData({
    required String fullName,
    required String email,
    required String password,
    required String confirmPassword,
  }) {
    // Clean and validate inputs
    final cleanEmail = email.trim().toLowerCase();
    final cleanFullName = fullName.trim();
    final cleanPassword = password.trim();
    final cleanConfirmPassword = confirmPassword.trim();

    // Validate inputs
    if (cleanEmail.isEmpty) {
      throw ApiException('البريد الإلكتروني مطلوب', statusCode: 400);
    }

    if (cleanFullName.isEmpty) {
      throw ApiException('الاسم الكامل مطلوب', statusCode: 400);
    }

    if (cleanPassword.isEmpty) {
      throw ApiException('كلمة المرور مطلوبة', statusCode: 400);
    }

    if (cleanConfirmPassword.isEmpty) {
      throw ApiException('تأكيد كلمة المرور مطلوب', statusCode: 400);
    }

    // Validate email format
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(cleanEmail)) {
      throw ApiException('صيغة البريد الإلكتروني غير صحيحة', statusCode: 400);
    }

    // Check password match
    if (cleanPassword != cleanConfirmPassword) {
      throw ApiException('كلمات المرور غير متطابقة', statusCode: 400);
    }

    // Check password length
    if (cleanPassword.length < 6) {
      throw ApiException('كلمة المرور يجب أن تكون 6 أحرف على الأقل', statusCode: 400);
    }

    return {
      'fullName': cleanFullName,
      'email': cleanEmail,
      'password': cleanPassword,
      'confirmPassword': cleanConfirmPassword,
    };
  }

  // Enhanced request body validation
  void _validateJsonData(Map<String, dynamic> data, String operation) {
    try {
      // Test JSON encoding to ensure all data is serializable
      final encoded = jsonEncode(data);
      print('🔐 $operation - JSON validation passed: $encoded');

      // Test decoding to ensure roundtrip works
      final decoded = jsonDecode(encoded) as Map<String, dynamic>;

      // Validate all keys are preserved
      if (decoded.keys.length != data.keys.length) {
        throw ApiException('بيانات الطلب غير صالحة: فقدان بعض الحقول', statusCode: 400);
      }

    } catch (e) {
      print('❌ $operation - JSON validation failed: $e');
      throw ApiException('بيانات الطلب غير صالحة', statusCode: 400);
    }
  }

  @override
  Future<AuthUserModel> signUp({
    required String fullName,
    required String email,
    required String password,
    required String confirmPassword,
  }) async {
    try {
      // Validate and sanitize input data
      final requestData = _validateAndSanitizeSignUpData(
        fullName: fullName,
        email: email,
        password: password,
        confirmPassword: confirmPassword,
      );

      // Validate JSON encoding
      _validateJsonData(requestData, 'SignUp');

      print('🔐 SignUp API call: POST /api/auth/signup');
      print('🔍 DEBUG - Request data: ${jsonEncode({
        'fullName': requestData['fullName'],
        'email': requestData['email'],
        'password': '[REDACTED]',
        'confirmPassword': '[REDACTED]',
      })}');

      final response = await apiService.post(
        '/api/auth/signup',
        headers: {
          'Content-Type': 'application/json; charset=utf-8',
          'Accept': 'application/json',
          'ngrok-skip-browser-warning': 'true',
          'User-Agent': 'FlutterApp/1.0',
        },
        body: requestData,
      );

      print('🔐 SignUp response received: ${response.keys.toList()}');

      // Enhanced response validation
      if (response['status'] == 'fail') {
        final errorMessage = response['message'] ?? 'فشل في إنشاء الحساب';
        throw ApiException(errorMessage, statusCode: 400);
      }

      // Validate response structure
      if (!response.containsKey('user') || response['user'] == null) {
        throw ApiException('استجابة غير صالحة من الخادم: بيانات المستخدم مفقودة', statusCode: 400);
      }

      final userData = response['user'];
      if (userData is! Map<String, dynamic>) {
        throw ApiException('استجابة غير صالحة من الخادم: تنسيق بيانات المستخدم غير صحيح', statusCode: 400);
      }

      final user = AuthUserModel.fromJson(userData);
      await authService.saveUserEmail(requestData['email']!);
      await authService.saveUser(user);

      print('🔐 SignUp successful: ${user.fullName} (${user.email})');
      return user;

    } on HttpException catch (e) {
      print('🔐 SignUp HttpException: $e');
      throw ApiException(e.message, statusCode: 500);
    } catch (e) {
      print('🔐 SignUp error: $e');
      if (e is ApiException) rethrow;
      throw ApiException('فشل في إنشاء الحساب: ${e.toString()}', statusCode: 500);
    }
  }

  @override
  Future<void> verifyOTP({
    required String email,
    required String otp,
  }) async {
    try {
      // Enhanced input validation
      final cleanEmail = email.trim().toLowerCase();
      final cleanOTP = otp.trim().replaceAll(RegExp(r'[^0-9]'), '');

      if (cleanEmail.isEmpty) {
        throw ApiException('البريد الإلكتروني مطلوب', statusCode: 400);
      }

      if (cleanOTP.isEmpty) {
        throw ApiException('رمز التحقق مطلوب', statusCode: 400);
      }

      if (cleanOTP.length != 6) {
        throw ApiException('رمز التحقق يجب أن يكون 6 أرقام', statusCode: 400);
      }

      if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(cleanEmail)) {
        throw ApiException('صيغة البريد الإلكتروني غير صحيحة', statusCode: 400);
      }

      final requestData = {
        'email': cleanEmail,
        'otp': cleanOTP,
      };

      // Validate JSON encoding
      _validateJsonData(requestData, 'VerifyOTP');

      print('🔐 VerifyOTP API call: POST /api/auth/verify-otp');
      print('🔍 DEBUG - Email: "$cleanEmail", OTP: "$cleanOTP"');

      final response = await apiService.post(
        '/api/auth/verify-otp',
        headers: {
          'Content-Type': 'application/json; charset=utf-8',
          'Accept': 'application/json',
          'ngrok-skip-browser-warning': 'true',
          'User-Agent': 'FlutterApp/1.0',
        },
        body: requestData,
      );

      print('🔐 VerifyOTP response received: ${response.keys.toList()}');

      if (response['status'] == 'fail') {
        final errorMessage = response['message'] ?? 'فشل في التحقق من الرمز';
        throw ApiException(errorMessage, statusCode: 400);
      }

      // Update user verification status locally
      final user = authService.getUser();
      if (user != null) {
        final updatedUser = AuthUserModel(
          id: user.id,
          fullName: user.fullName,
          email: user.email,
          avatar: user.avatar,
          avatarUrl: user.avatarUrl,
          bio: user.bio,
          isVerified: true,
          role: user.role,
          createdAt: user.createdAt,
          updatedAt: DateTime.now(),
          preferences: user.preferences,
          profile: user.profile,
        );
        await authService.saveUser(updatedUser);
      }

      await authService.clearUserEmail();
      print('🔐 OTP verification successful');

    } on HttpException catch (e) {
      print('🔐 VerifyOTP HttpException: $e');
      throw ApiException(e.message, statusCode: 400);
    } catch (e) {
      print('🔐 VerifyOTP error: $e');
      if (e is ApiException) rethrow;
      throw ApiException('فشل في التحقق من الرمز: ${e.toString()}', statusCode: 500);
    }
  }

  @override
  Future<void> resendOTP({
    required String email,
  }) async {
    try {
      final cleanEmail = email.trim().toLowerCase();

      if (cleanEmail.isEmpty) {
        throw ApiException('البريد الإلكتروني مطلوب', statusCode: 400);
      }

      if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(cleanEmail)) {
        throw ApiException('صيغة البريد الإلكتروني غير صحيحة', statusCode: 400);
      }

      final requestData = {
        'email': cleanEmail,
      };

      // Validate JSON encoding
      _validateJsonData(requestData, 'ResendOTP');

      print('🔐 ResendOTP API call: POST /api/auth/resend-otp');
      print('🔍 DEBUG - Email: "$cleanEmail"');

      final response = await apiService.post(
        '/api/auth/resend-otp',
        headers: {
          'Content-Type': 'application/json; charset=utf-8',
          'Accept': 'application/json',
          'ngrok-skip-browser-warning': 'true',
          'User-Agent': 'FlutterApp/1.0',
        },
        body: requestData,
      );

      print('🔐 ResendOTP response received: ${response.keys.toList()}');

      if (response['status'] == 'fail') {
        final errorMessage = response['message'] ?? 'فشل في إعادة إرسال الرمز';
        throw ApiException(errorMessage, statusCode: 400);
      }

      print('🔐 OTP resent successfully to $cleanEmail');

    } on HttpException catch (e) {
      print('🔐 ResendOTP HttpException: $e');
      throw ApiException(e.message, statusCode: 400);
    } catch (e) {
      print('🔐 ResendOTP error: $e');
      if (e is ApiException) rethrow;
      throw ApiException('فشل في إعادة إرسال الرمز: ${e.toString()}', statusCode: 500);
    }
  }

  @override
  Future<AuthTokens> login({
    // required BuildContext context,
    required String email,
    required String password,
  }) async {
    try {
      // Enhanced input validation
      final cleanEmail = email.trim().toLowerCase();
      final cleanPassword = password.trim();

      if (cleanEmail.isEmpty) {
        throw ApiException('البريد الإلكتروني مطلوب', statusCode: 400);
      }

      if (cleanPassword.isEmpty) {
        throw ApiException('كلمة المرور مطلوبة', statusCode: 400);
      }

      if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(cleanEmail)) {
        throw ApiException('صيغة البريد الإلكتروني غير صحيحة', statusCode: 400);
      }

      final requestData = {
        'email': cleanEmail,
        'password': cleanPassword,
      };

      // Validate JSON encoding
      _validateJsonData(requestData, 'Login');

      print('🔐 Login API call: POST /api/auth/login');
      print('🔍 DEBUG - Email: "$cleanEmail", Password length: ${cleanPassword.length}');

      final response = await apiService.post(
        '/api/auth/login',
        headers: {
          'Content-Type': 'application/json; charset=utf-8',
          'Accept': 'application/json',
          'ngrok-skip-browser-warning': 'true',
          'User-Agent': 'FlutterApp/1.0',
        },
        body: requestData,
      );

      print('🔐 Login response received: ${response.keys.toList()}');

      // Enhanced response validation
      if (response['status'] == 'fail') {
        final errorMessage = response['message'] ?? 'فشل في تسجيل الدخول';
        throw ApiException(errorMessage, statusCode: 400);
      }

      if (!response.containsKey('accessToken') || response['accessToken'] == null) {
        print('❌ Missing accessToken in response: $response');
        throw ApiException('استجابة غير صالحة من الخادم: رمز الوصول مفقود', statusCode: 401);
      }

      // Enhanced token creation with validation
      final tokens = AuthTokens.fromApiResponse(response);

      if (!tokens.isValid) {
        throw ApiException('رمز الوصول غير صالح', statusCode: 401);
      }

      // Save tokens with enhanced error handling
      await authService.saveAccessToken(
        accessToken: tokens.accessToken,
        expiry: tokens.expiry,
      );

      // Set token in API service
      apiService.setAuthToken(tokens.accessToken);

      // Save login email for user data retrieval
      await authService.saveUserEmail(cleanEmail);

      print('🔐 Login successful - tokens saved');
      // if (BuildContext.mounted) {
      //   Navigator.of(context).pushReplacementNamed(AppRoutes.home);
      // }
      return tokens;

    } on HttpException catch (e) {
      print('🔐 Login HttpException: $e');
      throw ApiException(e.message, statusCode: 400);
    } catch (e) {
      print('🔐 Login error: $e');
      if (e is ApiException) rethrow;

      // Handle specific error types
      if (e.toString().contains('SocketException') ||
          e.toString().contains('Connection refused') ||
          e.toString().contains('Failed host lookup')) {
        throw ApiException('لا يوجد اتصال بالإنترنت. يرجى فحص الاتصال والمحاولة مرة أخرى', statusCode: 0);
      }

      if (e.toString().contains('TimeoutException') || e.toString().contains('timeout')) {
        throw ApiException('انتهت مهلة الاتصال. يرجى المحاولة مرة أخرى', statusCode: 408);
      }

      throw ApiException('فشل في تسجيل الدخول: ${e.toString()}', statusCode: 500);
    }
  }

  @override
  Future<void> forgotPassword({
    required String email,
  }) async {
    try {
      final cleanEmail = email.trim().toLowerCase();

      if (cleanEmail.isEmpty) {
        throw ApiException('البريد الإلكتروني مطلوب', statusCode: 400);
      }

      if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(cleanEmail)) {
        throw ApiException('صيغة البريد الإلكتروني غير صحيحة', statusCode: 400);
      }

      final requestData = {
        'email': cleanEmail,
      };

      // Validate JSON encoding
      _validateJsonData(requestData, 'ForgotPassword');

      print('🔐 ForgotPassword API call: POST /api/auth/forgot-password');
      print('🔍 DEBUG - Email: "$cleanEmail"');

      final response = await apiService.post(
        '/api/auth/forgot-password',
        headers: {
          'Content-Type': 'application/json; charset=utf-8',
          'Accept': 'application/json',
          'ngrok-skip-browser-warning': 'true',
          'User-Agent': 'FlutterApp/1.0',
        },
        body: requestData,
      );

      print('🔐 ForgotPassword response received');

      if (response['status'] == 'fail') {
        final errorMessage = response['message'] ?? 'فشل في إرسال رابط إعادة التعيين';
        throw ApiException(errorMessage, statusCode: 400);
      }

      print('🔐 Password reset email sent to $cleanEmail');

    } on HttpException catch (e) {
      print('🔐 ForgotPassword HttpException: $e');
      throw ApiException(e.message, statusCode: 400);
    } catch (e) {
      print('🔐 ForgotPassword error: $e');
      if (e is ApiException) rethrow;
      throw ApiException('فشل في إرسال رابط إعادة التعيين: ${e.toString()}', statusCode: 500);
    }
  }

  @override
  Future<void> resetPassword({
    required String token,
    required String newPassword,
  }) async {
    try {
      final cleanToken = token.trim();
      final cleanNewPassword = newPassword.trim();

      if (cleanToken.isEmpty) {
        throw ApiException('رمز إعادة التعيين مطلوب', statusCode: 400);
      }

      if (cleanNewPassword.isEmpty) {
        throw ApiException('كلمة المرور الجديدة مطلوبة', statusCode: 400);
      }

      if (cleanNewPassword.length < 6) {
        throw ApiException('كلمة المرور يجب أن تكون 6 أحرف على الأقل', statusCode: 400);
      }

      final requestData = {
        'token': cleanToken,
        'password': cleanNewPassword,
      };

      // Validate JSON encoding
      _validateJsonData(requestData, 'ResetPassword');

      print('🔐 ResetPassword API call: POST /api/auth/reset-password');
      print('🔍 DEBUG - Token length: ${cleanToken.length}');

      final response = await apiService.post(
        '/api/auth/reset-password',
        headers: {
          'Content-Type': 'application/json; charset=utf-8',
          'Accept': 'application/json',
          'ngrok-skip-browser-warning': 'true',
          'User-Agent': 'FlutterApp/1.0',
        },
        body: requestData,
      );

      print('🔐 ResetPassword response received');

      if (response['status'] == 'fail') {
        final errorMessage = response['message'] ?? 'فشل في إعادة تعيين كلمة المرور';
        throw ApiException(errorMessage, statusCode: 400);
      }

      print('🔐 Password reset successful');

    } on HttpException catch (e) {
      print('🔐 ResetPassword HttpException: $e');
      throw ApiException(e.message, statusCode: 400);
    } catch (e) {
      print('🔐 ResetPassword error: $e');
      if (e is ApiException) rethrow;
      throw ApiException('فشل في إعادة تعيين كلمة المرور: ${e.toString()}', statusCode: 500);
    }
  }

  @override
  Future<void> logout() async {
    try {
      print('🔐 Logout API call: POST /api/auth/logout');

      // Try to call logout API but don't fail if it doesn't work
      try {
        await apiService.post(
          '/api/auth/logout',
          headers: {
            'Content-Type': 'application/json; charset=utf-8',
            'Accept': 'application/json',
            'ngrok-skip-browser-warning': 'true',
            'User-Agent': 'FlutterApp/1.0',
          },
        );
        print('🔐 Logout API call successful');
      } catch (apiError) {
        print('🔐 Logout API call failed: $apiError (continuing with local cleanup)');
      }

    } catch (e) {
      print('🔐 Logout error: $e (continuing with local cleanup)');
    } finally {
      // Always clear local data regardless of API call result
      await authService.clearAll();
      apiService.clearToken();
      print('🔐 Local auth data cleared');
    }
  }

  @override
  Future<AuthUserModel> getCurrentUser() async {
    try {
      print('🔐 GetCurrentUser: Attempting to get user data');

      final loginEmail = authService.getUserEmail();
      final savedUser = authService.getUser();

      // First, try to use saved user data if it matches login email
      if (savedUser != null && loginEmail != null &&
          savedUser.email.toLowerCase() == loginEmail.toLowerCase()) {
        print('🔐 GetCurrentUser: Using saved user data - ${savedUser.email}');
        return savedUser;
      }

      // If we have a valid token, try to fetch from API
      if (authService.hasValidToken()) {
        try {
          final response = await apiService.get(
            '/api/auth/login',
            headers: {
              'Accept': 'application/json',
              'ngrok-skip-browser-warning': 'true',
              'User-Agent': 'FlutterApp/1.0',
            },
          );

          print('🔐 GetCurrentUser: API response keys: ${response.keys.toList()}');

          // Enhanced response validation
          if (response.containsKey('user') && response['user'] != null) {
            final userData = response['user'];
            if (userData is Map<String, dynamic>) {
              final user = AuthUserModel.fromJson(userData);
              await authService.saveUser(user);
              await authService.clearUserEmail();
              print('🔐 GetCurrentUser: User data fetched from API - ${user.email}');
              return user;
            }
          } else if (response.containsKey('data') && response['data'] != null) {
            final userData = response['data'];
            if (userData is Map<String, dynamic>) {
              final user = AuthUserModel.fromJson(userData);
              await authService.saveUser(user);
              await authService.clearUserEmail();
              print('🔐 GetCurrentUser: User data fetched from API - ${user.email}');
              return user;
            }
          }
        } catch (apiError) {
          print('🔐 GetCurrentUser API call failed: $apiError');
        }

        // If API fails but we have login email, create minimal user
        if (loginEmail != null && loginEmail.isNotEmpty) {
          print('🔐 GetCurrentUser: Creating minimal user from login email');

          final minimalUser = AuthUserModel(
            id: 'user_${DateTime.now().millisecondsSinceEpoch}',
            fullName: loginEmail.split('@')[0],
            email: loginEmail,
            isVerified: true,
            role: 'learner',
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
            preferences: const AuthPreferencesModel(
              accessibility: AuthAccessibilityModel(
                hearingQuestions: false,
                readingQuestions: true,
                writingQuestions: true,
                speakingQuestions: true,
                soundEffects: false,
                hapticFeedback: false,
              ),
              language: 'arabic',
              darkMode: false,
              notificationsEnabled: true,
              rememberMe: false,
            ),
            profile: const AuthProfileModel(),
          );

          await authService.saveUser(minimalUser);
          await authService.clearUserEmail();
          print('🔐 GetCurrentUser: Minimal user created - ${minimalUser.email}');
          return minimalUser;
        }
      }

      // If we still have saved user, use it as fallback
      if (savedUser != null) {
        print('🔐 GetCurrentUser: Using existing saved user data - ${savedUser.email}');
        return savedUser;
      }

      throw ApiException('لا توجد بيانات مستخدم صالحة', statusCode: 401);

    } catch (e) {
      print('🔐 GetCurrentUser error: $e');
      if (e is ApiException) rethrow;
      throw ApiException('فشل في جلب بيانات المستخدم: ${e.toString()}', statusCode: 500);
    }
  }
}