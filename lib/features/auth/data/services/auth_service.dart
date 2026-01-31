// // lib/core/auth/auth_service.dart
//
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:jwt_decoder/jwt_decoder.dart';
// import 'package:http/http.dart' as http;
// import 'dart:convert';
//
// class AuthService {
//   static const String _accessTokenKey = 'access_token';
//   static const String _refreshTokenKey = 'refresh_token';
//   static const String _userIdKey = 'user_id';
//   static const String baseUrl = 'http://localhost:5000';
//
//   // Get access token
//   Future<String?> getAccessToken() async {
//     final prefs = await SharedPreferences.getInstance();
//     final token = prefs.getString(_accessTokenKey);
//
//     if (token != null && !JwtDecoder.isExpired(token)) {
//       return token;
//     }
//
//     // Token is expired, try to refresh
//     return await _refreshAccessToken();
//   }
//
//   // Get refresh token
//   Future<String?> getRefreshToken() async {
//     final prefs = await SharedPreferences.getInstance();
//     return prefs.getString(_refreshTokenKey);
//   }
//
//   // Get current user ID from token
//   Future<String?> getCurrentUserId() async {
//     final token = await getAccessToken();
//     if (token != null) {
//       try {
//         final decodedToken = JwtDecoder.decode(token);
//         return decodedToken['id'];
//       } catch (e) {
//         // Token is invalid, clear it
//         await clearTokens();
//         return null;
//       }
//     }
//     return null;
//   }
//
//   // Store tokens after login
//   Future<void> storeTokens({
//     required String accessToken,
//     required String refreshToken,
//   }) async {
//     final prefs = await SharedPreferences.getInstance();
//     await prefs.setString(_accessTokenKey, accessToken);
//     await prefs.setString(_refreshTokenKey, refreshToken);
//
//     // Extract and store user ID
//     try {
//       final decodedToken = JwtDecoder.decode(accessToken);
//       final userId = decodedToken['id'];
//       if (userId != null) {
//         await prefs.setString(_userIdKey, userId);
//       }
//     } catch (e) {
//       // Handle token decode error
//       print('Error decoding token: $e');
//     }
//   }
//
//   // Clear all tokens
//   Future<void> clearTokens() async {
//     final prefs = await SharedPreferences.getInstance();
//     await prefs.remove(_accessTokenKey);
//     await prefs.remove(_refreshTokenKey);
//     await prefs.remove(_userIdKey);
//   }
//
//   // Check if user is authenticated
//   Future<bool> isAuthenticated() async {
//     final token = await getAccessToken();
//     return token != null;
//   }
//
//   // Refresh access token using refresh token
//   Future<String?> _refreshAccessToken() async {
//     try {
//       final refreshToken = await getRefreshToken();
//       if (refreshToken == null) {
//         return null;
//       }
//
//       final response = await http.post(
//         Uri.parse('$baseUrl/api/auth/refresh'),
//         headers: {
//           'Content-Type': 'application/json',
//         },
//         body: json.encode({
//           'refreshToken': refreshToken,
//         }),
//       );
//
//       if (response.statusCode == 200) {
//         final data = json.decode(response.body);
//         final newAccessToken = data['accessToken'];
//         final newRefreshToken = data['refreshToken'];
//
//         if (newAccessToken != null) {
//           await storeTokens(
//             accessToken: newAccessToken,
//             refreshToken: newRefreshToken ?? refreshToken,
//           );
//           return newAccessToken;
//         }
//       } else {
//         // Refresh failed, clear tokens
//         await clearTokens();
//       }
//     } catch (e) {
//       print('Error refreshing token: $e');
//       await clearTokens();
//     }
//
//     return null;
//   }
//
//   // Login method
//   Future<Map<String, dynamic>?> login({
//     required String email,
//     required String password,
//   }) async {
//     try {
//       final response = await http.post(
//         Uri.parse('$baseUrl/api/auth/login'),
//         headers: {
//           'Content-Type': 'application/json',
//         },
//         body: json.encode({
//           'email': email,
//           'password': password,
//         }),
//       );
//
//       if (response.statusCode == 200) {
//         final data = json.decode(response.body);
//         final accessToken = data['accessToken'];
//         final refreshToken = data['refreshToken'];
//
//         if (accessToken != null && refreshToken != null) {
//           await storeTokens(
//             accessToken: accessToken,
//             refreshToken: refreshToken,
//           );
//           return data;
//         }
//       }
//     } catch (e) {
//       print('Login error: $e');
//     }
//
//     return null;
//   }
//
//   // Logout method
//   Future<void> logout() async {
//     try {
//       final token = await getAccessToken();
//       if (token != null) {
//         // Call logout endpoint
//         await http.post(
//           Uri.parse('$baseUrl/api/user/logout'),
//           headers: {
//             'Authorization': 'Bearer $token',
//             'Content-Type': 'application/json',
//           },
//         );
//       }
//     } catch (e) {
//       print('Logout error: $e');
//     } finally {
//       // Always clear local tokens
//       await clearTokens();
//     }
//   }
// }