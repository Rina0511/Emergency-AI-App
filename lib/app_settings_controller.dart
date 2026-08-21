import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppSettingsController extends ChangeNotifier {
  Locale _locale = const Locale('en');
  ThemeMode _themeMode = ThemeMode.light;

  Locale get locale => _locale;
  ThemeMode get themeMode => _themeMode;

  Future<void> loadSettings() async {
    final prefs = await SharedPreferences.getInstance();

    final languageCode = prefs.getString('languageCode') ?? 'en';
    final isDarkMode = prefs.getBool('darkMode') ?? false;

    _locale = Locale(languageCode);
    _themeMode = isDarkMode ? ThemeMode.dark : ThemeMode.light;

    notifyListeners();
  }

  Future<void> changeLanguage(String languageCode) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setString('languageCode', languageCode);

    _locale = Locale(languageCode);
    notifyListeners();
  }

  Future<void> changeTheme(bool isDarkMode) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setBool('darkMode', isDarkMode);

    _themeMode = isDarkMode ? ThemeMode.dark : ThemeMode.light;
    notifyListeners();
  }
}

final appSettingsController = AppSettingsController();
