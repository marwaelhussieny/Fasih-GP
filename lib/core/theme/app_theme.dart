// lib/core/theme/app_theme.dart
import 'package:flutter/material.dart';

class AppTheme {
  // Define your primary brand color consistently - matching your Figma design
  static const Color primaryBrandColor = Color(0xFFBE5103); // Primary brand color from Figma
  static const Color secondaryBrandColor = Color(0xFF966837); // Secondary color (Light) from Figma
  static const Color minimalColor = Color(0xFFF06400); // Minimal (light) color from Figma
  static const Color accentColor = Color(0xFF4A5660); // Dark accent color from Figma (used for some dark mode elements)

  // Additional colors matching your Figma design
  static const Color lightBackgroundColor = Color(0xFFFAF8EE); // Background from Figma
  static const Color cardBackgroundColor = Color(0xFFFAF8EE); // Same as background for seamless design
  static const Color primaryTextColor = Color(0xFF444444); // Paragraph-color (Light) from Figma
  static const Color secondaryTextColor = Color(0xFFA8A6A7); // Paragraph-secondary-color (Light) from Figma

  // Dark Mode Specific Colors (from your mockups)
  static const Color darkBackgroundColor = Color(0xFF1A1A1A); // Very dark gray
  static const Color darkCardColor = Color(0xFF2D2D2D); // Dark gray for cards
  static const Color darkPrimaryTextColor = Colors.white; // White text on dark background
  static const Color darkSecondaryTextColor = Color(0xFFB0B0B0); // Lighter gray for secondary text
  static const Color darkHintColor = Color(0xFF8F8F8F); // Hint text color for dark mode

  // Light theme colors (merged from AppColors)
  static const Color primaryOrange = Color(0xFFFF8C42);
  static const Color lightOrange = Color(0xFFFFB366);
  static const Color warmAmber = Color(0xFFFFC947);
  static const Color softPeach = Color(0xFFFFE5D3);
  static const Color desertSand = Color(0xFFFFF8F3);

  // Dark theme colors (merged from AppColors)
  static const Color nightBlue = Color(0xFF1A1B3A);
  static const Color darkPurple = Color(0xFF2D1B69);
  static const Color starGold = Color(0xFFFFD700);
  static const Color moonSilver = Color(0xFFE6E6FA);

  // Neutral colors (merged from AppColors)
  static const Color textDark = Color(0xFF2C3E50);
  static const Color textLight = Color(0xFF7F8C8D);
  static const Color backgroundLight = Color(0xFFFAFAFA);
  static const Color backgroundDark = Color(0xFF121212);

  // Status colors (merged from AppColors)
  static const Color success = Color(0xFF27AE60);
  static const Color error = Color(0xFFE74C3C);
  static const Color warning = Color(0xFFF39C12);
  static const Color info = Color(0xFF3498DB);

  // Gradient combinations (merged from AppColors and newly created)
  static const List<Color> primaryGradient = [primaryOrange, minimalColor]; // Updated gradient
  static const List<Color> secondaryGradient = [primaryBrandColor, secondaryBrandColor]; // New gradient
  static const List<Color> darkGradient = [darkPurple, accentColor]; // Updated dark gradient
  static const List<Color> goldGradient = [warmAmber, starGold];

  // Light Theme - matching your mockup design
  static final ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    primaryColor: primaryBrandColor,
    primarySwatch: _createMaterialColor(primaryBrandColor),
    fontFamily: 'Tajawal', // Default font family for the entire theme

    // Background colors matching your mockups
    scaffoldBackgroundColor: lightBackgroundColor,
    cardColor: cardBackgroundColor,
    dialogBackgroundColor: cardBackgroundColor,
    canvasColor: lightBackgroundColor, // Used for some internal Flutter widgets

    // Color scheme
    colorScheme: const ColorScheme.light(
      primary: primaryBrandColor, // #BE5103
      secondary: secondaryBrandColor, // #966837
      tertiary: minimalColor, // #F06400 for accent elements
      surface: cardBackgroundColor, // #FAF8EE (for cards, dialogs)
      background: lightBackgroundColor, // #FAF8EE (for scaffold)
      onPrimary: Colors.white, // Text/icons on primary color
      onSecondary: Colors.white, // Text/icons on secondary color
      onSurface: primaryTextColor, // Text/icons on surface color
      onBackground: primaryTextColor, // Text/icons on background color
      error: error, // Using merged error color
      onError: Colors.white, // Text/icons on error color
      outline: Color(0xFFE0E0E0), // For borders/dividers
    ),

    // Text theme with proper contrast matching your design and Tajwal font
    textTheme: const TextTheme(
      headlineLarge: TextStyle(
        color: primaryTextColor,
        fontWeight: FontWeight.bold,
        fontSize: 32,
        fontFamily: 'Tajawal',
      ),
      headlineMedium: TextStyle(
        color: primaryTextColor,
        fontWeight: FontWeight.bold,
        fontSize: 24,
        fontFamily: 'Tajawal',
      ),
      headlineSmall: TextStyle(
        color: primaryTextColor,
        fontWeight: FontWeight.w600,
        fontSize: 20,
        fontFamily: 'Tajawal',
      ),
      titleLarge: TextStyle(
        color: primaryTextColor,
        fontWeight: FontWeight.w600,
        fontSize: 18,
        fontFamily: 'Tajawal',
      ),
      titleMedium: TextStyle(
        color: primaryTextColor,
        fontWeight: FontWeight.w500,
        fontSize: 16,
        fontFamily: 'Tajawal',
      ),
      titleSmall: TextStyle(
        color: primaryTextColor,
        fontWeight: FontWeight.w500,
        fontSize: 14,
        fontFamily: 'Tajawal',
      ),
      bodyLarge: TextStyle(
        color: primaryTextColor,
        fontSize: 16,
        fontFamily: 'Tajawal',
      ),
      bodyMedium: TextStyle(
        color: primaryTextColor,
        fontSize: 14,
        fontFamily: 'Tajawal',
      ),
      bodySmall: TextStyle(
        color: secondaryTextColor,
        fontSize: 12,
        fontFamily: 'Tajawal',
      ),
      labelLarge: TextStyle(
        color: primaryTextColor,
        fontWeight: FontWeight.w500,
        fontSize: 14,
        fontFamily: 'Tajawal',
      ),
      labelMedium: TextStyle(
        color: secondaryTextColor,
        fontSize: 12,
        fontFamily: 'Tajawal',
      ),
      labelSmall: TextStyle(
        color: secondaryTextColor,
        fontSize: 11,
        fontFamily: 'Tajawal',
      ),
    ),

    // AppBar theme - matching your design with clean look
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
      iconTheme: const IconThemeData(color: primaryTextColor, size: 24),
      actionsIconTheme: const IconThemeData(color: primaryTextColor, size: 24),
      titleTextStyle: TextStyle(
        color: primaryTextColor,
        fontSize: 18,
        fontWeight: FontWeight.w600,
        fontFamily: 'Tajawal',
      ),
    ),

    // Card theme matching your design - clean cards with subtle shadow
    cardTheme: const CardThemeData(
      color: cardBackgroundColor,
      elevation: 1,
      shadowColor: Color(0x10000000), // Very subtle shadow (10% black)
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(16)),
      ),
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    ),

    // ElevatedButton theme - matching your brand colors
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryBrandColor,
        foregroundColor: Colors.white,
        textStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          fontFamily: 'Tajawal',
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
        elevation: 0,
        shadowColor: Colors.transparent,
        minimumSize: const Size(double.infinity, 56),
      ),
    ),

    // TextButton theme
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: primaryBrandColor,
        textStyle: const TextStyle(
          fontWeight: FontWeight.w600,
          fontFamily: 'Tajawal',
        ),
      ),
    ),

    // Input field decoration theme - matching your clean input design with Tajwal font
    inputDecorationTheme: InputDecorationTheme(
      filled: false, // No background fill - same as screen background
      fillColor: Colors.transparent,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      border: const UnderlineInputBorder(
        borderSide: BorderSide(color: primaryBrandColor, width: 1),
      ),
      enabledBorder: const UnderlineInputBorder(
        borderSide: BorderSide(color: secondaryTextColor, width: 1), // Use secondaryTextColor for enabled border
      ),
      focusedBorder: const UnderlineInputBorder(
        borderSide: BorderSide(color: primaryBrandColor, width: 2),
      ),
      errorBorder: const UnderlineInputBorder(
        borderSide: BorderSide(color: error, width: 1),
      ),
      focusedErrorBorder: const UnderlineInputBorder(
        borderSide: BorderSide(color: error, width: 2),
      ),
      labelStyle: const TextStyle(
        color: secondaryTextColor,
        fontSize: 14,
        fontFamily: 'Tajawal',
      ),
      hintStyle: const TextStyle(
        color: secondaryTextColor,
        fontSize: 14,
        fontFamily: 'Tajawal',
      ),
      prefixIconColor: primaryBrandColor,
      suffixIconColor: primaryBrandColor,
    ),

    // Switch theme for dark mode toggle
    switchTheme: SwitchThemeData(
      thumbColor: MaterialStateProperty.resolveWith((states) {
        if (states.contains(MaterialState.selected)) {
          return primaryBrandColor;
        }
        return const Color(0xFFBDBDBD);
      }),
      trackColor: MaterialStateProperty.resolveWith((states) {
        if (states.contains(MaterialState.selected)) {
          return primaryBrandColor.withOpacity(0.5);
        }
        return const Color(0xFFE0E0E0);
      }),
    ),

    // List Tile theme - matching your settings design
    listTileTheme: const ListTileThemeData(
      iconColor: primaryBrandColor,
      textColor: primaryTextColor,
      tileColor: cardBackgroundColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(12)),
      ),
      contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      minVerticalPadding: 12,
    ),

    // Icon theme
    iconTheme: const IconThemeData(
      color: primaryBrandColor,
      size: 24,
    ),
  );

  // Dark Theme - matching your dark mode mockup
  static final ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    primaryColor: primaryBrandColor,
    primarySwatch: _createMaterialColor(primaryBrandColor),
    fontFamily: 'Tajawal', // Default font family for the entire theme

    // Dark background colors
    scaffoldBackgroundColor: darkBackgroundColor,
    cardColor: darkCardColor,
    dialogBackgroundColor: darkCardColor,
    canvasColor: darkBackgroundColor,

    // Color scheme for dark mode
    colorScheme: const ColorScheme.dark(
      primary: primaryBrandColor,
      secondary: secondaryBrandColor,
      tertiary: minimalColor, // Using minimal color for tertiary in dark mode too
      surface: darkCardColor,
      background: darkBackgroundColor,
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onSurface: darkPrimaryTextColor, // Text/icons on surface color
      onBackground: darkPrimaryTextColor, // Text/icons on background color
      error: error, // Using merged error color
      onError: Colors.white,
      outline: Color(0xFF4D4D4D), // Darker outline for dark mode
    ),

    // Text theme for dark mode (all now include fontFamily)
    textTheme: const TextTheme(
      headlineLarge: TextStyle(color: darkPrimaryTextColor, fontWeight: FontWeight.bold, fontSize: 32, fontFamily: 'Tajawal'),
      headlineMedium: TextStyle(color: darkPrimaryTextColor, fontWeight: FontWeight.w600, fontSize: 24, fontFamily: 'Tajawal'),
      headlineSmall: TextStyle(color: darkPrimaryTextColor, fontWeight: FontWeight.w600, fontSize: 20, fontFamily: 'Tajawal'),
      titleLarge: TextStyle(color: darkPrimaryTextColor, fontWeight: FontWeight.w600, fontSize: 18, fontFamily: 'Tajawal'),
      titleMedium: TextStyle(color: darkPrimaryTextColor, fontWeight: FontWeight.w500, fontSize: 16, fontFamily: 'Tajawal'),
      titleSmall: TextStyle(color: darkPrimaryTextColor, fontWeight: FontWeight.w500, fontSize: 14, fontFamily: 'Tajawal'),
      bodyLarge: TextStyle(color: darkPrimaryTextColor, fontSize: 16, fontFamily: 'Tajawal'),
      bodyMedium: TextStyle(color: darkPrimaryTextColor, fontSize: 14, fontFamily: 'Tajawal'),
      bodySmall: TextStyle(color: darkSecondaryTextColor, fontSize: 12, fontFamily: 'Tajawal'),
      labelLarge: TextStyle(color: darkPrimaryTextColor, fontWeight: FontWeight.w500, fontSize: 14, fontFamily: 'Tajawal'),
      labelMedium: TextStyle(color: darkSecondaryTextColor, fontSize: 12, fontFamily: 'Tajawal'),
      labelSmall: TextStyle(color: darkSecondaryTextColor, fontSize: 11, fontFamily: 'Tajawal'),
    ),

    // AppBar theme for dark mode
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
      iconTheme: const IconThemeData(color: darkPrimaryTextColor),
      titleTextStyle: TextStyle(
          color: darkPrimaryTextColor,
          fontSize: 20,
          fontWeight: FontWeight.bold,
          fontFamily: 'Tajawal'
      ),
    ),

    // Card theme for dark mode
    cardTheme: const CardThemeData(
      color: darkCardColor,
      elevation: 4,
      shadowColor: Color(0x4D000000), // 30% black opacity
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(12)),
      ),
    ),

    // ElevatedButton theme for dark mode
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryBrandColor,
        foregroundColor: Colors.white,
        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, fontFamily: 'Tajawal'),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
        elevation: 4,
      ),
    ),

    // TextButton theme for dark mode
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: primaryBrandColor,
        textStyle: const TextStyle(fontWeight: FontWeight.w600, fontFamily: 'Tajawal'),
      ),
    ),

    // Input field decoration theme for dark mode
    inputDecorationTheme: InputDecorationTheme(
      filled: false,
      fillColor: Colors.transparent,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      border: const UnderlineInputBorder(
        borderSide: BorderSide(color: primaryBrandColor, width: 1),
      ),
      enabledBorder: const UnderlineInputBorder(
        borderSide: BorderSide(color: darkSecondaryTextColor, width: 1), // Use darkSecondaryTextColor for enabled border
      ),
      focusedBorder: const UnderlineInputBorder(
        borderSide: BorderSide(color: primaryBrandColor, width: 2),
      ),
      errorBorder: const UnderlineInputBorder(
        borderSide: BorderSide(color: error, width: 1),
      ),
      focusedErrorBorder: const UnderlineInputBorder(
        borderSide: BorderSide(color: error, width: 2),
      ),
      labelStyle: const TextStyle(
        color: darkSecondaryTextColor,
        fontSize: 14,
        fontFamily: 'Tajawal',
      ),
      hintStyle: const TextStyle(
        color: darkHintColor,
        fontSize: 14,
        fontFamily: 'Tajawal',
      ),
      prefixIconColor: primaryBrandColor,
      suffixIconColor: primaryBrandColor,
    ),

    // Switch theme for dark mode
    switchTheme: SwitchThemeData(
      thumbColor: MaterialStateProperty.resolveWith((states) {
        if (states.contains(MaterialState.selected)) {
          return primaryBrandColor;
        }
        return const Color(0xFF6D6D6D);
      }),
      trackColor: MaterialStateProperty.resolveWith((states) {
        if (states.contains(MaterialState.selected)) {
          return primaryBrandColor.withOpacity(0.5);
        }
        return const Color(0xFF4D4D4D);
      }),
    ),

    // List Tile theme for dark mode
    listTileTheme: const ListTileThemeData(
      iconColor: primaryBrandColor,
      textColor: darkPrimaryTextColor,
      tileColor: darkCardColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(12)),
      ),
      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    ),

    // Icon theme for dark mode
    iconTheme: const IconThemeData(
      color: primaryBrandColor,
      size: 24,
    ),
  );

  // Helper method to create MaterialColor from Color
  static MaterialColor _createMaterialColor(Color color) {
    List strengths = <double>[.05];
    final swatch = <int, Color>{};
    final int r = color.red, g = color.green, b = color.blue;

    for (int i = 1; i < 10; i++) {
      strengths.add(0.1 * i);
    }

    for (var strength in strengths) {
      final double ds = 0.5 - strength;
      swatch[(strength * 1000).round()] = Color.fromRGBO(
        r + ((ds < 0 ? r : (255 - r)) * ds).round(),
        g + ((ds < 0 ? g : (255 - g)) * ds).round(),
        b + ((ds < 0 ? b : (255 - b)) * ds).round(),
        1,
      );
    }
    return MaterialColor(color.value, swatch);
  }
}
