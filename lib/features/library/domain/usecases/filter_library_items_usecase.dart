// lib/features/library/domain/usecases/filter_library_items_usecase.dart
import 'package:grad_project/features/library/domain/entities/library_item_entity.dart';
import 'package:grad_project/features/library/domain/repositories/library_repository.dart';

class FilterLibraryItemsUseCase {
  final LibraryRepository repository;

  FilterLibraryItemsUseCase(this.repository);

  Future<List<LibraryItemEntity>> call(String category) async {
    return repository.filterLibraryItems(category);
  }
}