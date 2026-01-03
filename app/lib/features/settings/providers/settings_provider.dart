import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsProvider with ChangeNotifier {
  bool _isOnlineMode = false;
  // Default URL (Change this to your current laptop IP as a backup)
  String _serverUrl = "http://192.168.1.5:5000";

  bool get isOnlineMode => _isOnlineMode;
  String get serverUrl => _serverUrl;

  SettingsProvider() {
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    _isOnlineMode = prefs.getBool('is_online_mode') ?? false;
    // Load URL, or keep default if null
    _serverUrl = prefs.getString('server_url') ?? "http://192.168.1.5:5000";
    notifyListeners();
  }

  Future<void> toggleProcessingMode(bool value) async {
    _isOnlineMode = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('is_online_mode', value);
    notifyListeners();
  }

  // New method to set URL
  Future<void> setServerUrl(String url) async {
    // Basic cleanup: remove trailing slash if present
    String cleanUrl = url.trim();
    if (cleanUrl.endsWith('/')) {
      cleanUrl = cleanUrl.substring(0, cleanUrl.length - 1);
    }

    // Ensure http:// or https:// exists
    if (!cleanUrl.startsWith("http")) {
      cleanUrl = "http://$cleanUrl";
    }

    _serverUrl = cleanUrl;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('server_url', _serverUrl);
    notifyListeners();
  }
}
