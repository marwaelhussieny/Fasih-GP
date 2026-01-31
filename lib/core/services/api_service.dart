// lib/core/services/api_service.dart
// ENHANCED JSON REQUEST FORMATTING AND ERROR HANDLING

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

abstract class ApiService {
  Future<Map<String, dynamic>> get(
      String path, {
        Map<String, String>? headers,
        Map<String, dynamic>? queryParams,
      });

  Future<Map<String, dynamic>> post(
      String path, {
        Map<String, String>? headers,
        Map<String, dynamic>? body,
        Map<String, dynamic>? queryParams,
      });

  Future<Map<String, dynamic>> put(
      String path, {
        Map<String, String>? headers,
        Map<String, dynamic>? body,
      });

  Future<Map<String, dynamic>> delete(
      String path, {
        Map<String, String>? headers,
      });

  void setAuthToken(String token);
  void clearToken();
}

class ApiServiceImpl implements ApiService {
  final String baseUrl;
  final http.Client httpClient;
  String? _authToken;

  // Default timeout
  static const Duration _timeout = Duration(seconds: 30);

  ApiServiceImpl({
    required this.baseUrl,
    required this.httpClient,
  });

  @override
  void setAuthToken(String token) {
    _authToken = token;
    print('🌐 API Service: Auth token set');
  }

  @override
  void clearToken() {
    _authToken = null;
    print('🌐 API Service: Auth token cleared');
  }

  Map<String, String> _buildHeaders({Map<String, String>? additionalHeaders}) {
    final headers = <String, String>{
      'Content-Type': 'application/json; charset=utf-8',
      'Accept': 'application/json',
      'ngrok-skip-browser-warning': 'true',
      'User-Agent': 'FlutterApp/1.0',
    };

    if (_authToken != null) {
      headers['Authorization'] = 'Bearer $_authToken';
    }

    if (additionalHeaders != null) {
      headers.addAll(additionalHeaders);
    }

    return headers;
  }

  String _buildUrl(String path, {Map<String, dynamic>? queryParams}) {
    final uri = Uri.parse('$baseUrl$path');

    if (queryParams != null && queryParams.isNotEmpty) {
      return uri.replace(queryParameters:
      queryParams.map((key, value) => MapEntry(key, value.toString()))
      ).toString();
    }

    return uri.toString();
  }

  // Enhanced JSON encoding with validation
  String? _encodeBody(Map<String, dynamic>? body) {
    if (body == null || body.isEmpty) return null;

    try {
      // Validate all values are JSON serializable
      _validateJsonSerializable(body);

      final encoded = jsonEncode(body);
      print('🌐 API Service: JSON encoded body: $encoded');
      return encoded;
    } catch (e) {
      print('🌐 API Service: JSON encoding error: $e');
      throw HttpException('فشل في تنسيق البيانات للإرسال');
    }
  }

  // Validate that all values in the body are JSON serializable
  void _validateJsonSerializable(dynamic value, [String path = 'root']) {
    if (value == null) return;

    if (value is Map) {
      value.forEach((key, val) {
        if (key is! String) {
          throw ArgumentError('Non-string key found at $path: $key');
        }
        _validateJsonSerializable(val, '$path.$key');
      });
    } else if (value is List) {
      for (int i = 0; i < value.length; i++) {
        _validateJsonSerializable(value[i], '$path[$i]');
      }
    } else if (value is! String &&
        value is! num &&
        value is! bool &&
        value is! DateTime) {
      // Check if it has a toJson method
      if (value.runtimeType.toString().contains('Model') ||
          value.runtimeType.toString().contains('Entity')) {
        try {
          if (value.toString().contains('toJson')) {
            return; // Assume it's serializable
          }
        } catch (e) {
          // Continue to throw error below
        }
      }
      throw ArgumentError('Non-serializable value found at $path: ${value.runtimeType}');
    }
  }

  // Enhanced JSON decoding with better error handling
  Map<String, dynamic> _decodeResponse(String responseBody, String url) {
    if (responseBody.isEmpty) {
      return {'success': true, 'message': 'Empty response'};
    }

    try {
      // Clean response body from potential BOM or extra whitespace
      final cleanBody = responseBody.trim();
      if (cleanBody.startsWith('\uFEFF')) {
        final withoutBom = cleanBody.substring(1);
        print('🌐 API Service: Removed BOM from response');
        return jsonDecode(withoutBom) as Map<String, dynamic>;
      }

      final decoded = jsonDecode(cleanBody);

      // Ensure we return a Map<String, dynamic>
      if (decoded is Map<String, dynamic>) {
        return decoded;
      } else if (decoded is Map) {
        return Map<String, dynamic>.from(decoded);
      } else {
        throw FormatException('Response is not a JSON object: ${decoded.runtimeType}');
      }

    } catch (e) {
      print('🌐 API Service: JSON decode error: $e');
      print('🌐 API Service: Response body that failed: $responseBody');

      // Try to provide more specific error messages
      if (e is FormatException) {
        throw HttpException('الاستجابة من الخادم غير صحيحة (تنسيق JSON غير صالح)', uri: Uri.parse(url));
      } else {
        throw HttpException('فشل في معالجة استجابة الخادم', uri: Uri.parse(url));
      }
    }
  }

  Future<Map<String, dynamic>> _processResponse(http.Response response, String method, String url) async {
    print('🌐 API Service: $method $url - Status: ${response.statusCode}');
    print('🌐 API Service: Response headers: ${response.headers}');

    // Check content type
    final contentType = response.headers['content-type'] ?? '';
    if (contentType.isNotEmpty && !contentType.contains('application/json')) {
      print('🌐 API Service: Warning - Response content-type is not JSON: $contentType');
    }

    // Log response body for debugging (truncate if too long)
    final responseBody = response.body;
    if (responseBody.length > 1000) {
      print('🌐 API Service: Response body: ${responseBody.substring(0, 1000)}...[truncated]');
    } else {
      print('🌐 API Service: Response body: $responseBody');
    }

    try {
      // Decode JSON response
      final Map<String, dynamic> data = _decodeResponse(responseBody, url);

      // Handle different HTTP status codes
      if (response.statusCode >= 200 && response.statusCode < 300) {
        // Success response
        return data;
      } else if (response.statusCode == 400) {
        // Bad request - extract error message
        final message = _extractErrorMessage(data);
        throw HttpException(message, uri: Uri.parse(url));
      } else if (response.statusCode == 401) {
        // Unauthorized
        final message = _extractErrorMessage(data, defaultMessage: 'البريد الإلكتروني أو كلمة المرور غير صحيحة');
        throw HttpException(message, uri: Uri.parse(url));
      } else if (response.statusCode == 403) {
        // Forbidden
        final message = _extractErrorMessage(data, defaultMessage: 'غير مصرح لك بالوصول');
        throw HttpException(message, uri: Uri.parse(url));
      } else if (response.statusCode == 404) {
        // Not found
        throw HttpException('الخدمة غير متاحة', uri: Uri.parse(url));
      } else if (response.statusCode >= 500) {
        // Server error
        final message = _extractErrorMessage(data, defaultMessage: 'خطأ في الخادم. يرجى المحاولة لاحقاً');
        throw HttpException(message, uri: Uri.parse(url));
      } else {
        // Other errors
        final message = _extractErrorMessage(data);
        throw HttpException(message, uri: Uri.parse(url));
      }

    } catch (e) {
      if (e is HttpException) {
        rethrow;
      }
      print('🌐 API Service: Unexpected error processing response: $e');
      throw HttpException(
          'حدث خطأ غير متوقع: ${e.toString()}',
          uri: Uri.parse(url)
      );
    }
  }

  String _extractErrorMessage(Map<String, dynamic> data, {String? defaultMessage}) {
    // Try different possible error message fields
    if (data['message'] != null && data['message'].toString().isNotEmpty) {
      return data['message'].toString();
    }

    if (data['error'] != null && data['error'].toString().isNotEmpty) {
      return data['error'].toString();
    }

    if (data['detail'] != null && data['detail'].toString().isNotEmpty) {
      return data['detail'].toString();
    }

    // Check for validation errors
    if (data['errors'] != null) {
      if (data['errors'] is Map) {
        final errors = data['errors'] as Map;
        final firstError = errors.values.first;
        if (firstError is List && firstError.isNotEmpty) {
          return firstError.first.toString();
        } else if (firstError is String) {
          return firstError;
        }
      } else if (data['errors'] is List) {
        final errors = data['errors'] as List;
        if (errors.isNotEmpty) {
          return errors.first.toString();
        }
      }
    }

    return defaultMessage ?? 'حدث خطأ غير متوقع';
  }

  String _getErrorMessage(int statusCode) {
    switch (statusCode) {
      case 400:
        return 'طلب غير صحيح';
      case 401:
        return 'البريد الإلكتروني أو كلمة المرور غير صحيحة';
      case 403:
        return 'غير مصرح لك بالوصول';
      case 404:
        return 'الخدمة غير متاحة';
      case 408:
        return 'انتهت مهلة الاتصال';
      case 429:
        return 'تم تجاوز الحد المسموح من المحاولات';
      case 500:
        return 'خطأ في الخادم';
      case 502:
        return 'الخادم غير متاح';
      case 503:
        return 'الخدمة غير متاحة حالياً';
      default:
        return 'حدث خطأ غير متوقع ($statusCode)';
    }
  }

  @override
  Future<Map<String, dynamic>> get(
      String path, {
        Map<String, String>? headers,
        Map<String, dynamic>? queryParams,
      }) async {
    final url = _buildUrl(path, queryParams: queryParams);
    final requestHeaders = _buildHeaders(additionalHeaders: headers);

    print('🌐 API Service: GET $url');
    print('🌐 API Service: Headers: $requestHeaders');

    try {
      final response = await httpClient
          .get(Uri.parse(url), headers: requestHeaders)
          .timeout(_timeout);

      return await _processResponse(response, 'GET', url);
    } on SocketException {
      throw HttpException('لا يوجد اتصال بالإنترنت', uri: Uri.parse(url));
    } on TimeoutException {
      throw HttpException('انتهت مهلة الاتصال', uri: Uri.parse(url));
    } on HttpException {
      rethrow;
    } catch (e) {
      print('🌐 API Service: GET request failed: $e');
      throw HttpException('حدث خطأ في الطلب: ${e.toString()}', uri: Uri.parse(url));
    }
  }

  @override
  Future<Map<String, dynamic>> post(
      String path, {
        Map<String, String>? headers,
        Map<String, dynamic>? body,
        Map<String, dynamic>? queryParams,
      }) async {
    final url = _buildUrl(path, queryParams: queryParams);
    final requestHeaders = _buildHeaders(additionalHeaders: headers);

    // Enhanced JSON encoding with validation
    final requestBody = _encodeBody(body);

    print('🌐 API Service: POST $url');
    print('🌐 API Service: Headers: $requestHeaders');
    if (requestBody != null) {
      print('🌐 API Service: Request body: $requestBody');
    }

    try {
      final response = await httpClient
          .post(
        Uri.parse(url),
        headers: requestHeaders,
        body: requestBody,
        encoding: Encoding.getByName('utf-8'),
      )
          .timeout(_timeout);

      return await _processResponse(response, 'POST', url);
    } on SocketException {
      throw HttpException('لا يوجد اتصال بالإنترنت', uri: Uri.parse(url));
    } on HttpException {
      rethrow;
    } catch (e) {
      // Handle timeout and other exceptions
      if (e.toString().contains('TimeoutException') || e.toString().contains('timeout')) {
        throw HttpException('انتهت مهلة الاتصال', uri: Uri.parse(url));
      }
      print('🌐 API Service: POST request failed: $e');
      throw HttpException('حدث خطأ في الطلب: ${e.toString()}', uri: Uri.parse(url));
    }
  }

  @override
  Future<Map<String, dynamic>> put(
      String path, {
        Map<String, String>? headers,
        Map<String, dynamic>? body,
      }) async {
    final url = _buildUrl(path);
    final requestHeaders = _buildHeaders(additionalHeaders: headers);

    final requestBody = _encodeBody(body);

    print('🌐 API Service: PUT $url');
    if (requestBody != null) {
      print('🌐 API Service: Request body: $requestBody');
    }

    try {
      final response = await httpClient
          .put(
        Uri.parse(url),
        headers: requestHeaders,
        body: requestBody,
        encoding: Encoding.getByName('utf-8'),
      )
          .timeout(_timeout);

      return await _processResponse(response, 'PUT', url);
    } on SocketException {
      throw HttpException('لا يوجد اتصال بالإنترنت', uri: Uri.parse(url));
    } on TimeoutException {
      throw HttpException('انتهت مهلة الاتصال', uri: Uri.parse(url));
    } on HttpException {
      rethrow;
    } catch (e) {
      print('🌐 API Service: PUT request failed: $e');
      throw HttpException('حدث خطأ في الطلب: ${e.toString()}', uri: Uri.parse(url));
    }
  }

  @override
  Future<Map<String, dynamic>> delete(
      String path, {
        Map<String, String>? headers,
      }) async {
    final url = _buildUrl(path);
    final requestHeaders = _buildHeaders(additionalHeaders: headers);

    print('🌐 API Service: DELETE $url');

    try {
      final response = await httpClient
          .delete(Uri.parse(url), headers: requestHeaders)
          .timeout(_timeout);

      return await _processResponse(response, 'DELETE', url);
    } on SocketException {
      throw HttpException('لا يوجد اتصال بالإنترنت', uri: Uri.parse(url));
    } on TimeoutException {
      throw HttpException('انتهت مهلة الاتصال', uri: Uri.parse(url));
    } on HttpException {
      rethrow;
    } catch (e) {
      print('🌐 API Service: DELETE request failed: $e');
      throw HttpException('حدث خطأ في الطلب: ${e.toString()}', uri: Uri.parse(url));
    }
  }
}