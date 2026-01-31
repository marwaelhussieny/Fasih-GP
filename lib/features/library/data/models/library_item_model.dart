// lib/features/library/data/models/library_item_model.dart

import 'package:grad_project/features/library/domain/entities/library_item_entity.dart';

class LibraryItemModel {
  final String id;
  final String imageUrl;
  final String title;
  final String author;
  final String category;
  final String? categoryName;
  final String? description;
  final int? pages;
  final double? rating;
  final int? downloads;
  final String? fileUrl;
  final bool? isActive;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final List<String>? tags;
  final String? language;
  final String? publishedYear;
  final double? fileSize;

  LibraryItemModel({
    required this.id,
    required this.imageUrl,
    required this.title,
    required this.author,
    required this.category,
    this.categoryName,
    this.description,
    this.pages,
    this.rating,
    this.downloads,
    this.fileUrl,
    this.isActive,
    this.createdAt,
    this.updatedAt,
    this.tags,
    this.language,
    this.publishedYear,
    this.fileSize,
  });

  // Enhanced factory constructor for backend API response
  factory LibraryItemModel.fromBackendJson(Map<String, dynamic> json) {
    try {
      print('📚 LibraryItemModel: Parsing backend JSON: ${json.keys.toList()}');

      // Handle category - it can be a string ID or an object
      String categoryId = '';
      String categoryDisplayName = '';

      if (json['category'] != null) {
        if (json['category'] is String) {
          categoryId = json['category'];
          categoryDisplayName = _getCategoryDisplayName(categoryId);
        } else if (json['category'] is Map<String, dynamic>) {
          final categoryMap = json['category'] as Map<String, dynamic>;
          categoryId = categoryMap['_id'] ?? categoryMap['id'] ?? '';
          categoryDisplayName = categoryMap['name'] ?? categoryMap['title'] ?? _getCategoryDisplayName(categoryId);
        }
      }

      // Handle tags
      List<String>? tags;
      if (json['tags'] != null) {
        if (json['tags'] is List) {
          tags = (json['tags'] as List).map((tag) => tag.toString()).toList();
        } else if (json['tags'] is String) {
          tags = [json['tags']];
        }
      }

      // Handle rating conversion
      double? rating;
      if (json['rating'] != null) {
        if (json['rating'] is double) {
          rating = json['rating'];
        } else if (json['rating'] is int) {
          rating = json['rating'].toDouble();
        } else if (json['rating'] is String) {
          rating = double.tryParse(json['rating']) ?? 0.0;
        }
      }

      // Handle file size
      double? fileSize;
      if (json['fileSize'] != null || json['file_size'] != null) {
        final fileSizeValue = json['fileSize'] ?? json['file_size'];
        if (fileSizeValue is double) {
          fileSize = fileSizeValue;
        } else if (fileSizeValue is int) {
          fileSize = fileSizeValue.toDouble();
        } else if (fileSizeValue is String) {
          fileSize = double.tryParse(fileSizeValue);
        }
      }

      // Enhanced image URL handling
      String imageUrl = json['coverImage'] ??
          json['imageUrl'] ??
          json['image'] ??
          json['thumbnail'] ??
          _getPlaceholderImage(categoryDisplayName);

      // Ensure image URL is absolute
      if (imageUrl.isNotEmpty && !imageUrl.startsWith('http')) {
        // If it's a relative path, make it absolute
        if (imageUrl.startsWith('/')) {
          imageUrl = 'https://f35f3ddf1acd.ngrok-free.app$imageUrl';
        } else {
          imageUrl = 'https://f35f3ddf1acd.ngrok-free.app/$imageUrl';
        }
      }

      final model = LibraryItemModel(
        id: json['_id'] ?? json['id'] ?? DateTime.now().millisecondsSinceEpoch.toString(),
        title: json['title'] ?? json['name'] ?? 'Unknown Title',
        author: json['author'] ?? json['writer'] ?? json['creator'] ?? 'Unknown Author',
        description: json['description'] ?? json['summary'] ?? json['content'] ?? '',
        imageUrl: imageUrl,
        category: categoryId,
        categoryName: categoryDisplayName,
        pages: _parseIntField(json['pages'] ?? json['pageCount']),
        rating: rating ?? 0.0,
        downloads: _parseIntField(json['downloads'] ?? json['downloadCount']) ?? 0,
        fileUrl: json['fileUrl'] ?? json['file_url'] ?? json['downloadUrl'] ?? json['pdfUrl'],
        isActive: json['isActive'] ?? json['is_active'] ?? json['active'] ?? true,
        createdAt: _parseDateTime(json['createdAt'] ?? json['created_at'] ?? json['dateCreated']),
        updatedAt: _parseDateTime(json['updatedAt'] ?? json['updated_at'] ?? json['dateUpdated']),
        tags: tags,
        language: json['language'] ?? json['lang'] ?? 'ar',
        publishedYear: json['publishedYear'] ?? json['published_year'] ?? json['year'],
        fileSize: fileSize,
      );

      print('✅ LibraryItemModel: Successfully parsed "${model.title}" by ${model.author}');
      return model;
    } catch (e, stackTrace) {
      print('❌ LibraryItemModel.fromBackendJson error: $e');
      print('❌ Stack trace: $stackTrace');
      print('❌ JSON data: $json');

      // Return a basic model to prevent complete failure
      return LibraryItemModel(
        id: json['_id'] ?? json['id'] ?? DateTime.now().millisecondsSinceEpoch.toString(),
        title: json['title'] ?? 'Unknown Title',
        author: json['author'] ?? 'Unknown Author',
        category: 'unknown',
        categoryName: 'غير محدد',
        imageUrl: _getPlaceholderImage('غير محدد'),
        description: 'عذراً، حدث خطأ في تحميل تفاصيل هذا العنصر',
        isActive: true,
        createdAt: DateTime.now(),
      );
    }
  }

  // Helper method to parse integer fields safely
  static int? _parseIntField(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) return int.tryParse(value);
    return null;
  }

  // Helper method to parse DateTime fields safely
  static DateTime? _parseDateTime(dynamic value) {
    if (value == null) return null;
    if (value is DateTime) return value;
    if (value is String) {
      try {
        return DateTime.parse(value);
      } catch (e) {
        print('⚠️ LibraryItemModel: Invalid date format: $value');
        return null;
      }
    }
    return null;
  }

  // Legacy factory constructor for local/demo data
  factory LibraryItemModel.fromJson(Map<String, dynamic> json) {
    return LibraryItemModel(
      id: json['id'] as String,
      imageUrl: json['imageUrl'] as String,
      title: json['title'] as String,
      author: json['author'] as String,
      category: json['category'] as String,
      categoryName: json['categoryName'],
      description: json['description'],
      pages: json['pages'],
      rating: json['rating']?.toDouble(),
      downloads: json['downloads'],
      fileUrl: json['fileUrl'],
      tags: json['tags'] != null ? List<String>.from(json['tags']) : null,
      language: json['language'],
      publishedYear: json['publishedYear'],
      fileSize: json['fileSize']?.toDouble(),
    );
  }

  // Convert to domain entity
  LibraryItemEntity toEntity() {
    return LibraryItemEntity(
      id: id,
      imageUrl: imageUrl,
      title: title,
      author: author,
      category: categoryName ?? category,
      description: description,
      pages: pages,
      rating: rating,
      downloads: downloads,
      fileUrl: fileUrl,
      isActive: isActive,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'imageUrl': imageUrl,
      'title': title,
      'author': author,
      'category': category,
      'categoryName': categoryName,
      'description': description,
      'pages': pages,
      'rating': rating,
      'downloads': downloads,
      'fileUrl': fileUrl,
      'isActive': isActive,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'tags': tags,
      'language': language,
      'publishedYear': publishedYear,
      'fileSize': fileSize,
    };
  }

  // Enhanced helper method to get category display name from ID
  static String _getCategoryDisplayName(String categoryId) {
    final Map<String, String> categoryMap = {
      // English to Arabic
      'books': 'كتب',
      'articles': 'مقالات',
      'research': 'أبحاث',
      'stories': 'قصص',
      'poetry': 'الشعر',
      'grammar': 'النحو والصرف',
      'literature': 'الأدب والبلاغة',
      'history': 'تاريخ اللغة',
      'linguistics': 'علم اللغة',
      'education': 'تعليم',
      'children': 'أطفال',
      'academic': 'أكاديمي',
      'reference': 'مراجع',
      'fiction': 'خيال',
      'non-fiction': 'غير خيالي',
      // Arabic keys (in case backend sends Arabic)
      'كتب': 'كتب',
      'مقالات': 'مقالات',
      'أبحاث': 'أبحاث',
      'قصص': 'قصص',
      'الشعر': 'الشعر',
      'النحو والصرف': 'النحو والصرف',
      'الأدب والبلاغة': 'الأدب والبلاغة',
      'تاريخ اللغة': 'تاريخ اللغة',
    };

    final normalized = categoryId.toLowerCase().trim();
    return categoryMap[normalized] ?? categoryMap[categoryId] ?? categoryId;
  }

  // Enhanced helper method to get placeholder image based on category
  static String _getPlaceholderImage(String categoryName) {
    final Map<String, String> placeholderMap = {
      'كتب': 'https://placehold.co/150x200/4F46E5/white?text=كتاب',
      'مقالات': 'https://placehold.co/150x200/059669/white?text=مقالة',
      'أبحاث': 'https://placehold.co/150x200/DC2626/white?text=بحث',
      'قصص': 'https://placehold.co/150x200/7C3AED/white?text=قصة',
      'الشعر': 'https://placehold.co/150x200/EA580C/white?text=شعر',
      'النحو والصرف': 'https://placehold.co/150x200/10B981/white?text=نحو',
      'الأدب والبلاغة': 'https://placehold.co/150x200/8B5CF6/white?text=أدب',
      'تاريخ اللغة': 'https://placehold.co/150x200/F59E0B/white?text=تاريخ',
      'علم اللغة': 'https://placehold.co/150x200/06B6D4/white?text=لغويات',
      'تعليم': 'https://placehold.co/150x200/84CC16/white?text=تعليم',
      'أطفال': 'https://placehold.co/150x200/F472B6/white?text=أطفال',
      'أكاديمي': 'https://placehold.co/150x200/6366F1/white?text=أكاديمي',
      'مراجع': 'https://placehold.co/150x200/8B5A2B/white?text=مرجع',
    };

    return placeholderMap[categoryName] ?? 'https://placehold.co/150x200/6B7280/white?text=كتاب';
  }

  // Get formatted file size
  String get formattedFileSize {
    if (fileSize == null) return '';

    if (fileSize! < 1024) {
      return '${fileSize!.toInt()} B';
    } else if (fileSize! < 1024 * 1024) {
      return '${(fileSize! / 1024).toStringAsFixed(1)} KB';
    } else {
      return '${(fileSize! / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
  }

  // Get reading time estimate (assuming 250 words per page, 200 words per minute)
  String get estimatedReadingTime {
    if (pages == null || pages! <= 0) return '';

    final wordsPerPage = 250;
    final wordsPerMinute = 200;
    final totalWords = pages! * wordsPerPage;
    final minutes = (totalWords / wordsPerMinute).round();

    if (minutes < 60) {
      return '$minutes دقيقة';
    } else {
      final hours = (minutes / 60).floor();
      final remainingMinutes = minutes % 60;
      if (remainingMinutes == 0) {
        return '$hours ساعة';
      } else {
        return '$hours ساعة و$remainingMinutes دقيقة';
      }
    }
  }

  // Get publication info
  String get publicationInfo {
    final info = <String>[];

    if (publishedYear != null && publishedYear!.isNotEmpty) {
      info.add('نُشر في $publishedYear');
    }

    if (language != null && language! != 'ar') {
      final languageNames = {
        'en': 'الإنجليزية',
        'fr': 'الفرنسية',
        'de': 'الألمانية',
        'es': 'الإسبانية',
        'tr': 'التركية',
        'ur': 'الأردية',
        'fa': 'الفارسية',
      };
      final langName = languageNames[language] ?? language;
      info.add('باللغة $langName');
    }

    return info.join(' • ');
  }

  // Check if item is recently added (within last 7 days)
  bool get isNew {
    if (createdAt == null) return false;
    final daysDiff = DateTime.now().difference(createdAt!).inDays;
    return daysDiff <= 7;
  }

  // Check if item is popular (high download count)
  bool get isPopular {
    return downloads != null && downloads! >= 100;
  }

  // Get star rating display
  String get starRating {
    if (rating == null || rating! <= 0) return '☆☆☆☆☆';

    final fullStars = rating!.floor();
    final hasHalfStar = (rating! - fullStars) >= 0.5;
    final emptyStars = 5 - fullStars - (hasHalfStar ? 1 : 0);

    return '★' * fullStars +
        (hasHalfStar ? '☆' : '') +
        '☆' * emptyStars;
  }

  // Copy with method for updates
  LibraryItemModel copyWith({
    String? id,
    String? imageUrl,
    String? title,
    String? author,
    String? category,
    String? categoryName,
    String? description,
    int? pages,
    double? rating,
    int? downloads,
    String? fileUrl,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<String>? tags,
    String? language,
    String? publishedYear,
    double? fileSize,
  }) {
    return LibraryItemModel(
      id: id ?? this.id,
      imageUrl: imageUrl ?? this.imageUrl,
      title: title ?? this.title,
      author: author ?? this.author,
      category: category ?? this.category,
      categoryName: categoryName ?? this.categoryName,
      description: description ?? this.description,
      pages: pages ?? this.pages,
      rating: rating ?? this.rating,
      downloads: downloads ?? this.downloads,
      fileUrl: fileUrl ?? this.fileUrl,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      tags: tags ?? this.tags,
      language: language ?? this.language,
      publishedYear: publishedYear ?? this.publishedYear,
      fileSize: fileSize ?? this.fileSize,
    );
  }

  @override
  String toString() {
    return 'LibraryItemModel(id: $id, title: $title, author: $author, category: $categoryName, rating: $rating, downloads: $downloads)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is LibraryItemModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  // Additional helper methods for UI

  // Get category color for UI
  String getCategoryColor() {
    switch (categoryName?.toLowerCase() ?? category.toLowerCase()) {
      case 'كتب':
      case 'books':
        return '#4F46E5';
      case 'مقالات':
      case 'articles':
        return '#059669';
      case 'أبحاث':
      case 'research':
        return '#DC2626';
      case 'قصص':
      case 'stories':
        return '#7C3AED';
      case 'الشعر':
      case 'poetry':
        return '#EA580C';
      case 'النحو والصرف':
      case 'grammar':
        return '#10B981';
      case 'الأدب والبلاغة':
      case 'literature':
        return '#8B5CF6';
      case 'تاريخ اللغة':
      case 'history':
        return '#F59E0B';
      default:
        return '#6B7280';
    }
  }

  // Get appropriate icon for category
  String getCategoryIcon() {
    switch (categoryName?.toLowerCase() ?? category.toLowerCase()) {
      case 'كتب':
      case 'books':
        return 'book';
      case 'مقالات':
      case 'articles':
        return 'article';
      case 'أبحاث':
      case 'research':
        return 'science';
      case 'قصص':
      case 'stories':
        return 'auto_stories';
      case 'الشعر':
      case 'poetry':
        return 'format_quote';
      case 'النحو والصرف':
      case 'grammar':
        return 'school';
      case 'الأدب والبلاغة':
      case 'literature':
        return 'menu_book';
      case 'تاريخ اللغة':
      case 'history':
        return 'history';
      default:
        return 'library_books';
    }
  }

  // Search relevance score (for search filtering)
  double getSearchRelevance(String query) {
    if (query.isEmpty) return 0.0;

    final lowerQuery = query.toLowerCase();
    double score = 0.0;

    // Title match (highest weight)
    if (title.toLowerCase().contains(lowerQuery)) {
      score += 10.0;
      if (title.toLowerCase().startsWith(lowerQuery)) {
        score += 5.0; // Bonus for starting with query
      }
    }

    // Author match
    if (author.toLowerCase().contains(lowerQuery)) {
      score += 5.0;
    }

    // Description match
    if (description?.toLowerCase().contains(lowerQuery) == true) {
      score += 3.0;
    }

    // Category match
    if (categoryName?.toLowerCase().contains(lowerQuery) == true) {
      score += 2.0;
    }

    // Tags match
    if (tags != null) {
      for (final tag in tags!) {
        if (tag.toLowerCase().contains(lowerQuery)) {
          score += 1.0;
        }
      }
    }

    return score;
  }
}