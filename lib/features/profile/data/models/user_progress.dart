// lib/features/profile/data/models/user_progress_model.dart

import 'package:grad_project/features/profile/domain/entities/user_progress_entity.dart';

class UserProgressModel extends UserProgressEntity {
  const UserProgressModel({
    super.totalWords,
    super.learnedCount,
    super.favoriteCount,
    super.easyCount,
    super.mediumCount,
    super.hardCount,
  });

  factory UserProgressModel.fromMap(Map<String, dynamic> json) {
    return UserProgressModel(
      totalWords: json['totalWords'] as int? ?? 0,
      learnedCount: json['learnedCount'] as int? ?? 0,
      favoriteCount: json['favoriteCount'] as int? ?? 0,
      easyCount: json['easyCount'] as int? ?? 0,
      mediumCount: json['mediumCount'] as int? ?? 0,
      hardCount: json['hardCount'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'totalWords': totalWords,
      'learnedCount': learnedCount,
      'favoriteCount': favoriteCount,
      'easyCount': easyCount,
      'mediumCount': mediumCount,
      'hardCount': hardCount,
    };
  }

  UserProgressEntity toEntity() {
    return UserProgressEntity(
      totalWords: totalWords,
      learnedCount: learnedCount,
      favoriteCount: favoriteCount,
      easyCount: easyCount,
      mediumCount: mediumCount,
      hardCount: hardCount,
    );
  }
}