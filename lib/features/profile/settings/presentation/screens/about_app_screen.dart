// lib/features/profile/settings/presentation/screens/about_app_screen.dart
import 'package:flutter/material.dart';

class AboutAppScreen extends StatelessWidget {
  const AboutAppScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Colors adapt to the current theme
    final Color textColor = Theme.of(context).textTheme.bodyMedium!.color!;
    final Color backgroundColor = Theme.of(context).scaffoldBackgroundColor;
    final Color appBarIconColor = Theme.of(context).appBarTheme.iconTheme!.color!;
    final Color appBarTextColor = Theme.of(context).appBarTheme.titleTextStyle!.color!;


    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: Text(
          'عن التطبيق', // About App
          style: TextStyle(color: appBarTextColor),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: appBarIconColor),
          onPressed: () => Navigator.of(context).pop(),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: Center(
        child: Text(
          'هذه هي شاشة عن التطبيق', // This is the About App Screen
          style: TextStyle(fontSize: 18, color: textColor),
        ),
      ),
    );
  }
}