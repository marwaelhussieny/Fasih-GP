// lib/features/auth/presentation/providers/auth_provider_setup.dart

import 'package:provider/provider.dart';
import 'package:grad_project/features/auth/presentation/providers/auth_provider.dart';

// Simple function that returns the AuthProvider without dependency injection
AuthProvider createAuthProvider() {
  return AuthProvider(); // Direct instantiation - no DI needed
}

// List of providers for MultiProvider in main.dart
List<ChangeNotifierProvider> getAuthProviders() {
  return [
    ChangeNotifierProvider<AuthProvider>(
      create: (context) => createAuthProvider(),
      lazy: false, // Initialize immediately
    ),
  ];
}

// Alternative: Single provider function
ChangeNotifierProvider<AuthProvider> getAuthProvider() {
  return ChangeNotifierProvider<AuthProvider>(
    create: (context) => AuthProvider(),
    lazy: false, // Initialize immediately
  );
}