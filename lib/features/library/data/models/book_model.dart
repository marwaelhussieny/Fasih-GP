// book_model.dart
import 'package:grad_project/features/library/data/models/book_category_model.dart';
class Book {
  final String id;
  final String title;
  final String author;
  final BookCategory category;
  final String description;
  final String coverImage;
  final String fileUrl;
  final int pages;
  final int downloads;
  final double rating;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int version;

  Book({
    required this.id,
    required this.title,
    required this.author,
    required this.category,
    required this.description,
    required this.coverImage,
    required this.fileUrl,
    required this.pages,
    required this.downloads,
    required this.rating,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
    required this.version,
  });
  factory Book.fromJson(Map<String, dynamic> json) {
    return Book(
      id: json['_id'],
      title: json['title'],
      author: json['author'],
      category: BookCategory.fromJson(json['category']),
      description: json['description'],
      coverImage: json['coverImage'],
      fileUrl: json['fileUrl'],
      pages: json['pages'],
      downloads: json['downloads'],
      rating: (json['rating'] as num).toDouble(),
      isActive: json['isActive'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      version: json['__v'],
    );
  }
  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'title': title,
      'author': author,
      'category': category.toJson(),
      'description': description,
      'coverImage': coverImage,
      'fileUrl': fileUrl,
      'pages': pages,
      'downloads': downloads,
      'rating': rating,
      'isActive': isActive,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      '__v': version,
    };
  }
}