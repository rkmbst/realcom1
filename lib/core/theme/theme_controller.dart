import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeController extends ChangeNotifier {
  ThemeController._();

  static final ThemeController instance =
      ThemeController._();

  static const String _key = 'theme_mode';

  ThemeMode _themeMode = ThemeMode.system;

  ThemeMode get themeMode => _themeMode;

  Future<void> load() async {
    final prefs =
        await SharedPreferences.getInstance();

    final value =
        prefs.getString(_key);

    switch (value) {
      case 'dark':
        _themeMode = ThemeMode.dark;
        break;
      case 'light':
        _themeMode = ThemeMode.light;
        break;
      default:
        _themeMode = ThemeMode.system;
    }

    notifyListeners();
  }

  Future<void> setThemeMode(
    ThemeMode mode,
  ) async {
    _themeMode = mode;

    final prefs =
        await SharedPreferences.getInstance();

    final value = switch (mode) {
      ThemeMode.dark => 'dark',
      ThemeMode.light => 'light',
      ThemeMode.system => 'system',
    };

    await prefs.setString(
      _key,
      value,
    );

    notifyListeners();
  }
}
