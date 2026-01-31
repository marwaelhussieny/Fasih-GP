// // lib/features/auth/domain/usecases/signup_usecase.dart
//
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:grad_project/features/auth/domain/repositories/auth_repository.dart';
//
// class SignUpUseCase {
//   final AuthRepository repository;
//
//   SignUpUseCase({required this.repository});
//
//   Future<User?> call({required String email, required String password}) async {
//     return await repository.signUpWithEmailAndPassword(
//       email: email,
//       password: password,
//     );
//   }
// }