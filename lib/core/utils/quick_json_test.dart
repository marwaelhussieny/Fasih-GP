// lib/core/utils/quick_json_test.dart
// QUICK TEST FOR JSON ENCODING ISSUES

import 'dart:convert';

class QuickJsonTest {

  /// Quick test to verify JSON encoding is working correctly
  static void testLoginJsonEncoding({
    required String email,
    required String password,
  }) {
    print('🧪 QUICK JSON TEST START');
    print('🧪 ======================');

    // Test 1: Basic encoding
    final requestData = {
      'email': email.trim().toLowerCase(),
      'password': password.trim(),
    };

    print('🧪 Original data: $requestData');

    try {
      final encoded = jsonEncode(requestData);
      print('🧪 ✅ JSON Encoded: $encoded');

      // Test 2: Decoding roundtrip
      final decoded = jsonDecode(encoded) as Map<String, dynamic>;
      print('🧪 ✅ JSON Decoded: $decoded');

      // Test 3: Validation
      if (decoded['email'] == requestData['email'] &&
          decoded['password'] == requestData['password']) {
        print('🧪 ✅ Roundtrip validation PASSED');
      } else {
        print('🧪 ❌ Roundtrip validation FAILED');
        print('🧪   Expected email: ${requestData['email']}');
        print('🧪   Got email: ${decoded['email']}');
      }

      // Test 4: UTF-8 encoding
      final utf8Bytes = utf8.encode(encoded);
      final utf8Decoded = utf8.decode(utf8Bytes);
      print('🧪 ✅ UTF-8 test: ${utf8Decoded == encoded ? 'PASSED' : 'FAILED'}');

      // Test 5: Manual JSON construction (should match)
      final manualJson = '{"email":"${requestData['email']}","password":"${requestData['password']}"}';
      print('🧪 Manual JSON: $manualJson');
      print('🧪 Auto JSON:   $encoded');
      print('🧪 Match: ${manualJson == encoded ? '✅ YES' : '❌ NO'}');

    } catch (e) {
      print('🧪 ❌ JSON encoding FAILED: $e');
    }

    print('🧪 ======================');
    print('🧪 QUICK JSON TEST END');
  }

  /// Test what your API service is actually sending
  static String simulateApiServiceEncoding(Map<String, dynamic> body) {
    print('🧪 SIMULATING API SERVICE ENCODING');
    print('🧪 ================================');

    try {
      // This is what your _encodeBody method does:
      if (body.isEmpty) {
        print('🧪 Body is empty, returning null');
        return '';
      }

      // Validate JSON serializable (simplified)
      final encoded = jsonEncode(body);
      print('🧪 API Service would encode: $encoded');
      return encoded;

    } catch (e) {
      print('🧪 ❌ API Service encoding failed: $e');
      rethrow;
    }
  }

  /// Compare different encoding approaches
  static void compareEncodingApproaches({
    required String email,
    required String password,
  }) {
    print('🧪 COMPARING ENCODING APPROACHES');
    print('🧪 ===============================');

    final cleanEmail = email.trim().toLowerCase();
    final cleanPassword = password.trim();

    // Approach 1: Direct map
    final map1 = {'email': cleanEmail, 'password': cleanPassword};
    final json1 = jsonEncode(map1);
    print('🧪 Approach 1 (direct map): $json1');

    // Approach 2: Map.from
    final map2 = Map<String, dynamic>.from({'email': cleanEmail, 'password': cleanPassword});
    final json2 = jsonEncode(map2);
    print('🧪 Approach 2 (Map.from): $json2');

    // Approach 3: Explicit typing
    final Map<String, dynamic> map3 = <String, dynamic>{
      'email': cleanEmail,
      'password': cleanPassword,
    };
    final json3 = jsonEncode(map3);
    print('🧪 Approach 3 (explicit typing): $json3');

    // Approach 4: Manual string
    final json4 = '{"email":"$cleanEmail","password":"$cleanPassword"}';
    print('🧪 Approach 4 (manual): $json4');

    // Check if all match
    final allMatch = json1 == json2 && json2 == json3 && json3 == json4;
    print('🧪 All approaches match: ${allMatch ? '✅ YES' : '❌ NO'}');

    if (!allMatch) {
      print('🧪 ❌ MISMATCH DETECTED!');
      print('🧪   json1 == json2: ${json1 == json2}');
      print('🧪   json2 == json3: ${json2 == json3}');
      print('🧪   json3 == json4: ${json3 == json4}');
    }
  }

  /// Test with problematic characters
  static void testProblematicCharacters() {
    print('🧪 TESTING PROBLEMATIC CHARACTERS');
    print('🧪 =================================');

    final testCases = [
      {'email': 'test@example.com', 'password': 'مرحبا'}, // Arabic
      {'email': 'أحمد@example.com', 'password': 'test'}, // Arabic email
      {'email': 'test@example.com', 'password': 'with&ampersand'},
      {'email': 'test@example.com', 'password': 'with%percent'},
      {'email': 'test@example.com', 'password': 'with#hash'},
      {'email': 'test@example.com', 'password': 'with?question'},
      {'email': 'test@example.com', 'password': 'with=equals'},
      {'email': 'test@example.com', 'password': 'with spaces'},
      {'email': 'test@example.com', 'password': 'with🔐emoji'},
      {'email': 'test@example.com', 'password': 'UPPERCASE'},
      {'email': 'test@example.com', 'password': 'MiXeD_cAsE123!@#'},
      {'email': 'TEST@EXAMPLE.COM', 'password': 'lowercase'}, // Uppercase email
      {'email': '  test@example.com  ', 'password': '  password  '}, // With spaces
      {'email': 'test@example.com', 'password': ''}, // Empty password
      {'email': '', 'password': 'test'}, // Empty email
      {'email': 'test+tag@example.com', 'password': 'with+plus'},
      {'email': 'test@example.com', 'password': 'with"quotes'},
      {'email': 'test@example.com', 'password': "with'apostrophe"},
      {'email': 'test@example.com', 'password': 'with\nnewline'},
      {'email': 'test@example.com', 'password': 'with\ttab'},
      {'email': 'test@example.com', 'password': 'with\\backslash'},
      {'email': 'test@example.com', 'password': 'with/slash'},
    ];

    for (int i = 0; i < testCases.length; i++) {
      final testCase = testCases[i];
      print('🧪 Test ${i + 1}: "${testCase['email']}" / "${testCase['password']}"');

      try {
        final encoded = jsonEncode(testCase);
        final decoded = jsonDecode(encoded) as Map<String, dynamic>;

        final emailMatch = decoded['email'] == testCase['email'];
        final passwordMatch = decoded['password'] == testCase['password'];

        if (emailMatch && passwordMatch) {
          print('🧪   ✅ PASSED - JSON: $encoded');
        } else {
          print('🧪   ❌ FAILED - JSON: $encoded');
          if (!emailMatch) {
            print('🧪     Email: expected "${testCase['email']}", got "${decoded['email']}"');
          }
          if (!passwordMatch) {
            print('🧪     Password: expected "${testCase['password']}", got "${decoded['password']}"');
          }
        }

        // Test byte length
        final utf8Bytes = utf8.encode(encoded);
        print('🧪   Byte length: ${utf8Bytes.length}');

        // Test special characters handling
        final hasSpecialChars = encoded.contains('\\') ||
            encoded.contains('\\"') ||
            encoded.contains('\\n') ||
            encoded.contains('\\t');
        if (hasSpecialChars) {
          print('🧪   ⚠️  Contains escaped characters');
        }

      } catch (e) {
        print('🧪   ❌ ENCODING ERROR: $e');
        print('🧪   Error type: ${e.runtimeType}');
      }

      print(''); // Empty line for readability
    }
  }

  /// Test HTTP body formatting specifically
  static void testHttpBodyFormatting({
    required String email,
    required String password,
  }) {
    print('🧪 HTTP BODY FORMATTING TEST');
    print('🧪 ===========================');

    final cleanEmail = email.trim().toLowerCase();
    final cleanPassword = password.trim();

    final requestData = {
      'email': cleanEmail,
      'password': cleanPassword,
    };

    // Test 1: Standard JSON encoding
    final standardJson = jsonEncode(requestData);
    print('🧪 Standard JSON: $standardJson');

    // Test 2: Manual JSON with proper escaping
    final manualJson = _buildJsonManually(cleanEmail, cleanPassword);
    print('🧪 Manual JSON: $manualJson');

    // Test 3: Check if they match
    final match = standardJson == manualJson;
    print('🧪 JSONs match: ${match ? '✅ YES' : '❌ NO'}');

    if (!match) {
      print('🧪 ❌ DIFFERENCE DETECTED:');
      print('🧪   Standard: $standardJson');
      print('🧪   Manual:   $manualJson');

      // Character by character comparison
      final standardChars = standardJson.split('');
      final manualChars = manualJson.split('');
      final maxLength = standardChars.length > manualChars.length
          ? standardChars.length
          : manualChars.length;

      for (int i = 0; i < maxLength; i++) {
        final standardChar = i < standardChars.length ? standardChars[i] : 'EOF';
        final manualChar = i < manualChars.length ? manualChars[i] : 'EOF';

        if (standardChar != manualChar) {
          print('🧪   Diff at position $i: "$standardChar" vs "$manualChar"');
          break;
        }
      }
    }

    // Test 4: UTF-8 encoding
    final standardBytes = utf8.encode(standardJson);
    final manualBytes = utf8.encode(manualJson);

    print('🧪 Standard bytes: ${standardBytes.length} - $standardBytes');
    print('🧪 Manual bytes: ${manualBytes.length} - $manualBytes');

    // Test 5: HTTP Content-Length would be
    print('🧪 Content-Length would be: ${standardBytes.length}');

    // Test 6: Simulate HTTP body exactly as sent
    print('🧪 Exact HTTP body simulation:');
    print('🧪 Headers: Content-Type: application/json; charset=utf-8');
    print('🧪 Body bytes: $standardBytes');
    print('🧪 Body string: "$standardJson"');
  }

  /// Build JSON manually to compare with automatic encoding
  static String _buildJsonManually(String email, String password) {
    // Escape special characters manually
    final escapedEmail = email
        .replaceAll('\\', '\\\\')
        .replaceAll('"', '\\"')
        .replaceAll('\n', '\\n')
        .replaceAll('\r', '\\r')
        .replaceAll('\t', '\\t');

    final escapedPassword = password
        .replaceAll('\\', '\\\\')
        .replaceAll('"', '\\"')
        .replaceAll('\n', '\\n')
        .replaceAll('\r', '\\r')
        .replaceAll('\t', '\\t');

    return '{"email":"$escapedEmail","password":"$escapedPassword"}';
  }

  /// Test what happens with different data types
  static void testDataTypes() {
    print('🧪 DATA TYPES TEST');
    print('🧪 ================');

    final testCases = [
      // Standard case
      {'email': 'test@example.com', 'password': 'password123'},

      // Numbers in strings (should remain strings)
      {'email': 'user123@example.com', 'password': '123456'},

      // Boolean-like strings (should remain strings)
      {'email': 'test@example.com', 'password': 'true'},
      {'email': 'test@example.com', 'password': 'false'},

      // Null-like strings (should remain strings)
      {'email': 'test@example.com', 'password': 'null'},
      {'email': 'test@example.com', 'password': 'undefined'},

      // JSON-like strings (should be escaped)
      {'email': 'test@example.com', 'password': '{"key":"value"}'},
      {'email': 'test@example.com', 'password': '[1,2,3]'},

      // With actual null (should handle gracefully)
      {'email': 'test@example.com', 'password': null},
    ];

    for (int i = 0; i < testCases.length; i++) {
      final testCase = testCases[i];
      print('🧪 Data type test ${i + 1}:');
      print('🧪   Email: ${testCase['email']} (${testCase['email'].runtimeType})');
      print('🧪   Password: ${testCase['password']} (${testCase['password'].runtimeType})');

      try {
        final encoded = jsonEncode(testCase);
        print('🧪   ✅ JSON: $encoded');

        final decoded = jsonDecode(encoded);
        print('🧪   ✅ Decoded types: email=${decoded['email'].runtimeType}, password=${decoded['password'].runtimeType}');

        // Check if types are preserved
        if (testCase['email'].runtimeType == decoded['email'].runtimeType &&
            testCase['password'].runtimeType == decoded['password'].runtimeType) {
          print('🧪   ✅ Types preserved correctly');
        } else {
          print('🧪   ⚠️  Type change detected');
        }

      } catch (e) {
        print('🧪   ❌ Failed: $e');
      }

      print(''); // Empty line
    }
  }

  /// Test edge cases that might break JSON encoding
  static void testEdgeCases() {
    print('🧪 EDGE CASES TEST');
    print('🧪 ================');

    // Test empty data
    print('🧪 Testing empty data...');
    try {
      final emptyData = <String, dynamic>{};
      final emptyJson = jsonEncode(emptyData);
      print('🧪   ✅ Empty object: $emptyJson');
    } catch (e) {
      print('🧪   ❌ Empty object failed: $e');
    }

    // Test very long strings
    print('🧪 Testing very long strings...');
    try {
      final longEmail = 'very.long.email.address.that.might.cause.issues@very-long-domain-name-example.com';
      final longPassword = 'a' * 1000; // 1000 character password
      final longData = {'email': longEmail, 'password': longPassword};
      final longJson = jsonEncode(longData);
      print('🧪   ✅ Long strings: ${longJson.length} characters');
    } catch (e) {
      print('🧪   ❌ Long strings failed: $e');
    }

    // Test unicode characters
    print('🧪 Testing Unicode characters...');
    try {
      final unicodeData = {
        'email': 'tëst@éxämplë.com',
        'password': 'pässwörd123'
      };
      final unicodeJson = jsonEncode(unicodeData);
      print('🧪   ✅ Unicode: $unicodeJson');
    } catch (e) {
      print('🧪   ❌ Unicode failed: $e');
    }

    // Test control characters
    print('🧪 Testing control characters...');
    try {
      final controlData = {
        'email': 'test@example.com',
        'password': 'pass\u0000word\u0001test\u001f'
      };
      final controlJson = jsonEncode(controlData);
      print('🧪   ✅ Control chars: $controlJson');
    } catch (e) {
      print('🧪   ❌ Control chars failed: $e');
    }

    // Test high Unicode characters (emojis, etc.)
    print('🧪 Testing high Unicode characters...');
    try {
      final emojiData = {
        'email': '👤@example.com',
        'password': '🔐password🚀'
      };
      final emojiJson = jsonEncode(emojiData);
      print('🧪   ✅ High Unicode: $emojiJson');
    } catch (e) {
      print('🧪   ❌ High Unicode failed: $e');
    }
  }

  /// Comprehensive test that matches your API service behavior
  static void testApiServiceBehavior({
    required String email,
    required String password,
  }) {
    print('🧪 API SERVICE BEHAVIOR TEST');
    print('🧪 ============================');

    // Simulate your exact validation and encoding process
    try {
      // Step 1: Input validation (from your code)
      final cleanEmail = email.trim().toLowerCase();
      final cleanPassword = password.trim();

      print('🧪 Step 1 - Input cleaning:');
      print('🧪   Original email: "$email"');
      print('🧪   Clean email: "$cleanEmail"');
      print('🧪   Email changed: ${email != cleanEmail}');
      print('🧪   Password changed: ${password != cleanPassword}');

      // Step 2: Email validation
      final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
      final isValidEmail = emailRegex.hasMatch(cleanEmail);
      print('🧪 Step 2 - Email validation: ${isValidEmail ? '✅ VALID' : '❌ INVALID'}');

      if (!isValidEmail) {
        print('🧪   ❌ Email validation would fail here!');
        return;
      }

      // Step 3: Create request data (exactly like your code)
      final requestData = {
        'email': cleanEmail,
        'password': cleanPassword,
      };
      print('🧪 Step 3 - Request data created: $requestData');

      // Step 4: JSON validation (from your _validateJsonData)
      try {
        final encoded = jsonEncode(requestData);
        final decoded = jsonDecode(encoded) as Map<String, dynamic>;

        if (decoded.keys.length != requestData.keys.length) {
          print('🧪   ❌ JSON validation would fail: key count mismatch');
          return;
        }

        print('🧪 Step 4 - JSON validation: ✅ PASSED');
        print('🧪   Encoded: $encoded');

        // Step 5: Simulate actual encoding in _encodeBody
        print('🧪 Step 5 - Final encoding:');
        print('🧪   Final JSON: $encoded');
        print('🧪   Byte length: ${utf8.encode(encoded).length}');
        print('🧪   UTF-8 bytes: ${utf8.encode(encoded)}');

        // Step 6: Headers simulation
        final headers = <String, String>{
          'Content-Type': 'application/json; charset=utf-8',
          'Accept': 'application/json',
          'ngrok-skip-browser-warning': 'true',
          'User-Agent': 'FlutterApp/1.0',
        };
        print('🧪 Step 6 - Headers: $headers');

        print('🧪 ✅ Complete API service simulation PASSED');
        print('🧪 This request should work with your current implementation.');

      } catch (e) {
        print('🧪   ❌ JSON validation failed: $e');
      }

    } catch (e) {
      print('🧪 ❌ API service simulation failed: $e');
    }
  }

  /// Run all quick tests
  static void runAllTests({
    required String email,
    required String password,
  }) {
    print('🧪 =============================================');
    print('🧪 COMPREHENSIVE JSON ENCODING TEST SUITE');
    print('🧪 =============================================');
    print('🧪 Testing with email: "$email"');
    print('🧪 Testing with password: "[${password.length} characters]"');
    print('🧪 =============================================\n');

    // Test 1: Basic JSON encoding
    testLoginJsonEncoding(email: email, password: password);
    print('');

    // Test 2: API Service simulation
    final loginData = {
      'email': email.trim().toLowerCase(),
      'password': password.trim(),
    };
    simulateApiServiceEncoding(loginData);
    print('');

    // Test 3: Encoding approaches comparison
    compareEncodingApproaches(email: email, password: password);
    print('');

    // Test 4: HTTP body formatting
    testHttpBodyFormatting(email: email, password: password);
    print('');

    // Test 5: Data types handling
    testDataTypes();
    print('');

    // Test 6: Edge cases
    testEdgeCases();
    print('');

    // Test 7: Problematic characters
    testProblematicCharacters();
    print('');

    // Test 8: Complete API service behavior simulation
    testApiServiceBehavior(email: email, password: password);

    print('\n🧪 =============================================');
    print('🧪 ALL TESTS COMPLETED');
    print('🧪 =============================================');
    print('🧪 SUMMARY:');
    print('🧪 - If all tests show ✅, your JSON encoding is correct');
    print('🧪 - If you see ❌, there\'s an encoding issue to fix');
    print('🧪 - Pay special attention to the API Service Behavior test');
    print('🧪 =============================================');
  }

  /// Quick one-liner test for debugging
  static void quickTest(String email, String password) {
    final data = {'email': email.trim().toLowerCase(), 'password': password.trim()};
    final json = jsonEncode(data);
    final decoded = jsonDecode(json);
    print('🧪 QUICK: $json -> ${decoded == data ? '✅' : '❌'}');
  }

  /// Test network encoding simulation
  static void testNetworkEncoding({
    required String email,
    required String password,
  }) {
    print('🧪 NETWORK ENCODING SIMULATION');
    print('🧪 ==============================');

    final requestData = {
      'email': email.trim().toLowerCase(),
      'password': password.trim(),
    };

    try {
      // Simulate what happens during HTTP request
      final jsonString = jsonEncode(requestData);
      final bodyBytes = utf8.encode(jsonString);

      print('🧪 Request data: $requestData');
      print('🧪 JSON string: "$jsonString"');
      print('🧪 Body bytes: $bodyBytes');
      print('🧪 Content-Length: ${bodyBytes.length}');

      // Simulate server receiving and decoding
      final receivedString = utf8.decode(bodyBytes);
      final receivedData = jsonDecode(receivedString);

      print('🧪 Server received: "$receivedString"');
      print('🧪 Server decoded: $receivedData');

      // Verify integrity
      final dataMatch = receivedData['email'] == requestData['email'] &&
          receivedData['password'] == requestData['password'];

      print('🧪 Data integrity: ${dataMatch ? '✅ PRESERVED' : '❌ CORRUPTED'}');

      if (!dataMatch) {
        print('🧪 ❌ CORRUPTION DETAILS:');
        print('🧪   Original email: "${requestData['email']}"');
        print('🧪   Received email: "${receivedData['email']}"');
        print('🧪   Original password: "${requestData['password']}"');
        print('🧪   Received password: "${receivedData['password']}"');
      }

    } catch (e) {
      print('🧪 ❌ Network simulation failed: $e');
    }
  }

  /// Validate specific login scenario
  static void validateLoginScenario(String email, String password) {
    print('🧪 =========================================');
    print('🧪 VALIDATING LOGIN SCENARIO');
    print('🧪 =========================================');
    print('🧪 Email: "$email"');
    print('🧪 Password: "[HIDDEN - ${password.length} chars]"');
    print('🧪 =========================================');

    // Quick validation
    quickTest(email, password);
    print('');

    // Network simulation
    testNetworkEncoding(email: email, password: password);
    print('');

    // Full API behavior test
    testApiServiceBehavior(email: email, password: password);

    print('🧪 =========================================');
    print('🧪 LOGIN SCENARIO VALIDATION COMPLETE');
    print('🧪 =========================================');
  }
}