
// lib/features/profile/data/datasources/profile_remote_datasource.dart - ALTERNATIVE

import 'dart:io';
import 'package:grad_project/core/services/api_service.dart';
import 'package:grad_project/core/services/auth_service.dart';
import 'package:grad_project/features/profile/data/models/profile_user_model.dart';
import 'package:grad_project/features/profile/domain/entities/user_preferences_entity.dart';
import '../models/user_preferences_model.dart';

abstract class ProfileRemoteDataSource {
  Future<ProfileUserModel> getUserData();
  Future<ProfileUserModel> updateProfile({
    String? fullName,
    String? mobileNumber,
    String? email,
    DateTime? dateOfBirth,
    String? country,
    String? job,
  });
  Future<String> updateAvatar(String avatarUrl);
  Future<UserPreferencesEntity?> getPreferences();
  Future<UserPreferencesEntity> updatePreferences(UserPreferencesEntity preferences);
  Future<void> updateNotifications(bool enabled);
  Future<void> updateAccessibility(Map<String, bool> accessibilitySettings);
  Future<void> changePassword(String oldPassword, String newPassword);
  Future<void> changeEmail(String newEmail);
  Future<void> logout();
}

class ProfileRemoteDataSourceImpl implements ProfileRemoteDataSource {
  final ApiService apiService;
  final AuthService authService;

  ProfileRemoteDataSourceImpl({
    required this.apiService,
    required this.authService,
  });

  String? get _currentUserId {
    final user = authService.getUser();
    return user?.id;
  }

  @override
  Future<ProfileUserModel> getUserData() async {
    try {
      final currentUserId = _currentUserId;
      if (currentUserId == null) {
        throw Exception('No authenticated user found');
      }

      print('🔍 Getting user data for ID: $currentUserId');

      // Use the exact endpoint from your backend
      final response = await apiService.get('/user/getUser/$currentUserId');

      print('📡 API Response: $response');

      if (response['status'] != 'success' || response['data'] == null) {
        throw Exception('User data not found');
      }

      // Parse using the exact structure from your backend
      final user = ProfileUserModel.fromMap(response);
      print('✅ User parsed successfully: ${user.fullName}');

      return user;
    } catch (e) {
      print('❌ Failed to get user data: $e');
      throw Exception('Failed to get user data: $e');
    }
  }

  @override
  Future<ProfileUserModel> updateProfile({
    String? fullName,
    String? mobileNumber,
    String? email,
    DateTime? dateOfBirth,
    String? country,
    String? job,
  }) async {
    try {
      final body = <String, dynamic>{};

      if (fullName != null) body['fullName'] = fullName;
      if (mobileNumber != null) body['mobileNumber'] = mobileNumber;
      if (email != null) body['email'] = email;
      if (dateOfBirth != null) body['dateOfBirth'] = dateOfBirth.toIso8601String();
      if (country != null) body['country'] = country;
      if (job != null) body['job'] = job;

      print('🔄 Updating profile with data: $body');

      // Try PUT first, if it fails, use POST
      Map<String, dynamic> response;
      try {
        response = await apiService.put('/user/settings/edit-profile', body: body);
      } catch (e) {
        print('⚠️ PUT failed, trying POST: $e');
        // If PUT is not available, use POST with update endpoint
        response = await apiService.post('/user/settings/edit-profile/update', body: body);
      }

      if (response['status'] != 'success') {
        throw Exception('Failed to update profile: ${response['message'] ?? 'Unknown error'}');
      }

      print('✅ Profile updated successfully');

      // Reload user data after update
      return await getUserData();
    } catch (e) {
      print('❌ Failed to update profile: $e');
      throw Exception('Failed to update profile: ${e.toString()}');
    }
  }

  @override
  Future<String> updateAvatar(String avatarUrl) async {
    try {
      print('🖼️ Updating avatar: $avatarUrl');

      // Use the correct endpoint from your Postman collection
      Map<String, dynamic> response;
      try {
        response = await apiService.put('/user/avatar', body: {'avatarUrl': avatarUrl});
      } catch (e) {
        print('⚠️ PUT failed for avatar, trying POST: $e');
        response = await apiService.post('/user/avatar/update', body: {'avatarUrl': avatarUrl});
      }

      if (response['success'] != true || response['data'] == null) {
        throw Exception('Failed to update avatar: ${response['message'] ?? 'Unknown error'}');
      }

      final data = response['data'] as Map<String, dynamic>;
      final newAvatarUrl = data['avatarUrl'] as String;

      print('✅ Avatar updated successfully: $newAvatarUrl');
      return newAvatarUrl;
    } catch (e) {
      print('❌ Failed to update avatar: $e');
      throw Exception('Failed to update avatar: ${e.toString()}');
    }
  }

  @override
  Future<UserPreferencesEntity?> getPreferences() async {
    try {
      print('🔧 Getting user preferences...');

      // Get preferences from the user data itself since they're nested
      final userData = await getUserData();

      if (userData.preferences != null) {
        print('✅ Preferences loaded successfully');
      } else {
        print('⚠️ No preferences found in user data');
      }

      return userData.preferences;
    } catch (e) {
      print('❌ Failed to get preferences: $e');
      throw Exception('Failed to get user preferences: ${e.toString()}');
    }
  }

  @override
  Future<UserPreferencesEntity> updatePreferences(UserPreferencesEntity preferences) async {
    try {
      final body = (preferences as UserPreferencesModel).toMap();
      print('🔧 Updating preferences: $body');

      // Update accessibility settings
      try {
        await apiService.put('/user/settings/accessibility',
            body: {'accessibility': body['accessibility']});
      } catch (e) {
        print('⚠️ PUT failed for accessibility, trying POST: $e');
        await apiService.post('/user/settings/accessibility/update',
            body: {'accessibility': body['accessibility']});
      }

      // Update notification settings
      try {
        await apiService.put('/user/settings/notifications',
            body: {'notificationsEnabled': body['notificationsEnabled']});
      } catch (e) {
        print('⚠️ PUT failed for notifications, trying POST: $e');
        await apiService.post('/user/settings/notifications/update',
            body: {'notificationsEnabled': body['notificationsEnabled']});
      }

      print('✅ Preferences updated successfully');
      return preferences;
    } catch (e) {
      print('❌ Failed to update preferences: $e');
      throw Exception('Failed to update user preferences: ${e.toString()}');
    }
  }

  @override
  Future<void> updateNotifications(bool enabled) async {
    try {
      print('🔔 Updating notifications: $enabled');

      // Use the endpoint from your Postman collection
      Map<String, dynamic> response;
      try {
        response = await apiService.put('/user/settings/notifications',
            body: {'notificationsEnabled': enabled});
      } catch (e) {
        print('⚠️ PUT failed for notifications, trying POST: $e');
        response = await apiService.post('/user/settings/notifications/update',
            body: {'notificationsEnabled': enabled});
      }

      if (response['status'] == 'success') {
        print('✅ Notifications updated successfully');
      } else {
        throw Exception('Failed to update notifications: ${response['message']}');
      }
    } catch (e) {
      print('❌ Failed to update notifications: $e');
      throw Exception('Failed to update notifications: ${e.toString()}');
    }
  }

  @override
  Future<void> updateAccessibility(Map<String, bool> accessibilitySettings) async {
    try {
      print('♿ Updating accessibility settings: $accessibilitySettings');

      Map<String, dynamic> response;
      try {
        response = await apiService.put('/user/settings/accessibility',
            body: {'accessibility': accessibilitySettings});
      } catch (e) {
        print('⚠️ PUT failed for accessibility, trying POST: $e');
        response = await apiService.post('/user/settings/accessibility/update',
            body: {'accessibility': accessibilitySettings});
      }

      if (response['status'] == 'success') {
        print('✅ Accessibility settings updated successfully');
      } else {
        throw Exception('Failed to update accessibility: ${response['message']}');
      }
    } catch (e) {
      print('❌ Failed to update accessibility: $e');
      throw Exception('Failed to update accessibility settings: ${e.toString()}');
    }
  }

  @override
  Future<void> changePassword(String oldPassword, String newPassword) async {
    try {
      print('🔒 Changing password...');

      Map<String, dynamic> response;
      try {
        response = await apiService.put('/user/security/change-password',
            body: {'oldPassword': oldPassword, 'newPassword': newPassword});
      } catch (e) {
        print('⚠️ PUT failed for password change, trying POST: $e');
        response = await apiService.post('/user/security/change-password',
            body: {'oldPassword': oldPassword, 'newPassword': newPassword});
      }

      if (response['status'] == 'success') {
        print('✅ Password changed successfully');
      } else {
        throw Exception('Failed to change password: ${response['message']}');
      }
    } catch (e) {
      print('❌ Failed to change password: $e');
      throw Exception('Failed to change password: ${e.toString()}');
    }
  }

  @override
  Future<void> changeEmail(String newEmail) async {
    try {
      print('📧 Changing email to: $newEmail');

      Map<String, dynamic> response;
      try {
        response = await apiService.put('/user/security/change-email',
            body: {'newEmail': newEmail});
      } catch (e) {
        print('⚠️ PUT failed for email change, trying POST: $e');
        response = await apiService.post('/user/security/change-email',
            body: {'newEmail': newEmail});
      }

      if (response['status'] == 'success') {
        print('✅ Email changed successfully');
      } else {
        throw Exception('Failed to change email: ${response['message']}');
      }
    } catch (e) {
      print('❌ Failed to change email: $e');
      throw Exception('Failed to change email: ${e.toString()}');
    }
  }

  @override
  Future<void> logout() async {
    try {
      print('🚪 Logging out...');

      await apiService.post('/user/logout');
      await authService.clearAll();

      print('✅ Logout successful');
    } catch (e) {
      print('❌ Logout failed: $e');
      // Still clear local data even if logout API fails
      await authService.clearAll();
      throw Exception('Failed to logout: ${e.toString()}');
    }
  }
}

// ============================================
// QUICK FIX FOR YOUR EXISTING APISERVICE
// ============================================

/*
If your ApiService doesn't have PUT method, you can add it quickly:

In your ApiService implementation, add:

Future<Map<String, dynamic>> put(String endpoint, {Map<String, dynamic>? body}) async {
  return await _request('PUT', endpoint, body: body);
}

Future<Map<String, dynamic>> patch(String endpoint, {Map<String, dynamic>? body}) async {
  return await _request('PATCH', endpoint, body: body);
}

Or if you have a _request method, update it to handle PUT and PATCH verbs.
*/

// ============================================
// DEBUGGING HELPER
// ============================================

// Add this to test which methods your ApiService supports:
class ApiServiceTester {
  final ApiService apiService;

  ApiServiceTester(this.apiService);

  Future<void> testAvailableMethods() async {
    print('🔍 Testing ApiService methods...');

    final methods = [
          () => apiService.get('/test'),
          () => apiService.post('/test', body: {}),
      // Uncomment these to test if they exist:
      // () => apiService.put('/test', body: {}),
      // () => apiService.patch('/test', body: {}),
      // () => apiService.delete('/test'),
    ];

    for (int i = 0; i < methods.length; i++) {
      try {
        await methods[i]();
        print('✅ Method ${i} works');
      } catch (e) {
        if (e.toString().contains('method') || e.toString().contains('defined')) {
          print('❌ Method ${i} not available: $e');
        } else {
          print('✅ Method ${i} exists (got different error): $e');
        }
      }
    }
  }
}