// lib/features/auth/presentation/providers/auth_provider.dart

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:grad_project/features/auth/domain/usecases/login_usecase.dart';
import 'package:grad_project/features/auth/domain/usecases/signup_usecase.dart';
import 'package:grad_project/features/auth/domain/usecases/forgot_password_usecase.dart';
import 'package:grad_project/features/auth/domain/usecases/signout_usecase.dart';
import 'package:grad_project/features/auth/domain/usecases/get_auth_state_changes_usecase.dart';
import 'package:grad_project/features/auth/domain/usecases/get_current_user_usecase.dart';

class AuthProvider with ChangeNotifier {
  final LoginUseCase _loginUseCase;
  final SignUpUseCase _signUpUseCase;
  final ForgotPasswordUseCase _forgotPasswordUseCase;
  final SignOutUseCase _signOutUseCase;
  final GetAuthStateChangesUseCase _getAuthStateChangesUseCase;
  final GetCurrentUserUseCase _getCurrentUserUseCase;

  User? _user;
  bool _isLoading = false;
  String? _error; // Stores the last error message

  User? get user => _user;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated => _user != null;

  AuthProvider({
    required LoginUseCase loginUseCase,
    required SignUpUseCase signUpUseCase,
    required ForgotPasswordUseCase forgotPasswordUseCase,
    required SignOutUseCase signOutUseCase,
    required GetAuthStateChangesUseCase getAuthStateChangesUseCase,
    required GetCurrentUserUseCase getCurrentUserUseCase,
  })  : _loginUseCase = loginUseCase,
        _signUpUseCase = signUpUseCase,
        _forgotPasswordUseCase = forgotPasswordUseCase,
        _signOutUseCase = signOutUseCase,
        _getAuthStateChangesUseCase = getAuthStateChangesUseCase,
        _getCurrentUserUseCase = getCurrentUserUseCase {
    _getAuthStateChangesUseCase().listen((firebaseUser) {
      _user = firebaseUser;
      notifyListeners();
    });
    _user = _getCurrentUserUseCase();
  }

  Future<void> login(String email, String password) async {
    _setLoading(true);
    _clearError();
    try {
      _user = await _loginUseCase(email: email, password: password);
    } on FirebaseAuthException catch (e) {
      _setError(_getFirebaseAuthErrorMessage(e.code));
    } catch (e) {
      _setError('حدث خطأ غير متوقع: ${e.toString()}'); // Unexpected error
    } finally {
      _setLoading(false);
    }
  }

  Future<void> signUp(String email, String password) async {
    _setLoading(true);
    _clearError();
    try {
      _user = await _signUpUseCase(email: email, password: password);
    } on FirebaseAuthException catch (e) {
      _setError(_getFirebaseAuthErrorMessage(e.code));
    } catch (e) {
      _setError('حدث خطأ غير متوقع: ${e.toString()}'); // Unexpected error
    } finally {
      _setLoading(false);
    }
  }

  // UPDATED: sendPasswordResetEmail method
  Future<void> sendPasswordResetEmail(String email) async {
    _setLoading(true);
    _clearError();
    try {
      // Firebase does NOT throw an error for unregistered emails for security reasons.
      // It will just silently not send an email.
      // We will always show a success message to the user to prevent email enumeration.
      await _forgotPasswordUseCase(email: email);
      // No explicit success message set here, as the UI will show a generic one.
      // If Firebase *did* throw an error (e.g., invalid email format, network issue),
      // it would be caught below.
    } on FirebaseAuthException catch (e) {
      // Catch specific Firebase Auth errors that *do* get thrown (e.g., invalid-email format)
      _setError(_getFirebaseAuthErrorMessage(e.code));
    } catch (e) {
      // Catch any other unexpected errors (e.g., network issues)
      _setError('حدث خطأ أثناء إرسال رابط إعادة التعيين. يرجى المحاولة مرة أخرى.'); // Generic error for unexpected issues
    } finally {
      _setLoading(false);
    }
  }

  Future<void> signOut() async {
    _setLoading(true);
    _clearError();
    try {
      await _signOutUseCase();
      _user = null;
    } on FirebaseAuthException catch (e) {
      _setError(_getFirebaseAuthErrorMessage(e.code));
    } catch (e) {
      _setError('حدث خطأ غير متوقع أثناء تسجيل الخروج: ${e.toString()}'); // Unexpected error
    } finally {
      _setLoading(false);
    }
  }

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

  String _getFirebaseAuthErrorMessage(String errorCode) {
    switch (errorCode) {
      case 'user-not-found':
        return 'لا يوجد مستخدم بهذا البريد الإلكتروني.';
      case 'wrong-password':
        return 'كلمة المرور خاطئة.';
      case 'email-already-in-use':
        return 'هذا البريد الإلكتروني مستخدم بالفعل.';
      case 'invalid-email':
        return 'صيغة البريد الإلكتروني غير صحيحة.';
      case 'weak-password':
        return 'كلمة المرور ضعيفة جداً.';
      case 'operation-not-allowed':
        return 'تم تعطيل تسجيل الدخول بالبريد الإلكتروني/كلمة المرور.';
      case 'too-many-requests':
        return 'تم حظر الوصول مؤقتًا بسبب كثرة المحاولات الفاشلة. حاول لاحقًا.';
      default:
        return 'حدث خطأ غير معروف. يرجى المحاولة مرة أخرى.';
    }
  }
}