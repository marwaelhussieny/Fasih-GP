// lib/features/profile/settings/presentation/screens/personal_account_screen.dart
import 'package:flutter/material.dart';

class PersonalAccountScreen extends StatelessWidget {
  const PersonalAccountScreen({super.key});

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
          'الحساب الشخصي', // Personal Account
          style: TextStyle(color: appBarTextColor),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: appBarIconColor),
          onPressed: () => Navigator.of(context).pop(),
        ),
        backgroundColor: Colors.transparent, // Transparent like SettingsScreen AppBar
        elevation: 0,
        centerTitle: true,
      ),
      body: Center(
        child: Text(
          'هذه هي شاشة الحساب الشخصي', // This is the Personal Account Screen
          style: TextStyle(fontSize: 18, color: textColor),
        ),
      ),
    );
  }
}