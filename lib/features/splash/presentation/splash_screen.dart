// lib/features/splash/presentation/splash_screen.dart
// (Using your existing splash screen - no changes needed)

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:grad_project/features/auth/presentation/providers/auth_provider.dart';
import 'package:grad_project/core/navigation/app_routes.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();

    // Initialize fade animation
    _fadeController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(_fadeController);

    // Start animation
    _fadeController.forward();

    // Initialize the auth provider to check the user's login state
    _initializeAuth();
  }

  Future<void> _initializeAuth() async {
    // Wait for the animation to complete and a minimum splash time
    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      await authProvider.initialize();
      if (mounted) {
        // Set the initialization flag to true
        setState(() {
          _isInitialized = true;
        });
        // Check if the user is already authenticated
        if (authProvider.isAuthenticated) {
          // Navigate directly to the main screen
          Navigator.pushReplacementNamed(context, AppRoutes.main);
        }
      }
    } catch (e) {
      // In case of error, the user will be presented with the "Start Now" button
      // to retry or navigate to login.
      if (mounted) {
        setState(() {
          _isInitialized = true;
        });
      }
    }
  }

  void _navigateToNextScreen() {
    if (!mounted) return;

    // Check if the auth provider has been initialized before navigating
    if (_isInitialized) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      if (authProvider.isAuthenticated) {
        Navigator.pushReplacementNamed(context, AppRoutes.main);
      } else {
        Navigator.pushReplacementNamed(context, AppRoutes.login);
      }
    } else {
      // If not initialized yet, you could show a snackbar or just wait.
      // For this case, we will simply wait for the initialization to complete.
    }
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: const Color(0xFFFDF8F3),
      body: Stack(
        children: [
          // Full background image (sky + mosque + stars)
          Positioned.fill(
            child: Image.asset(
              'assets/images/splash_bg.png',
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  color: const Color(0xFFFDF8F3),
                  child: Center(
                    child: Icon(
                      Icons.mosque,
                      size: 100,
                      color: const Color(0xFFD2691E).withOpacity(0.3),
                    ),
                  ),
                );
              },
            ),
          ),

          // Animated content
          FadeTransition(
            opacity: _fadeAnimation,
            child: Column(
              children: [
                // Arabic logo positioned in the center-top area
                Expanded(
                  flex: 3,
                  child: Center(
                    child: Container(
                      width: screenWidth * 0.8,
                      height: screenHeight * 0.4,
                      alignment: Alignment.center,
                      child: Image.asset(
                        'assets/images/animated_logo.gif',
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            width: 200.w,
                            height: 200.h,
                            decoration: BoxDecoration(
                              color: const Color(0xFFD2691E).withOpacity(0.2),
                              borderRadius: BorderRadius.circular(20.r),
                            ),
                            child: const Icon(
                              Icons.mosque,
                              size: 100,
                              color: Color(0xFFD2691E),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ),

                // Gazelle positioned at the bottom
                Expanded(
                  flex: 2,
                  child: Container(
                    width: screenWidth,
                    alignment: Alignment.bottomCenter,
                    child: Image.asset(
                      'assets/images/splash_gazelle.png',
                      fit: BoxFit.contain,
                      height: screenHeight * 0.3,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          height: screenHeight * 0.2,
                          width: screenWidth * 0.6,
                          decoration: BoxDecoration(
                            color: const Color(0xFFD2691E).withOpacity(0.2),
                            borderRadius: BorderRadius.circular(15.r),
                          ),
                          child: const Icon(
                            Icons.pets,
                            size: 80,
                            color: Color(0xFFD2691E),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Next button positioned at the bottom
          Positioned(
            bottom: 30.h,
            left: 20.w,
            right: 20.w,
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: SizedBox(
                width: double.infinity,
                height: 50.h,
                child: ElevatedButton(
                  onPressed: _isInitialized ? _navigateToNextScreen : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFD2691E),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25.r),
                    ),
                    elevation: 5,
                  ),
                  child: Text(
                    'ابدأ الآن',
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'Tajawal',
                    ),
                  ),
                ),
              ),
            ),
          ),

          // Loading indicator and auth state management
          Consumer<AuthProvider>(
            builder: (context, authProvider, child) {
              // Only show the loading indicator if not initialized and not authenticated
              if (authProvider.isLoading && !_isInitialized) {
                return Positioned(
                  bottom: 100.h,
                  left: 0,
                  right: 0,
                  child: const Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFD2691E)),
                    ),
                  ),
                );
              }

              // Show error message if authentication fails
              if (authProvider.error != null) {
                return Positioned(
                  bottom: 100.h,
                  left: 20.w,
                  right: 20.w,
                  child: Container(
                    padding: EdgeInsets.all(12.w),
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8.r),
                      border: Border.all(color: Colors.red.withOpacity(0.3)),
                    ),
                    child: Text(
                      authProvider.error ?? 'خطأ في تحميل التطبيق',
                      style: TextStyle(
                        color: Colors.red,
                        fontSize: 12.sp,
                        fontFamily: 'Tajawal',
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                );
              }

              return const SizedBox.shrink();
            },
          ),
        ],
      ),
    );
  }
}