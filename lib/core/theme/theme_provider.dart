// lib/core/theme/theme_provider.dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider with ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.light; // Default to light
  bool _isInitialized = false; // Track if theme has been loaded

  // Constructor
  ThemeProvider();

  ThemeMode get themeMode => _themeMode;
  bool get isDarkMode => _themeMode == ThemeMode.dark;
  bool get isInitialized => _isInitialized;

  // Method to toggle the theme mode
  Future<void> toggleTheme(bool isOn) async {
    _themeMode = isOn ? ThemeMode.dark : ThemeMode.light;
    notifyListeners(); // IMPORTANT: Notify widgets listening to this provider
    await _saveThemeToPrefs(_themeMode); // Save the new preference
  }

  // Method to explicitly set theme mode (if needed elsewhere)
  Future<void> setThemeMode(ThemeMode mode) async {
    if (_themeMode != mode) {
      _themeMode = mode;
      notifyListeners();
      await _saveThemeToPrefs(_themeMode);
    }
  }

  // CRUCIAL METHOD: Loads the saved theme preference from SharedPreferences
  Future<void> loadThemeFromPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final isDark = prefs.getBool('isDarkMode') ?? false; // Default to light if not found
      _themeMode = isDark ? ThemeMode.dark : ThemeMode.light;
      _isInitialized = true;
      notifyListeners(); // Notify listeners after loading the initial theme
    } catch (e) {
      // If there's an error loading preferences, use default light theme
      _themeMode = ThemeMode.light;
      _isInitialized = true;
      notifyListeners();
    }
  }

  // Helper method to save the current theme preference
  Future<void> _saveThemeToPrefs(ThemeMode mode) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isDarkMode', mode == ThemeMode.dark);
    } catch (e) {
      // Handle error silently - theme will still work for current session
      debugPrint('Error saving theme preference: $e');
    }
  }

  // Method to get current theme brightness for conditional styling
  Brightness get currentBrightness {
    return _themeMode == ThemeMode.dark ? Brightness.dark : Brightness.light;
  }

  // Method to get theme-aware colors
  Color getBackgroundColor(BuildContext context) {
    return isDarkMode ? const Color(0xFF1A1A1A) : const Color(0xFFF5F5DC);
  }

  Color getCardColor(BuildContext context) {
    return isDarkMode ? const Color(0xFF2D2D2D) : const Color(0xFFFAF0E6);
  }

  Color getTextColor(BuildContext context) {
    return isDarkMode ? Colors.white : const Color(0xFF2F2F2F);
  }

  Color getSecondaryTextColor(BuildContext context) {
    return isDarkMode ? const Color(0xFFB0B0B0) : const Color(0xFF5F5F5F);
  }
}