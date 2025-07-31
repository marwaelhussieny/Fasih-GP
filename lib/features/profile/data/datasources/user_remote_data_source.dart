/// lib/features/profile/data/datasources/user_remote_data_source.dart

import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:grad_project/features/profile/domain/entities/user_entity.dart';
import 'package:grad_project/features/profile/domain/entities/user_progress_entity.dart';
import 'package:grad_project/features/profile/domain/entities/daily_activity_entity.dart'; // Ensure this is imported

abstract class UserRemoteDataSource {
  Future<UserEntity?> getUserProfile(String uid);
  Future<void> updateUserProfile(String uid, UserEntity user);
  Future<String> uploadProfileImage(String uid, File imageFile);
  Future<void> createUserProfile(String uid, String email, String name);
}

class UserRemoteDataSourceImpl implements UserRemoteDataSource {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _firebaseAuth;
  final FirebaseStorage _firebaseStorage;

  UserRemoteDataSourceImpl({
    FirebaseFirestore? firestore,
    FirebaseAuth? firebaseAuth,
    FirebaseStorage? firebaseStorage,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance,
        _firebaseStorage = firebaseStorage ?? FirebaseStorage.instance;

  @override
  Future<UserEntity?> getUserProfile(String uid) async {
    try {
      final docSnapshot = await _firestore.collection('users').doc(uid).get();
      if (docSnapshot.exists) {
        // FIX: Pass the document ID (uid) as the second argument to fromMap
        return UserEntity.fromMap(docSnapshot.data()!, docSnapshot.id);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get user profile: $e');
    }
  }

  @override
  Future<void> updateUserProfile(String uid, UserEntity user) async {
    try {
      // user.toMap() already contains the data to be saved.
      // The 'id' field is part of the UserEntity but not typically stored
      // in the Firestore document's map itself, as it's the document ID.
      // However, if your UserEntity.toMap() includes 'id', Firestore will just ignore it
      // or store it redundantly. It's fine as long as it doesn't cause issues.
      await _firestore.collection('users').doc(uid).set(user.toMap(), SetOptions(merge: true));
    } catch (e) {
      throw Exception('Failed to update user profile: $e');
    }
  }

  @override
  Future<String> uploadProfileImage(String uid, File imageFile) async {
    try {
      final storageRef = _firebaseStorage.ref().child('profile_images').child('$uid.jpg');
      final uploadTask = storageRef.putFile(imageFile);
      final snapshot = await uploadTask.whenComplete(() {});
      final downloadUrl = await snapshot.ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      throw Exception('Failed to upload profile image: $e');
    }
  }

  @override
  Future<void> createUserProfile(String uid, String email, String name) async {
    try {
      // Create user entity that matches your actual UserEntity structure
      // Ensure all required fields of UserEntity are provided or defaulted.
      final userEntity = UserEntity(
        id: uid,
        email: email,
        name: name,
        phoneNumber: '', // Default for non-nullable
        job: '',         // Default for non-nullable
        level: 'مبتدئ',   // Default for non-nullable
        status: 'نشط',   // Default for non-nullable
        profileImageUrl: null,
        memberSince: DateTime.now(),
        progress: UserProgressEntity.empty(), // Use empty factory for required progress
        dailyActivities: const [], // FIX: Empty LIST for new user
      );
      await _firestore.collection('users').doc(uid).set(userEntity.toMap());
    } catch (e) {
      throw Exception('Failed to create user profile: $e');
    }
  }
}