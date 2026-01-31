// lib/core/utils/chatbot_debug_helper.dart - Debug and Test Helper

import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:grad_project/core/services/api_service.dart';
import 'package:grad_project/core/services/auth_service.dart';
import 'package:flutter/foundation.dart';

class ChatbotDebugHelper {
  static const String baseUrl = 'https://f35f3ddf1acd.ngrok-free.app';
  static const String apiUrl = '$baseUrl/api/v1';

  /// Comprehensive chatbot connection test
  static Future<ChatbotTestResult> testChatbotConnection() async {
    print('🧪 === CHATBOT CONNECTION TEST STARTING ===');

    final result = ChatbotTestResult();

    try {
      // Step 1: Test basic connectivity
      result.basicConnectivity = await _testBasicConnectivity();
      print('🌐 Basic connectivity: ${result.basicConnectivity ? "✅ PASS" : "❌ FAIL"}');

      // Step 2: Test ngrok endpoint
      result.ngrokReachable = await _testNgrokEndpoint();
      print('🔗 Ngrok reachable: ${result.ngrokReachable ? "✅ PASS" : "❌ FAIL"}');

      // Step 3: Test auth token
      result.authToken = await _getAuthToken();
      result.hasValidAuth = result.authToken != null && result.authToken!.isNotEmpty;
      print('🔑 Auth token: ${result.hasValidAuth ? "✅ PRESENT" : "❌ MISSING"}');

      // Step 4: Test API service
      result.apiServiceWorking = await _testApiService();
      print('⚙️ API Service: ${result.apiServiceWorking ? "✅ WORKING" : "❌ BROKEN"}');

      // Step 5: Test chatbot endpoint specifically
      result.chatbotEndpointWorking = await _testChatbotEndpoint(result.authToken);
      print('🤖 Chatbot endpoint: ${result.chatbotEndpointWorking ? "✅ WORKING" : "❌ BROKEN"}');

      // Step 6: Test with real message
      result.messageTestResult = await _testRealMessage(result.authToken);
      result.messageTestWorking = result.messageTestResult?.isNotEmpty == true;
      print('📝 Message test: ${result.messageTestWorking ? "✅ SUCCESS" : "❌ FAILED"}');

      result.overallSuccess = result.basicConnectivity &&
          result.ngrokReachable &&
          result.apiServiceWorking &&
          result.chatbotEndpointWorking;

      print('🎯 Overall Result: ${result.overallSuccess ? "✅ SUCCESS" : "❌ FAILED"}');
      print('🧪 === CHATBOT CONNECTION TEST COMPLETE ===');

      return result;

    } catch (e) {
      print('💥 Test framework error: $e');
      result.testError = e.toString();
      return result;
    }
  }

  static Future<bool> _testBasicConnectivity() async {
    try {
      final client = http.Client();
      final response = await client.get(
        Uri.parse('https://google.com'),
      ).timeout(const Duration(seconds: 5));

      client.close();
      return response.statusCode == 200;
    } catch (e) {
      print('🌐 Basic connectivity failed: $e');
      return false;
    }
  }

  static Future<bool> _testNgrokEndpoint() async {
    try {
      final client = http.Client();
      print('🔗 Testing ngrok endpoint: $baseUrl');

      final response = await client.get(
        Uri.parse(baseUrl),
        headers: {
          'ngrok-skip-browser-warning': 'true',
          'User-Agent': 'Fasih-Mobile-App/1.0',
        },
      ).timeout(const Duration(seconds: 10));

      print('🔗 Ngrok response status: ${response.statusCode}');
      print('🔗 Ngrok response headers: ${response.headers}');

      client.close();

      // Any response from ngrok (even 404) means it's reachable
      return response.statusCode >= 200 && response.statusCode < 600;
    } catch (e) {
      print('🔗 Ngrok test failed: $e');
      return false;
    }
  }

  static Future<String?> _getAuthToken() async {
    try {
      final authService = await AuthService.getInstance();
      final token = authService.getAccessToken();

      if (token != null) {
        print('🔑 Token length: ${token.length}');
        print('🔑 Token starts with: ${token.substring(0, token.length > 20 ? 20 : token.length)}...');
      }

      return token;
    } catch (e) {
      print('🔑 Auth token retrieval failed: $e');
      return null;
    }
  }

  static Future<bool> _testApiService() async {
    try {
      final apiService = ApiServiceImpl(
        baseUrl: apiUrl,
        httpClient: http.Client(),
      );

      // Test a simple endpoint that should exist
      final response = await apiService.get('/e3rbly/status');
      print('⚙️ API Service test response: $response');

      return response.isNotEmpty;
    } catch (e) {
      print('⚙️ API Service test failed: $e');
      return false;
    }
  }

  static Future<bool> _testChatbotEndpoint(String? authToken) async {
    try {
      final client = http.Client();
      final url = Uri.parse('$apiUrl/chatbot/chat');

      print('🤖 Testing chatbot endpoint: $url');

      final headers = <String, String>{
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'ngrok-skip-browser-warning': 'true',
        'User-Agent': 'Fasih-Mobile-App/1.0',
      };

      if (authToken != null && authToken.isNotEmpty) {
        headers['Authorization'] = 'Bearer $authToken';
        print('🔑 Authorization header added');
      }

      final testBody = {
        'userId': 'test_${DateTime.now().millisecondsSinceEpoch}',
        'message': 'test',
      };

      print('🤖 Test request headers: $headers');
      print('🤖 Test request body: ${jsonEncode(testBody)}');

      final response = await client.post(
        url,
        headers: headers,
        body: jsonEncode(testBody),
      ).timeout(const Duration(seconds: 15));

      print('🤖 Chatbot response status: ${response.statusCode}');
      print('🤖 Chatbot response headers: ${response.headers}');
      print('🤖 Chatbot response body: ${response.body}');

      client.close();

      // Check if we get a valid response (200, 401, 403 are all "working" responses)
      return response.statusCode == 200 ||
          response.statusCode == 401 ||
          response.statusCode == 403;

    } catch (e) {
      print('🤖 Chatbot endpoint test failed: $e');
      return false;
    }
  }

  static Future<String?> _testRealMessage(String? authToken) async {
    try {
      final apiService = ApiServiceImpl(
        baseUrl: apiUrl,
        httpClient: http.Client(),
      );

      if (authToken != null && authToken.isNotEmpty) {
        apiService.setAuthToken(authToken);
      }

      final response = await apiService.post(
        '/chatbot/chat',
        body: {
          'userId': 'test_real_${DateTime.now().millisecondsSinceEpoch}',
          'message': 'ما هو مضاد كلمة النور؟',
        },
      );

      print('📝 Real message test response: $response');

      if (response['status'] == 'success') {
        return response['response'] as String?;
      } else {
        print('📝 Real message test failed: ${response['message']}');
        return null;
      }

    } catch (e) {
      print('📝 Real message test error: $e');
      return null;
    }
  }

  /// Quick test for debugging in development
  static Future<void> quickDebugTest() async {
    print('🚀 === QUICK DEBUG TEST ===');

    try {
      // Test 1: Basic HTTP request to your exact endpoint
      final client = http.Client();
      final response = await client.post(
        Uri.parse('$apiUrl/chatbot/chat'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'ngrok-skip-browser-warning': 'true',
          'User-Agent': 'Fasih-Mobile-App/1.0',
        },
        body: jsonEncode({
          'userId': 'quick_test_${DateTime.now().millisecondsSinceEpoch}',
          'message': 'مرحبا',
        }),
      ).timeout(const Duration(seconds: 10));

      print('📡 Quick test status: ${response.statusCode}');
      print('📡 Quick test response: ${response.body}');

      // Test 2: Check if it matches your Postman success pattern
      if (response.statusCode == 200) {
        try {
          final data = jsonDecode(response.body);
          if (data['status'] == 'success') {
            print('✅ Quick test SUCCESS - API is working!');
            print('📝 Response: ${data['response']}');
          } else {
            print('⚠️ API responded but with error: ${data['message']}');
          }
        } catch (e) {
          print('❌ Response parsing failed: $e');
        }
      } else {
        print('❌ HTTP error: ${response.statusCode}');
      }

      client.close();

    } catch (e) {
      print('💥 Quick test failed: $e');
    }

    print('🚀 === QUICK DEBUG TEST COMPLETE ===');
  }

  /// Generate a comprehensive debug report
  static Future<String> generateDebugReport() async {
    final result = await testChatbotConnection();

    final report = StringBuffer();
    report.writeln('=== CHATBOT DEBUG REPORT ===');
    report.writeln('Generated: ${DateTime.now()}');
    report.writeln('');
    report.writeln('🌐 Basic Connectivity: ${result.basicConnectivity ? "✅ WORKING" : "❌ FAILED"}');
    report.writeln('🔗 Ngrok Reachable: ${result.ngrokReachable ? "✅ WORKING" : "❌ FAILED"}');
    report.writeln('🔑 Auth Token Present: ${result.hasValidAuth ? "✅ YES" : "❌ NO"}');
    report.writeln('⚙️ API Service: ${result.apiServiceWorking ? "✅ WORKING" : "❌ FAILED"}');
    report.writeln('🤖 Chatbot Endpoint: ${result.chatbotEndpointWorking ? "✅ WORKING" : "❌ FAILED"}');
    report.writeln('📝 Message Test: ${result.messageTestWorking ? "✅ SUCCESS" : "❌ FAILED"}');
    report.writeln('');
    report.writeln('🎯 Overall Status: ${result.overallSuccess ? "✅ WORKING" : "❌ NEEDS FIX"}');

    if (result.testError != null) {
      report.writeln('');
      report.writeln('❌ Test Error: ${result.testError}');
    }

    if (result.messageTestResult != null) {
      report.writeln('');
      report.writeln('📝 Sample Response: ${result.messageTestResult}');
    }

    report.writeln('');
    report.writeln('=== RECOMMENDATIONS ===');

    if (!result.basicConnectivity) {
      report.writeln('• Check internet connection');
    }

    if (!result.ngrokReachable) {
      report.writeln('• Verify ngrok URL is correct and active');
      report.writeln('• Check if ngrok tunnel is running');
    }

    if (!result.hasValidAuth) {
      report.writeln('• Login to get valid auth token');
      report.writeln('• Check AuthService implementation');
    }

    if (!result.apiServiceWorking) {
      report.writeln('• Check ApiService configuration');
      report.writeln('• Verify base URL settings');
    }

    if (!result.chatbotEndpointWorking) {
      report.writeln('• Check chatbot endpoint implementation');
      report.writeln('• Verify request format matches API expectations');
    }

    report.writeln('=== END REPORT ===');

    return report.toString();
  }
}

class ChatbotTestResult {
  bool basicConnectivity = false;
  bool ngrokReachable = false;
  String? authToken;
  bool hasValidAuth = false;
  bool apiServiceWorking = false;
  bool chatbotEndpointWorking = false;
  bool messageTestWorking = false;
  String? messageTestResult;
  bool overallSuccess = false;
  String? testError;
}
