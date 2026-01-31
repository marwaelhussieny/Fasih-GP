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