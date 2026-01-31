// // lib/features/auth/data/datasources/auth_local_datasource.dart
//
// import 'dart:convert';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:grad_project/features/auth/data/models/auth_user_model.dart';
// import 'package:grad_project/features/auth/domain/repositories/auth_repository.dart';
//
// abstract class AuthLocalDataSource {
//   Future<void> saveUser(AuthUserModel user);
//   Future<AuthUserModel?> getUser();
//   Future<void> clearUser();
//   Future<void> saveTokens(AuthTokens tokens);
//   Future<String?> getAccessToken();
//   Future<String?> getRefreshToken();
//   Future<void> clearTokens();
//   Future<bool> isLoggedIn();
//   Future<void> saveUserEmail(String email); // For OTP flow
//   Future<String?> getUserEmail();
//   Future<void> clearUserEmail();
// }
//
// class AuthLocalDataSourceImpl implements AuthLocalDataSource {
//   static const String _userKey = 'auth_user';
//   static const String _accessTokenKey = 'access_token';
//   static const String _refreshTokenKey = 'refresh_token';
//   static const String _isLoggedInKey = 'is_logged_in';
//   static const String _userEmailKey = 'user_email'; // For OTP flow
//
//   final SharedPreferences sharedPreferences;
//
//   AuthLocalDataSourceImpl({required this.sharedPreferences});
//
//   @override
//   Future<void> saveUser(AuthUserModel user) async {
//     final userJson = jsonEncode(user.toJson());
//     await sharedPreferences.setString(_userKey, userJson);
//     await sharedPreferences.setBool(_isLoggedInKey, true);
//   }
//
//   @override
//   Future<AuthUserModel?> getUser() async {
//     final userJson = sharedPreferences.getString(_userKey);
//     if (userJson == null) return null;
//
//     try {
//       final userMap = jsonDecode(userJson) as Map<String, dynamic>;
//       return AuthUserModel.fromJson(userMap);
//     } catch (e) {
//       // If user data is corrupted, clear it
//       await clearUser();
//       return null;
//     }
//   }
//
//   @override
//   Future<void> clearUser() async {
//     await sharedPreferences.remove(_userKey);
//     await sharedPreferences.setBool(_isLoggedInKey, false);
//   }
//
//   @override
//   Future<void> saveTokens(AuthTokens tokens) async {
//     await sharedPreferences.setString(_accessTokenKey, tokens.accessToken);
//     await sharedPreferences.setString(_refreshTokenKey, tokens.refreshToken);
//   }
//
//   @override
//   Future<String?> getAccessToken() async {
//     return sharedPreferences.getString(_accessTokenKey);
//   }
//
//   @override
//   Future<String?> getRefreshToken() async {
//     return sharedPreferences.getString(_refreshTokenKey);
//   }
//
//   @override
//   Future<void> clearTokens() async {
//     await sharedPreferences.remove(_accessTokenKey);
//     await sharedPreferences.remove(_refreshTokenKey);
//   }
//
//   @override
//   Future<bool> isLoggedIn() async {
//     final accessToken = await getAccessToken();
//     final refreshToken = await getRefreshToken();
//     final hasUser = sharedPreferences.containsKey(_userKey);
//     final isLoggedIn = sharedPreferences.getBool(_isLoggedInKey) ?? false;
//
//     return accessToken != null &&
//         refreshToken != null &&
//         hasUser &&
//         isLoggedIn;
//   }
//
//   @override
//   Future<void> saveUserEmail(String email) async {
//     await sharedPreferences.setString(_userEmailKey, email);
//   }
//
//   @override
//   Future<String?> getUserEmail() async {
//     return sharedPreferences.getString(_userEmailKey);
//   }
//
//   @override
//   Future<void> clearUserEmail() async {
//     await sharedPreferences.remove(_userEmailKey);
//   }
// }