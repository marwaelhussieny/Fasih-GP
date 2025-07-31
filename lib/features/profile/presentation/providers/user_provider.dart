// lib/features/profile/data/providers/user_provider.dart

import 'package:flutter/material.dart';
import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:grad_project/features/profile/domain/entities/user_entity.dart';
import 'package:grad_project/features/profile/domain/usecases/profile_usecases.dart';
import 'package:grad_project/features/profile/domain/usecases/activity_usecases.dart';
import 'package:grad_project/features/auth/domain/usecases/get_auth_state_changes_usecase.dart';

class UserProvider with ChangeNotifier {
  final GetUserProfile _getUserProfile;
  final UpdateUserProfile _updateUserProfile;
  final UploadProfileImage _uploadProfileImage;
  final CreateUserProfile _createUserProfile;
  final GetAuthStateChangesUseCase _getAuthStateChangesUseCase;

  UserEntity? _user;
  bool _isLoading = false;
  String? _error;

  UserEntity? get user => _user;
  bool get isLoading => _isLoading;
  String? get error => _error;

  UserProvider({
    required GetUserProfile getUserProfile,
    required UpdateUserProfile updateUserProfile,
    required UploadProfileImage uploadProfileImage,
    required CreateUserProfile createUserProfile,
    required GetAuthStateChangesUseCase getAuthStateChangesUseCase,
  })  : _getUserProfile = getUserProfile,
        _updateUserProfile = updateUserProfile,
        _uploadProfileImage = uploadProfileImage,
        _createUserProfile = createUserProfile,
        _getAuthStateChangesUseCase = getAuthStateChangesUseCase {
    debugPrint('UserProvider: Constructor called. Setting up auth state listener.');
    _getAuthStateChangesUseCase().listen((firebaseUser) {
      debugPrint('UserProvider: Auth state changed. Firebase user: ${firebaseUser?.uid}');
      if (firebaseUser != null) {
        // User logged in, try to load their profile
        debugPrint('UserProvider: Firebase user logged in. Calling loadUser().');
        loadUser();
      } else {
        // User logged out, clear profile
        debugPrint('UserProvider: Firebase user logged out. Clearing _user.');
        _user = null;
        notifyListeners();
      }
    });
    // Initial check for current user on app start
    debugPrint('UserProvider: Initial check for current Firebase user.');
    if (FirebaseAuth.instance.currentUser != null) {
      loadUser();
    }
  }

  Future<void> loadUser() async {
    debugPrint('UserProvider: loadUser() called. Current _user: ${_user?.id}');
    _setLoading(true);
    _clearError();
    try {
      final firebaseUser = FirebaseAuth.instance.currentUser;
      debugPrint('UserProvider: loadUser - Current Firebase Auth user: ${firebaseUser?.uid}');
      if (firebaseUser != null) {
        debugPrint('UserProvider: loadUser - Attempting to get user profile from Firestore for UID: ${firebaseUser.uid}');
        _user = await _getUserProfile(); // Call the use case
        debugPrint('UserProvider: loadUser - Result from _getUserProfile: ${_user?.id}');

        if (_user == null) {
          debugPrint('UserProvider: loadUser - User profile NOT found in Firestore. Attempting to create.');
          await _createUserProfile(
            uid: firebaseUser.uid,
            email: firebaseUser.email ?? '',
            name: firebaseUser.displayName ?? 'New User',
          );
          debugPrint('UserProvider: loadUser - Profile creation attempted. Re-fetching profile.');
          _user = await _getUserProfile(); // Try loading again after creation
          debugPrint('UserProvider: loadUser - Result after creation and re-fetch: ${_user?.id}');
        }
      } else {
        debugPrint('UserProvider: loadUser - No Firebase authenticated user found.');
        _user = null; // No authenticated user
      }
    } catch (e) {
      debugPrint('UserProvider: loadUser - ERROR: ${e.toString()}');
      _setError('Failed to load user profile: ${e.toString()}');
    } finally {
      debugPrint('UserProvider: loadUser - Finished. Final _user: ${_user?.id}, isLoading: $_isLoading');
      _setLoading(false); // This will call notifyListeners()
    }
  }

  Future<void> updateUserProfileData({
    String? name,
    String? phoneNumber,
    String? email,
    DateTime? dateOfBirth,
    String? job,
  }) async {
    debugPrint('UserProvider: updateUserProfileData called.');
    if (_user == null) {
      _setError('No user logged in to update profile.');
      debugPrint('UserProvider: updateUserProfileData - ERROR: No user logged in.');
      return;
    }
    _setLoading(true);
    _clearError();
    try {
      final updatedUser = _user!.copyWith(
        name: name,
        phoneNumber: phoneNumber,
        email: email,
        dateOfBirth: dateOfBirth,
        job: job,
      );
      debugPrint('UserProvider: updateUserProfileData - Calling _updateUserProfile with: ${updatedUser.toMap()}');
      await _updateUserProfile(updatedUser); // Call the use case
      _user = updatedUser; // Update local state
      debugPrint('UserProvider: updateUserProfileData - Profile updated successfully. New _user: ${_user?.id}');
    } catch (e) {
      debugPrint('UserProvider: updateUserProfileData - ERROR: ${e.toString()}');
      _setError('Failed to update profile data: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> uploadProfileImageFile({required File imageFile}) async {
    debugPrint('UserProvider: uploadProfileImageFile called.');
    if (_user == null) {
      _setError('No user logged in to upload image.');
      debugPrint('UserProvider: uploadProfileImageFile - ERROR: No user logged in.');
      return;
    }
    _setLoading(true);
    _clearError();
    try {
      final imageUrl = await _uploadProfileImage(imageFile: imageFile); // Call the use case
      debugPrint('UserProvider: uploadProfileImageFile - Image uploaded. URL: $imageUrl');
      final updatedUser = _user!.copyWith(profileImageUrl: imageUrl);
      debugPrint('UserProvider: uploadProfileImageFile - Calling _updateUserProfile with new image URL.');
      await _updateUserProfile(updatedUser); // Update profile with new image URL
      _user = updatedUser; // Update local state
      debugPrint('UserProvider: uploadProfileImageFile - Profile image updated successfully. New _user: ${_user?.id}');
    } catch (e) {
      debugPrint('UserProvider: uploadProfileImageFile - ERROR: ${e.toString()}');
      _setError('Failed to upload profile image: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    debugPrint('UserProvider: _setLoading called. _isLoading: $_isLoading');
    notifyListeners();
  }

  void _setError(String message) {
    _error = message;
    debugPrint('UserProvider: _setError called. _error: $_error');
    notifyListeners();
  }

  void _clearError() {
    _error = null;
    debugPrint('UserProvider: _clearError called.');
    notifyListeners();
  }
}