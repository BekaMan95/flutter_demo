import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider with ChangeNotifier {
  bool _isDarkMode = false;
  bool _isInitialized = false;
  static const String _themeKey = 'isDarkMode';

  bool get isDarkMode => _isDarkMode;
  bool get isInitialized => _isInitialized;

  ThemeProvider() {
    _loadThemePreference();
  }

  Future<void> _loadThemePreference() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _isDarkMode = prefs.getBool(_themeKey) ?? false;
      _isInitialized = true;
      notifyListeners();
    } catch (e) {
      print('Error loading theme preference: $e');
      _isDarkMode = false;
      _isInitialized = true;
      notifyListeners();
    }
  }

  Future<void> toggleTheme() async {
    try {
      _isDarkMode = !_isDarkMode;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_themeKey, _isDarkMode);
      notifyListeners();
    } catch (e) {
      print('Error saving theme preference: $e');
      // Revert the change if saving fails
      _isDarkMode = !_isDarkMode;
      notifyListeners();
    }
  }

  ThemeData get currentTheme {
    if (!_isInitialized) {
      return _lightTheme; // Default theme while loading
    }
    return _isDarkMode ? _darkTheme : _lightTheme;
  }

  static final _lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    colorScheme: ColorScheme.fromSeed(
      seedColor: Colors.blue,
      brightness: Brightness.light,
    ),
    scaffoldBackgroundColor: Colors.grey[50],
    cardTheme: const CardThemeData(
      elevation: 2,
      color: Colors.white,
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.blue,
      foregroundColor: Colors.white,
      elevation: 0,
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: Colors.blue,
      foregroundColor: Colors.white,
    ),
  );

  static final _darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: ColorScheme.fromSeed(
      seedColor: Colors.yellow,
      brightness: Brightness.dark,
    ),
    scaffoldBackgroundColor: Colors.grey[900],
    cardTheme: const CardThemeData(
      elevation: 2,
      color: Color(0xFF424242),
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.grey[900],
      foregroundColor: Colors.yellow,
      elevation: 0,
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: Colors.yellow,
      foregroundColor: Colors.black,
    ),
  );
} 