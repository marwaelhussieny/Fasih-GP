// lib/features/community/presentation/providers/community_provider.dart

import 'package:flutter/foundation.dart';
import 'package:grad_project/core/services/api_service.dart';
import 'package:grad_project/core/services/auth_service.dart';
import 'package:grad_project/features/community/data/services/community_service.dart';
import 'package:grad_project/features/community/data/models/community_models.dart';
import 'package:grad_project/core/services/auth_service.dart';
enum CommunityLoadingState {
  idle,
  loading,
  loaded,
  error,
}

class CommunityProvider extends ChangeNotifier {
  final CommunityService _communityService;
  final AuthService _authService;

  // State
  CommunityLoadingState _loadingState = CommunityLoadingState.idle;
  String? _errorMessage;
  String? _currentUserId;

  // Data
  List<CommunityPost> _allPosts = [];
  List<CommunityCategory> _categories = [];
  CommunityStats? _stats;

  // Filters and Search
  String _selectedFilter = 'الأحدث';
  String _searchQuery = '';
  String? _selectedCategory;

  CommunityProvider(this._communityService, this._authService) {
    _initializeUser();
  }

  // Getters
  CommunityLoadingState get loadingState => _loadingState;
  String? get errorMessage => _errorMessage;
  String? get currentUserId => _currentUserId;

  List<CommunityPost> get allPosts => _allPosts;
  List<CommunityCategory> get categories => _categories;
  CommunityStats? get stats => _stats;

  String get selectedFilter => _selectedFilter;
  String get searchQuery => _searchQuery;
  String? get selectedCategory => _selectedCategory;

  // Computed getters
  List<CommunityPost> get filteredPosts {
    List<CommunityPost> posts = List.from(_allPosts);

    // Apply search filter
    if (_searchQuery.isNotEmpty) {
      posts = posts.where((post) {
        return post.content.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            (post.createdByName?.toLowerCase().contains(_searchQuery.toLowerCase()) ?? false);
      }).toList();
    }

    // Apply category filter
    if (_selectedCategory != null && _selectedCategory!.isNotEmpty) {
      posts = posts.where((post) => post.category == _selectedCategory).toList();
    }

    // Apply sort filter
    switch (_selectedFilter) {
      case 'الأقدم':
        posts.sort((a, b) => a.createdAt.compareTo(b.createdAt));
        break;
      case 'الأكثر تفاعلاً':
        posts.sort((a, b) =>
            (b.likesCount + b.commentsCount).compareTo(a.likesCount + a.commentsCount));
        break;
      case 'الأكثر إعجاباً':
        posts.sort((a, b) => b.likesCount.compareTo(a.likesCount));
        break;
      case 'الأكثر تعليقاً':
        posts.sort((a, b) => b.commentsCount.compareTo(a.commentsCount));
        break;
      default: // الأحدث
        posts.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    }

    return posts;
  }

  List<CommunityPost> get recentPosts {
    return filteredPosts.take(5).toList();
  }

  bool get isLoading => _loadingState == CommunityLoadingState.loading;
  bool get hasError => _loadingState == CommunityLoadingState.error;
  bool get hasData => _loadingState == CommunityLoadingState.loaded;

  void _initializeUser() async {
    try {
      final user = _authService.getUser();
      _currentUserId = user?.id;
      print('🏠 Community Provider: User initialized: $_currentUserId');
    } catch (e) {
      print('🏠 Community Provider: Error initializing user: $e');
    }
  }

  void _setLoadingState(CommunityLoadingState state, {String? error}) {
    _loadingState = state;
    _errorMessage = error;
    notifyListeners();
  }

  // Load all community data
  Future<void> loadCommunityData() async {
    _setLoadingState(CommunityLoadingState.loading);

    try {
      // Load all data in parallel
      final results = await Future.wait([
        _communityService.getAllPosts(),
        _communityService.getAllCategories(),
        _communityService.getCommunityStats(),
      ]);

      _allPosts = results[0] as List<CommunityPost>;
      _categories = results[1] as List<CommunityCategory>;
      _stats = results[2] as CommunityStats;

      // Update likes status for current user
      _updatePostLikesStatus();

      _setLoadingState(CommunityLoadingState.loaded);

      print('🏠 Community Provider: Loaded ${_allPosts.length} posts, ${_categories.length} categories');
    } catch (e) {
      print('🏠 Community Provider: Error loading community data: $e');
      _setLoadingState(CommunityLoadingState.error, error: e.toString());
    }
  }

  // Refresh data
  Future<void> refreshData() async {
    await loadCommunityData();
  }

  // Create new post
  Future<bool> createPost({
    required String content,
    required String category,
  }) async {
    if (_currentUserId == null) {
      _setLoadingState(CommunityLoadingState.error, error: 'يجب تسجيل الدخول أولاً');
      return false;
    }

    try {
      _setLoadingState(CommunityLoadingState.loading);

      final request = CreatePostRequest(
        content: content,
        userId: _currentUserId!,
        category: category,
      );

      final newPost = await _communityService.createPost(request);

      // Add the new post to the beginning of the list
      _allPosts.insert(0, newPost);

      _setLoadingState(CommunityLoadingState.loaded);

      print('🏠 Community Provider: Post created successfully');
      return true;
    } catch (e) {
      print('🏠 Community Provider: Error creating post: $e');
      _setLoadingState(CommunityLoadingState.error, error: e.toString());
      return false;
    }
  }

  // Toggle post like
  Future<void> togglePostLike(String postId) async {
    if (_currentUserId == null) return;

    try {
      // Optimistically update UI
      final postIndex = _allPosts.indexWhere((post) => post.id == postId);
      if (postIndex != -1) {
        final post = _allPosts[postIndex];
        final newLikes = List<String>.from(post.likes);
        bool isLiked = newLikes.contains(_currentUserId!);

        if (isLiked) {
          newLikes.remove(_currentUserId!);
        } else {
          newLikes.add(_currentUserId!);
        }

        _allPosts[postIndex] = post.copyWith(
          likes: newLikes,
          isLiked: !isLiked,
        );

        notifyListeners();

        // Make API call
        if (!isLiked) {
          await _communityService.likePost(postId);
        }
        // Note: Unlike functionality would need a separate endpoint

        print('🏠 Community Provider: Post like toggled');
      }
    } catch (e) {
      print('🏠 Community Provider: Error toggling like: $e');
      // Revert optimistic update on error
      await loadCommunityData();
    }
  }

  // Add comment to post
  Future<bool> addComment(String postId, String text) async {
    if (_currentUserId == null) {
      _setLoadingState(CommunityLoadingState.error, error: 'يجب تسجيل الدخول أولاً');
      return false;
    }

    try {
      final request = AddCommentRequest(text: text);
      await _communityService.addComment(postId, request);

      // Optimistically add comment to UI
      final postIndex = _allPosts.indexWhere((post) => post.id == postId);
      if (postIndex != -1) {
        final post = _allPosts[postIndex];
        final newComments = List<CommunityComment>.from(post.comments);

        newComments.add(CommunityComment(
          userId: _currentUserId!,
          userName: _authService.getUser()?.fullName ?? 'أنت',
          text: text,
          createdAt: DateTime.now(),
        ));

        _allPosts[postIndex] = post.copyWith(comments: newComments);
        notifyListeners();
      }

      print('🏠 Community Provider: Comment added successfully');
      return true;
    } catch (e) {
      print('🏠 Community Provider: Error adding comment: $e');
      _setLoadingState(CommunityLoadingState.error, error: e.toString());
      return false;
    }
  }

  // Filter and search methods
  void setFilter(String filter) {
    if (_selectedFilter != filter) {
      _selectedFilter = filter;
      notifyListeners();
      print('🏠 Community Provider: Filter changed to: $filter');
    }
  }

  void setSearchQuery(String query) {
    if (_searchQuery != query) {
      _searchQuery = query;
      notifyListeners();
      print('🏠 Community Provider: Search query: $query');
    }
  }

  void setSelectedCategory(String? category) {
    if (_selectedCategory != category) {
      _selectedCategory = category;
      notifyListeners();
      print('🏠 Community Provider: Category filter: $category');
    }
  }

  void clearFilters() {
    _selectedFilter = 'الأحدث';
    _searchQuery = '';
    _selectedCategory = null;
    notifyListeners();
    print('🏠 Community Provider: Filters cleared');
  }

  // Load posts by category
  Future<void> loadPostsByCategory(String categoryName) async {
    try {
      _setLoadingState(CommunityLoadingState.loading);

      final posts = await _communityService.getPostsByCategory(categoryName);
      _allPosts = posts;
      _updatePostLikesStatus();

      _setLoadingState(CommunityLoadingState.loaded);

      print('🏠 Community Provider: Loaded ${posts.length} posts for category: $categoryName');
    } catch (e) {
      print('🏠 Community Provider: Error loading category posts: $e');
      _setLoadingState(CommunityLoadingState.error, error: e.toString());
    }
  }

  // Search posts
  Future<void> searchPosts(String query) async {
    if (query.isEmpty) {
      setSearchQuery('');
      return;
    }

    try {
      _setLoadingState(CommunityLoadingState.loading);

      final posts = await _communityService.searchPosts(query);
      _allPosts = posts;
      _updatePostLikesStatus();

      setSearchQuery(query);
      _setLoadingState(CommunityLoadingState.loaded);

      print('🏠 Community Provider: Search completed: ${posts.length} results');
    } catch (e) {
      print('🏠 Community Provider: Error searching posts: $e');
      _setLoadingState(CommunityLoadingState.error, error: e.toString());
    }
  }

  // Create new category
  Future<bool> createCategory(String name) async {
    try {
      final category = await _communityService.createCategory(name);
      _categories.add(category);
      notifyListeners();

      print('🏠 Community Provider: Category created: $name');
      return true;
    } catch (e) {
      print('🏠 Community Provider: Error creating category: $e');
      _setLoadingState(CommunityLoadingState.error, error: e.toString());
      return false;
    }
  }

  // Helper method to update likes status for current user
  void _updatePostLikesStatus() {
    if (_currentUserId == null) return;

    for (int i = 0; i < _allPosts.length; i++) {
      final post = _allPosts[i];
      final isLiked = post.likes.contains(_currentUserId!);
      _allPosts[i] = post.copyWith(isLiked: isLiked);
    }
  }

  // Clear error
  void clearError() {
    if (_loadingState == CommunityLoadingState.error) {
      _setLoadingState(CommunityLoadingState.idle);
    }
  }

  @override
  void dispose() {
    super.dispose();
  }
}