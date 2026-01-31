// lib/features/library/presentation/providers/library_provider.dart

import 'package:flutter/material.dart';
import 'package:grad_project/features/library/domain/entities/library_item_entity.dart';
import 'package:grad_project/features/library/domain/repositories/library_repository.dart';
import 'package:grad_project/features/library/domain/usecases/get_library_items_usecase.dart';
import 'package:grad_project/features/library/domain/usecases/search_library_items_usecase.dart';
import 'package:grad_project/features/library/domain/usecases/filter_library_items_usecase.dart';
import 'package:url_launcher/url_launcher.dart';

enum LibraryViewMode { grid, list }
enum SortOption { newest, oldest, title, author, rating, downloads }

class LibraryProvider with ChangeNotifier {
  final GetLibraryItemsUseCase getLibraryItemsUseCase;
  final SearchLibraryItemsUseCase searchLibraryItemsUseCase;
  final FilterLibraryItemsUseCase filterLibraryItemsUseCase;
  final LibraryRepository repository;

  // Core data
  List<LibraryItemEntity> _items = [];
  List<LibraryItemEntity> _allItems = []; // Keep original list for filtering
  List<CategoryEntity> _categories = [];

  // UI State
  bool _isLoading = false;
  bool _isInitialized = false;
  String _currentCategory = 'الجميع';
  bool _isSearching = false;
  String _searchQuery = '';
  String _errorMessage = '';
  bool _hasError = false;
  LibraryViewMode _viewMode = LibraryViewMode.grid;
  SortOption _sortOption = SortOption.newest;

  // Statistics
  int _totalItems = 0;
  int _totalDownloads = 0;
  Map<String, int> _categoryStats = {};

  LibraryProvider({
    required this.getLibraryItemsUseCase,
    required this.searchLibraryItemsUseCase,
    required this.filterLibraryItemsUseCase,
    required this.repository,
  });

  // Getters
  List<LibraryItemEntity> get items => _items;
  List<LibraryItemEntity> get allItems => _allItems;
  List<CategoryEntity> get categories => _categories;
  bool get isLoading => _isLoading;
  bool get isInitialized => _isInitialized;
  String get currentCategory => _currentCategory;
  bool get isSearching => _isSearching;
  String get searchQuery => _searchQuery;
  String get errorMessage => _errorMessage;
  bool get hasError => _hasError;
  LibraryViewMode get viewMode => _viewMode;
  SortOption get sortOption => _sortOption;
  int get totalItems => _totalItems;
  int get totalDownloads => _totalDownloads;
  Map<String, int> get categoryStats => _categoryStats;

  // Computed getters
  bool get hasItems => _items.isNotEmpty;
  bool get isEmpty => _items.isEmpty && !_isLoading;
  int get displayedItemsCount => _items.length;

  String get statusMessage {
    if (_isLoading) return 'جاري التحميل...';
    if (_hasError) return _errorMessage;
    if (_isSearching && _searchQuery.isNotEmpty) {
      return 'تم العثور على ${_items.length} نتيجة للبحث عن "$_searchQuery"';
    }
    if (_currentCategory != 'الجميع') {
      return '${_items.length} عنصر في فئة "$_currentCategory"';
    }
    return '${_items.length} عنصر في المكتبة';
  }

  // Initialize the provider
  Future<void> initialize() async {
    if (_isInitialized) return;

    print('📚 LibraryProvider: Initializing...');
    _setLoading(true);
    _clearError();

    try {
      await loadCategories();
      await loadItems();
      _updateStatistics();
      _isInitialized = true;
      print('✅ LibraryProvider: Initialization complete');
    } catch (e) {
      print('❌ LibraryProvider: Initialization failed: $e');
      _setError('فشل في تحميل المكتبة: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Load categories with enhanced error handling
  Future<void> loadCategories() async {
    try {
      print('📂 LibraryProvider: Loading categories...');
      final categoryEntities = await repository.getCategories();

      _categories = [
        CategoryEntity(id: 'all', name: 'الجميع', color: '#4F46E5'),
        ...categoryEntities,
      ];

      print('✅ LibraryProvider: Loaded ${_categories.length} categories');
    } catch (e) {
      print('❌ LibraryProvider: Error loading categories: $e');
      // Use comprehensive default categories if API fails
      _categories = [
        CategoryEntity(id: 'all', name: 'الجميع', color: '#4F46E5'),
        CategoryEntity(id: 'books', name: 'كتب', color: '#059669'),
        CategoryEntity(id: 'articles', name: 'مقالات', color: '#DC2626'),
        CategoryEntity(id: 'research', name: 'أبحاث', color: '#7C3AED'),
        CategoryEntity(id: 'stories', name: 'قصص', color: '#EA580C'),
        CategoryEntity(id: 'poetry', name: 'الشعر', color: '#10B981'),
        CategoryEntity(id: 'grammar', name: 'النحو والصرف', color: '#8B5CF6'),
        CategoryEntity(id: 'literature', name: 'الأدب والبلاغة', color: '#F59E0B'),
        CategoryEntity(id: 'history', name: 'تاريخ اللغة', color: '#06B6D4'),
      ];
    }
  }

  // Load initial items
  Future<void> loadItems() async {
    await fetchLibraryItems();
  }

  // Fetch library items from repository with retry logic
  Future<void> fetchLibraryItems({int retryCount = 0}) async {
    if (!_isInitialized) _setLoading(true);
    _clearError();

    try {
      print('📚 LibraryProvider: Fetching library items (attempt ${retryCount + 1})...');
      final items = await getLibraryItemsUseCase.call();

      _allItems = items;
      _applySorting();

      // If we have a current filter, apply it
      if (_currentCategory != 'الجميع') {
        await _applyCurrentFilter();
      } else if (_isSearching && _searchQuery.isNotEmpty) {
        await _applyCurrentSearch();
      } else {
        _items = List.from(_allItems);
      }

      _updateStatistics();
      _clearError();

      print('✅ LibraryProvider: Successfully loaded ${_allItems.length} items');
    } catch (e) {
      print('❌ LibraryProvider: Error fetching library items: $e');

      // Retry logic for network errors
      if (retryCount < 2 && (e.toString().contains('timeout') || e.toString().contains('connection'))) {
        print('🔄 LibraryProvider: Retrying fetch after ${(retryCount + 1) * 2} seconds...');
        await Future.delayed(Duration(seconds: (retryCount + 1) * 2));
        return fetchLibraryItems(retryCount: retryCount + 1);
      }

      _setError(_getErrorMessage(e));
      _items = [];
      _allItems = [];
    } finally {
      if (!_isInitialized) _setLoading(false);
    }
  }

  // Enhanced search with debouncing and relevance scoring
  Future<void> searchItems(String query) async {
    _searchQuery = query.trim();

    if (_searchQuery.isEmpty) {
      _isSearching = false;
      _items = List.from(_allItems);
      _applySorting();
      notifyListeners();
      return;
    }

    _isSearching = true;
    _setLoading(true);
    _clearError();

    try {
      print('🔍 LibraryProvider: Searching for: $_searchQuery');

      // Try backend search first
      List<LibraryItemEntity> searchResults;
      try {
        searchResults = await searchLibraryItemsUseCase.call(_searchQuery);
        print('✅ LibraryProvider: Backend search returned ${searchResults.length} results');
      } catch (e) {
        print('⚠️ LibraryProvider: Backend search failed, using local search: $e');
        // Fallback to local search with relevance scoring
        searchResults = _performLocalSearch(_searchQuery);
      }

      _items = searchResults;
      _applySorting();

      print('✅ LibraryProvider: Found ${_items.length} items for query: $_searchQuery');
    } catch (e) {
      print('❌ LibraryProvider: Error searching library items: $e');
      _setError('فشل في البحث: ${_getErrorMessage(e)}');
      _items = [];
    } finally {
      _setLoading(false);
    }
  }

  // Perform local search with relevance scoring
  List<LibraryItemEntity> _performLocalSearch(String query) {
    if (_allItems.isEmpty) return [];

    final queryLower = query.toLowerCase();
    final results = <LibraryItemEntity>[];

    for (final item in _allItems) {
      bool matches = false;

      // Check title
      if (item.title.toLowerCase().contains(queryLower)) matches = true;

      // Check author
      if (item.author.toLowerCase().contains(queryLower)) matches = true;

      // Check description
      if (item.description?.toLowerCase().contains(queryLower) == true) matches = true;

      // Check category
      if (item.category.toLowerCase().contains(queryLower)) matches = true;

      if (matches) results.add(item);
    }

    // Sort by relevance (title matches first)
    results.sort((a, b) {
      final aInTitle = a.title.toLowerCase().contains(queryLower);
      final bInTitle = b.title.toLowerCase().contains(queryLower);

      if (aInTitle && !bInTitle) return -1;
      if (!aInTitle && bInTitle) return 1;

      return a.title.compareTo(b.title);
    });

    return results;
  }

  // Enhanced filter with better category matching
  Future<void> filterItems(String category) async {
    _currentCategory = category;
    _isSearching = false;
    _searchQuery = '';

    if (category == 'الجميع' || category == 'All') {
      _items = List.from(_allItems);
      _applySorting();
      notifyListeners();
      return;
    }

    _setLoading(true);
    _clearError();

    try {
      await _applyCurrentFilter();
      print('✅ LibraryProvider: Filtered to ${_items.length} items in category: $category');
    } catch (e) {
      print('❌ LibraryProvider: Error filtering library items: $e');
      _setError('فشل في التصفية: ${_getErrorMessage(e)}');
      _items = [];
    } finally {
      _setLoading(false);
    }
  }

  Future<void> _applyCurrentFilter() async {
    try {
      // Try backend filtering first
      final filteredItems = await filterLibraryItemsUseCase.call(_currentCategory);
      _items = filteredItems;
    } catch (e) {
      print('⚠️ LibraryProvider: Backend filtering failed, using local filter: $e');
      // Fallback to local filtering
      _items = _allItems.where((item) =>
      item.category == _currentCategory ||
          item.category.toLowerCase() == _currentCategory.toLowerCase() ||
          _normalizeCategoryName(item.category) == _currentCategory
      ).toList();
    }

    _applySorting();
  }

  Future<void> _applyCurrentSearch() async {
    if (_searchQuery.isEmpty) return;
    await searchItems(_searchQuery);
  }

  // Normalize category names for better matching
  String _normalizeCategoryName(String category) {
    final Map<String, String> normalizationMap = {
      'books': 'كتب',
      'articles': 'مقالات',
      'research': 'أبحاث',
      'stories': 'قصص',
      'poetry': 'الشعر',
      'grammar': 'النحو والصرف',
      'literature': 'الأدب والبلاغة',
      'history': 'تاريخ اللغة',
    };

    return normalizationMap[category.toLowerCase()] ?? category;
  }

  // Toggle search mode
  void toggleSearch(bool value) {
    _isSearching = value;

    if (!value) {
      _searchQuery = '';
      if (_currentCategory == 'الجميع') {
        _items = List.from(_allItems);
        _applySorting();
      } else {
        filterItems(_currentCategory);
      }
    }

    notifyListeners();
  }

  // Set view mode
  void setViewMode(LibraryViewMode mode) {
    if (_viewMode != mode) {
      _viewMode = mode;
      notifyListeners();
    }
  }

  // Set sort option
  void setSortOption(SortOption option) {
    if (_sortOption != option) {
      _sortOption = option;
      _applySorting();
      notifyListeners();
    }
  }

  // Apply current sorting
  void _applySorting() {
    switch (_sortOption) {
      case SortOption.newest:
        _items.sort((a, b) {
          if (a.createdAt == null && b.createdAt == null) return 0;
          if (a.createdAt == null) return 1;
          if (b.createdAt == null) return -1;
          return b.createdAt!.compareTo(a.createdAt!);
        });
        break;
      case SortOption.oldest:
        _items.sort((a, b) {
          if (a.createdAt == null && b.createdAt == null) return 0;
          if (a.createdAt == null) return 1;
          if (b.createdAt == null) return -1;
          return a.createdAt!.compareTo(b.createdAt!);
        });
        break;
      case SortOption.title:
        _items.sort((a, b) => a.title.compareTo(b.title));
        break;
      case SortOption.author:
        _items.sort((a, b) => a.author.compareTo(b.author));
        break;
      case SortOption.rating:
        _items.sort((a, b) {
          final aRating = a.rating ?? 0.0;
          final bRating = b.rating ?? 0.0;
          return bRating.compareTo(aRating);
        });
        break;
      case SortOption.downloads:
        _items.sort((a, b) {
          final aDownloads = a.downloads ?? 0;
          final bDownloads = b.downloads ?? 0;
          return bDownloads.compareTo(aDownloads);
        });
        break;
    }
  }

  // Update statistics
  void _updateStatistics() {
    _totalItems = _allItems.length;
    _totalDownloads = _allItems.fold<int>(0, (sum, item) => sum + (item.downloads ?? 0));

    _categoryStats.clear();
    for (final item in _allItems) {
      final category = item.category;
      _categoryStats[category] = (_categoryStats[category] ?? 0) + 1;
    }
  }

  // Download book with enhanced error handling
  Future<bool> downloadBook(String bookId, String bookTitle) async {
    try {
      print('📥 LibraryProvider: Downloading book: $bookId');
      final downloadUrl = await repository.downloadBook(bookId);

      // Validate URL
      if (downloadUrl.isEmpty) {
        throw Exception('رابط التحميل غير متاح');
      }

      // Launch the download URL
      final uri = Uri.parse(downloadUrl);
      if (await canLaunchUrl(uri)) {
        final launched = await launchUrl(
          uri,
          mode: LaunchMode.externalApplication,
        );

        if (launched) {
          print('✅ LibraryProvider: Download started for: $bookTitle');
          return true;
        } else {
          throw Exception('فشل في فتح رابط التحميل');
        }
      } else {
        throw Exception('لا يمكن فتح رابط التحميل');
      }
    } catch (e) {
      print('❌ LibraryProvider: Error downloading book: $e');
      _setError('فشل في تحميل "$bookTitle": ${_getErrorMessage(e)}');
      return false;
    }
  }

  // Get book details by ID
  Future<LibraryItemEntity?> getBookById(String bookId) async {
    try {
      print('📖 LibraryProvider: Getting book details for: $bookId');
      final book = await repository.getBookById(bookId);
      print('✅ LibraryProvider: Got book details: ${book.title}');
      return book;
    } catch (e) {
      print('❌ LibraryProvider: Error getting book details: $e');
      _setError('فشل في تحميل تفاصيل الكتاب: ${_getErrorMessage(e)}');
      return null;
    }
  }

  // Refresh data with pull-to-refresh support
  Future<void> refresh() async {
    print('🔄 LibraryProvider: Refreshing library data...');

    try {
      await loadCategories();
      await fetchLibraryItems();

      // Reapply current filters/search
      if (_isSearching && _searchQuery.isNotEmpty) {
        await _applyCurrentSearch();
      } else if (_currentCategory != 'الجميع') {
        await _applyCurrentFilter();
      }

      _updateStatistics();
      print('✅ LibraryProvider: Refresh complete');
    } catch (e) {
      print('❌ LibraryProvider: Refresh failed: $e');
      _setError('فشل في تحديث البيانات: ${_getErrorMessage(e)}');
    }
  }

  // Get category color by name
  String getCategoryColor(String categoryName) {
    final category = _categories.firstWhere(
          (cat) => cat.name == categoryName,
      orElse: () => CategoryEntity(id: 'default', name: categoryName, color: '#6B7280'),
    );
    return category.color;
  }

  // Get category icon by name
  IconData getCategoryIcon(String categoryName) {
    switch (categoryName.toLowerCase()) {
      case 'كتب':
      case 'books':
        return Icons.book;
      case 'مقالات':
      case 'articles':
        return Icons.article;
      case 'أبحاث':
      case 'research':
        return Icons.science;
      case 'قصص':
      case 'stories':
        return Icons.auto_stories;
      case 'الشعر':
      case 'poetry':
        return Icons.format_quote;
      case 'النحو والصرف':
      case 'grammar':
        return Icons.school;
      case 'الأدب والبلاغة':
      case 'literature':
        return Icons.menu_book;
      case 'تاريخ اللغة':
      case 'history':
        return Icons.history;
      case 'علم اللغة':
      case 'linguistics':
        return Icons.psychology;
      case 'تعليم':
      case 'education':
        return Icons.school_outlined;
      case 'أطفال':
      case 'children':
        return Icons.child_friendly;
      default:
        return Icons.library_books;
    }
  }

  // Get sort option display name
  String getSortOptionName(SortOption option) {
    switch (option) {
      case SortOption.newest:
        return 'الأحدث';
      case SortOption.oldest:
        return 'الأقدم';
      case SortOption.title:
        return 'العنوان';
      case SortOption.author:
        return 'المؤلف';
      case SortOption.rating:
        return 'التقييم';
      case SortOption.downloads:
        return 'التحميلات';
    }
  }

  // Get items by category for statistics
  List<LibraryItemEntity> getItemsByCategory(String categoryName) {
    if (categoryName == 'الجميع') return _allItems;

    return _allItems.where((item) =>
    item.category == categoryName ||
        item.category.toLowerCase() == categoryName.toLowerCase() ||
        _normalizeCategoryName(item.category) == categoryName
    ).toList();
  }

  // Get popular items (high downloads or rating)
  List<LibraryItemEntity> getPopularItems({int limit = 10}) {
    final popularItems = List<LibraryItemEntity>.from(_allItems);

    // Sort by combination of rating and downloads
    popularItems.sort((a, b) {
      final aScore = (a.rating ?? 0.0) * 2 + (a.downloads ?? 0) / 100;
      final bScore = (b.rating ?? 0.0) * 2 + (b.downloads ?? 0) / 100;
      return bScore.compareTo(aScore);
    });

    return popularItems.take(limit).toList();
  }

  // Get recent items
  List<LibraryItemEntity> getRecentItems({int limit = 10}) {
    final recentItems = _allItems.where((item) => item.createdAt != null).toList();

    recentItems.sort((a, b) => b.createdAt!.compareTo(a.createdAt!));

    return recentItems.take(limit).toList();
  }

  // Get recommended items based on user preferences (mock implementation)
  List<LibraryItemEntity> getRecommendedItems({int limit = 5}) {
    // Simple recommendation based on popular items in different categories
    final recommendations = <LibraryItemEntity>[];

    for (final category in _categories.skip(1)) { // Skip "الجميع"
      final categoryItems = getItemsByCategory(category.name);
      if (categoryItems.isNotEmpty) {
        // Get the highest rated item from each category
        categoryItems.sort((a, b) => (b.rating ?? 0.0).compareTo(a.rating ?? 0.0));
        recommendations.add(categoryItems.first);

        if (recommendations.length >= limit) break;
      }
    }

    return recommendations;
  }

  // Check if item exists in library
  bool hasItem(String itemId) {
    return _allItems.any((item) => item.id == itemId);
  }

  // Get item by ID from current loaded items
  LibraryItemEntity? getItem(String itemId) {
    try {
      return _allItems.firstWhere((item) => item.id == itemId);
    } catch (e) {
      return null;
    }
  }

  // Export statistics
  Map<String, dynamic> getLibraryStatistics() {
    final stats = <String, dynamic>{};

    stats['totalItems'] = _totalItems;
    stats['totalDownloads'] = _totalDownloads;
    stats['categoriesCount'] = _categories.length - 1; // Exclude "الجميع"
    stats['categoryBreakdown'] = Map.from(_categoryStats);

    if (_allItems.isNotEmpty) {
      final ratings = _allItems
          .where((item) => item.rating != null && item.rating! > 0)
          .map((item) => item.rating!)
          .toList();

      if (ratings.isNotEmpty) {
        stats['averageRating'] = ratings.reduce((a, b) => a + b) / ratings.length;
        stats['highestRating'] = ratings.reduce((a, b) => a > b ? a : b);
      }

      final recentItems = _allItems.where((item) {
        if (item.createdAt == null) return false;
        final daysDiff = DateTime.now().difference(item.createdAt!).inDays;
        return daysDiff <= 30;
      }).length;

      stats['recentItems'] = recentItems;
    }

    return stats;
  }

  // Private helper methods
  void _setLoading(bool loading) {
    if (_isLoading != loading) {
      _isLoading = loading;
      notifyListeners();
    }
  }

  void _setError(String error) {
    _errorMessage = error;
    _hasError = error.isNotEmpty;
    notifyListeners();
  }

  void _clearError() {
    if (_hasError) {
      _errorMessage = '';
      _hasError = false;
      notifyListeners();
    }
  }

  String _getErrorMessage(dynamic error) {
    String errorStr = error.toString();

    if (errorStr.contains('timeout') || errorStr.contains('TimeoutException')) {
      return 'انتهت مهلة الاتصال. تحقق من اتصال الإنترنت';
    } else if (errorStr.contains('SocketException') || errorStr.contains('connection')) {
      return 'لا يوجد اتصال بالإنترنت';
    } else if (errorStr.contains('404')) {
      return 'الخدمة غير متاحة حالياً';
    } else if (errorStr.contains('500')) {
      return 'خطأ في الخادم. يرجى المحاولة لاحقاً';
    } else if (errorStr.contains('401') || errorStr.contains('403')) {
      return 'غير مصرح بالوصول';
    } else {
      return 'حدث خطأ غير متوقع. يرجى المحاولة مرة أخرى';
    }
  }

  // Clear error manually
  void clearError() {
    _clearError();
  }

  // Reset provider state
  void reset() {
    _items.clear();
    _allItems.clear();
    _categories.clear();
    _isLoading = false;
    _isInitialized = false;
    _currentCategory = 'الجميع';
    _isSearching = false;
    _searchQuery = '';
    _errorMessage = '';
    _hasError = false;
    _viewMode = LibraryViewMode.grid;
    _sortOption = SortOption.newest;
    _totalItems = 0;
    _totalDownloads = 0;
    _categoryStats.clear();
    notifyListeners();
  }

  @override
  void dispose() {
    print('🗑️ LibraryProvider: Disposing...');
    super.dispose();
  }

  // Debug information
  Map<String, dynamic> getDebugInfo() {
    return {
      'isInitialized': _isInitialized,
      'isLoading': _isLoading,
      'hasError': _hasError,
      'errorMessage': _errorMessage,
      'totalItems': _totalItems,
      'displayedItems': _items.length,
      'allItemsCount': _allItems.length,
      'categoriesCount': _categories.length,
      'currentCategory': _currentCategory,
      'isSearching': _isSearching,
      'searchQuery': _searchQuery,
      'viewMode': _viewMode.toString(),
      'sortOption': _sortOption.toString(),
      'categoryStats': _categoryStats,
    };
  }
}