import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.system;

  ThemeMode get themeMode => _themeMode;

  void setTheme(ThemeMode mode) {
    _themeMode = mode;
    saveTheme(mode);
    notifyListeners();
  }

  Future<void> loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final themeIndex = prefs.getInt('themeMode') ?? ThemeMode.system.index;
    _themeMode = ThemeMode.values[themeIndex];
    notifyListeners();
  }

  Future<void> saveTheme(ThemeMode mode) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setInt('themeMode', mode.index);
  }

  /// 🟢 Automatically applies system theme when enabled
  ThemeMode getAdaptiveTheme(BuildContext context) {
    if (_themeMode == ThemeMode.system) {
      final brightness = MediaQuery.of(context).platformBrightness;
      return brightness == Brightness.dark ? ThemeMode.dark : ThemeMode.light;
    }
    return _themeMode;
  }
}
