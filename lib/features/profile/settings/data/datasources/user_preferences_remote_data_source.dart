// lib/features/profile/data/datasources/user_preferences_remote_data_source.dart

import 'package:grad_project/core/services/api_service.dart';
import 'package:grad_project/features/profile/data/models/profile_user_model.dart';
import 'package:grad_project/features/profile/domain/entities/user_preferences_entity.dart';
import 'package:grad_project/features/profile/domain/entities/accessibility_preferences.dart';

import 'package:grad_project/features/profile/data/models/accessibility_preferences_model.dart';
import 'package:grad_project/features/profile/data/models/user_preferences_model.dart';

abstract class UserPreferencesRemoteDataSource {
  Future<UserPreferencesModel> getPreferences();
  Future<UserPreferencesModel> updateNotifications(bool enabled);
  Future<UserPreferencesModel> updateAccessibility(AccessibilityPreferences accessibility);
}

class UserPreferencesRemoteDataSourceImpl implements UserPreferencesRemoteDataSource {
  final ApiService apiService;

  UserPreferencesRemoteDataSourceImpl({required this.apiService});

  @override
  Future<UserPreferencesModel> getPreferences() async {
    try {
      final response = await apiService.get('/user/settings');

      if (response.isEmpty) {
        throw Exception('Failed to get user preferences: Data is null.');
      }

      return UserPreferencesModel.fromMap(response);
    } catch (e) {
      throw Exception('Failed to get user preferences: $e');
    }
  }

  @override
  Future<UserPreferencesModel> updateNotifications(bool enabled) async {
    try {
      final body = {'notificationsEnabled': enabled};
      final response = await apiService.put('/user/settings/notifications', body: body);

      if (response.isEmpty) {
        throw Exception('Failed to update notifications: Data is null.');
      }

      return UserPreferencesModel.fromMap(response);
    } catch (e) {
      throw Exception('Failed to update notifications: $e');
    }
  }

  @override
  Future<UserPreferencesModel> updateAccessibility(AccessibilityPreferences accessibility) async {
    try {
      final body = (accessibility as AccessibilityPreferencesModel).toMap();
      final response = await apiService.put('/user/settings/accessibility', body: body);

      if (response.isEmpty) {
        throw Exception('Failed to update accessibility settings: Data is null.');
      }

      return UserPreferencesModel.fromMap(response);
    } catch (e) {
      throw Exception('Failed to update accessibility settings: $e');
    }
  }
}