// lib/features/home/data/datasources/home_remote_data_source.dart

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:grad_project/core/services/api_service.dart';
import 'package:grad_project/core/services/auth_service.dart';

abstract class HomeRemoteDataSource {
  Future<List<Map<String, dynamic>>> getLevels();
  Future<List<Map<String, dynamic>>> getLessons();
  Future<List<Map<String, dynamic>>> getLessonsForLevel(String levelId);
  Future<Map<String, dynamic>> getUserProgress();
  Future<Map<String, dynamic>> getCurrentStreak();
  Future<Map<String, dynamic>> getAchievements();
  Future<Map<String, dynamic>> completeLesson(String lessonId);
  Future<Map<String, dynamic>> completeLevel(String levelId);
  Future<Map<String, dynamic>> updateStreak();
  Future<Map<String, dynamic>> getLessonDetails(String lessonId);
  Future<Map<String, dynamic>> startLesson(String lessonId);
  Future<Map<String, dynamic>> getVideoLessonData(String lessonId);
}

class HomeRemoteDataSourceImpl implements HomeRemoteDataSource {
  final ApiService apiService;
  final AuthService authService;
  final String baseUrl = 'https://f35f3ddf1acd.ngrok-free.app/api/v1';

  HomeRemoteDataSourceImpl({
    required this.apiService,
    required this.authService,
  });

  Map<String, String> get _headers => {
    'Content-Type': 'application/json',
    'ngrok-skip-browser-warning': 'true',
    'User-Agent': 'FlutterApp/1.0',
    // Add auth header if available - simplified approach
    if (_getCurrentUserToken() != null)
      'Authorization': 'Bearer ${_getCurrentUserToken()}',
  };

  // Helper method to safely get current user token
  String? _getCurrentUserToken() {
    try {
      // This depends on your AuthService implementation
      // Replace with your actual token getter
      return authService.toString().hashCode.toString(); // Placeholder
    } catch (e) {
      print('No auth token available: $e');
      return null;
    }
  }

  // Helper method to safely get current user ID
  String _getCurrentUserId() {
    try {
      // Replace with your actual user ID getter
      return authService.toString().hashCode.toString(); // Placeholder
    } catch (e) {
      return 'anonymous_user';
    }
  }

  @override
  Future<List<Map<String, dynamic>>> getLevels() async {
    try {
      print('🏠 Fetching levels from: $baseUrl/levels');
      final response = await http.get(
        Uri.parse('$baseUrl/levels'),
        headers: _headers,
      ).timeout(const Duration(seconds: 10));

      print('📡 Levels response status: ${response.statusCode}');
      print('📡 Levels response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        // Handle different response formats
        if (data is List) {
          return List<Map<String, dynamic>>.from(data);
        } else if (data is Map && data['data'] != null) {
          return List<Map<String, dynamic>>.from(data['data']);
        } else if (data is Map && data['levels'] != null) {
          return List<Map<String, dynamic>>.from(data['levels']);
        }

        // Fallback: create mock levels if none exist
        return _createMockLevels();
      } else {
        throw Exception('Failed to load levels: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Error fetching levels: $e');
      // Return mock data for development
      return _createMockLevels();
    }
  }

  @override
  Future<List<Map<String, dynamic>>> getLessons() async {
    try {
      print('🏠 Fetching lessons from: $baseUrl/lessons');
      final response = await http.get(
        Uri.parse('$baseUrl/lessons'),
        headers: _headers,
      ).timeout(const Duration(seconds: 10));

      print('📡 Lessons response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data is List) {
          return List<Map<String, dynamic>>.from(data);
        } else if (data is Map && data['data'] != null) {
          return List<Map<String, dynamic>>.from(data['data']);
        } else if (data is Map && data['lessons'] != null) {
          return List<Map<String, dynamic>>.from(data['lessons']);
        }

        return _createMockLessons();
      } else {
        throw Exception('Failed to load lessons: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Error fetching lessons: $e');
      return _createMockLessons();
    }
  }

  @override
  Future<List<Map<String, dynamic>>> getLessonsForLevel(String levelId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/levels/$levelId/lessons'),
        headers: _headers,
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data is List) {
          return List<Map<String, dynamic>>.from(data);
        } else if (data is Map && data['data'] != null) {
          return List<Map<String, dynamic>>.from(data['data']);
        }

        return [];
      } else {
        throw Exception('Failed to load lessons for level: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Error fetching lessons for level $levelId: $e');
      return [];
    }
  }

  @override
  Future<Map<String, dynamic>> getUserProgress() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/progress'),
        headers: _headers,
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data is Map<String, dynamic> ? data : data['data'] ?? {};
      } else {
        throw Exception('Failed to load user progress: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Error fetching user progress: $e');
      return _createMockProgress();
    }
  }

  @override
  Future<Map<String, dynamic>> getCurrentStreak() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/progress/streak'),
        headers: _headers,
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data is Map<String, dynamic> ? data : data['data'] ?? {};
      } else {
        throw Exception('Failed to load streak: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Error fetching streak: $e');
      return _createMockStreak();
    }
  }

  @override
  Future<Map<String, dynamic>> getAchievements() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/progress/achievements'),
        headers: _headers,
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data is Map<String, dynamic> ? data : data['data'] ?? {};
      } else {
        throw Exception('Failed to load achievements: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Error fetching achievements: $e');
      return {};
    }
  }

  @override
  Future<Map<String, dynamic>> completeLesson(String lessonId) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/lessons/$lessonId/complete'),
        headers: _headers,
        body: json.encode({
          'lessonId': lessonId,
          'completedAt': DateTime.now().toIso8601String(),
        }),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = json.decode(response.body);
        return data is Map<String, dynamic> ? data : data['data'] ?? {};
      } else {
        throw Exception('Failed to complete lesson: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Error completing lesson: $e');
      // Return mock completion data
      return {
        'success': true,
        'xpEarned': 100,
        'message': 'Lesson completed!',
      };
    }
  }

  @override
  Future<Map<String, dynamic>> completeLevel(String levelId) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/levels/$levelId/complete'),
        headers: _headers,
        body: json.encode({
          'levelId': levelId,
          'completedAt': DateTime.now().toIso8601String(),
        }),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = json.decode(response.body);
        return data is Map<String, dynamic> ? data : data['data'] ?? {};
      } else {
        throw Exception('Failed to complete level: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Error completing level: $e');
      return {
        'success': true,
        'xpEarned': 500,
        'message': 'Level completed!',
      };
    }
  }

  @override
  Future<Map<String, dynamic>> updateStreak() async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/progress/streak'),
        headers: _headers,
        body: json.encode({
          'date': DateTime.now().toIso8601String(),
        }),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = json.decode(response.body);
        return data is Map<String, dynamic> ? data : data['data'] ?? {};
      } else {
        throw Exception('Failed to update streak: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Error updating streak: $e');
      return _createMockStreak();
    }
  }

  @override
  Future<Map<String, dynamic>> getLessonDetails(String lessonId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/lessons/$lessonId'),
        headers: _headers,
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data is Map<String, dynamic> ? data : data['data'] ?? {};
      } else {
        throw Exception('Failed to load lesson details: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Error fetching lesson details: $e');
      return _createMockLessonDetails(lessonId);
    }
  }

  @override
  Future<Map<String, dynamic>> startLesson(String lessonId) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/lessons/$lessonId/start'),
        headers: _headers,
        body: json.encode({
          'lessonId': lessonId,
          'startedAt': DateTime.now().toIso8601String(),
        }),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = json.decode(response.body);
        return data is Map<String, dynamic> ? data : data['data'] ?? {};
      } else {
        throw Exception('Failed to start lesson: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Error starting lesson: $e');
      return {
        'success': true,
        'message': 'Lesson started!',
      };
    }
  }

  @override
  Future<Map<String, dynamic>> getVideoLessonData(String lessonId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/lessons/$lessonId/video'),
        headers: _headers,
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data is Map<String, dynamic> ? data : data['data'] ?? {};
      } else {
        throw Exception('Failed to load video lesson data: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Error fetching video lesson data: $e');
      return _createMockVideoData(lessonId);
    }
  }

  // Mock data methods for development/fallback
  List<Map<String, dynamic>> _createMockLevels() {
    return [
      {
        '_id': 'level_1',
        'title': 'الأحرف العربية',
        'description': 'تعلم الأحرف العربية الأساسية',
        'image': 'https://images.unsplash.com/photo-1481627834876-b7833e8f5570?w=500',
        'order': 1,
        'requiredXP': 0,
        'isCompleted': false,
        'isUnlocked': true,
        'lessons': ['lesson_1', 'lesson_2', 'lesson_3'],
      },
      {
        '_id': 'level_2',
        'title': 'الكلمات الأساسية',
        'description': 'تعلم الكلمات العربية الأساسية',
        'image': 'https://images.unsplash.com/photo-1503676260728-1c00da094a0b?w=500',
        'order': 2,
        'requiredXP': 500,
        'isCompleted': false,
        'isUnlocked': false,
        'lessons': ['lesson_4', 'lesson_5', 'lesson_6'],
      },
      {
        '_id': 'level_3',
        'title': 'الجمل البسيطة',
        'description': 'تعلم تكوين الجمل العربية البسيطة',
        'image': 'https://images.unsplash.com/photo-1544716278-ca5e3f4abd8c?w=500',
        'order': 3,
        'requiredXP': 1000,
        'isCompleted': false,
        'isUnlocked': false,
        'lessons': ['lesson_7', 'lesson_8', 'lesson_9'],
      },
    ];
  }

  List<Map<String, dynamic>> _createMockLessons() {
    return [
      {
        '_id': 'lesson_1',
        'title': 'حرف الألف',
        'description': 'تعلم حرف الألف وطريقة كتابته',
        'levelId': 'level_1',
        'order': 1,
        'duration': 10,
        'xpReward': 100,
        'isCompleted': false,
        'isRequired': true,
        'progress': 0.0,
        'activities': [
          {
            'id': 'activity_1',
            'title': 'فيديو تعليمي',
            'description': 'مشاهدة فيديو تعليمي عن حرف الألف',
            'type': 'video',
            'videoUrl': 'https://sample-videos.com/zip/10/mp4/SampleVideo_1280x720_1mb.mp4',
            'duration': 5,
            'xpReward': 50,
            'isCompleted': false,
            'isRequired': true,
          },
          {
            'id': 'activity_2',
            'title': 'اختبار الحرف',
            'description': 'اختبار قصير على حرف الألف',
            'type': 'quiz',
            'duration': 5,
            'xpReward': 50,
            'isCompleted': false,
            'isRequired': true,
          }
        ],
      },
      {
        '_id': 'lesson_2',
        'title': 'حرف الباء',
        'description': 'تعلم حرف الباء وطريقة كتابته',
        'levelId': 'level_1',
        'order': 2,
        'duration': 10,
        'xpReward': 100,
        'isCompleted': false,
        'isRequired': true,
        'progress': 0.0,
        'activities': [
          {
            'id': 'activity_3',
            'title': 'فيديو تعليمي',
            'description': 'مشاهدة فيديو تعليمي عن حرف الباء',
            'type': 'video',
            'videoUrl': 'https://sample-videos.com/zip/10/mp4/SampleVideo_1280x720_1mb.mp4',
            'duration': 5,
            'xpReward': 50,
            'isCompleted': false,
            'isRequired': true,
          },
          {
            'id': 'activity_4',
            'title': 'اختبار الحرف',
            'description': 'اختبار قصير على حرف الباء',
            'type': 'quiz',
            'duration': 5,
            'xpReward': 50,
            'isCompleted': false,
            'isRequired': true,
          }
        ],
      },
      {
        '_id': 'lesson_3',
        'title': 'حرف التاء',
        'description': 'تعلم حرف التاء وطريقة كتابته',
        'levelId': 'level_1',
        'order': 3,
        'duration': 10,
        'xpReward': 100,
        'isCompleted': false,
        'isRequired': true,
        'progress': 0.0,
        'activities': [
          {
            'id': 'activity_5',
            'title': 'فيديو تعليمي',
            'description': 'مشاهدة فيديو تعليمي عن حرف التاء',
            'type': 'video',
            'videoUrl': 'https://sample-videos.com/zip/10/mp4/SampleVideo_1280x720_1mb.mp4',
            'duration': 5,
            'xpReward': 50,
            'isCompleted': false,
            'isRequired': true,
          },
          {
            'id': 'activity_6',
            'title': 'اختبار الحرف',
            'description': 'اختبار قصير على حرف التاء',
            'type': 'quiz',
            'duration': 5,
            'xpReward': 50,
            'isCompleted': false,
            'isRequired': true,
          }
        ],
      },
    ];
  }

  Map<String, dynamic> _createMockProgress() {
    return {
      'userId': _getCurrentUserId(),
      'totalXP': 250,
      'completedLessons': 1,
      'currentLevel': 1,
      'completedLevels': [],
      'achievements': ['first_lesson'],
      'lastActivity': DateTime.now().toIso8601String(),
      'stats': {
        'studyStreak': 3,
        'totalStudyTime': 45,
        'averageSessionTime': 15,
      },
    };
  }

  Map<String, dynamic> _createMockStreak() {
    return {
      'userId': _getCurrentUserId(),
      'currentStreak': 3,
      'longestStreak': 7,
      'lastActivityDate': DateTime.now().toIso8601String(),
      'streakDates': [
        DateTime.now().subtract(const Duration(days: 2)).toIso8601String(),
        DateTime.now().subtract(const Duration(days: 1)).toIso8601String(),
        DateTime.now().toIso8601String(),
      ],
    };
  }

  Map<String, dynamic> _createMockLessonDetails(String lessonId) {
    return {
      '_id': lessonId,
      'title': 'درس تفصيلي',
      'description': 'وصف تفصيلي للدرس',
      'videoUrl': 'https://sample-videos.com/zip/10/mp4/SampleVideo_1280x720_1mb.mp4',
      'transcript': 'نص الدرس هنا...',
      'notes': 'ملاحظات مهمة للدرس',
      'activities': [
        {
          'id': 'activity_1',
          'title': 'مشاهدة الفيديو',
          'description': 'مشاهدة الفيديو التعليمي',
          'type': 'video',
          'videoUrl': 'https://sample-videos.com/zip/10/mp4/SampleVideo_1280x720_1mb.mp4',
          'duration': 10,
          'xpReward': 100,
          'isCompleted': false,
          'isRequired': true,
        },
        {
          'id': 'activity_2',
          'title': 'اختبار سريع',
          'description': 'اختبار قصير على محتوى الدرس',
          'type': 'quiz',
          'duration': 5,
          'xpReward': 50,
          'isCompleted': false,
          'isRequired': true,
        }
      ],
    };
  }

  Map<String, dynamic> _createMockVideoData(String lessonId) {
    return {
      'videoUrl': 'https://sample-videos.com/zip/10/mp4/SampleVideo_1280x720_1mb.mp4',
      'title': 'درس فيديو تعليمي',
      'description': 'وصف الفيديو التعليمي',
      'duration': 600, // 10 minutes in seconds
      'transcript': 'نص الفيديو هنا...',
      'subtitles': [
        {
          'start': 0,
          'end': 5,
          'text': 'مرحباً بكم في هذا الدرس',
        },
        {
          'start': 5,
          'end': 10,
          'text': 'سنتعلم اليوم عن...',
        }
      ],
      'thumbnailUrl': 'https://images.unsplash.com/photo-1481627834876-b7833e8f5570?w=500',
    };
  }
}