// lib/features/library/domain/entities/library_item_entity.dart

class LibraryItemEntity {
  final String id;
  final String imageUrl;
  final String title;
  final String author;
  final String category;
  final String? description;
  final int? pages;
  final double? rating;
  final int? downloads;
  final String? fileUrl;
  final bool? isActive;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  LibraryItemEntity({
    required this.id,
    required this.imageUrl,
    required this.title,
    required this.author,
    required this.category,
    this.description,
    this.pages,
    this.rating,
    this.downloads,
    this.fileUrl,
    this.isActive,
    this.createdAt,
    this.updatedAt,
  });

  // Copy with method for updates
  LibraryItemEntity copyWith({
    String? id,
    String? imageUrl,
    String? title,
    String? author,
    String? category,
    String? description,
    int? pages,
    double? rating,
    int? downloads,
    String? fileUrl,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return LibraryItemEntity(
      id: id ?? this.id,
      imageUrl: imageUrl ?? this.imageUrl,
      title: title ?? this.title,
      author: author ?? this.author,
      category: category ?? this.category,
      description: description ?? this.description,
      pages: pages ?? this.pages,
      rating: rating ?? this.rating,
      downloads: downloads ?? this.downloads,
      fileUrl: fileUrl ?? this.fileUrl,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'LibraryItemEntity(id: $id, title: $title, author: $author, category: $category)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is LibraryItemEntity && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}