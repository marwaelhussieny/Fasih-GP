// lib/core/utils/json_request_test.dart
// UTILITY FOR TESTING JSON REQUEST/RESPONSE HANDLING

import 'dart:convert';
import 'package:grad_project/core/services/api_service.dart';
import 'package:grad_project/core/types/auth_tokens.dart';

class JsonRequestTest {
  final ApiService apiService;

  JsonRequestTest({required this.apiService});

  /// Test JSON encoding/decoding for authentication requests
  Future<void> testAuthJsonHandling() async {
    print('🧪 Starting JSON handling tests...');

    // Test 1: SignUp JSON encoding
    await _testSignUpJson();

    // Test 2: Login JSON encoding
    await _testLoginJson();

    // Test 3: OTP JSON encoding
    await _testOtpJson();

    // Test 4: Token parsing
    await _testTokenParsing();

    print('🧪 JSON handling tests completed');
  }

  Future<void> _testSignUpJson() async {
    print('🧪 Test 1: SignUp JSON encoding');

    final signUpData = {
      'fullName': 'أحمد محمد',
      'email': 'ahmed@example.com',
      'password': 'password123',
      'confirmPassword': 'password123',
    };

    try {
      // Test JSON encoding
      final encoded = jsonEncode(signUpData);
      print('✅ SignUp JSON encoded: $encoded');

      // Test JSON decoding
      final decoded = jsonDecode(encoded) as Map<String, dynamic>;
      print('✅ SignUp JSON decoded: $decoded');

      // Validate all fields are preserved
      assert(decoded['fullName'] == signUpData['fullName']);
      assert(decoded['email'] == signUpData['email']);
      assert(decoded['password'] == signUpData['password']);
      assert(decoded['confirmPassword'] == signUpData['confirmPassword']);

      print('✅ SignUp JSON validation passed');
    } catch (e) {
      print('❌ SignUp JSON test failed: $e');
    }
  }

  Future<void> _testLoginJson() async {
    print('🧪 Test 2: Login JSON encoding');

    final loginData = {
      'email': 'user@example.com',
      'password': 'mypassword',
    };

    try {
      // Test JSON encoding
      final encoded = jsonEncode(loginData);
      print('✅ Login JSON encoded: $encoded');

      // Test JSON decoding
      final decoded = jsonDecode(encoded) as Map<String, dynamic>;
      print('✅ Login JSON decoded: $decoded');

      // Validate fields
      assert(decoded['email'] == loginData['email']);
      assert(decoded['password'] == loginData['password']);

      print('✅ Login JSON validation passed');
    } catch (e) {
      print('❌ Login JSON test failed: $e');
    }
  }

  Future<void> _testOtpJson() async {
    print('🧪 Test 3: OTP JSON encoding');

    final otpData = {
      'email': 'user@example.com',
      'otp': '123456',
    };

    try {
      // Test JSON encoding
      final encoded = jsonEncode(otpData);
      print('✅ OTP JSON encoded: $encoded');

      // Test JSON decoding
      final decoded = jsonDecode(encoded) as Map<String, dynamic>;
      print('✅ OTP JSON decoded: $decoded');

      // Validate fields
      assert(decoded['email'] == otpData['email']);
      assert(decoded['otp'] == otpData['otp']);

      print('✅ OTP JSON validation passed');
    } catch (e) {
      print('❌ OTP JSON test failed: $e');
    }
  }

  Future<void> _testTokenParsing() async {
    print('🧪 Test 4: Token parsing');

    // Mock token response from your API
    final mockTokenResponse = {
      'message': 'تم تسجيل الدخول بنجاح',
      'accessToken': 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6IjY4OGU5NDExMzZmNjJhMzc0YWQ2MjVjMSIsImlhdCI6MTc1NDE3NzE4NSwiZXhwIjoxNzU0MTc4MDg1fQ.8nMd0KnzZeLW8hC2tUXaN_8EvLFAPVBuDUYBOe4HWvQ',
      'refreshToken': 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6IjY4OGU5NDExMzZmNjJhMzc0YWQ2MjVjMSIsImlhdCI6MTc1NDE3NzE4NSwiZXhwIjoxNzU0NzgxOTg1fQ.qVPco1QxYjTpnxh9no36uQfAIz9bEwoVNP1WLxGlZwA'
    };

    try {
      // Test JSON encoding of response
      final encoded = jsonEncode(mockTokenResponse);
      print('✅ Token response JSON encoded: $encoded');

      // Test JSON decoding of response
      final decoded = jsonDecode(encoded) as Map<String, dynamic>;
      print('✅ Token response JSON decoded: ${decoded.keys}');

      // Test AuthTokens creation from API response
      final tokens = AuthTokens.fromApiResponse(decoded);
      print('✅ AuthTokens created: ${tokens.toString()}');

      // Test AuthTokens JSON serialization
      final tokensJson = tokens.toJson();
      final tokensEncoded = jsonEncode(tokensJson);
      print('✅ AuthTokens JSON serialized: $tokensEncoded');

      // Test AuthTokens JSON deserialization
      final tokensDecoded = jsonDecode(tokensEncoded) as Map<String, dynamic>;
      final tokensFromJson = AuthTokens.fromJson(tokensDecoded);
      print('✅ AuthTokens deserialized: ${tokensFromJson.toString()}');

      // Validate token fields
      assert(tokens.accessToken == mockTokenResponse['accessToken']);
      assert(tokensFromJson.accessToken == tokens.accessToken);

      print('✅ Token parsing validation passed');
    } catch (e) {
      print('❌ Token parsing test failed: $e');
    }
  }

  /// Test API request with actual network call (optional)
  Future<void> testLiveApiRequest() async {
    print('🧪 Testing live API request with JSON handling...');

    // Test data that should be properly encoded
    final testData = {
      'email': 'test@example.com',
      'password': 'testpass123',
    };

    try {
      print('🧪 Sending test request with JSON: ${jsonEncode(testData)}');

      // This will test the actual JSON encoding/decoding pipeline
      final response = await apiService.post(
        '/api/auth/login',
        body: testData,
      );

      print('✅ Live API request succeeded');
      print('✅ Response received: ${response.keys}');

      // Test response parsing
      if (response.containsKey('accessToken')) {
        final tokens = AuthTokens.fromApiResponse(response);
        print('✅ Token parsing from live response: ${tokens.toString()}');
      }

    } catch (e) {
      print('⚠️ Live API request failed (expected for test data): $e');
      // This is expected since we're using test data
      print('⚠️ This failure is expected when using test credentials');
    }
  }

  /// Test Arabic text handling in JSON
  Future<void> testArabicTextHandling() async {
    print('🧪 Test 5: Arabic text JSON handling');

    final arabicData = {
      'fullName': 'أحمد محمد علي',
      'email': 'ahmed.ali@example.com',
      'message': 'مرحباً بك في التطبيق',
      'specialChars': 'نص عربي مع أرقام ١٢٣ ورموز !@#',
    };

    try {
      // Test JSON encoding with Arabic text
      final encoded = jsonEncode(arabicData);
      print('✅ Arabic JSON encoded: $encoded');

      // Test JSON decoding
      final decoded = jsonDecode(encoded) as Map<String, dynamic>;
      print('✅ Arabic JSON decoded: $decoded');

      // Validate Arabic text preservation
      assert(decoded['fullName'] == arabicData['fullName']);
      assert(decoded['message'] == arabicData['message']);
      assert(decoded['specialChars'] == arabicData['specialChars']);

      print('✅ Arabic text handling validation passed');
    } catch (e) {
      print('❌ Arabic text handling test failed: $e');
    }
  }

  /// Test edge cases and error scenarios
  Future<void> testEdgeCases() async {
    print('🧪 Test 6: Edge cases');

    try {
      // Test empty object
      final empty = <String, dynamic>{};
      final emptyEncoded = jsonEncode(empty);
      final emptyDecoded = jsonDecode(emptyEncoded) as Map<String, dynamic>;
      assert(emptyDecoded.isEmpty);
      print('✅ Empty object handling passed');

      // Test null values
      final withNulls = {
        'validField': 'value',
        'nullField': null,
        'emptyString': '',
      };
      final nullsEncoded = jsonEncode(withNulls);
      final nullsDecoded = jsonDecode(nullsEncoded) as Map<String, dynamic>;
      assert(nullsDecoded['validField'] == 'value');
      assert(nullsDecoded['nullField'] == null);
      assert(nullsDecoded['emptyString'] == '');
      print('✅ Null values handling passed');

      // Test special characters
      final specialChars = {
        'quotes': 'Text with "quotes" and \'apostrophes\'',
        'newlines': 'Line 1\nLine 2\rCarriage return',
        'unicode': '🔐 🌐 ✅ ❌ 🧪',
      };
      final specialEncoded = jsonEncode(specialChars);
      final specialDecoded = jsonDecode(specialEncoded) as Map<String, dynamic>;
      assert(specialDecoded['quotes'] == specialChars['quotes']);
      assert(specialDecoded['newlines'] == specialChars['newlines']);
      assert(specialDecoded['unicode'] == specialChars['unicode']);
      print('✅ Special characters handling passed');

    } catch (e) {
      print('❌ Edge cases test failed: $e');
    }
  }

  /// Run all tests
  Future<void> runAllTests() async {
    print('🧪 =====================================');
    print('🧪 STARTING COMPREHENSIVE JSON TESTS');
    print('🧪 =====================================');

    await testAuthJsonHandling();
    await testArabicTextHandling();
    await testEdgeCases();

    print('🧪 =====================================');
    print('🧪 ALL JSON TESTS COMPLETED');
    print('🧪 =====================================');
  }
}