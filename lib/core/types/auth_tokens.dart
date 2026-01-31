// lib/core/types/auth_tokens.dart - ENHANCED JSON HANDLING

import 'dart:convert';

class AuthTokens {
  final String accessToken;
  final DateTime? expiry;

  const AuthTokens({
    required this.accessToken,
    this.expiry,
  });

  // Enhanced JSON serialization with validation
  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{
      'accessToken': accessToken,
    };

    if (expiry != null) {
      json['expiry'] = expiry!.toIso8601String();
    }

    return json;
  }

  // Enhanced JSON deserialization with validation
  factory AuthTokens.fromJson(Map<String, dynamic> json) {
    try {
      // Validate required fields
      if (!json.containsKey('accessToken')) {
        throw ArgumentError('Missing required field: accessToken');
      }

      final accessToken = json['accessToken'];
      if (accessToken == null || accessToken is! String || accessToken.isEmpty) {
        throw ArgumentError('Invalid accessToken: must be a non-empty string');
      }

      DateTime? expiry;
      if (json.containsKey('expiry') && json['expiry'] != null) {
        final expiryValue = json['expiry'];
        if (expiryValue is String) {
          expiry = DateTime.tryParse(expiryValue);
          if (expiry == null) {
            print('⚠️ AuthTokens: Invalid expiry date format: $expiryValue');
          }
        } else {
          print('⚠️ AuthTokens: Expiry is not a string: ${expiryValue.runtimeType}');
        }
      }

      return AuthTokens(
        accessToken: accessToken,
        expiry: expiry,
      );
    } catch (e) {
      print('❌ AuthTokens.fromJson error: $e');
      print('❌ JSON data: $json');
      rethrow;
    }
  }

  // Create from API response with enhanced validation and JWT parsing
  factory AuthTokens.fromApiResponse(Map<String, dynamic> response) {
    try {
      print('🔐 AuthTokens: Parsing API response: ${response.keys.toList()}');

      // Validate response structure
      if (!response.containsKey('accessToken')) {
        throw ArgumentError('Missing accessToken in API response');
      }

      final accessToken = response['accessToken'];
      if (accessToken == null || accessToken is! String || accessToken.isEmpty) {
        throw ArgumentError('Invalid accessToken in API response');
      }

      print('🔐 AuthTokens: Access token extracted (length: ${accessToken.length})');

      // Backend sends refreshToken but we completely ignore it
      if (response.containsKey('refreshToken')) {
        print('🔐 AuthTokens: Ignoring refresh token from response');
      }

      // Enhanced JWT parsing with better error handling
      DateTime? expiry;
      try {
        expiry = _parseJwtExpiry(accessToken);
      } catch (e) {
        print('⚠️ AuthTokens: JWT parsing failed: $e');
        // Set default expiry (15 minutes from now)
        expiry = DateTime.now().add(const Duration(minutes: 15));
        print('🔐 AuthTokens: Using default expiry: $expiry');
      }

      final tokens = AuthTokens(
        accessToken: accessToken,
        expiry: expiry,
      );

      print('🔐 AuthTokens: Successfully created tokens (expires: $expiry)');
      return tokens;
    } catch (e) {
      print('❌ AuthTokens.fromApiResponse error: $e');
      print('❌ Response data: $response');
      rethrow;
    }
  }

  // Enhanced JWT expiry parsing
  static DateTime? _parseJwtExpiry(String accessToken) {
    try {
      final parts = accessToken.split('.');
      if (parts.length != 3) {
        throw FormatException('Invalid JWT format: expected 3 parts, got ${parts.length}');
      }

      final payload = parts[1];

      // Add padding if needed for base64 decoding
      String normalizedPayload = payload;
      final paddingLength = payload.length % 4;
      if (paddingLength != 0) {
        normalizedPayload += '=' * (4 - paddingLength);
      }

      // Decode base64
      List<int> decodedBytes;
      try {
        decodedBytes = base64.decode(normalizedPayload);
      } catch (e) {
        throw FormatException('Failed to decode JWT payload: $e');
      }

      // Convert to UTF-8 string
      String payloadString;
      try {
        payloadString = utf8.decode(decodedBytes);
      } catch (e) {
        throw FormatException('Failed to convert JWT payload to UTF-8: $e');
      }

      // Parse JSON
      Map<String, dynamic> payloadMap;
      try {
        final decoded = jsonDecode(payloadString);
        if (decoded is! Map<String, dynamic>) {
          throw FormatException('JWT payload is not a JSON object');
        }
        payloadMap = decoded;
      } catch (e) {
        throw FormatException('Failed to parse JWT payload JSON: $e');
      }

      // Extract expiry
      final exp = payloadMap['exp'];
      if (exp == null) {
        print('⚠️ AuthTokens: No exp claim found in JWT');
        return null;
      }

      if (exp is! int) {
        throw FormatException('JWT exp claim is not an integer: ${exp.runtimeType}');
      }

      final expiry = DateTime.fromMillisecondsSinceEpoch(exp * 1000);
      print('🔐 AuthTokens: Extracted JWT expiry: $expiry');

      // Validate expiry is in the future
      if (expiry.isBefore(DateTime.now())) {
        print('⚠️ AuthTokens: JWT token is already expired');
      }

      return expiry;
    } catch (e) {
      print('❌ AuthTokens: JWT parsing failed: $e');
      rethrow;
    }
  }

  // Enhanced validation
  bool get isExpired {
    if (expiry == null) {
      print('⚠️ AuthTokens: No expiry set, assuming not expired');
      return false;
    }

    final now = DateTime.now();
    final expired = now.isAfter(expiry!);

    if (expired) {
      print('⚠️ AuthTokens: Token expired at $expiry (now: $now)');
    }

    return expired;
  }

  bool get isValid {
    final hasToken = accessToken.isNotEmpty;
    final notExpired = !isExpired;

    print('🔐 AuthTokens: Token validation - hasToken: $hasToken, notExpired: $notExpired');

    return hasToken && notExpired;
  }

  // Helper method to get remaining time
  Duration? get timeToExpiry {
    if (expiry == null) return null;

    final now = DateTime.now();
    if (expiry!.isBefore(now)) return Duration.zero;

    return expiry!.difference(now);
  }

  // Helper method to check if token expires soon
  bool get expiresSoon {
    final remaining = timeToExpiry;
    if (remaining == null) return false;

    // Consider "soon" as within 5 minutes
    return remaining.inMinutes <= 5;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AuthTokens &&
        other.accessToken == accessToken &&
        other.expiry == expiry;
  }

  @override
  int get hashCode {
    return accessToken.hashCode ^ expiry.hashCode;
  }

  @override
  String toString() {
    final tokenPreview = accessToken.length > 20
        ? '${accessToken.substring(0, 20)}...'
        : accessToken;

    return 'AuthTokens(accessToken: $tokenPreview, expiry: $expiry, valid: $isValid)';
  }
}