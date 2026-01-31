// lib/core/utils/login_diagnostics.dart
// COMPREHENSIVE LOGIN REQUEST DIAGNOSTICS

import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

class LoginDiagnostics {
  final String baseUrl;

  LoginDiagnostics({required this.baseUrl});

  /// Comprehensive login request testing with detailed logging
  Future<void> diagnoseLoginRequest({
    required String email,
    required String password,
  }) async {
    print('🔬 ==========================================');
    print('🔬 STARTING LOGIN DIAGNOSTICS');
    print('🔬 ==========================================');

    // Step 1: Input validation
    _diagnoseInputs(email, password);

    // Step 2: JSON encoding test
    final requestData = await _diagnoseJsonEncoding(email, password);

    // Step 3: URL construction test
    final url = await _diagnoseUrlConstruction();

    // Step 4: Headers construction test
    final headers = await _diagnoseHeaders();

    // Step 5: Complete request test
    await _diagnoseCompleteRequest(url, headers, requestData);

    print('🔬 ==========================================');
    print('🔬 LOGIN DIAGNOSTICS COMPLETED');
    print('🔬 ==========================================');
  }

  void _diagnoseInputs(String email, String password) {
    print('🔬 Step 1: Input Validation');
    print('🔬 Raw email: "$email" (length: ${email.length})');
    print('🔬 Raw password: "[REDACTED]" (length: ${password.length})');

    // Check for invisible characters
    final emailBytes = utf8.encode(email);
    final passwordBytes = utf8.encode(password);
    print('🔬 Email UTF-8 bytes: $emailBytes');
    print('🔬 Password UTF-8 bytes length: ${passwordBytes.length}');

    // Clean inputs
    final cleanEmail = email.trim().toLowerCase();
    final cleanPassword = password.trim();

    print('🔬 Clean email: "$cleanEmail" (length: ${cleanEmail.length})');
    print('🔬 Clean password length: ${cleanPassword.length}');

    // Check for changes
    if (email != cleanEmail) {
      print('🔬 ⚠️  Email was modified during cleaning');
    }
    if (password != cleanPassword) {
      print('🔬 ⚠️  Password was modified during cleaning');
    }

    // Validate email format
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    final isValidEmail = emailRegex.hasMatch(cleanEmail);
    print('🔬 Email format valid: $isValidEmail');

    if (!isValidEmail) {
      print('🔬 ❌ Invalid email format detected!');
    }

    print('🔬 ✅ Input validation completed\n');
  }

  Future<Map<String, dynamic>> _diagnoseJsonEncoding(String email, String password) async {
    print('🔬 Step 2: JSON Encoding Diagnostics');

    final cleanEmail = email.trim().toLowerCase();
    final cleanPassword = password.trim();

    final requestData = {
      'email': cleanEmail,
      'password': cleanPassword,
    };

    print('🔬 Request data object: $requestData');
    print('🔬 Request data type: ${requestData.runtimeType}');

    try {
      // Test JSON encoding
      final encoded = jsonEncode(requestData);
      print('🔬 JSON encoded successfully: $encoded');
      print('🔬 Encoded length: ${encoded.length}');
      print('🔬 Encoded bytes: ${utf8.encode(encoded)}');

      // Test JSON decoding (roundtrip test)
      final decoded = jsonDecode(encoded) as Map<String, dynamic>;
      print('🔬 JSON roundtrip successful: $decoded');

      // Validate roundtrip
      if (decoded['email'] == requestData['email'] &&
          decoded['password'] == requestData['password']) {
        print('🔬 ✅ JSON roundtrip validation passed');
      } else {
        print('🔬 ❌ JSON roundtrip validation failed!');
        print('🔬 Original email: "${requestData['email']}"');
        print('🔬 Decoded email: "${decoded['email']}"');
      }

      // Test with different encoding options
      final encodedUtf8 = jsonEncode(requestData);
      final manualJson = '{"email":"$cleanEmail","password":"$cleanPassword"}';
      print('🔬 Manual JSON: $manualJson');
      print('🔬 Auto JSON:   $encodedUtf8');
      print('🔬 JSONs match: ${manualJson == encodedUtf8}');

    } catch (e) {
      print('🔬 ❌ JSON encoding failed: $e');
      print('🔬 Error type: ${e.runtimeType}');
    }

    print('🔬 ✅ JSON encoding diagnostics completed\n');
    return requestData;
  }

  Future<String> _diagnoseUrlConstruction() async {
    print('🔬 Step 3: URL Construction Diagnostics');

    final loginPath = '/api/auth/login';
    final fullUrl = '$baseUrl$loginPath';

    print('🔬 Base URL: "$baseUrl"');
    print('🔬 Login path: "$loginPath"');
    print('🔬 Full URL: "$fullUrl"');

    try {
      final uri = Uri.parse(fullUrl);
      print('🔬 Parsed URI: $uri');
      print('🔬 URI scheme: ${uri.scheme}');
      print('🔬 URI host: ${uri.host}');
      print('🔬 URI port: ${uri.port}');
      print('🔬 URI path: ${uri.path}');
      print('🔬 ✅ URL construction valid');
    } catch (e) {
      print('🔬 ❌ URL construction failed: $e');
    }

    print('🔬 ✅ URL diagnostics completed\n');
    return fullUrl;
  }

  Future<Map<String, String>> _diagnoseHeaders() async {
    print('🔬 Step 4: Headers Diagnostics');

    final headers = <String, String>{
      'Content-Type': 'application/json; charset=utf-8',
      'Accept': 'application/json',
      'ngrok-skip-browser-warning': 'true',
      'User-Agent': 'FlutterApp/1.0',
    };

    print('🔬 Headers constructed:');
    headers.forEach((key, value) {
      print('🔬   $key: $value');
    });

    // Test headers encoding
    try {
      final headersJson = jsonEncode(headers);
      print('🔬 Headers JSON: $headersJson');
      print('🔬 ✅ Headers are JSON serializable');
    } catch (e) {
      print('🔬 ❌ Headers JSON encoding failed: $e');
    }

    print('🔬 ✅ Headers diagnostics completed\n');
    return headers;
  }

  Future<void> _diagnoseCompleteRequest(
      String url,
      Map<String, String> headers,
      Map<String, dynamic> requestData,
      ) async {
    print('🔬 Step 5: Complete Request Diagnostics');

    try {
      final requestBody = jsonEncode(requestData);
      print('🔬 Final request body: $requestBody');
      print('🔬 Request body bytes: ${utf8.encode(requestBody).length}');

      print('🔬 Making HTTP POST request...');
      print('🔬 URL: $url');
      print('🔬 Headers: $headers');
      print('🔬 Body: $requestBody');

      final stopwatch = Stopwatch()..start();

      final response = await http.post(
        Uri.parse(url),
        headers: headers,
        body: requestBody,
        encoding: Encoding.getByName('utf-8'),
      ).timeout(const Duration(seconds: 30));

      stopwatch.stop();

      print('🔬 ✅ Request completed in ${stopwatch.elapsedMilliseconds}ms');
      print('🔬 Response status: ${response.statusCode}');
      print('🔬 Response headers: ${response.headers}');

      // Check content type
      final contentType = response.headers['content-type'] ?? 'none';
      print('🔬 Response content-type: $contentType');

      if (!contentType.contains('application/json')) {
        print('🔬 ⚠️  Response is not JSON!');
      }

      // Log response body
      final responseBody = response.body;
      print('🔬 Response body length: ${responseBody.length}');

      if (responseBody.length > 1000) {
        print('🔬 Response body (first 500 chars): ${responseBody.substring(0, 500)}...');
      } else {
        print('🔬 Response body: $responseBody');
      }

      // Try to parse JSON response
      try {
        if (responseBody.isNotEmpty) {
          final jsonResponse = jsonDecode(responseBody);
          print('🔬 ✅ Response is valid JSON');
          print('🔬 JSON response type: ${jsonResponse.runtimeType}');

          if (jsonResponse is Map) {
            print('🔬 JSON response keys: ${jsonResponse.keys.toList()}');

            // Check for specific fields
            if (jsonResponse.containsKey('message')) {
              print('🔬 Response message: ${jsonResponse['message']}');
            }
            if (jsonResponse.containsKey('accessToken')) {
              print('🔬 ✅ Access token present in response');
            }
            if (jsonResponse.containsKey('status')) {
              print('🔬 Response status: ${jsonResponse['status']}');
            }
          }
        } else {
          print('🔬 ❌ Empty response body');
        }
      } catch (e) {
        print('🔬 ❌ Response JSON parsing failed: $e');
        print('🔬 Raw response (first 200 chars): ${responseBody.length > 200 ? responseBody.substring(0, 200) : responseBody}');
      }

      // Analyze status code
      if (response.statusCode >= 200 && response.statusCode < 300) {
        print('🔬 ✅ Success status code: ${response.statusCode}');
      } else if (response.statusCode == 400) {
        print('🔬 ❌ Bad Request (400) - Check request format');
      } else if (response.statusCode == 401) {
        print('🔬 ❌ Unauthorized (401) - Check credentials');
      } else if (response.statusCode == 422) {
        print('🔬 ❌ Unprocessable Entity (422) - Validation error');
      } else if (response.statusCode >= 500) {
        print('🔬 ❌ Server Error (${response.statusCode})');
      } else {
        print('🔬 ❌ Unexpected status code: ${response.statusCode}');
      }

    } on SocketException catch (e) {
      print('🔬 ❌ Network error: $e');
    } on http.ClientException catch (e) {
      print('🔬 ❌ HTTP client error: $e');
    } on FormatException catch (e) {
      print('🔬 ❌ Format error: $e');
    } catch (e) {
      print('🔬 ❌ Unexpected error: $e');
      print('🔬 Error type: ${e.runtimeType}');
    }

    print('🔬 ✅ Complete request diagnostics completed\n');
  }

  /// Test different request variations
  Future<void> testRequestVariations({
    required String email,
    required String password,
  }) async {
    print('🔬 ==========================================');
    print('🔬 TESTING REQUEST VARIATIONS');
    print('🔬 ==========================================');

    final cleanEmail = email.trim().toLowerCase();
    final cleanPassword = password.trim();

    // Variation 1: Original format
    await _testRequestVariation('Original Format', {
      'email': cleanEmail,
      'password': cleanPassword,
    });

    // Variation 2: With extra fields (test backend tolerance)
    await _testRequestVariation('With Extra Fields', {
      'email': cleanEmail,
      'password': cleanPassword,
      'rememberMe': false,
    });

    // Variation 3: Different field order
    await _testRequestVariation('Different Order', {
      'password': cleanPassword,
      'email': cleanEmail,
    });

    // Variation 4: Explicit null values
    await _testRequestVariation('With Explicit Nulls', {
      'email': cleanEmail,
      'password': cleanPassword,
      'device': null,
    });

    print('🔬 ==========================================');
    print('🔬 REQUEST VARIATIONS TESTING COMPLETED');
    print('🔬 ==========================================');
  }

  Future<void> _testRequestVariation(String name, Map<String, dynamic> data) async {
    print('🔬 Testing: $name');

    try {
      final encoded = jsonEncode(data);
      print('🔬   JSON: $encoded');

      final response = await http.post(
        Uri.parse('$baseUrl/api/auth/login'),
        headers: {
          'Content-Type': 'application/json; charset=utf-8',
          'Accept': 'application/json',
          'ngrok-skip-browser-warning': 'true',
          'User-Agent': 'FlutterApp/1.0',
        },
        body: encoded,
        encoding: Encoding.getByName('utf-8'),
      ).timeout(const Duration(seconds: 10));

      print('🔬   Status: ${response.statusCode}');

      if (response.body.length > 100) {
        print('🔬   Response: ${response.body.substring(0, 100)}...');
      } else {
        print('🔬   Response: ${response.body}');
      }

    } catch (e) {
      print('🔬   Error: $e');
    }

    print('');
  }

  /// Compare with curl command
  void generateCurlCommand({
    required String email,
    required String password,
  }) {
    print('🔬 ==========================================');
    print('🔬 EQUIVALENT CURL COMMAND');
    print('🔬 ==========================================');

    final cleanEmail = email.trim().toLowerCase();
    final cleanPassword = password.trim();

    final requestData = {
      'email': cleanEmail,
      'password': cleanPassword,
    };

    final jsonBody = jsonEncode(requestData);

    print('curl -X POST "$baseUrl/api/auth/login" \\');
    print('  -H "Content-Type: application/json; charset=utf-8" \\');
    print('  -H "Accept: application/json" \\');
    print('  -H "ngrok-skip-browser-warning: true" \\');
    print('  -H "User-Agent: FlutterApp/1.0" \\');
    print('  -d \'$jsonBody\'');

    print('🔬 ==========================================');
  }
}

/// Extension to easily run diagnostics from anywhere
extension LoginDiagnosticsExtension on String {
  Future<void> diagnoseLogin({
    required String email,
    required String password,
  }) async {
    final diagnostics = LoginDiagnostics(baseUrl: this);
    await diagnostics.diagnoseLoginRequest(email: email, password: password);
  }
}

/// Usage example for integration:
/*
// In your auth_remote_data_source.dart, add this to the login method:

@override
Future<AuthTokens> login({
  required String email,
  required String password,
}) async {
  // ADD THIS FOR DEBUGGING:
  if (kDebugMode) {
    final diagnostics = LoginDiagnostics(baseUrl: 'YOUR_BASE_URL_HERE');
    await diagnostics.diagnoseLoginRequest(email: email, password: password);
    // You can also test variations:
    // await diagnostics.testRequestVariations(email: email, password: password);
    // Or generate curl command:
    // diagnostics.generateCurlCommand(email: email, password: password);
  }

  // Your existing login code continues here...
  try {
    final cleanEmail = email.trim().toLowerCase();
    final cleanPassword = password.trim();
    // ... rest of your code
  } catch (e) {
    // ... your error handling
  }
}

// Or use it in a separate test file:
void main() async {
  final diagnostics = LoginDiagnostics(baseUrl: 'YOUR_BASE_URL');
  await diagnostics.diagnoseLoginRequest(
    email: 'test@example.com',
    password: 'testpassword123',
  );
}
*/