// // lib/core/services/token_storage_service.dart
//
// import 'dart:convert';
// import 'package:shared_preferences/shared_preferences.dart';
// import '../types/auth_tokens.dart';
//
// class TokenStorageService {
//   static const String _tokenKey = 'auth_tokens';
//
//   // Save tokens to persistent storage
//   static Future<void> saveTokens(AuthTokens tokens) async {
//     try {
//       final prefs = await SharedPreferences.getInstance();
//       final tokenJson = jsonEncode(tokens.toJson());
//       await prefs.setString(_tokenKey, tokenJson);
//       print('🔐 TokenStorage: Tokens saved successfully');
//     } catch (e) {
//       print('❌ TokenStorage: Failed to save tokens: $e');
//       rethrow;
//     }
//   }
//
//   // Load tokens from persistent storage
//   static Future<AuthTokens?> loadTokens() async {
//     try {
//       final prefs = await SharedPreferences.getInstance();
//       final tokenJson = prefs.getString(_tokenKey);
//
//       if (tokenJson == null) {
//         print('🔐 TokenStorage: No saved tokens found');
//         return null;
//       }
//
//       final tokenMap = jsonDecode(tokenJson) as Map<String, dynamic>;
//       final tokens = AuthTokens.fromJson(tokenMap);
//
//       print('🔐 TokenStorage: Tokens loaded successfully');
//       return tokens;
//     } catch (e) {
//       print('❌ TokenStorage: Failed to load tokens: $e');
//       // Clear corrupted data
//       await clearTokens();
//       return null;
//     }
//   }
//
//   // Clear stored tokens
//   static Future<void> clearTokens() async {
//     try {
//       final prefs = await SharedPreferences.getInstance();
//       await prefs.remove(_tokenKey);
//       print('🔐 TokenStorage: Tokens cleared successfully');
//     } catch (e) {
//       print('❌ TokenStorage: Failed to clear tokens: $e');
//     }
//   }
//
//   // Check if tokens exist and are valid
//   static Future<bool> hasValidTokens() async {
//     final tokens = await loadTokens();
//     return tokens?.isValid ?? false;
//   }
// }