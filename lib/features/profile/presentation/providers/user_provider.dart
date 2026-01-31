// lib/features/profile/presentation/providers/user_provider.dart

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:grad_project/features/profile/domain/entities/profile_user_entity.dart';
import 'package:grad_project/features/profile/domain/entities/user_preferences_entity.dart';
import 'package:grad_project/features/profile/domain/usecases/profile_usecases.dart';

class UserProvider extends ChangeNotifier {
  // Profile Management Use Cases
  final GetProfileUseCase _getProfileUseCase;
  final UpdateProfileUseCase _updateProfileUseCase;
  final UploadProfileImageUseCase _uploadProfileImageUseCase;
  final UpdateProfileImageUseCase _updateProfileImageUseCase;
  final DeleteAccountUseCase _deleteAccountUseCase;

  // Preferences Use Cases
  final GetPreferencesUseCase _getPreferencesUseCase;
  final UpdatePreferencesUseCase _updatePreferencesUseCase;
  final UpdateAccessibilityPreferenceUseCase _updateAccessibilityPreferenceUseCase;
  final UpdateGeneralPreferenceUseCase _updateGeneralPreferenceUseCase;
  final UpdateThemePreferenceUseCase _updateThemePreferenceUseCase;
  final UpdateLanguagePreferenceUseCase _updateLanguagePreferenceUseCase; // Added

  // Settings & Security Use Cases
  final ChangePasswordUseCase _changePasswordUseCase;
  final ChangeEmailUseCase _changeEmailUseCase;
  final UpdateNotificationSettingsUseCase _updateNotificationSettingsUseCase;

  UserProvider({
    required GetProfileUseCase getProfileUseCase,
    required UpdateProfileUseCase updateProfileUseCase,
    required UploadProfileImageUseCase uploadProfileImageUseCase,
    required UpdateProfileImageUseCase updateProfileImageUseCase,
    required GetPreferencesUseCase getPreferencesUseCase,
    required UpdatePreferencesUseCase updatePreferencesUseCase,
    required UpdateAccessibilityPreferenceUseCase updateAccessibilityPreferenceUseCase,
    required UpdateGeneralPreferenceUseCase updateGeneralPreferenceUseCase,
    required ChangePasswordUseCase changePasswordUseCase,
    required ChangeEmailUseCase changeEmailUseCase,
    required UpdateNotificationSettingsUseCase updateNotificationSettingsUseCase,
    required UpdateThemePreferenceUseCase updateThemePreferenceUseCase,
    required DeleteAccountUseCase deleteAccountUseCase,
    required UpdateLanguagePreferenceUseCase updateLanguagePreferenceUseCase, // Added
  })  : _getProfileUseCase = getProfileUseCase,
        _updateProfileUseCase = updateProfileUseCase,
        _uploadProfileImageUseCase = uploadProfileImageUseCase,
        _updateProfileImageUseCase = updateProfileImageUseCase,
        _getPreferencesUseCase = getPreferencesUseCase,
        _updatePreferencesUseCase = updatePreferencesUseCase,
        _updateAccessibilityPreferenceUseCase = updateAccessibilityPreferenceUseCase,
        _updateGeneralPreferenceUseCase = updateGeneralPreferenceUseCase,
        _changePasswordUseCase = changePasswordUseCase,
        _changeEmailUseCase = changeEmailUseCase,
        _updateNotificationSettingsUseCase = updateNotificationSettingsUseCase,
        _updateThemePreferenceUseCase = updateThemePreferenceUseCase,
        _deleteAccountUseCase = deleteAccountUseCase,
        _updateLanguagePreferenceUseCase = updateLanguagePreferenceUseCase; // Added

  // User data
  ProfileUserEntity? _user;
  UserPreferencesEntity? _preferences;

  // Loading states
  bool _isLoading = false;
  bool _isUpdating = false;

  // Error handling
  String? _error;

  // Getters
  ProfileUserEntity? get user => _user;
  UserPreferencesEntity? get preferences => _preferences;
  bool get isLoading => _isLoading;
  bool get isUpdating => _isUpdating;
  String? get error => _error;

  // Load user profile
  Future<void> loadUser() async {
    _setLoading(true);
    _clearError();

    try {
      _user = await _getProfileUseCase();
      notifyListeners();
    } catch (e) {
      _setError('Failed to load user: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }

  // Load user preferences
  Future<void> loadPreferences() async {
    _setLoading(true);
    _clearError();

    try {
      _preferences = await _getPreferencesUseCase();
      notifyListeners();
    } catch (e) {
      _setError('Failed to load preferences: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }

  // Update user profile data
  Future<void> updateUserProfileData({
    String? fullName,
    String? phoneNumber,
    String? job,
    DateTime? dateOfBirth,
    String? country, required String email, // Added country parameter
  }) async {
    _setUpdating(true);
    _clearError();

    try {
      _user = await _updateProfileUseCase(
        fullName: fullName,
        phoneNumber: phoneNumber,
        job: job,
        dateOfBirth: dateOfBirth,
        country: country, // Pass country to use case
        email: email
      );
      notifyListeners();
    } catch (e) {
      _setError('Failed to update profile: ${e.toString()}');
      rethrow;
    } finally {
      _setUpdating(false);
    }
  }

  // Upload profile image file
  Future<void> uploadProfileImageFile({required File imageFile}) async {
    _setUpdating(true);
    _clearError();

    try {
      await _uploadProfileImageUseCase(imageFile);
      // Reload user data after image upload
      await loadUser();
    } catch (e) {
      _setError('Failed to upload image: ${e.toString()}');
      rethrow;
    } finally {
      _setUpdating(false);
    }
  }

  // Update profile image with URL
  Future<void> updateProfileImageUrl({required String imageUrl}) async {
    _setUpdating(true);
    _clearError();

    try {
      _user = await _updateProfileImageUseCase(imageUrl);
      notifyListeners();
    } catch (e) {
      _setError('Failed to update profile image: ${e.toString()}');
      rethrow;
    } finally {
      _setUpdating(false);
    }
  }

  // Update accessibility preference
  Future<void> updateAccessibilityPreference(String key, bool value) async {
    _setUpdating(true);
    _clearError();

    try {
      await _updateAccessibilityPreferenceUseCase(key, value);
      await loadPreferences();
    } catch (e) {
      _setError('Failed to update accessibility preference: ${e.toString()}');
      rethrow;
    } finally {
      _setUpdating(false);
    }
  }

  // Update general preference
  Future<void> updateGeneralPreference(String key, dynamic value) async {
    _setUpdating(true);
    _clearError();

    try {
      await _updateGeneralPreferenceUseCase(key, value);
      await loadPreferences();
    } catch (e) {
      _setError('Failed to update preference: ${e.toString()}');
      rethrow;
    } finally {
      _setUpdating(false);
    }
  }

  // Change password
  Future<void> changePassword(String oldPassword, String newPassword) async {
    _setUpdating(true);
    _clearError();

    try {
      await _changePasswordUseCase(oldPassword, newPassword);
    } catch (e) {
      _setError('Failed to change password: ${e.toString()}');
      rethrow;
    } finally {
      _setUpdating(false);
    }
  }

  // Change email
  Future<void> changeEmail(String newEmail) async {
    _setUpdating(true);
    _clearError();

    try {
      await _changeEmailUseCase(newEmail);
      await loadUser();
    } catch (e) {
      _setError('Failed to change email: ${e.toString()}');
      rethrow;
    } finally {
      _setUpdating(false);
    }
  }

  // Update notification settings
  Future<void> updateNotificationSettings(bool enabled) async {
    _setUpdating(true);
    _clearError();

    try {
      await _updateNotificationSettingsUseCase(enabled);
      await loadPreferences();
    } catch (e) {
      _setError('Failed to update notification settings: ${e.toString()}');
      rethrow;
    } finally {
      _setUpdating(false);
    }
  }

  // Update language preference
  Future<void> updateLanguagePreference(String language) async {
    _setUpdating(true);
    _clearError();

    try {
      await _updateLanguagePreferenceUseCase(language);
      await loadPreferences();
    } catch (e) {
      _setError('Failed to update language preference: ${e.toString()}');
      rethrow;
    } finally {
      _setUpdating(false);
    }
  }

  // Update theme preference
  Future<void> updateThemePreference(bool darkMode) async {
    _setUpdating(true);
    _clearError();

    try {
      await _updateThemePreferenceUseCase(darkMode);
      await loadPreferences();
    } catch (e) {
      _setError('Failed to update theme preference: ${e.toString()}');
      rethrow;
    } finally {
      _setUpdating(false);
    }
  }

  // Delete account
  Future<void> deleteAccount() async {
    _setUpdating(true);
    _clearError();

    try {
      await _deleteAccountUseCase();
      _user = null;
      _preferences = null;
      notifyListeners();
    } catch (e) {
      _setError('Failed to delete account: ${e.toString()}');
      rethrow;
    } finally {
      _setUpdating(false);
    }
  }

  // Reset user data (for logout)
  void resetUser() {
    _user = null;
    _preferences = null;
    _clearError();
    notifyListeners();
  }

  // Helper methods for state management
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setUpdating(bool updating) {
    _isUpdating = updating;
    notifyListeners();
  }

  void _setError(String error) {
    _error = error;
    notifyListeners();
  }

  void _clearError() {
    _error = null;
  }
}
