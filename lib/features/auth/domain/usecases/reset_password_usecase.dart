// // lib/features/auth/domain/usecases/reset_password_usecase.dart
//
// import 'package:grad_project/features/auth/domain/repositories/auth_repository.dart';
//
// class ResetPasswordUseCase {
//   final AuthRepository repository;
//
//   ResetPasswordUseCase({required this.repository});
//
//   Future<Map<String, dynamic>> call({
//     required String resetToken,
//     required String newPassword,
//   }) async {
//     return await repository.resetPassword(
//       resetToken: resetToken,
//       newPassword: newPassword,
//     );
//   }
// }