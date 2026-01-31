// lib/features/auth/presentation/providers/auth_provider.dart - FIXED ERROR HANDLING

import 'package:flutter/material.dart';
import 'package:grad_project/features/auth/domain/entities/auth_user_entity.dart';
import 'package:grad_project/features/auth/domain/usecases/auth_usecases.dart';
import 'package:grad_project/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:grad_project/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:grad_project/core/services/api_service.dart';
import 'package:grad_project/core/services/auth_service.dart';
import 'package:http/http.dart' as http;

class AuthProvider with ChangeNotifier {
  // Use cases
  late final SignUpUseCase _signUpUseCase;
  late final VerifyOTPUseCase _verifyOTPUseCase;
  late final ResendOTPUseCase _resendOTPUseCase;
  late final LoginUseCase _loginUseCase;
  late final ForgotPasswordUseCase _forgotPasswordUseCase;
  late final ResetPasswordUseCase _resetPasswordUseCase;
  late final LogoutUseCase _logoutUseCase;
  late final GetCurrentUserUseCase _getCurrentUserUseCase;
  late final IsLoggedInUseCase _isLoggedInUseCase;

  // Services
  late final ApiService _apiService;
  late final AuthService _authService;
  bool _isInitialized = false;

  // State
  AuthUserEntity? _user;
  bool _isLoading = false;
  String? _error;

  // Getters
  AuthUserEntity? get user => _user;
  AuthUserEntity? get currentUser => _user;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated => _user != null;
  bool get isInitialized => _isInitialized;

  AuthProvider() {
    _initializeServices();
  }

  Future<void> _initializeServices() async {
    try {
      print('🔐 AuthProvider: Starting initialization...');

      // Create API service
      _apiService = ApiServiceImpl(
        baseUrl: 'https://f35f3ddf1acd.ngrok-free.app', // Your ngrok URL
        httpClient: http.Client(),
      );

      // Create auth service
      _authService = await AuthService.getInstance();

      // Create data source
      final authRemoteDataSource = AuthRemoteDataSourceImpl(
        apiService: _apiService,
        authService: _authService,
      );

      // Create repository
      final authRepository = AuthRepositoryImpl(
        remoteDataSource: authRemoteDataSource,
        authService: _authService,
      );

      // Create use cases
      _signUpUseCase = SignUpUseCase(repository: authRepository);
      _verifyOTPUseCase = VerifyOTPUseCase(repository: authRepository);
      _resendOTPUseCase = ResendOTPUseCase(repository: authRepository);
      _loginUseCase = LoginUseCase(repository: authRepository);
      _forgotPasswordUseCase = ForgotPasswordUseCase(repository: authRepository);
      _resetPasswordUseCase = ResetPasswordUseCase(repository: authRepository);
      _logoutUseCase = LogoutUseCase(repository: authRepository);
      _getCurrentUserUseCase = GetCurrentUserUseCase(repository: authRepository);
      _isLoggedInUseCase = IsLoggedInUseCase(repository: authRepository);

      // Initialize authentication state
      await _initializeAuthState();

      _isInitialized = true;
      print('🔐 AuthProvider: Initialization complete');
    } catch (e) {
      print('🔐 AuthProvider: Initialization failed: $e');
      _setError('فشل في تهيئة خدمة المصادقة');
    }
  }

  Future<void> _initializeAuthState() async {
    print('🔐 AuthProvider: Checking auth state...');
    _setLoading(true);

    try {
      final isLoggedIn = await _isLoggedInUseCase();
      print('🔐 AuthProvider: Is logged in: $isLoggedIn');

      if (isLoggedIn) {
        try {
          _user = await _getCurrentUserUseCase();
          if (_user != null) {
            final token = await _authService.getAccessToken();
            if (token != null) {
              _apiService.setAuthToken(token);
            }
            print('🔐 AuthProvider: User loaded: ${_user!.email}');
          }
        } catch (e) {
          print('🔐 AuthProvider: Failed to get current user: $e');
          await _authService.clearAll();
          _user = null;
        }
      }

      _clearError();
    } catch (e) {
      print('🔐 AuthProvider: Auth state check failed: $e');
      _user = null;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> initialize() async {
    if (!_isInitialized) {
      await _initializeServices();
    }
  }

  // Sign up
  Future<void> signUp({
    required String fullName,
    required String email,
    required String password,
    required String confirmPassword,
  }) async {
    print('🔐 AuthProvider: Starting signup for: $email');
    _setLoading(true);
    _clearError();

    try {
      _user = await _signUpUseCase(
        fullName: fullName,
        email: email,
        password: password,
        confirmPassword: confirmPassword,
      );
      print('🔐 AuthProvider: Signup successful: ${_user!.email}');
      _clearError();
    } catch (e) {
      print('🔐 AuthProvider: Signup failed: $e');
      _setError(_extractErrorMessage(e));
      _user = null;
    } finally {
      _setLoading(false);
    }
  }

  // Verify OTP
  Future<bool> verifyOTP({
    required String email,
    required String otp,
  }) async {
    print('🔐 AuthProvider: Verifying OTP for: $email');
    _setLoading(true);
    _clearError();

    try {
      await _verifyOTPUseCase(email: email, otp: otp);

      if (_user != null && _user!.email.toLowerCase() == email.toLowerCase()) {
        _user = _user!.copyWith(isVerified: true);
      }

      print('🔐 AuthProvider: OTP verification successful');
      _clearError();
      return true;
    } catch (e) {
      print('🔐 AuthProvider: OTP verification failed: $e');
      _setError(_extractErrorMessage(e));
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Resend OTP
  Future<bool> resendOTP({required String email}) async {
    print('🔐 AuthProvider: Resending OTP for: $email');
    _setLoading(true);
    _clearError();

    try {
      await _resendOTPUseCase(email: email);
      print('🔐 AuthProvider: OTP resend successful');
      _clearError();
      return true;
    } catch (e) {
      print('🔐 AuthProvider: OTP resend failed: $e');
      _setError(_extractErrorMessage(e));
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Login - FIXED ERROR HANDLING
  Future<void> login({
    required String email,
    required String password,
  }) async {
    print('🔐 AuthProvider: Starting login for: $email');
    _setLoading(true);
    _clearError();

    try {
      // Call login API
      await _loginUseCase(
        email: email,
        password: password,
      );

      // Get user data with retry mechanism
      AuthUserEntity? userData;
      int retries = 3;

      while (retries > 0 && userData == null) {
        try {
          userData = await _getCurrentUserUseCase();
          if (userData != null) {
            if (userData.email.toLowerCase() == email.toLowerCase()) {
              print('🔐 AuthProvider: Login successful - got correct user data');
              break;
            } else {
              print('🔐 AuthProvider: Got wrong user data, retrying...');
              userData = null;
            }
          }
        } catch (e) {
          print('🔐 AuthProvider: Get user retry failed: $e');
        }

        retries--;
        if (retries > 0) {
          await Future.delayed(const Duration(milliseconds: 500));
        }
      }

      if (userData != null) {
        _user = userData;
        print('🔐 AuthProvider: Login complete - ${_user!.email}');
      } else {
        throw Exception('فشل في تحميل بيانات المستخدم بعد تسجيل الدخول');
      }

      _clearError();
    } catch (e) {
      print('🔐 AuthProvider: Login failed: $e');
      // CRITICAL FIX: Don't process error message, use it directly
      _setError(_extractErrorMessage(e));
      _user = null;
    } finally {
      _setLoading(false);
    }
  }

  // Send password reset email
  Future<void> sendPasswordResetEmail(String email) async {
    print('🔐 AuthProvider: Sending password reset email to: $email');
    _setLoading(true);
    _clearError();

    try {
      await _forgotPasswordUseCase(email: email);
      print('🔐 AuthProvider: Password reset email sent successfully');
      _clearError();
    } catch (e) {
      print('🔐 AuthProvider: Password reset failed: $e');
      _setError(_extractErrorMessage(e));
    } finally {
      _setLoading(false);
    }
  }

  // Reset password
  Future<void> resetPassword({
    required String token,
    required String newPassword,
  }) async {
    print('🔐 AuthProvider: Resetting password');
    _setLoading(true);
    _clearError();

    try {
      await _resetPasswordUseCase(
        token: token,
        newPassword: newPassword,
      );
      print('🔐 AuthProvider: Password reset successful');
      _clearError();
    } catch (e) {
      print('🔐 AuthProvider: Password reset failed: $e');
      _setError(_extractErrorMessage(e));
    } finally {
      _setLoading(false);
    }
  }

  // Sign out
  Future<void> signOut() async {
    print('🔐 AuthProvider: Starting sign out');
    _setLoading(true);
    _clearError();

    try {
      await _logoutUseCase();
      _user = null;
      print('🔐 AuthProvider: Sign out successful');
      _clearError();
    } catch (e) {
      print('🔐 AuthProvider: Sign out failed: $e');
      _setError(_extractErrorMessage(e));
      _user = null;
    } finally {
      _setLoading(false);
    }
  }

  // Refresh auth state
  Future<void> refreshAuthState() async {
    if (!_isInitialized) return;

    try {
      final isLoggedIn = await _isLoggedInUseCase();
      if (isLoggedIn) {
        final userData = await _getCurrentUserUseCase();
        if (userData != null) {
          _user = userData;
          print('🔐 AuthProvider: Auth state refreshed: ${_user!.email}');
        } else {
          _user = null;
        }
      } else {
        _user = null;
      }
      notifyListeners();
    } catch (e) {
      print('🔐 AuthProvider: Failed to refresh auth state: $e');
    }
  }

  // Helper methods
  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setError(String message) {
    _error = message;
    notifyListeners();
  }

  void _clearError() {
    _error = null;
    notifyListeners();
  }

  // CRITICAL FIX: Simplified error extraction that preserves backend messages
  String _extractErrorMessage(dynamic error) {
    String message = error.toString();

    // Remove "Exception: " prefix if present
    if (message.startsWith('Exception: ')) {
      message = message.substring(11);
    }

    // If the message is already in Arabic from backend, use it directly
    if (message.contains('البريد الإلكتروني أو كلمة المرور غير صحيحة')) {
      return message;
    }

    if (message.contains('OTP غير صالح') || message.contains('OTP invalid')) {
      return message;
    }

    // Other common patterns
    if (message.contains('لا يوجد اتصال') || message.contains('No internet')) {
      return 'لا يوجد اتصال بالإنترنت. يرجى فحص الاتصال والمحاولة مرة أخرى';
    }

    if (message.contains('الخادم غير متاح') || message.contains('Server unavailable')) {
      return 'الخادم غير متاح حالياً. يرجى المحاولة لاحقاً';
    }

    return message.isNotEmpty ? message : 'حدث خطأ غير متوقع';
  }
}