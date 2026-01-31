// // lib/features/auth/domain/usecases/verify_otp_usecase.dart
//
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:grad_project/features/auth/domain/repositories/auth_repository.dart';
//
// class VerifyOtpUseCase {
//   final AuthRepository repository;
//
//   VerifyOtpUseCase({required this.repository});
//
//   /// Apply action code for Firebase email verification
//   /// This is used when user clicks the verification link in their email
//   Future<Map<String, dynamic>> call({
//     required String actionCode,
//   }) async {
//     try {
//       return await repository.applyActionCode(actionCode: actionCode);
//     } catch (e) {
//       return {
//         'success': false,
//         'message': 'فشل في تطبيق رمز التحقق',
//         'error': e.toString(),
//       };
//     }
//   }}