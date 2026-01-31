// // lib/core/middleware/auth_middleware.dart
//
// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import 'package:grad_project/features/auth/presentation/providers/auth_provider.dart';
// import 'package:grad_project/core/navigation/app_routes.dart';
//
// class AuthMiddleware {
//   static Future<bool> checkAuthentication(BuildContext context) async {
//     final authProvider = Provider.of<AuthProvider>(context, listen: false);
//
//     // Check if user is authenticated
//     if (!authProvider.isAuthenticated) {
//       // Redirect to login
//       Navigator.pushReplacementNamed(context, AppRoutes.login);
//       return false;
//     }
//
//     // Check if token is valid
//     final accessToken = await authProvider.getValidAccessToken();
//     if (accessToken == null) {
//       // Token is invalid, redirect to login
//       Navigator.pushReplacementNamed(context, AppRoutes.login);
//       return false;
//     }
//
//     return true;
//   }
//
//   static Future<String?> getAuthToken(BuildContext context) async {
//     final authProvider = Provider.of<AuthProvider>(context, listen: false);
//     return await authProvider.getValidAccessToken();
//   }
//
//   static void handleAuthError(BuildContext context, String error) {
//     final authProvider = Provider.of<AuthProvider>(context, listen: false);
//
//     if (error.contains('401') || error.contains('Unauthorized')) {
//       // Token expired or invalid, sign out user
//       authProvider.signOut();
//       Navigator.pushReplacementNamed(context, AppRoutes.login);
//     }
//   }
// }
//
// // Widget wrapper for authenticated routes
// class AuthenticatedRoute extends StatelessWidget {
//   final Widget child;
//   final String? fallbackRoute;
//
//   const AuthenticatedRoute({
//     Key? key,
//     required this.child,
//     this.fallbackRoute,
//   }) : super(key: key);
//
//   @override
//   Widget build(BuildContext context) {
//     return Consumer<AuthProvider>(
//       builder: (context, authProvider, _) {
//         if (authProvider.isLoading) {
//           return const Scaffold(
//             body: Center(
//               child: CircularProgressIndicator(),
//             ),
//           );
//         }
//
//         if (!authProvider.isAuthenticated) {
//           Future.microtask(() {
//             Navigator.pushReplacementNamed(
//               context,
//               fallbackRoute ?? AppRoutes.login,
//             );
//           });
//
//           return const Scaffold(
//             body: Center(
//               child: CircularProgressIndicator(),
//             ),
//           );
//         }
//
//         return child;
//       },
//     );
//   }
// }