// // lib/core/utils/error_handler.dart
//
// import 'package:flutter/material.dart';
// import 'dart:io';
// import 'package:grad_project/features/auth/data/services/auth_service.dart';
//
// class ErrorHandler {
//   /// Get localized error message based on error type
//   static String getErrorMessage(dynamic error) {
//     // Handle custom exceptions first
//     if (error is AuthException) {
//       return _getAuthErrorMessage(error.message);
//     } else if (error is BadRequestException) {
//       return 'البيانات المدخلة غير صحيحة';
//     } else if (error is UnauthorizedException) {
//       return 'غير مخول للوصول. قم بتسجيل الدخول مرة أخرى';
//     } else if (error is ForbiddenException) {
//       return 'ليس لديك صلاحية للوصول لهذا المحتوى';
//     } else if (error is NotFoundException) {
//       return 'المحتوى المطلوب غير موجود';
//     } else if (error is GoneException) {
//       return 'انتهت صلاحية الرمز أو الرابط';
//     } else if (error is ValidationException) {
//       return 'بيانات غير صالحة. تحقق من المدخلات';
//     } else if (error is ServerException) {
//       return 'خطأ في الخادم. حاول مرة أخرى لاحقاً';
//     }
//
//     // Handle standard exceptions
//     if (error is SocketException) {
//       return 'فشل الاتصال بالخادم. تحقق من اتصال الإنترنت';
//     } else if (error is HttpException) {
//       return 'خطأ في الخادم. حاول مرة أخرى لاحقاً';
//     } else if (error is FormatException) {
//       return 'تنسيق البيانات غير صحيح';
//     } else if (error.toString().contains('TimeoutException')) {
//       return 'انتهت مهلة الاتصال. حاول مرة أخرى';
//     } else if (error.toString().contains('No internet connection')) {
//       return 'لا يوجد اتصال بالإنترنت';
//     } else if (error.toString().contains('Connection timeout')) {
//       return 'انتهت مهلة الاتصال';
//     } else if (error.toString().contains('Invalid OTP')) {
//       return 'رمز التحقق غير صحيح';
//     } else if (error.toString().contains('OTP expired')) {
//       return 'انتهت صلاحية رمز التحقق';
//     } else if (error.toString().contains('No refresh token')) {
//       return 'انتهت جلسة المستخدم. قم بتسجيل الدخول مرة أخرى';
//     } else {
//       return 'حدث خطأ غير متوقع. حاول مرة أخرى';
//     }
//   }
//
//   /// Get specific auth error messages
//   static String _getAuthErrorMessage(String message) {
//     if (message.contains('Invalid credentials')) {
//       return 'البريد الإلكتروني أو كلمة المرور غير صحيحة';
//     } else if (message.contains('User not found')) {
//       return 'المستخدم غير موجود';
//     } else if (message.contains('Email already exists')) {
//       return 'البريد الإلكتروني مسجل بالفعل';
//     } else if (message.contains('Weak password')) {
//       return 'كلمة المرور ضعيفة جداً';
//     } else if (message.contains('Invalid email')) {
//       return 'البريد الإلكتروني غير صحيح';
//     } else if (message.contains('Account locked')) {
//       return 'الحساب مقفل مؤقتاً. حاول لاحقاً';
//     } else if (message.contains('Too many attempts')) {
//       return 'محاولات كثيرة جداً. حاول لاحقاً';
//     } else {
//       return message;
//     }
//   }
//
//   /// Show error snack bar with enhanced styling
//   static void showErrorSnackBar(BuildContext context, String message, {
//     Duration duration = const Duration(seconds: 4),
//     VoidCallback? onActionPressed,
//     String? actionLabel,
//   }) {
//     if (!context.mounted) return;
//
//     ScaffoldMessenger.of(context).clearSnackBars(); // Clear existing snackbars
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Row(
//           children: [
//             Icon(
//               Icons.error_outline,
//               color: Colors.white,
//               size: 20,
//             ),
//             const SizedBox(width: 12),
//             Expanded(
//               child: Text(
//                 message,
//                 style: const TextStyle(
//                   fontFamily: 'Tajawal',
//                   color: Colors.white,
//                   fontSize: 14,
//                 ),
//               ),
//             ),
//           ],
//         ),
//         backgroundColor: Theme.of(context).colorScheme.error,
//         behavior: SnackBarBehavior.floating,
//         margin: const EdgeInsets.all(16),
//         shape: RoundedRectangleBorder(
//           borderRadius: BorderRadius.circular(8),
//         ),
//         duration: duration,
//         action: onActionPressed != null && actionLabel != null
//             ? SnackBarAction(
//           label: actionLabel,
//           textColor: Colors.white,
//           onPressed: onActionPressed,
//         )
//             : null,
//       ),
//     );
//   }
//
//   /// Show success snack bar with enhanced styling
//   static void showSuccessSnackBar(BuildContext context, String message, {
//     Duration duration = const Duration(seconds: 3),
//   }) {
//     if (!context.mounted) return;
//
//     ScaffoldMessenger.of(context).clearSnackBars();
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Row(
//           children: [
//             Icon(
//               Icons.check_circle_outline,
//               color: Colors.white,
//               size: 20,
//             ),
//             const SizedBox(width: 12),
//             Expanded(
//               child: Text(
//                 message,
//                 style: const TextStyle(
//                   fontFamily: 'Tajawal',
//                   color: Colors.white,
//                   fontSize: 14,
//                 ),
//               ),
//             ),
//           ],
//         ),
//         backgroundColor: Colors.green,
//         behavior: SnackBarBehavior.floating,
//         margin: const EdgeInsets.all(16),
//         shape: RoundedRectangleBorder(
//           borderRadius: BorderRadius.circular(8),
//         ),
//         duration: duration,
//       ),
//     );
//   }
//
//   /// Show info snack bar with enhanced styling
//   static void showInfoSnackBar(BuildContext context, String message, {
//     Duration duration = const Duration(seconds: 3),
//   }) {
//     if (!context.mounted) return;
//
//     ScaffoldMessenger.of(context).clearSnackBars();
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Row(
//           children: [
//             Icon(
//               Icons.info_outline,
//               color: Colors.white,
//               size: 20,
//             ),
//             const SizedBox(width: 12),
//             Expanded(
//               child: Text(
//                 message,
//                 style: const TextStyle(
//                   fontFamily: 'Tajawal',
//                   color: Colors.white,
//                   fontSize: 14,
//                 ),
//               ),
//             ),
//           ],
//         ),
//         backgroundColor: Theme.of(context).primaryColor,
//         behavior: SnackBarBehavior.floating,
//         margin: const EdgeInsets.all(16),
//         shape: RoundedRectangleBorder(
//           borderRadius: BorderRadius.circular(8),
//         ),
//         duration: duration,
//       ),
//     );
//   }
//
//   /// Show warning snack bar
//   static void showWarningSnackBar(BuildContext context, String message, {
//     Duration duration = const Duration(seconds: 4),
//   }) {
//     if (!context.mounted) return;
//
//     ScaffoldMessenger.of(context).clearSnackBars();
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Row(
//           children: [
//             Icon(
//               Icons.warning_outlined,
//               color: Colors.white,
//               size: 20,
//             ),
//             const SizedBox(width: 12),
//             Expanded(
//               child: Text(
//                 message,
//                 style: const TextStyle(
//                   fontFamily: 'Tajawal',
//                   color: Colors.white,
//                   fontSize: 14,
//                 ),
//               ),
//             ),
//           ],
//         ),
//         backgroundColor: Colors.orange,
//         behavior: SnackBarBehavior.floating,
//         margin: const EdgeInsets.all(16),
//         shape: RoundedRectangleBorder(
//           borderRadius: BorderRadius.circular(8),
//         ),
//         duration: duration,
//       ),
//     );
//   }
//
//   /// Show loading snack bar (useful for long operations)
//   static ScaffoldFeatureController<SnackBar, SnackBarClosedReason> showLoadingSnackBar(
//       BuildContext context,
//       String message,
//       ) {
//     if (!context.mounted) {
//       throw StateError('Context is not mounted');
//     }
//
//     ScaffoldMessenger.of(context).clearSnackBars();
//     return ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Row(
//           children: [
//             SizedBox(
//               width: 20,
//               height: 20,
//               child: CircularProgressIndicator(
//                 strokeWidth: 2,
//                 valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
//               ),
//             ),
//             const SizedBox(width: 12),
//             Expanded(
//               child: Text(
//                 message,
//                 style: const TextStyle(
//                   fontFamily: 'Tajawal',
//                   color: Colors.white,
//                   fontSize: 14,
//                 ),
//               ),
//             ),
//           ],
//         ),
//         backgroundColor: Theme.of(context).primaryColor,
//         behavior: SnackBarBehavior.floating,
//         margin: const EdgeInsets.all(16),
//         shape: RoundedRectangleBorder(
//           borderRadius: BorderRadius.circular(8),
//         ),
//         duration: const Duration(minutes: 1), // Long duration for loading
//       ),
//     );
//   }
//
//   /// Handle and display error from any source
//   static void handleError(BuildContext context, dynamic error, {
//     String? customMessage,
//     VoidCallback? onRetry,
//   }) {
//     if (!context.mounted) return;
//
//     final message = customMessage ?? getErrorMessage(error);
//
//     // Log error for debugging
//     print('ErrorHandler: $error');
//
//     if (error is UnauthorizedException) {
//       // Handle unauthorized errors with logout option
//       showErrorSnackBar(
//         context,
//         message,
//         actionLabel: 'تسجيل دخول',
//         onActionPressed: () async {
//           final authService = await AuthService.getInstance();
//           await authService.logout();
//           // Navigate to login screen - this should be handled by your app's navigation
//         },
//       );
//     } else if (onRetry != null) {
//       // Show retry option for retryable errors
//       showErrorSnackBar(
//         context,
//         message,
//         actionLabel: 'إعادة المحاولة',
//         onActionPressed: onRetry,
//       );
//     } else {
//       // Standard error display
//       showErrorSnackBar(context, message);
//     }
//   }
// }
//
// // Enhanced network connectivity checker
// class NetworkUtils {
//   static const String _testHost = 'google.com';
//   static const int _timeoutSeconds = 10;
//
//   /// Check internet connectivity
//   static Future<bool> isConnected() async {
//     try {
//       final result = await InternetAddress.lookup(_testHost)
//           .timeout(Duration(seconds: _timeoutSeconds));
//       return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
//     } on SocketException catch (_) {
//       return false;
//     } catch (_) {
//       return false;
//     }
//   }
//
//   /// Check connection and execute action with proper error handling
//   static Future<void> checkConnectionAndExecute(
//       BuildContext context,
//       Future<void> Function() action, {
//         String? loadingMessage,
//         String? customNoConnectionMessage,
//       }) async {
//     if (!context.mounted) return;
//
//     // Show loading if specified
//     ScaffoldFeatureController<SnackBar, SnackBarClosedReason>? loadingController;
//     if (loadingMessage != null) {
//       loadingController = ErrorHandler.showLoadingSnackBar(context, loadingMessage);
//     }
//
//     try {
//       final connectionStatus = await NetworkUtils.isConnected();
//
//       if (!connectionStatus) {
//         loadingController?.close();
//         ErrorHandler.showErrorSnackBar(
//           context,
//           customNoConnectionMessage ?? 'لا يوجد اتصال بالإنترنت. تحقق من اتصالك وحاول مرة أخرى',
//           onActionPressed: () => checkConnectionAndExecute(context, action, loadingMessage: loadingMessage),
//           actionLabel: 'إعادة المحاولة',
//         );
//         return;
//       }
//
//       await action();
//       loadingController?.close();
//     } catch (e) {
//       loadingController?.close();
//       ErrorHandler.handleError(
//         context,
//         e,
//         onRetry: () => checkConnectionAndExecute(context, action, loadingMessage: loadingMessage),
//       );
//     }
//   }
//
//   /// Execute action with network check and loading state
//   static Future<T?> executeWithNetworkCheck<T>(
//       BuildContext context,
//       Future<T> Function() action, {
//         String? loadingMessage,
//         bool showLoading = false,
//       }) async {
//     if (!context.mounted) return null;
//
//     ScaffoldFeatureController<SnackBar, SnackBarClosedReason>? loadingController;
//
//     try {
//       final connectionStatus = await NetworkUtils.isConnected();
//
//       if (!connectionStatus) {
//         ErrorHandler.showErrorSnackBar(
//           context,
//           'لا يوجد اتصال بالإنترنت. تحقق من اتصالك وحاول مرة أخرى',
//           onActionPressed: () => executeWithNetworkCheck(context, action, loadingMessage: loadingMessage),
//           actionLabel: 'إعادة المحاولة',
//         );
//         return null;
//       }
//
//       if (showLoading && loadingMessage != null) {
//         loadingController = ErrorHandler.showLoadingSnackBar(context, loadingMessage);
//       }
//
//       final result = await action();
//       loadingController?.close();
//       return result;
//     } catch (e) {
//       loadingController?.close();
//       ErrorHandler.handleError(
//         context,
//         e,
//         onRetry: () => executeWithNetworkCheck(context, action, loadingMessage: loadingMessage),
//       );
//       return null;
//     }
//   }
//
//   /// Test connection to specific host
//   static Future<bool> canReachHost(String host, {int timeoutSeconds = 5}) async {
//     try {
//       final result = await InternetAddress.lookup(host)
//           .timeout(Duration(seconds: timeoutSeconds));
//       return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
//     } catch (_) {
//       return false;
//     }
//   }
// }