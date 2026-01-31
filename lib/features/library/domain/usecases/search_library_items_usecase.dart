// lib/features/library/domain/usecases/search_library_items_usecase.dart
import 'package:grad_project/features/library/domain/entities/library_item_entity.dart';
import 'package:grad_project/features/library/domain/repositories/library_repository.dart';

class SearchLibraryItemsUseCase {
  final LibraryRepository repository;

  SearchLibraryItemsUseCase(this.repository);

  Future<List<LibraryItemEntity>> call(String query) async {
    return repository.searchLibraryItems(query);
  }
}