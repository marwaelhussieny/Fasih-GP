// lib/features/library/domain/repositories/library_repository.dart

import 'package:grad_project/features/library/domain/entities/library_item_entity.dart';

abstract class LibraryRepository {
  Future<List<LibraryItemEntity>> getLibraryItems();
  Future<List<LibraryItemEntity>> searchLibraryItems(String query);
  Future<List<LibraryItemEntity>> filterLibraryItems(String category);
  Future<List<CategoryEntity>> getCategories();
  Future<String> downloadBook(String bookId);
  Future<LibraryItemEntity> getBookById(String bookId);
}

// Category entity for domain layer
class CategoryEntity {
  final String id;
  final String name;
  final String color;

  CategoryEntity({
    required this.id,
    required this.name,
    required this.color,
  });

  @override
  String toString() {
    return 'CategoryEntity(id: $id, name: $name, color: $color)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is CategoryEntity && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}