
// lib/features/auth/domain/usecases/get_auth_state_changes_usecase.dart
import 'package:grad_project/features/auth/domain/repositories/auth_repository.dart';

class GetAuthStateChangesUseCase {
  final AuthRepository repository;

  GetAuthStateChangesUseCase({required this.repository});

  Future<String?> call() async {
    try {
      final user = await repository.getCurrentUser();
      return user?.id;
    } catch (e) {
      return null;
    }
  }
}