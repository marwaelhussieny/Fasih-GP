// lib/features/library/domain/usecases/get_library_items_usecase.dart
import 'package:grad_project/features/library/domain/entities/library_item_entity.dart';
import 'package:grad_project/features/library/domain/repositories/library_repository.dart';

class GetLibraryItemsUseCase {
  final LibraryRepository repository;

  GetLibraryItemsUseCase(this.repository);

  Future<List<LibraryItemEntity>> call() async {
    return await repository.getLibraryItems();
  }
}

// lib/features/library/domain/usecases/search_library_items_usecase.dart
class SearchLibraryItemsUseCase {
  final LibraryRepository repository;

  SearchLibraryItemsUseCase(this.repository);

  Future<List<LibraryItemEntity>> call(String query) async {
    return repository.searchLibraryItems(query);
  }
}

// lib/features/library/domain/usecases/filter_library_items_usecase.dart
class FilterLibraryItemsUseCase {
  final LibraryRepository repository;

  FilterLibraryItemsUseCase(this.repository);

  Future<List<LibraryItemEntity>> call(String category) async {
    return repository.filterLibraryItems(category);
  }
}

// lib/features/library/domain/usecases/get_categories_usecase.dart
class GetCategoriesUseCase {
  final LibraryRepository repository;

  GetCategoriesUseCase(this.repository);

  Future<List<CategoryEntity>> call() async {
    return repository.getCategories();
  }
}

// lib/features/library/domain/usecases/download_book_usecase.dart
class DownloadBookUseCase {
  final LibraryRepository repository;

  DownloadBookUseCase(this.repository);

  Future<String> call(String bookId) async {
    return repository.downloadBook(bookId);
  }
}

// lib/features/library/domain/usecases/get_book_by_id_usecase.dart
class GetBookByIdUseCase {
  final LibraryRepository repository;

  GetBookByIdUseCase(this.repository);

  Future<LibraryItemEntity> call(String bookId) async {
    return repository.getBookById(bookId);
  }
}