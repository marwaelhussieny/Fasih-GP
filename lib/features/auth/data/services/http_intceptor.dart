// // lib/core/services/http_interceptor.dart
//
// import 'package:http/http.dart' as http;
// import 'dart:convert';
// import 'dart:io';
// import 'package:grad_project/core/services/token_storage_service.dart';
// import 'package:grad_project/core/config/api_config.dart';
// import 'package:grad_project/features/auth/data/services/auth_service.dart';
// import 'package:grad_project/core/utils/error_handler.dart';
//
// class HttpInterceptor {
//   static HttpInterceptor? _instance;
//   late final TokenStorageService _tokenStorage;
//   late final AuthService _authService;
//   bool _isInitialized = false;
//
//   HttpInterceptor._();
//
//   static Future<HttpInterceptor> getInstance() async {
//     _instance ??= HttpInterceptor._();
//     if (!_instance!._isInitialized) {
//       await _instance!._initialize();
//     }
//     return _instance!;
//   }
//
//   Future<void> _initialize() async {
//     if (!_isInitialized) {
//       _tokenStorage = await TokenStorageService.getInstance();
//       _authService = await AuthService.getInstance();
//       _isInitialized = true;
//     }
//   }
//
//   /// Make authenticated HTTP requests with automatic token refresh
//   Future<http.Response> authenticatedRequest({
//     required String method,
//     required String url,
//     Map<String, String>? headers,
//     Object? body,
//     Duration? timeout,
//   }) async {
//     await _initialize();
//
//     // Get or refresh access token using centralized AuthService
//     String? accessToken = await _authService.getValidAccessToken();
//
//     final requestHeaders = {
//       ...ApiConfig.defaultHeaders,
//       ...?headers,
//     };
//
//     if (accessToken != null) {
//       requestHeaders['Authorization'] = 'Bearer $accessToken';
//     }
//
//     final uri = Uri.parse(url);
//     http.Response response;
//
//     try {
//       response = await _performRequest(method, uri, requestHeaders, body, timeout);
//
//       // Handle token expiration - retry once with refreshed token
//       if (response.statusCode == 401) {
//         print('HttpInterceptor: Token expired, attempting refresh...');
//
//         // Try to get a fresh token using AuthService
//         accessToken = await _authService.getValidAccessToken();
//
//         if (accessToken != null) {
//           requestHeaders['Authorization'] = 'Bearer $accessToken';
//           response = await _performRequest(method, uri, requestHeaders, body, timeout);
//           print('HttpInterceptor: Request retried with refreshed token');
//         } else {
//           print('HttpInterceptor: Unable to refresh token, user needs to re-authenticate');
//         }
//       }
//
//       return response;
//     } catch (e) {
//       print('HttpInterceptor: Request failed - $e');
//       throw _handleError(e);
//     }
//   }
//
//   /// Perform the actual HTTP request
//   Future<http.Response> _performRequest(
//       String method,
//       Uri uri,
//       Map<String, String> headers,
//       Object? body,
//       Duration? timeout,
//       ) async {
//     final requestTimeout = timeout ?? ApiConfig.connectTimeout;
//
//     switch (method.toUpperCase()) {
//       case 'GET':
//         return await http.get(uri, headers: headers).timeout(requestTimeout);
//       case 'POST':
//         return await http.post(uri, headers: headers, body: body).timeout(requestTimeout);
//       case 'PUT':
//         return await http.put(uri, headers: headers, body: body).timeout(requestTimeout);
//       case 'DELETE':
//         return await http.delete(uri, headers: headers).timeout(requestTimeout);
//       case 'PATCH':
//         return await http.patch(uri, headers: headers, body: body).timeout(requestTimeout);
//       default:
//         throw ArgumentError('Unsupported HTTP method: $method');
//     }
//   }
//
//   /// GET request with authentication
//   Future<http.Response> get(String url, {Map<String, String>? headers}) {
//     return authenticatedRequest(method: 'GET', url: url, headers: headers);
//   }
//
//   /// POST request with authentication
//   Future<http.Response> post(String url, {Map<String, String>? headers, Object? body}) {
//     return authenticatedRequest(method: 'POST', url: url, headers: headers, body: body);
//   }
//
//   /// PUT request with authentication
//   Future<http.Response> put(String url, {Map<String, String>? headers, Object? body}) {
//     return authenticatedRequest(method: 'PUT', url: url, headers: headers, body: body);
//   }
//
//   /// DELETE request with authentication
//   Future<http.Response> delete(String url, {Map<String, String>? headers}) {
//     return authenticatedRequest(method: 'DELETE', url: url, headers: headers);
//   }
//
//   /// PATCH request with authentication
//   Future<http.Response> patch(String url, {Map<String, String>? headers, Object? body}) {
//     return authenticatedRequest(method: 'PATCH', url: url, headers: headers, body: body);
//   }
//
//   /// Helper method to parse JSON response
//   Map<String, dynamic> parseJsonResponse(http.Response response) {
//     try {
//       return jsonDecode(response.body) as Map<String, dynamic>;
//     } catch (e) {
//       throw FormatException('Invalid JSON response from server');
//     }
//   }
//
//   /// Check if response indicates success
//   bool isSuccessResponse(http.Response response) {
//     return response.statusCode >= 200 && response.statusCode < 300;
//   }
//
//   /// Extract error message from response
//   String getErrorMessageFromResponse(http.Response response) {
//     try {
//       final data = parseJsonResponse(response);
//       return data['message'] ?? data['error'] ?? 'Request failed';
//     } catch (e) {
//       return 'Request failed with status ${response.statusCode}';
//     }
//   }
//
//   /// Centralized error handling using ErrorHandler
//   Exception _handleError(dynamic error) {
//     if (error is SocketException) {
//       return NetworkException(ErrorHandler.getErrorMessage(error));
//     } else if (error is HttpException) {
//       return ServerException(ErrorHandler.getErrorMessage(error));
//     } else if (error is FormatException) {
//       return ResponseFormatException(ErrorHandler.getErrorMessage(error));
//     } else if (error.toString().contains('TimeoutException')) {
//       return TimeoutException(ErrorHandler.getErrorMessage(error));
//     } else if (error is ArgumentError) {
//       return Exception(error.message);
//     } else {
//       return AppException(ErrorHandler.getErrorMessage(error));
//     }
//   }
//
//   /// Clear all cached data (useful for logout)
//   Future<void> clearCache() async {
//     await _initialize();
//     await _authService.logout();
//   }
//
//   /// Check if user is authenticated
//   Future<bool> isAuthenticated() async {
//     await _initialize();
//     return await _authService.hasValidSession();
//   }
// }
//
// // Custom exception classes for HTTP interceptor
// class NetworkException implements Exception {
//   final String message;
//   NetworkException(this.message);
//
//   @override
//   String toString() => message;
// }
//
// class ServerException implements Exception {
//   final String message;
//   ServerException(this.message);
//
//   @override
//   String toString() => message;
// }
//
// class ResponseFormatException implements Exception {
//   final String message;
//   ResponseFormatException(this.message);
//
//   @override
//   String toString() => message;
// }
//
// class TimeoutException implements Exception {
//   final String message;
//   TimeoutException(this.message);
//
//   @override
//   String toString() => message;
// }
//
// class AppException implements Exception {
//   final String message;
//   AppException(this.message);
//
//   @override
//   String toString() => message;
// }