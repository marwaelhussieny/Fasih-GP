// // lib/core/services/token_storage_service.dart
//
// import 'package:shared_preferences/shared_preferences.dart';
// import 'dart:convert';
//
// class TokenStorageService {
//   static const String _accessTokenKey = 'access_token';
//   static const String _refreshTokenKey = 'refresh_token';
//   static const String _userDataKey = 'user_data';
//   static const String _tokenExpiryKey = 'token_expiry';
//
//   static TokenStorageService? _instance;
//   late SharedPreferences _prefs;
//
//   TokenStorageService._();
//
//   static Future<TokenStorageService> getInstance() async {
//     _instance ??= TokenStorageService._();
//     _instance!._prefs = await SharedPreferences.getInstance();
//     return _instance!;
//   }
//
//   // Access Token Methods
//   Future<void> saveAccessToken(String token) async {
//     await _prefs.setString(_accessTokenKey, token);
//   }
//
//   String? getAccessToken() {
//     return _prefs.getString(_accessTokenKey);
//   }
//
//   Future<void> removeAccessToken() async {
//     await _prefs.remove(_accessTokenKey);
//   }
//
//   // Refresh Token Methods
//   Future<void> saveRefreshToken(String token) async {
//     await _prefs.setString(_refreshTokenKey, token);
//   }
//
//   String? getRefreshToken() {
//     return _prefs.getString(_refreshTokenKey);
//   }
//
//   Future<void> removeRefreshToken() async {
//     await _prefs.remove(_refreshTokenKey);
//   }
//
//   // Token Expiry Methods
//   Future<void> saveTokenExpiry(DateTime expiry) async {
//     await _prefs.setString(_tokenExpiryKey, expiry.toIso8601String());
//   }
//
//   DateTime? getTokenExpiry() {
//     final expiryString = _prefs.getString(_tokenExpiryKey);
//     if (expiryString != null) {
//       return DateTime.parse(expiryString);
//     }
//     return null;
//   }
//
//   bool isTokenExpired() {
//     final expiry = getTokenExpiry();
//     if (expiry == null) return true;
//     return DateTime.now().isAfter(expiry);
//   }
//
//   // User Data Methods
//   Future<void> saveUserData(Map<String, dynamic> userData) async {
//     await _prefs.setString(_userDataKey, jsonEncode(userData));
//   }
//
//   Map<String, dynamic>? getUserData() {
//     final userDataString = _prefs.getString(_userDataKey);
//     if (userDataString != null) {
//       return jsonDecode(userDataString) as Map<String, dynamic>;
//     }
//     return null;
//   }
//
//   Future<void> removeUserData() async {
//     await _prefs.remove(_userDataKey);
//   }
//
//   // Save complete auth data
//   Future<void> saveAuthData({
//     required String accessToken,
//     required String refreshToken,
//     required Map<String, dynamic> userData,
//     DateTime? expiry,
//   }) async {
//     await Future.wait([
//       saveAccessToken(accessToken),
//       saveRefreshToken(refreshToken),
//       saveUserData(userData),
//       if (expiry != null) saveTokenExpiry(expiry),
//     ]);
//   }
//
//   // Clear all auth data
//   Future<void> clearAll() async {
//     await Future.wait([
//       removeAccessToken(),
//       removeRefreshToken(),
//       removeUserData(),
//       _prefs.remove(_tokenExpiryKey),
//     ]);
//   }
//
//   // Check if user has valid session
//   bool hasValidSession() {
//     final accessToken = getAccessToken();
//     final refreshToken = getRefreshToken();
//     return accessToken != null && refreshToken != null && !isTokenExpired();
//   }
// }