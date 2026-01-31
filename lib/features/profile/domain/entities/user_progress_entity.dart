// lib/features/profile/domain/entities/user_progress_entity.dart

import 'package:equatable/equatable.dart';

class UserProgressEntity extends Equatable {
  final int totalWords;
  final int learnedCount;
  final int favoriteCount;
  final int easyCount;
  final int mediumCount;
  final int hardCount;

  const UserProgressEntity({
    this.totalWords = 0,
    this.learnedCount = 0,
    this.favoriteCount = 0,
    this.easyCount = 0,
    this.mediumCount = 0,
    this.hardCount = 0,
  });

  @override
  List<Object?> get props => [
    totalWords,
    learnedCount,
    favoriteCount,
    easyCount,
    mediumCount,
    hardCount,
  ];
}