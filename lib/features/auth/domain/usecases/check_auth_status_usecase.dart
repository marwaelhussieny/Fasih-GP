// // lib/features/auth/domain/usecases/check_auth_status_usecase.dart
//
// import 'package:grad_project/features/auth/domain/repositories/auth_repository.dart';
//
// class CheckAuthStatusUseCase {
//   final AuthRepository repository;
//
//   CheckAuthStatusUseCase({required this.repository});
//
//   Future<bool> call() async {
//     return await repository.hasValidSession();
//   }
// }