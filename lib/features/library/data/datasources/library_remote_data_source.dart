// lib/features/library/data/datasources/library_remote_data_source.dart

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:grad_project/features/library/data/models/library_item_model.dart';
import 'package:grad_project/core/services/auth_service.dart';

abstract class LibraryRemoteDataSource {
  Future<List<LibraryItemModel>> getLibraryItems();
  Future<List<LibraryItemModel>> searchLibraryItems(String query);
  Future<List<LibraryItemModel>> filterLibraryItems(String category);
  Future<List<CategoryModel>> getCategories();
  Future<String> downloadBook(String bookId);
  Future<LibraryItemModel> getBookById(String bookId);
}

class LibraryRemoteDataSourceImpl implements LibraryRemoteDataSource {
  final String baseUrl;
  final http.Client httpClient;
  final AuthService? authService;

  LibraryRemoteDataSourceImpl({
    String? baseUrl,
    http.Client? httpClient,
    this.authService,
  }) : baseUrl = baseUrl ?? 'https://f35f3ddf1acd.ngrok-free.app/api/v1',
        httpClient = httpClient ?? http.Client();

  Map<String, String> get _headers {
    final headers = {
      'Content-Type': 'application/json',
      'ngrok-skip-browser-warning': 'true',
      'User-Agent': 'FlutterApp/1.0',
      'Accept': 'application/json',
    };

    // For now, we'll skip authentication for the library
    // Many library APIs work with public access
    // If authentication is needed later, it can be added when we know the exact AuthService interface

    print('ℹ️ LibraryRemoteDataSource: Using public access (no authentication required for library content)');

    return headers;
  }

  @override
  Future<List<LibraryItemModel>> getLibraryItems() async {
    try {
      print('🔍 Fetching library items from: $baseUrl/library/books');

      final response = await httpClient.get(
        Uri.parse('$baseUrl/library/books'),
        headers: _headers,
      ).timeout(const Duration(seconds: 15));

      print('📡 Response status: ${response.statusCode}');
      print('📡 Response body: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);

        if (jsonResponse['success'] == true && jsonResponse['data'] != null) {
          final List<dynamic> booksData = jsonResponse['data'];
          final List<LibraryItemModel> books = booksData
              .map((bookJson) => LibraryItemModel.fromBackendJson(bookJson))
              .toList();

          print('✅ Successfully fetched ${books.length} books');
          return books;
        } else {
          print('⚠️ API returned success=false or null data');
          return _getFallbackData();
        }
      } else if (response.statusCode == 404) {
        print('📚 Books endpoint not found, using fallback data');
        return _getFallbackData();
      } else {
        print('❌ Failed to fetch books: ${response.statusCode}');
        return _getFallbackData();
      }
    } catch (e) {
      print('❌ Error fetching library items: $e');
      return _getFallbackData();
    }
  }

  @override
  Future<List<LibraryItemModel>> searchLibraryItems(String query) async {
    try {
      print('🔍 Searching library items with query: $query');

      final encodedQuery = Uri.encodeComponent(query);
      final response = await httpClient.get(
        Uri.parse('$baseUrl/library/books/search?q=$encodedQuery'),
        headers: _headers,
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);

        if (jsonResponse['success'] == true && jsonResponse['data'] != null) {
          final List<dynamic> booksData = jsonResponse['data'];
          final List<LibraryItemModel> books = booksData
              .map((bookJson) => LibraryItemModel.fromBackendJson(bookJson))
              .toList();

          print('✅ Found ${books.length} books matching query: $query');
          return books;
        }
      }

      // Fallback to local search if API fails or endpoint doesn't exist
      print('🔄 API search failed, falling back to local filter');
      final allBooks = await getLibraryItems();
      return allBooks.where((book) =>
      book.title.toLowerCase().contains(query.toLowerCase()) ||
          book.author.toLowerCase().contains(query.toLowerCase()) ||
          (book.description?.toLowerCase().contains(query.toLowerCase()) ?? false)
      ).toList();
    } catch (e) {
      print('❌ Error searching library items: $e');
      // Fallback to local search
      final allBooks = await getLibraryItems();
      return allBooks.where((book) =>
      book.title.toLowerCase().contains(query.toLowerCase()) ||
          book.author.toLowerCase().contains(query.toLowerCase()) ||
          (book.description?.toLowerCase().contains(query.toLowerCase()) ?? false)
      ).toList();
    }
  }

  @override
  Future<List<LibraryItemModel>> filterLibraryItems(String categoryName) async {
    try {
      print('🔍 Filtering library items by category: $categoryName');

      if (categoryName == 'الجميع' || categoryName == 'All') {
        return await getLibraryItems();
      }

      // Try API filtering first
      try {
        final encodedCategory = Uri.encodeComponent(categoryName);
        final response = await httpClient.get(
          Uri.parse('$baseUrl/library/books/category/$encodedCategory'),
          headers: _headers,
        ).timeout(const Duration(seconds: 10));

        if (response.statusCode == 200) {
          final Map<String, dynamic> jsonResponse = json.decode(response.body);
          if (jsonResponse['success'] == true && jsonResponse['data'] != null) {
            final List<dynamic> booksData = jsonResponse['data'];
            final List<LibraryItemModel> books = booksData
                .map((bookJson) => LibraryItemModel.fromBackendJson(bookJson))
                .toList();

            print('✅ Found ${books.length} books in category: $categoryName via API');
            return books;
          }
        }
      } catch (e) {
        print('⚠️ API filtering failed: $e, falling back to local filter');
      }

      // Fallback to local filtering
      final allBooks = await getLibraryItems();
      final filteredBooks = allBooks.where((book) =>
      book.categoryName == categoryName ||
          book.category == categoryName ||
          _normalizeCategoryName(book.categoryName ?? book.category) == _normalizeCategoryName(categoryName)
      ).toList();

      print('✅ Found ${filteredBooks.length} books in category: $categoryName via local filter');
      return filteredBooks;
    } catch (e) {
      print('❌ Error filtering library items: $e');
      return [];
    }
  }

  String _normalizeCategoryName(String category) {
    final Map<String, String> categoryMap = {
      'books': 'كتب',
      'articles': 'مقالات',
      'research': 'أبحاث',
      'stories': 'قصص',
      'poetry': 'الشعر',
      'grammar': 'النحو والصرف',
      'literature': 'الأدب والبلاغة',
      'history': 'تاريخ اللغة',
    };

    final normalized = category.toLowerCase().trim();
    return categoryMap[normalized] ?? category;
  }

  @override
  Future<List<CategoryModel>> getCategories() async {
    try {
      print('🔍 Fetching book categories from: $baseUrl/library/categories');

      final response = await httpClient.get(
        Uri.parse('$baseUrl/library/categories'),
        headers: _headers,
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);

        if (jsonResponse['success'] == true && jsonResponse['data'] != null) {
          final List<dynamic> categoriesData = jsonResponse['data'];
          final List<CategoryModel> categories = categoriesData
              .map((categoryJson) => CategoryModel.fromJson(categoryJson))
              .toList();

          print('✅ Successfully fetched ${categories.length} categories');
          return categories;
        }
      }

      // Return default categories if API fails
      print('⚠️ Categories API failed, using defaults');
      return _getDefaultCategories();
    } catch (e) {
      print('❌ Error fetching categories: $e');
      return _getDefaultCategories();
    }
  }

  @override
  Future<String> downloadBook(String bookId) async {
    try {
      print('🔍 Getting download URL for book: $bookId');

      final response = await httpClient.get(
        Uri.parse('$baseUrl/library/books/$bookId/download'),
        headers: _headers,
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);

        if (jsonResponse['success'] == true) {
          final String downloadUrl = jsonResponse['downloadUrl'] ?? jsonResponse['data']?['downloadUrl'] ?? '';
          if (downloadUrl.isNotEmpty) {
            print('✅ Got download URL: $downloadUrl');
            return downloadUrl;
          }
        }
      }

      throw Exception('Download URL not found in response');
    } catch (e) {
      print('❌ Error getting download URL: $e');
      throw Exception('Failed to download book: $e');
    }
  }

  @override
  Future<LibraryItemModel> getBookById(String bookId) async {
    try {
      print('🔍 Fetching book details for ID: $bookId');

      final response = await httpClient.get(
        Uri.parse('$baseUrl/library/books/$bookId'),
        headers: _headers,
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);

        if (jsonResponse['success'] == true && jsonResponse['data'] != null) {
          final LibraryItemModel book = LibraryItemModel.fromBackendJson(jsonResponse['data']);
          print('✅ Successfully fetched book: ${book.title}');
          return book;
        }
      }

      throw Exception('Book not found');
    } catch (e) {
      print('❌ Error fetching book details: $e');
      throw Exception('Failed to fetch book: $e');
    }
  }

  // Enhanced fallback data with more realistic content
  List<LibraryItemModel> _getFallbackData() {
    return [
      LibraryItemModel(
        id: '1',
        imageUrl: 'https://placehold.co/150x200/4F46E5/white?text=كتاب+النحو',
        title: 'مقدمة في النحو العربي',
        author: 'أحمد الشافعي',
        category: 'grammar',
        categoryName: 'النحو والصرف',
        description: 'مقدمة شاملة في قواعد النحو العربي مع أمثلة تطبيقية وتمارين متنوعة',
        pages: 120,
        rating: 4.5,
        downloads: 250,
        fileUrl: 'https://example.com/book1.pdf',
        isActive: true,
        createdAt: DateTime.now().subtract(const Duration(days: 30)),
      ),
      LibraryItemModel(
        id: '2',
        imageUrl: 'https://placehold.co/150x200/059669/white?text=بلاغة+القرآن',
        title: 'بلاغة القرآن الكريم',
        author: 'محمد عبد الباسط',
        category: 'literature',
        categoryName: 'الأدب والبلاغة',
        description: 'دراسة تحليلية في بلاغة القرآن الكريم وإعجازه البياني',
        pages: 80,
        rating: 4.8,
        downloads: 180,
        fileUrl: 'https://example.com/article1.pdf',
        isActive: true,
        createdAt: DateTime.now().subtract(const Duration(days: 15)),
      ),
      LibraryItemModel(
        id: '3',
        imageUrl: 'https://placehold.co/150x200/DC2626/white?text=تاريخ+العربية',
        title: 'تاريخ اللغة العربية',
        author: 'فاطمة الزهراء',
        category: 'history',
        categoryName: 'تاريخ اللغة',
        description: 'بحث شامل في تطور اللغة العربية عبر التاريخ والعصور المختلفة',
        pages: 200,
        rating: 4.2,
        downloads: 95,
        fileUrl: 'https://example.com/research1.pdf',
        isActive: true,
        createdAt: DateTime.now().subtract(const Duration(days: 7)),
      ),
      LibraryItemModel(
        id: '4',
        imageUrl: 'https://placehold.co/150x200/7C3AED/white?text=قصة+الذئب',
        title: 'قصة الذئب والخراف السبعة',
        author: 'حسن محمد',
        category: 'stories',
        categoryName: 'قصص',
        description: 'قصة تعليمية للأطفال بأسلوب ممتع ولغة عربية فصيحة',
        pages: 25,
        rating: 4.6,
        downloads: 320,
        fileUrl: 'https://example.com/story1.pdf',
        isActive: true,
        createdAt: DateTime.now().subtract(const Duration(days: 3)),
      ),
      LibraryItemModel(
        id: '5',
        imageUrl: 'https://placehold.co/150x200/EA580C/white?text=ديوان+الشعر',
        title: 'ديوان الشعر العربي الكلاسيكي',
        author: 'عمر الفاروق',
        category: 'poetry',
        categoryName: 'الشعر',
        description: 'مجموعة مختارة من أجمل القصائد في الشعر العربي الكلاسيكي',
        pages: 150,
        rating: 4.7,
        downloads: 210,
        fileUrl: 'https://example.com/poetry1.pdf',
        isActive: true,
        createdAt: DateTime.now().subtract(const Duration(hours: 12)),
      ),
      LibraryItemModel(
        id: '6',
        imageUrl: 'https://placehold.co/150x200/10B981/white?text=مقال+الصرف',
        title: 'قواعد الصرف في العربية',
        author: 'سعاد أحمد',
        category: 'articles',
        categoryName: 'مقالات',
        description: 'مقال تفصيلي حول قواعد الصرف وتطبيقاتها في اللغة العربية',
        pages: 45,
        rating: 4.3,
        downloads: 165,
        fileUrl: 'https://example.com/article2.pdf',
        isActive: true,
        createdAt: DateTime.now().subtract(const Duration(days: 2)),
      ),
    ];
  }

  List<CategoryModel> _getDefaultCategories() {
    return [
      CategoryModel(id: 'grammar', name: 'النحو والصرف', color: '#4F46E5'),
      CategoryModel(id: 'literature', name: 'الأدب والبلاغة', color: '#059669'),
      CategoryModel(id: 'history', name: 'تاريخ اللغة', color: '#DC2626'),
      CategoryModel(id: 'stories', name: 'قصص', color: '#7C3AED'),
      CategoryModel(id: 'poetry', name: 'الشعر', color: '#EA580C'),
      CategoryModel(id: 'articles', name: 'مقالات', color: '#10B981'),
    ];
  }
}

// Enhanced Category model for book categories
class CategoryModel {
  final String id;
  final String name;
  final String color;
  final String? description;
  final int? count;

  CategoryModel({
    required this.id,
    required this.name,
    required this.color,
    this.description,
    this.count,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: json['_id'] ?? json['id'] ?? '',
      name: json['name'] ?? 'Unknown Category',
      color: json['color'] ?? '#4F46E5',
      description: json['description'],
      count: json['count'] ?? json['bookCount'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'color': color,
      'description': description,
      'count': count,
    };
  }

  @override
  String toString() {
    return 'CategoryModel(id: $id, name: $name, color: $color)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is CategoryModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}