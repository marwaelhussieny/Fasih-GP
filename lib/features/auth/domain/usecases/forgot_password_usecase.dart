// // lib/features/auth/domain/usecases/forgot_password_usecase.dart
//
// import 'package:grad_project/features/auth/domain/repositories/auth_repository.dart';
//
// class ForgotPasswordUseCase {
//   final AuthRepository repository;
//
//   ForgotPasswordUseCase({required this.repository});
//
//   Future<void> call({required String email}) async {
//     await repository.sendPasswordResetEmail(email: email);
//   }
// }