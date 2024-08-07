import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider extends ChangeNotifier {
  bool _isDarkTheme = true;

  ThemeProvider() {
    _loadThemePreference();
  }

  bool get isDarkTheme => _isDarkTheme;

  void toggleTheme() async {
    _isDarkTheme = !_isDarkTheme;
    notifyListeners();
    _saveThemePreference();
  }

  /// If the connected user is not the selected user, the theme is different than default
  void setOtherThemeWhenSelectedUserIsNotConnectedUser(
      bool selectedUserIsConnectedUser) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _isDarkTheme = (prefs.getBool('isDarkTheme') ?? true);
    if (!selectedUserIsConnectedUser) {
      _isDarkTheme = !_isDarkTheme;
    }
    notifyListeners();
  }

  void _loadThemePreference() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _isDarkTheme = (prefs.getBool('isDarkTheme') ?? true);
    notifyListeners();
  }

  void _saveThemePreference() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool('isDarkTheme', _isDarkTheme);
  }
}
