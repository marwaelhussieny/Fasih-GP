// lib/core/navigation/auth_guard.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:grad_project/features/auth/presentation/providers/auth_provider.dart' as custom_auth;
import 'package:grad_project/core/navigation/app_routes.dart';

class AuthGuard extends StatelessWidget {
  final Widget child;

  const AuthGuard({Key? key, required this.child}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<custom_auth.AuthProvider>(
      builder: (context, authProvider, _) {
        // Show loading while checking authentication state
        if (authProvider.isLoading) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        // If user is authenticated, show the child widget
        if (authProvider.isAuthenticated) {
          return child;
        }

        // If not authenticated, redirect to login
        WidgetsBinding.instance.addPostFrameCallback((_) {
          Navigator.pushReplacementNamed(context, AppRoutes.login);
        });

        return const Scaffold(
          body: Center(
            child: CircularProgressIndicator(),
          ),
        );
      },
    );
  }
}

// Route wrapper to protect authenticated routes
class ProtectedRoute extends StatelessWidget {
  final Widget child;
  final String? redirectTo;

  const ProtectedRoute({
    Key? key,
    required this.child,
    this.redirectTo,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<custom_auth.AuthProvider>(
      builder: (context, authProvider, _) {
        if (authProvider.isAuthenticated) {
          return child;
        }

        // Redirect to login or specified route
        Future.microtask(() {
          Navigator.pushReplacementNamed(
            context,
            redirectTo ?? AppRoutes.login,
          );
        });

        return const Scaffold(
          body: Center(
            child: CircularProgressIndicator(),
          ),
        );
      },
    );
  }
}

// Reverse guard - redirects authenticated users away from auth screens
class GuestOnlyRoute extends StatelessWidget {
  final Widget child;
  final String? redirectTo;

  const GuestOnlyRoute({
    Key? key,
    required this.child,
    this.redirectTo,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<custom_auth.AuthProvider>(
      builder: (context, authProvider, _) {
        if (!authProvider.isAuthenticated) {
          return child;
        }

        // Redirect authenticated users to home
        Future.microtask(() {
          Navigator.pushReplacementNamed(
            context,
            redirectTo ?? AppRoutes.home,
          );
        });

        return const Scaffold(
          body: Center(
            child: CircularProgressIndicator(),
          ),
        );
      },
    );
  }
}