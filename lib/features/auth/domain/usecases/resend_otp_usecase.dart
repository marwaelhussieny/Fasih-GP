// // lib/features/auth/domain/usecases/resend_otp_usecase.dart
//
// import 'package:grad_project/features/auth/domain/repositories/auth_repository.dart';
//
// class ResendOtpUseCase {
//   final AuthRepository repository;
//
//   ResendOtpUseCase({required this.repository});
//
//   Future<Map<String, dynamic>> call({required String email}) async {
//     return await repository.resendOtp(email: email);
//   }
// }