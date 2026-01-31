// lib/core/utils/quick_json_response_test.dart
// QUICK TEST FOR JSON RESPONSE DECODING ISSUES

import 'dart:convert';

class QuickJsonResponseTest {

  /// Test decoding typical login success responses
  static void testLoginSuccessDecoding() {
    print('🔍 LOGIN SUCCESS RESPONSE DECODING TEST');
    print('🔍 ======================================');

    final successResponses = [
      // Typical success response
      '{"success": true, "message": "Login successful", "token": "abc123", "user": {"id": 1, "email": "test@example.com"}}',

      // With additional fields
      '{"success": true, "data": {"token": "xyz789", "user": {"id": 2, "name": "Ahmed", "email": "ahmed@example.com"}}, "message": "تم تسجيل الدخول بنجاح"}',

      // Simple token response
      '{"token": "simple_token_123", "expires_in": 3600}',

      // With nested user data
      '{"status": "success", "user": {"id": 3, "profile": {"name": "User Name", "avatar": "https://example.com/avatar.jpg"}}, "access_token": "bearer_token"}',

      // Array in response
      '{"success": true, "permissions": ["read", "write"], "user_id": 123}',
    ];

    for (int i = 0; i < successResponses.length; i++) {
      print('🔍 Success Response ${i + 1}:');
      _testSingleResponse(successResponses[i]);
      print('');
    }
  }

  /// Test decoding typical login error responses
  static void testLoginErrorDecoding() {
    print('🔍 LOGIN ERROR RESPONSE DECODING TEST');
    print('🔍 ====================================');

    final errorResponses = [
      // Standard error
      '{"success": false, "message": "Invalid credentials"}',

      // With error code
      '{"error": "INVALID_LOGIN", "message": "البريد الإلكتروني أو كلمة المرور غير صحيحة", "code": 401}',

      // Validation errors
      '{"success": false, "errors": {"email": ["Email is required"], "password": ["Password must be at least 8 characters"]}}',

      // Server error
      '{"error": "INTERNAL_ERROR", "message": "Something went wrong", "timestamp": "2024-01-15T10:30:00Z"}',

      // Rate limiting
      '{"error": "TOO_MANY_REQUESTS", "message": "Too many login attempts", "retry_after": 300}',

      // Empty response (sometimes happens)
      '{}',

      // Null values
      '{"success": null, "message": null, "data": null}',
    ];

    for (int i = 0; i < errorResponses.length; i++) {
      print('🔍 Error Response ${i + 1}:');
      _testSingleResponse(errorResponses[i]);
      print('');
    }
  }

  /// Test decoding malformed or problematic responses
  static void testProblematicResponses() {
    print('🔍 PROBLEMATIC RESPONSE DECODING TEST');
    print('🔍 ===================================');

    final problematicResponses = [
      // Missing quotes
      '{success: true, message: "Login successful"}',

      // Single quotes (invalid JSON)
      "{'success': true, 'message': 'Login successful'}",

      // Trailing comma
      '{"success": true, "message": "Login successful",}',

      // Unicode characters
      '{"message": "مرحبا بك 🎉", "success": true}',

      // Very large numbers
      '{"user_id": 9007199254740992, "timestamp": 1641024600000}',

      // HTML instead of JSON (server error)
      '<html><body><h1>500 Internal Server Error</h1></body></html>',

      // Plain text
      'Login successful',

      // Empty string
      '',

      // Just whitespace
      '   \n  \t  ',

      // Invalid escape sequences
      '{"message": "Hello \\invalid world"}',

      // Mixed encodings
      '{"arabic": "مرحبا", "emoji": "🔐", "english": "hello"}',
    ];

    for (int i = 0; i < problematicResponses.length; i++) {
      print('🔍 Problematic Response ${i + 1}:');
      _testSingleResponse(problematicResponses[i], expectError: true);
      print('');
    }
  }

  /// Test decoding with different HTTP status codes context
  static void testHttpStatusDecoding() {
    print('🔍 HTTP STATUS CONTEXT DECODING TEST');
    print('🔍 ==================================');

    final statusTests = [
      {
        'status': 200,
        'body': '{"success": true, "message": "OK"}',
        'description': 'Success 200'
      },
      {
        'status': 201,
        'body': '{"success": true, "user": {"id": 123}}',
        'description': 'Created 201'
      },
      {
        'status': 400,
        'body': '{"error": "Bad Request", "message": "Invalid input"}',
        'description': 'Bad Request 400'
      },
      {
        'status': 401,
        'body': '{"error": "Unauthorized", "message": "Invalid credentials"}',
        'description': 'Unauthorized 401'
      },
      {
        'status': 403,
        'body': '{"error": "Forbidden", "message": "Access denied"}',
        'description': 'Forbidden 403'
      },
      {
        'status': 404,
        'body': '{"error": "Not Found", "message": "Endpoint not found"}',
        'description': 'Not Found 404'
      },
      {
        'status': 429,
        'body': '{"error": "Rate Limited", "retry_after": 60}',
        'description': 'Rate Limited 429'
      },
      {
        'status': 500,
        'body': '{"error": "Internal Server Error", "message": "Something went wrong"}',
        'description': 'Server Error 500'
      },
      {
        'status': 503,
        'body': '{"error": "Service Unavailable", "message": "Server temporarily down"}',
        'description': 'Service Unavailable 503'
      },
      // Status code vs body mismatch
      {
        'status': 200,
        'body': '{"success": false, "error": "Actually failed"}',
        'description': 'Status/Body Mismatch'
      },
    ];

    for (final test in statusTests) {
      print('🔍 ${test['description']} (${test['status']}):');
      print('🔍   Body: ${test['body']}');

      try {
        final decoded = jsonDecode(test['body'] as String);
        print('🔍   ✅ Decoded successfully: $decoded');

        // Analyze response based on status code
        final status = test['status'] as int;
        if (status >= 200 && status < 300) {
          // Success status
          if (decoded is Map && (decoded['success'] == false || decoded.containsKey('error'))) {
            print('🔍   ⚠️  WARNING: Success status but error in body!');
          }
        } else {
          // Error status
          if (decoded is Map && decoded['success'] == true) {
            print('🔍   ⚠️  WARNING: Error status but success in body!');
          }
        }

        // Check for required fields based on context
        _analyzeResponseFields(decoded, status);

      } catch (e) {
        print('🔍   ❌ Decoding failed: $e');
      }

      print('');
    }
  }

  /// Test your actual API response handling logic
  static void testApiResponseHandling() {
    print('🔍 API RESPONSE HANDLING SIMULATION');
    print('🔍 =================================');

    final responses = [
      // What your API might actually return
      '{"success": true, "token": "real_jwt_token_here", "user": {"id": 1, "email": "test@example.com", "name": "Test User"}}',
      '{"success": false, "message": "Invalid email or password"}',
      '{"error": "validation_failed", "details": {"email": "Email format is invalid"}}',
    ];

    for (int i = 0; i < responses.length; i++) {
      final response = responses[i];
      print('🔍 API Response ${i + 1}:');
      print('🔍   Raw: $response');

      try {
        final decoded = jsonDecode(response);
        print('🔍   ✅ Parsed: $decoded');

        // Simulate your actual response handling logic
        _simulateResponseHandling(decoded);

      } catch (e) {
        print('🔍   ❌ Parsing failed: $e');
        print('🔍   This would cause your app to crash or show wrong error!');
      }

      print('');
    }
  }

  /// Test UTF-8 and encoding issues in responses
  static void testEncodingIssues() {
    print('🔍 RESPONSE ENCODING ISSUES TEST');
    print('🔍 ==============================');

    // Simulate different encoding scenarios
    final encodingTests = [
      {
        'name': 'UTF-8 Arabic',
        'bytes': utf8.encode('{"message": "مرحبا بك", "success": true}'),
      },
      {
        'name': 'UTF-8 Emojis',
        'bytes': utf8.encode('{"message": "Login successful! 🎉✅", "success": true}'),
      },
      {
        'name': 'Mixed Languages',
        'bytes': utf8.encode('{"message": "Welcome مرحبا Hello 你好", "success": true}'),
      },
      {
        'name': 'Special Characters',
        'bytes': utf8.encode('{"message": "User: test@domain.com (ID: #123)", "success": true}'),
      },
    ];

    for (final test in encodingTests) {
      print('🔍 ${test['name']}:');
      final bytes = test['bytes'] as List<int>;

      try {
        // Simulate receiving bytes from HTTP response
        final stringResponse = utf8.decode(bytes);
        print('🔍   ✅ UTF-8 decoded: $stringResponse');

        final jsonDecoded = jsonDecode(stringResponse);
        print('🔍   ✅ JSON parsed: $jsonDecoded');

        // Check if message is readable
        if (jsonDecoded is Map && jsonDecoded['message'] != null) {
          final message = jsonDecoded['message'].toString();
          print('🔍   Message: "$message"');
          print('🔍   Message length: ${message.length} characters');
        }

      } catch (e) {
        print('🔍   ❌ Failed: $e');
      }

      print('');
    }
  }

  /// Helper method to test a single response
  static void _testSingleResponse(String responseBody, {bool expectError = false}) {
    print('🔍   Raw response: "$responseBody"');
    print('🔍   Length: ${responseBody.length} characters');

    try {
      final decoded = jsonDecode(responseBody);

      if (expectError) {
        print('🔍   ⚠️  Expected error but decoded successfully: $decoded');
      } else {
        print('🔍   ✅ Decoded successfully: $decoded');
      }

      // Analyze the decoded response
      _analyzeDecodedResponse(decoded);

    } catch (e) {
      if (expectError) {
        print('🔍   ✅ Failed as expected: $e');
      } else {
        print('🔍   ❌ Decoding failed: $e');
        print('🔍   Error type: ${e.runtimeType}');

        // Try to identify the issue
        _diagnoseDecodingError(responseBody, e);
      }
    }
  }

  /// Analyze decoded response structure
  static void _analyzeDecodedResponse(dynamic decoded) {
    if (decoded == null) {
      print('🔍   ⚠️  Response is null');
      return;
    }

    if (decoded is Map) {
      print('🔍   Type: Map with ${decoded.keys.length} keys');
      print('🔍   Keys: ${decoded.keys.toList()}');

      // Check for common login response fields
      if (decoded.containsKey('success')) {
        print('🔍   Success field: ${decoded['success']}');
      }
      if (decoded.containsKey('token') || decoded.containsKey('access_token')) {
        print('🔍   ✅ Contains authentication token');
      }
      if (decoded.containsKey('message')) {
        print('🔍   Message: "${decoded['message']}"');
      }
      if (decoded.containsKey('error')) {
        print('🔍   Error: "${decoded['error']}"');
      }
      if (decoded.containsKey('user')) {
        print('🔍   ✅ Contains user data: ${decoded['user']}');
      }

    } else if (decoded is List) {
      print('🔍   Type: List with ${decoded.length} items');
    } else {
      print('🔍   Type: ${decoded.runtimeType}');
      print('🔍   Value: $decoded');
    }
  }

  /// Analyze response fields based on HTTP status
  static void _analyzeResponseFields(dynamic decoded, int statusCode) {
    if (decoded is! Map) return;

    if (statusCode >= 200 && statusCode < 300) {
      // Success responses should have positive indicators
      final hasSuccess = decoded['success'] == true;
      final hasToken = decoded.containsKey('token') || decoded.containsKey('access_token');
      final hasUser = decoded.containsKey('user');

      if (!hasSuccess && !hasToken && !hasUser) {
        print('🔍   ⚠️  Success status but no success indicators in body');
      }
    } else if (statusCode >= 400) {
      // Error responses should have error information
      final hasError = decoded.containsKey('error') ||
          decoded.containsKey('message') ||
          decoded['success'] == false;

      if (!hasError) {
        print('🔍   ⚠️  Error status but no error information in body');
      }
    }
  }

  /// Simulate your actual response handling logic
  static void _simulateResponseHandling(dynamic decoded) {
    print('🔍   🎯 Simulating your response handling:');

    if (decoded is! Map<String, dynamic>) {
      print('🔍     ❌ Would fail: Response is not a Map');
      return;
    }

    final response = decoded;

    // Check success field
    if (response.containsKey('success')) {
      if (response['success'] == true) {
        print('🔍     ✅ Success detected');

        // Check for token
        if (response.containsKey('token')) {
          print('🔍     ✅ Token found: ${response['token']}');
        } else {
          print('🔍     ⚠️  No token in success response');
        }

        // Check for user data
        if (response.containsKey('user')) {
          print('🔍     ✅ User data found: ${response['user']}');
        }

      } else {
        print('🔍     ❌ Failure detected');

        // Check for error message
        if (response.containsKey('message')) {
          print('🔍     Error message: "${response['message']}"');
        } else {
          print('🔍     ⚠️  No error message provided');
        }
      }
    } else {
      print('🔍     ⚠️  No success field - unclear if success or error');

      // Check for token (might indicate success)
      if (response.containsKey('token')) {
        print('🔍     ✅ Has token - probably success');
      }

      // Check for error (might indicate failure)
      if (response.containsKey('error')) {
        print('🔍     ❌ Has error field - probably failure');
      }
    }
  }

  /// Diagnose why decoding failed
  static void _diagnoseDecodingError(String responseBody, dynamic error) {
    print('🔍   🔧 Diagnosing decoding error:');

    if (responseBody.isEmpty) {
      print('🔍     Issue: Empty response body');
      return;
    }

    if (!responseBody.trim().startsWith('{') && !responseBody.trim().startsWith('[')) {
      print('🔍     Issue: Response doesn\'t start with { or [ - not JSON');
      print('🔍     First 50 chars: "${responseBody.length > 50 ? responseBody.substring(0, 50) + '...' : responseBody}"');
      return;
    }

    // Check for common JSON issues
    if (responseBody.contains("'")) {
      print('🔍     Issue: Contains single quotes - JSON requires double quotes');
    }

    if (responseBody.contains(',}') || responseBody.contains(',]')) {
      print('🔍     Issue: Trailing comma detected');
    }

    if (responseBody.contains('\\')) {
      print('🔍     Issue: Contains backslashes - possible escape sequence problem');
    }

    if (error.toString().contains('Unexpected character')) {
      print('🔍     Issue: Invalid character in JSON');
    }

    if (error.toString().contains('Unexpected end of input')) {
      print('🔍     Issue: JSON is incomplete/truncated');
    }
  }

  /// Run all response decoding tests
  static void runAllTests() {
    print('🔍 =============================================');
    print('🔍 COMPREHENSIVE JSON RESPONSE DECODING TESTS');
    print('🔍 =============================================\n');

    testLoginSuccessDecoding();
    print('\n');

    testLoginErrorDecoding();
    print('\n');

    testHttpStatusDecoding();
    print('\n');

    testApiResponseHandling();
    print('\n');

    testEncodingIssues();
    print('\n');

    testProblematicResponses();

    print('\n🔍 =============================================');
    print('🔍 ALL RESPONSE DECODING TESTS COMPLETED');
    print('🔍 =============================================');
    print('🔍 SUMMARY:');
    print('🔍 - ✅ means your response decoding should work');
    print('🔍 - ❌ means there could be issues with that response type');
    print('🔍 - ⚠️  means potential edge case to handle');
    print('🔍 =============================================');
  }

  /// Test a specific response you received
  static void testSpecificResponse(String responseBody, {int? statusCode}) {
    print('🔍 ==========================================');
    print('🔍 TESTING SPECIFIC RESPONSE');
    print('🔍 ==========================================');
    if (statusCode != null) {
      print('🔍 HTTP Status: $statusCode');
    }
    print('🔍 Response Body: "$responseBody"');
    print('🔍 ==========================================');

    _testSingleResponse(responseBody);

    print('🔍 ==========================================');
  }

  /// Quick test for a response you're having trouble with
  static void quickResponseTest(String response) {
    try {
      final decoded = jsonDecode(response);
      print('🔍 QUICK: ✅ "$response" -> $decoded');
    } catch (e) {
      print('🔍 QUICK: ❌ "$response" -> ERROR: $e');
    }
  }
}