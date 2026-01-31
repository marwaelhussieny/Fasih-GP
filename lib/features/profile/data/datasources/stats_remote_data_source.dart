
// 3. LEARNING WORDS STATS DATA SOURCE
// ============================================

// lib/features/profile/data/datasources/stats_remote_data_source.dart
import 'package:grad_project/core/services/api_service.dart';
import 'package:grad_project/features/profile/domain/entities/user_progress_entity.dart';

abstract class StatsRemoteDataSource {
Future<UserProgressEntity> getUserStats();
}

class StatsRemoteDataSourceImpl implements StatsRemoteDataSource {
final ApiService apiService;

StatsRemoteDataSourceImpl({required this.apiService});

@override
Future<UserProgressEntity> getUserStats() async {
try {
// Use the learning words stats endpoint from your backend
final response = await apiService.get('/v1/learningwords/stats');

if (response['success'] != true || response['data'] == null) {
throw Exception('Failed to get user stats');
}

final data = response['data'] as Map<String, dynamic>;

return UserProgressEntity(
totalWords: data['totalWords'] ?? 0,
learnedCount: data['learnedCount'] ?? 0,
favoriteCount: data['favoriteCount'] ?? 0,
easyCount: data['easyCount'] ?? 0,
mediumCount: data['mediumCount'] ?? 0,
hardCount: data['hardCount'] ?? 0,
);
} catch (e) {
throw Exception('Failed to get user stats: $e');
}
}
}
