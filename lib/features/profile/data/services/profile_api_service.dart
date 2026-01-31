// lib/features/profile/data/services/profile_api_service.dart

import 'dart:io';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:http_parser/http_parser.dart';
import 'package:mime/mime.dart';

class ProfileApiService {
  static const String baseUrl = 'https://f35f3ddf1acd.ngrok-free.app';

  // Get user profile data
  Future<Map<String, dynamic>> getUserProfile(String userId, String token) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/user/getUser/'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['data'];
      } else {
        throw Exception('Failed to load user profile: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  // Get edit profile data
  Future<Map<String, dynamic>> getEditProfileData(String token) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/user/settings/edit-profile'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['data'];
      } else {
        throw Exception('Failed to load edit profile data: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  // Update profile data
  Future<Map<String, dynamic>> updateProfile({
    required String token,
    required String fullName,
    required String email,
    required String mobileNumber,
    DateTime? dateOfBirth,
    String? job,
    String? country,
  }) async {
    try {
      final Map<String, dynamic> requestBody = {
        'fullName': fullName,
        'email': email,
        'mobileNumber': mobileNumber,
        if (dateOfBirth != null) 'dateOfBirth': dateOfBirth.toIso8601String(),
        if (job != null && job.isNotEmpty) 'job': job,
        if (country != null && country.isNotEmpty) 'country': country,
      };

      final response = await http.patch(
        Uri.parse('$baseUrl/api/user/settings/edit-profile'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode(requestBody),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data;
      } else {
        final errorData = json.decode(response.body);
        throw Exception(errorData['message'] ?? 'Failed to update profile');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  // Upload profile image
  Future<Map<String, dynamic>> uploadProfileImage({
    required String token,
    required File imageFile,
  }) async {
    try {
      final mimeType = lookupMimeType(imageFile.path);
      final request = http.MultipartRequest(
        'PUT',
        Uri.parse('$baseUrl/api/user/avatar'),
      );

      request.headers['Authorization'] = 'Bearer $token';

      request.files.add(
        await http.MultipartFile.fromPath(
          'avatar',
          imageFile.path,
          contentType: mimeType != null ? MediaType.parse(mimeType) : null,
        ),
      );

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data;
      } else {
        final errorData = json.decode(response.body);
        throw Exception(errorData['message'] ?? 'Failed to upload image');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  // Update avatar URL directly
  Future<Map<String, dynamic>> updateAvatarUrl({
    required String token,
    required String avatarUrl,
  }) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/api/user/avatar'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode({'avatarUrl': avatarUrl}),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data;
      } else {
        final errorData = json.decode(response.body);
        throw Exception(errorData['message'] ?? 'Failed to update avatar');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  // Get user statistics (learning words stats)
  Future<Map<String, dynamic>> getUserStats(String token) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/v1/learningwords/stats'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['data'];
      } else {
        throw Exception('Failed to load user stats: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  // Get settings data
  Future<List<Map<String, dynamic>>> getSettings(String token) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/user/settings'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return List<Map<String, dynamic>>.from(data['data']);
      } else {
        throw Exception('Failed to load settings: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  // Logout
  Future<bool> logout(String token) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/user/logout'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      return response.statusCode == 200;
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }
}