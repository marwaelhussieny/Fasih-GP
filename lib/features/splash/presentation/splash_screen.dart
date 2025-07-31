import 'dart:async';
import 'package:flutter/material.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // Timer(const Duration(seconds: 3), () {
    //   Navigator.pushReplacementNamed(context, '/onboarding');
    // });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDF8F3),
      body: Stack(
        children: [
          // Full background image (sky + mosque + stars)
          Positioned.fill(
            child: Image.asset(
              'assets/images/splash_bg.png',
              fit: BoxFit.cover,
            ),
          ),

          // Gazelle positioned at the bottom
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Image.asset(
              'assets/images/splash_gazelle.png',
              width: MediaQuery.of(context).size.width,
              fit: BoxFit.contain,
            ),
          ),

          // Centered animated logo
          Positioned(
            top: MediaQuery.of(context).size.height * 0.12,
            left: 0,
            right: 0,
            child: Center(
              child: Image.asset(
                'assets/images/animated_logo.gif',
                width: MediaQuery.of(context).size.width * 2, // Adjust size here
                height: MediaQuery.of(context).size.width * 2,
                fit: BoxFit.contain,
              ),
            ),
          ),

          Positioned(
            bottom: 50,
            left: 0,
            right: 0,
            child: Center(
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/login'); // or /onboarding, /signup etc.
                },
                child: const Text('Next'),
              ),
            ),
          ),

        ],
      ),
    );
  }
}
