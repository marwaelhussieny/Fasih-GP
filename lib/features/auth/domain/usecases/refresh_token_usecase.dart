// // lib/features/auth/domain/usecases/refresh_token_usecase.dart
//
// import 'package:grad_project/features/auth/domain/repositories/auth_repository.dart';
//
// class RefreshTokenUseCase {
//   final AuthRepository repository;
//
//   RefreshTokenUseCase({required this.repository});
//
//   Future<Map<String, dynamic>> call() async {
//     return await repository.refreshToken();
//   }
// }