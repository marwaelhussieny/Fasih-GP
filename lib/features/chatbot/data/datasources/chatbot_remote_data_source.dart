// lib/features/chatbot/data/datasources/chatbot_remote_data_source.dart - CORRECTED

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:grad_project/core/services/auth_service.dart';
import 'package:flutter/foundation.dart';

abstract class ChatbotRemoteDataSource {
  Future<String> sendMessage(String message, String userId, List<ChatbotMessage> conversationHistory);
  Future<List<String>> getSuggestedQuestions();
}

class ChatbotRemoteDataSourceImpl implements ChatbotRemoteDataSource {
  final http.Client client;
  final String baseUrl;
  // final ApiService apiService; // ADDED: Missing field

  ChatbotRemoteDataSourceImpl({
    required this.client,
    // required this.apiService, // ADDED: Missing named parameter
    this.baseUrl = 'https://f35f3ddf1acd.ngrok-free.app/api/v1',
  });

  Future<String> _getAuthToken() async {
    try {
      final authService = await AuthService.getInstance();
      final token = authService.getAccessToken();
      debugPrint('🔑 Retrieved token: ${token != null ? 'Present (${token.length} chars)' : 'Missing'}');
      return token ?? '';
    } catch (e) {
      debugPrint('❌ Error getting auth token: $e');
      return '';
    }
  }

  @override
  Future<String> sendMessage(
      String message,
      String userId,
      List<ChatbotMessage> conversationHistory,
      ) async {
    final url = Uri.parse('$baseUrl/chatbot/chat');
    debugPrint('📤 Sending message to: $url');
    debugPrint('📤 Message: $message');
    debugPrint('📤 User ID: $userId');
    debugPrint('📤 Base URL: $baseUrl');

    try {
      final token = await _getAuthToken();

      final headers = <String, String>{
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        // IMPORTANT: ngrok requires this header to bypass browser warning
        'ngrok-skip-browser-warning': 'true',
        'User-Agent': 'Fasih-Mobile-App/1.0',
      };

      // Add authorization header if token is available
      if (token.isNotEmpty) {
        headers['Authorization'] = 'Bearer $token';
        debugPrint('🔐 Authorization header added');
      } else {
        debugPrint('⚠️ No authentication token available');
      }

      // Request body matching your API exactly
      final requestBody = <String, dynamic>{
        'userId': userId,
        'message': message,
      };

      debugPrint('📦 Request headers: $headers');
      debugPrint('📦 Request body: ${jsonEncode(requestBody)}');

      final response = await client
          .post(
        url,
        headers: headers,
        body: jsonEncode(requestBody),
      )
          .timeout(const Duration(seconds: 45)); // Longer timeout for ngrok

      debugPrint('📥 Response status: ${response.statusCode}');
      debugPrint('📥 Response headers: ${response.headers}');
      debugPrint('📥 Response body: ${response.body}');

      if (response.statusCode == 200) {
        try {
          final data = jsonDecode(response.body) as Map<String, dynamic>;

          // Handle your API response structure exactly as shown in Postman
          if (data['status'] == 'success') {
            final responseText = data['response'] as String? ?? 'عذراً، لا يمكنني الإجابة في الوقت الحالي.';
            debugPrint('✅ Success response received');
            return responseText;
          } else {
            final errorMessage = data['message'] as String? ?? 'حدث خطأ غير متوقع';
            debugPrint('❌ API error in response: $errorMessage');
            throw ChatbotException(errorMessage);
          }
        } catch (e) {
          debugPrint('❌ Error parsing response JSON: $e');
          throw ChatbotException('خطأ في تنسيق الاستجابة من الخادم');
        }
      } else if (response.statusCode == 401) {
        debugPrint('🔒 Unauthorized access - Token may be invalid or expired');
        throw ChatbotException('انتهت صلاحية الجلسة. يرجى تسجيل الدخول مرة أخرى.');
      } else if (response.statusCode == 404) {
        debugPrint('🔍 Endpoint not found');
        throw ChatbotException('الخدمة غير متاحة حالياً');
      } else if (response.statusCode == 403) {
        debugPrint('🚫 Forbidden - ngrok may be blocking request');
        throw ChatbotException('طلب محظور. يرجى التحقق من إعدادات الخادم.');
      } else if (response.statusCode == 429) {
        debugPrint('🚫 Rate limit exceeded');
        throw ChatbotException('تم تجاوز الحد المسموح من الرسائل. يرجى المحاولة لاحقاً.');
      } else if (response.statusCode >= 500) {
        debugPrint('💥 Server error: ${response.statusCode}');
        throw ChatbotException('خطأ في الخادم. يرجى المحاولة لاحقاً.');
      } else {
        debugPrint('❌ HTTP error: ${response.statusCode}');
        debugPrint('❌ Response body: ${response.body}');

        String errorMessage = 'فشل في إرسال الرسالة';

        try {
          final data = jsonDecode(response.body) as Map<String, dynamic>;
          errorMessage = data['message'] as String? ?? errorMessage;
        } catch (e) {
          // Keep default error message
        }

        throw ChatbotException('$errorMessage (كود الخطأ: ${response.statusCode})');
      }
    } on TimeoutException {
      debugPrint('⏱️ Request timeout - ngrok may be slow');
      throw ChatbotException('انتهت مهلة الاتصال. الخادم يستغرق وقتاً أطول من المعتاد.');
    } on SocketException catch (e) {
      debugPrint('🌐 Socket exception: $e');
      throw ChatbotException('لا يوجد اتصال بالإنترنت. يرجى التحقق من اتصال الشبكة.');
    } on FormatException catch (e) {
      debugPrint('🔧 JSON format error: $e');
      throw ChatbotException('خطأ في تنسيق البيانات المستلمة من الخادم.');
    } on http.ClientException catch (e) {
      debugPrint('🔗 Client exception: $e');
      throw ChatbotException('خطأ في الاتصال بالخادم: ${e.message}');
    } catch (e) {
      if (e is ChatbotException) rethrow;
      debugPrint('💥 Unexpected error: $e');
      throw ChatbotException('خطأ غير متوقع: ${e.toString()}');
    }
  }

  @override
  Future<List<String>> getSuggestedQuestions() async {
    debugPrint('📤 Getting suggested questions (using defaults)');
    return _getDefaultSuggestedQuestions();
  }

  List<String> _getDefaultSuggestedQuestions() {
    return [
      'ما هو مضاد كلمة النور؟',
      'كيف يمكنني تحسين مهاراتي في اللغة العربية؟',
      'ما هي قواعد النحو الأساسية؟',
      'كيف أتعلم الإعراب بسهولة؟',
      'ما الفرق بين الفعل والاسم؟',
      'كيف أحفظ الشعر العربي؟',
      'اشرح لي درس اسم الفاعل',
      'كيف أميز بين المفعول به والفاعل؟',
    ];
  }

  // Enhanced connection test method for ngrok
  Future<bool> testConnection() async {
    try {
      debugPrint('🧪 Testing ngrok connection to: $baseUrl/chatbot/chat');

      final token = await _getAuthToken();
      final headers = <String, String>{
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        // CRITICAL for ngrok
        'ngrok-skip-browser-warning': 'true',
        'User-Agent': 'Fasih-Mobile-App/1.0',
      };

      if (token.isNotEmpty) {
        headers['Authorization'] = 'Bearer $token';
      }

      // Test with a simple message
      final testBody = {
        'userId': 'test_connection_${DateTime.now().millisecondsSinceEpoch}',
        'message': 'مرحبا',
      };

      debugPrint('🧪 Test request headers: $headers');
      debugPrint('🧪 Test request body: ${jsonEncode(testBody)}');

      final response = await client
          .post(
        Uri.parse('$baseUrl/chatbot/chat'),
        headers: headers,
        body: jsonEncode(testBody),
      )
          .timeout(const Duration(seconds: 15));

      debugPrint('🧪 Test response status: ${response.statusCode}');
      debugPrint('🧪 Test response body: ${response.body}');

      // Consider connection successful for these status codes
      if (response.statusCode == 200) {
        try {
          final data = jsonDecode(response.body) as Map<String, dynamic>;
          return data['status'] == 'success';
        } catch (e) {
          // If we can't parse response but got 200, server is reachable
          return true;
        }
      } else if (response.statusCode == 401) {
        // Server is reachable but needs authentication
        debugPrint('🔐 Server reachable but requires authentication');
        return true;
      } else if (response.statusCode == 403) {
        // ngrok might be blocking, but server is reachable
        debugPrint('🚫 Server reachable but access forbidden (ngrok issue?)');
        return true;
      } else {
        // Any other response means server is reachable
        debugPrint('🌐 Server reachable with status: ${response.statusCode}');
        return true;
      }
    } on SocketException catch (e) {
      debugPrint('🧪 Socket exception during test: $e');
      return false;
    } on TimeoutException {
      debugPrint('🧪 Timeout during connection test');
      return false;
    } catch (e) {
      debugPrint('🧪 Test connection error: $e');
      return false;
    }
  }
}

// Models
class ChatbotMessage {
  final String text;
  final bool isUser;
  final DateTime timestamp;

  ChatbotMessage({
    required this.text,
    required this.isUser,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() => {
    'text': text,
    'is_user': isUser,
    'timestamp': timestamp.toIso8601String(),
  };

  factory ChatbotMessage.fromJson(Map<String, dynamic> json) => ChatbotMessage(
    text: json['text'] as String,
    isUser: json['is_user'] as bool,
    timestamp: DateTime.parse(json['timestamp'] as String),
  );

  @override
  String toString() => 'ChatbotMessage(text: ${text.length > 50 ? text.substring(0, 50) + "..." : text}, isUser: $isUser)';
}

class ChatbotException implements Exception {
  final String message;
  ChatbotException(this.message);

  @override
  String toString() => 'ChatbotException: $message';
}