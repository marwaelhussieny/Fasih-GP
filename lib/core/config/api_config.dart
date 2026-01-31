// // lib/core/config/api_config.dart
//
// class ApiConfig {
//   // Base URLs - Update these to your actual backend URLs
//   static const String _baseUrl = 'https://3608bf173666.ngrok-free.app'; // For local development
//   // static const String _baseUrl = 'https://your-production-domain.com'; // For production
//
//   static const String authBaseUrl = '$_baseUrl/api/auth';
//   static const String userBaseUrl = '$_baseUrl/api/users';
//   static const String quizBaseUrl = '$_baseUrl/api/quiz';
//   static const String libraryBaseUrl = '$_baseUrl/api/library';
//   static const String grammarBaseUrl = '$_baseUrl/api/grammar';
//   static const String chatbotBaseUrl = '$_baseUrl/api/chatbot';
//
//   // Timeout configurations
//   static const Duration connectTimeout = Duration(seconds: 30);
//   static const Duration receiveTimeout = Duration(seconds: 30);
//   static const Duration sendTimeout = Duration(seconds: 30);
//
//   // Default headers
//   static const Map<String, String> defaultHeaders = {
//     'Content-Type': 'application/json',
//     'Accept': 'application/json',
//   };
//
//   // Get authenticated headers with token
//   static Map<String, String> getAuthHeaders(String? token) {
//     final headers = Map<String, String>.from(defaultHeaders);
//     if (token != null) {
//       headers['Authorization'] = 'Bearer $token';
//     }
//     return headers;
//   }
//
//   // API endpoints
//   static const Map<String, String> endpoints = {
//     // Auth endpoints
//     'signup': '/signup',
//     'login': '/login',
//     'verifyOtp': '/verify-otp',
//     'resendOtp': '/resend-otp',
//     'forgotPassword': '/forgot-password',
//     'resetPassword': '/reset-password',
//     'refreshToken': '/refresh-token',
//     'logout': '/logout',
//
//     // User endpoints
//     'profile': '/profile',
//     'updateProfile': '/profile',
//     'uploadAvatar': '/upload-avatar',
//
//     // Quiz endpoints
//     'quizzes': '/quizzes',
//     'submitQuiz': '/submit',
//     'quizResults': '/results',
//
//     // Library endpoints
//     'libraryItems': '/items',
//     'searchLibrary': '/search',
//
//     // Grammar endpoints
//     'parseGrammar': '/parse',
//     'analyzeMorphology': '/morphology',
//   };
// }