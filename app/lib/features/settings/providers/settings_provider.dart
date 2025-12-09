import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsProvider with ChangeNotifier {
  bool _isOnlineMode = false; // Default to Offline for stability

  bool get isOnlineMode => _isOnlineMode;

  SettingsProvider() {
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    _isOnlineMode = prefs.getBool('is_online_mode') ?? false;
    notifyListeners();
  }

  Future<void> toggleProcessingMode(bool value) async {
    _isOnlineMode = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('is_online_mode', value);
    notifyListeners();
  }
}
