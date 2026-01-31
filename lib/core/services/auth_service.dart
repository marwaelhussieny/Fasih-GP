// lib/core/services/auth_service.dart - ACCESS TOKEN ONLY (FINAL)

import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:grad_project/features/auth/data/models/auth_user_model.dart';

class AuthService {
  static const String _accessTokenKey = 'access_token';
  static const String _userDataKey = 'user_data';
  static const String _tokenExpiryKey = 'token_expiry';
  static const String _userEmailKey = 'user_email'; // For OTP flow

  static AuthService? _instance;
  SharedPreferences? _prefs;

  AuthService._();

  static Future<AuthService> getInstance() async {
    _instance ??= AuthService._();
    _instance!._prefs ??= await SharedPreferences.getInstance();
    return _instance!;
  }

  // Token Management - Access Token Only
  Future<void> saveAccessToken({
    required String accessToken,
    DateTime? expiry,
  }) async {
    await Future.wait([
      _prefs!.setString(_accessTokenKey, accessToken),
      if (expiry != null) _prefs!.setString(_tokenExpiryKey, expiry.toIso8601String()),
    ]);
    print('🔐 Auth Service: Access token saved');
  }

  String? getAccessToken() => _prefs?.getString(_accessTokenKey);

  DateTime? getTokenExpiry() {
    final expiryString = _prefs?.getString(_tokenExpiryKey);
    return expiryString != null ? DateTime.tryParse(expiryString) : null;
  }

  bool isTokenExpired() {
    final expiry = getTokenExpiry();
    return expiry != null && DateTime.now().isAfter(expiry);
  }

  bool hasValidToken() {
    final token = getAccessToken();
    return token != null && token.isNotEmpty && !isTokenExpired();
  }

  // User Management
  Future<void> saveUser(AuthUserModel user) async {
    await _prefs!.setString(_userDataKey, jsonEncode(user.toJson()));
    print('🔐 Auth Service: User data saved for ${user.email}');
  }

  AuthUserModel? getUser() {
    final userJson = _prefs?.getString(_userDataKey);
    if (userJson == null) return null;

    try {
      final userMap = jsonDecode(userJson) as Map<String, dynamic>;
      return AuthUserModel.fromJson(userMap);
    } catch (e) {
      print('🔐 Auth Service: Error parsing user data: $e');
      return null;
    }
  }

  // Auth State Check
  bool isLoggedIn() {
    return hasValidToken() && getUser() != null;
  }

  // OTP Flow Support
  Future<void> saveUserEmail(String email) async {
    await _prefs!.setString(_userEmailKey, email);
    print('🔐 Auth Service: Email saved for OTP: $email');
  }

  String? getUserEmail() => _prefs?.getString(_userEmailKey);

  Future<void> clearUserEmail() async {
    await _prefs!.remove(_userEmailKey);
    print('🔐 Auth Service: Email cleared');
  }

  // Clear All Data
  Future<void> clearAll() async {
    await Future.wait([
      _prefs!.remove(_accessTokenKey),
      _prefs!.remove(_userDataKey),
      _prefs!.remove(_tokenExpiryKey),
      _prefs!.remove(_userEmailKey),
    ]);
    print('🔐 Auth Service: All data cleared');
  }

  // Complete Auth Session Save - Access Token Only
  Future<void> saveAuthSession({
    required String accessToken,
    required AuthUserModel user,
    DateTime? expiry,
  }) async {
    await Future.wait([
      saveAccessToken(accessToken: accessToken, expiry: expiry),
      saveUser(user),
    ]);
    print('🔐 Auth Service: Complete auth session saved (access token only)');
  }
}