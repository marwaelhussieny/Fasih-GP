// // lib/core/utils/deep_link_handler.dart
//
// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import 'package:grad_project/features/auth/presentation/providers/auth_provider.dart';
// import 'package:grad_project/core/navigation/app_routes.dart';
//
// class DeepLinkHandler {
//   static void handlePasswordReset(
//       BuildContext context,
//       String token,
//       ) {
//     // Set the reset token in the AuthProvider
//     final authProvider = Provider.of<AuthProvider>(context, listen: false);
//     authProvider.setResetToken(token);
//
//     // Navigate to new password screen
//     Navigator.pushNamed(
//       context,
//       AppRoutes.newPassword,
//       arguments: {'resetToken': token},
//     );
//   }
//
//   static void handleEmailVerification(
//       BuildContext context,
//       String token,
//       ) {
//     // Handle email verification if needed
//     // This could be used for email verification after signup
//     ScaffoldMessenger.of(context).showSnackBar(
//       const SnackBar(
//         content: Text('تم التحقق من البريد الإلكتروني بنجاح'),
//         backgroundColor: Colors.green,
//       ),
//     );
//   }
//
//   static bool isPasswordResetLink(String link) {
//     return link.contains('/reset-password') && link.contains('token=');
//   }
//
//   static bool isEmailVerificationLink(String link) {
//     return link.contains('/verify-email') && link.contains('token=');
//   }
//
//   static String? extractTokenFromLink(String link) {
//     final uri = Uri.parse(link);
//     return uri.queryParameters['token'];
//   }
//
//   static void handleIncomingLink(BuildContext context, String link) {
//     final token = extractTokenFromLink(link);
//
//     if (token == null) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(
//           content: Text('رابط غير صالح'),
//           backgroundColor: Colors.red,
//         ),
//       );
//       return;
//     }
//
//     if (isPasswordResetLink(link)) {
//       handlePasswordReset(context, token);
//     } else if (isEmailVerificationLink(link)) {
//       handleEmailVerification(context, token);
//     }
//   }
// }