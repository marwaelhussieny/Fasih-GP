// lib/features/community/data/services/community_service.dart

import 'dart:io';
import 'package:grad_project/core/services/api_service.dart';
import 'package:grad_project/features/community/data/models/community_models.dart';

class CommunityService {
  final ApiService _apiService;
  static const String baseEndpoint = '/community/post';

  CommunityService(this._apiService);

  // Get all posts
  Future<List<CommunityPost>> getAllPosts() async {
    try {
      print('🌐 Community Service: Fetching all posts');

      final response = await _apiService.get(baseEndpoint);

      if (response['success'] == true && response['data'] != null) {
        final List<dynamic> postsJson = response['data'] as List<dynamic>;
        final posts = postsJson.map((json) => CommunityPost.fromJson(json)).toList();

        print('🌐 Community Service: Fetched ${posts.length} posts');
        return posts;
      } else {
        throw Exception('Invalid response format');
      }
    } catch (e) {
      print('🌐 Community Service: Error fetching posts: $e');
      throw Exception('فشل في تحميل المنشورات: ${e.toString()}');
    }
  }

  // Get posts by category
  Future<List<CommunityPost>> getPostsByCategory(String categoryName) async {
    try {
      print('🌐 Community Service: Fetching posts for category: $categoryName');

      // URL encode the category name for Arabic text
      final encodedCategory = Uri.encodeComponent(categoryName);
      final response = await _apiService.get('$baseEndpoint/category/$encodedCategory/users');

      if (response['success'] == true && response['data'] != null) {
        final List<dynamic> postsJson = response['data'] as List<dynamic>;

        // Transform the response structure if needed
        final posts = postsJson.map((json) {
          // Handle different response structure from category endpoint
          return CommunityPost(
            id: json['postId'] ?? '',
            createdBy: json['postedBy']?['_id'] ?? '',
            content: json['content'] ?? '',
            category: categoryName,
            likes: [], // Will be populated separately
            comments: [],
            createdAt: DateTime.now(), // Will be updated with actual data
            updatedAt: DateTime.now(),
            createdByName: json['postedBy']?['fullName'],
          );
        }).toList();

        print('🌐 Community Service: Fetched ${posts.length} posts for category $categoryName');
        return posts;
      } else {
        throw Exception('Invalid response format');
      }
    } catch (e) {
      print('🌐 Community Service: Error fetching posts by category: $e');
      throw Exception('فشل في تحميل منشورات المجتمع: ${e.toString()}');
    }
  }

  // Create a new post
  Future<CommunityPost> createPost(CreatePostRequest request) async {
    try {
      print('🌐 Community Service: Creating new post');
      print('🌐 Community Service: Request data: ${request.toJson()}');

      final response = await _apiService.post(
        '$baseEndpoint/',
        body: request.toJson(),
      );

      if (response['message'] != null && response['data'] != null) {
        final postData = response['data'] as Map<String, dynamic>;
        final post = CommunityPost.fromJson(postData);

        print('🌐 Community Service: Post created successfully with ID: ${post.id}');
        return post;
      } else {
        throw Exception('Invalid response format');
      }
    } catch (e) {
      print('🌐 Community Service: Error creating post: $e');
      if (e is HttpException) {
        throw Exception(e.message);
      }
      throw Exception('فشل في إنشاء المنشور: ${e.toString()}');
    }
  }

  // Add like to post
  Future<void> likePost(String postId) async {
    try {
      print('🌐 Community Service: Liking post: $postId');

      await _apiService.post('$baseEndpoint/$postId/like');

      print('🌐 Community Service: Post liked successfully');
    } catch (e) {
      print('🌐 Community Service: Error liking post: $e');
      throw Exception('فشل في إضافة الإعجاب: ${e.toString()}');
    }
  }

  // Add comment to post
  Future<void> addComment(String postId, AddCommentRequest request) async {
    try {
      print('🌐 Community Service: Adding comment to post: $postId');

      await _apiService.post(
        '$baseEndpoint/$postId/comment',
        body: request.toJson(),
      );

      print('🌐 Community Service: Comment added successfully');
    } catch (e) {
      print('🌐 Community Service: Error adding comment: $e');
      throw Exception('فشل في إضافة التعليق: ${e.toString()}');
    }
  }

  // Get all categories
  Future<List<CommunityCategory>> getAllCategories() async {
    try {
      print('🌐 Community Service: Fetching all categories');

      final response = await _apiService.get('$baseEndpoint/allcategories');

      if (response['success'] == true && response['data'] != null) {
        final List<dynamic> categoriesJson = response['data'] as List<dynamic>;
        final categories = categoriesJson.map((json) => CommunityCategory.fromJson(json)).toList();

        print('🌐 Community Service: Fetched ${categories.length} categories');
        return categories;
      } else {
        throw Exception('Invalid response format');
      }
    } catch (e) {
      print('🌐 Community Service: Error fetching categories: $e');
      throw Exception('فشل في تحميل المجتمعات: ${e.toString()}');
    }
  }

  // Create new category
  Future<CommunityCategory> createCategory(String name) async {
    try {
      print('🌐 Community Service: Creating new category: $name');

      final response = await _apiService.post(
        '$baseEndpoint/category',
        body: {'name': name},
      );

      if (response['data'] != null) {
        final category = CommunityCategory.fromJson(response['data']);
        print('🌐 Community Service: Category created successfully');
        return category;
      } else {
        throw Exception('Invalid response format');
      }
    } catch (e) {
      print('🌐 Community Service: Error creating category: $e');
      throw Exception('فشل في إنشاء المجتمع: ${e.toString()}');
    }
  }

  // Search posts
  Future<List<CommunityPost>> searchPosts(String query) async {
    try {
      print('🌐 Community Service: Searching posts with query: $query');

      final response = await _apiService.get(
        '$baseEndpoint/search',
        queryParams: {'q': query},
      );

      if (response['success'] == true && response['data'] != null) {
        final List<dynamic> postsJson = response['data'] as List<dynamic>;
        final posts = postsJson.map((json) => CommunityPost.fromJson(json)).toList();

        print('🌐 Community Service: Found ${posts.length} posts for query: $query');
        return posts;
      } else {
        throw Exception('Invalid response format');
      }
    } catch (e) {
      print('🌐 Community Service: Error searching posts: $e');
      // Return empty list for search errors to gracefully handle no results
      return [];
    }
  }

  // Get community stats (mock implementation - extend as needed)
  Future<CommunityStats> getCommunityStats() async {
    try {
      // This could be a separate endpoint in your backend
      // For now, we'll calculate from available data
      final posts = await getAllPosts();
      final categories = await getAllCategories();

      final totalInteractions = posts.fold<int>(
        0,
            (sum, post) => sum + post.likesCount + post.commentsCount,
      );

      return CommunityStats(
        totalMembers: 226, // Static for now - could be from backend
        activePosts: posts.length,
        totalInteractions: totalInteractions,
        savedPosts: 1, // Static for now - could be from user preferences
      );
    } catch (e) {
      print('🌐 Community Service: Error fetching stats: $e');
      return CommunityStats(); // Return default stats on error
    }
  }
}