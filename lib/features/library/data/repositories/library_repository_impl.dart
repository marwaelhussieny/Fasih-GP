// lib/features/library/data/repositories/library_repository_impl.dart

import 'package:grad_project/features/library/data/datasources/library_remote_data_source.dart';
import 'package:grad_project/features/library/domain/entities/library_item_entity.dart';
import 'package:grad_project/features/library/domain/repositories/library_repository.dart';

class LibraryRepositoryImpl implements LibraryRepository {
  final LibraryRemoteDataSource remoteDataSource;

  LibraryRepositoryImpl({required this.remoteDataSource});

  @override
  Future<List<LibraryItemEntity>> getLibraryItems() async {
    try {
      print('📚 LibraryRepository: Fetching library items...');
      final models = await remoteDataSource.getLibraryItems();
      final entities = models.map((model) => model.toEntity()).toList();
      print('✅ LibraryRepository: Converted ${entities.length} models to entities');
      return entities;
    } catch (e) {
      print('❌ LibraryRepository: Error getting library items: $e');
      rethrow;
    }
  }

  @override
  Future<List<LibraryItemEntity>> searchLibraryItems(String query) async {
    try {
      print('🔍 LibraryRepository: Searching for: $query');
      final models = await remoteDataSource.searchLibraryItems(query);
      final entities = models.map((model) => model.toEntity()).toList();
      print('✅ LibraryRepository: Found ${entities.length} items matching query');
      return entities;
    } catch (e) {
      print('❌ LibraryRepository: Error searching library items: $e');
      rethrow;
    }
  }

  @override
  Future<List<LibraryItemEntity>> filterLibraryItems(String category) async {
    try {
      print('🔧 LibraryRepository: Filtering by category: $category');
      final models = await remoteDataSource.filterLibraryItems(category);
      final entities = models.map((model) => model.toEntity()).toList();
      print('✅ LibraryRepository: Filtered to ${entities.length} items');
      return entities;
    } catch (e) {
      print('❌ LibraryRepository: Error filtering library items: $e');
      rethrow;
    }
  }

  @override
  Future<List<CategoryEntity>> getCategories() async {
    try {
      print('📂 LibraryRepository: Fetching categories...');
      final models = await remoteDataSource.getCategories();
      final entities = models.map((model) => CategoryEntity(
        id: model.id,
        name: model.name,
        color: model.color,
      )).toList();
      print('✅ LibraryRepository: Converted ${entities.length} category models to entities');
      return entities;
    } catch (e) {
      print('❌ LibraryRepository: Error getting categories: $e');
      rethrow;
    }
  }

  @override
  Future<String> downloadBook(String bookId) async {
    try {
      print('📥 LibraryRepository: Getting download URL for book: $bookId');
      final downloadUrl = await remoteDataSource.downloadBook(bookId);
      print('✅ LibraryRepository: Got download URL');
      return downloadUrl;
    } catch (e) {
      print('❌ LibraryRepository: Error downloading book: $e');
      rethrow;
    }
  }

  @override
  Future<LibraryItemEntity> getBookById(String bookId) async {
    try {
      print('📖 LibraryRepository: Getting book details for ID: $bookId');
      final model = await remoteDataSource.getBookById(bookId);
      final entity = model.toEntity();
      print('✅ LibraryRepository: Got book entity: ${entity.title}');
      return entity;
    } catch (e) {
      print('❌ LibraryRepository: Error getting book by ID: $e');
      rethrow;
    }
  }
}