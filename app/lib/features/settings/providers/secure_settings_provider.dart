import 'package:flutter/material.dart';
import 'package:hand2voice/core/services/secure_storage_service.dart';

/// Secure settings provider using encrypted storage
class SecureSettingsProvider with ChangeNotifier {
  final SecureStorageService _secureStorage = SecureStorageService();
  
  bool _isOnlineMode = false;
  String _serverUrl = "http://192.168.1.5:5000";
  bool _isInitialized = false;

  bool get isOnlineMode => _isOnlineMode;
  String get serverUrl => _serverUrl;
  bool get isInitialized => _isInitialized;

  SecureSettingsProvider() {
    _initialize();
  }

  Future<void> _initialize() async {
    try {
      await _secureStorage.initialize();
      await _loadSettings();
      _isInitialized = true;
      notifyListeners();
    } catch (e) {
      print('Error initializing secure settings: $e');
      _isInitialized = true;
      notifyListeners();
    }
  }

  Future<void> _loadSettings() async {
    try {
      _isOnlineMode = await _secureStorage.readBool('is_online_mode') ?? false;
      _serverUrl = await _secureStorage.readString('server_url') ?? "http://192.168.1.5:5000";
      notifyListeners();
    } catch (e) {
      print('Error loading settings: $e');
    }
  }

  Future<void> toggleProcessingMode(bool value) async {
    _isOnlineMode = value;
    await _secureStorage.writeBool('is_online_mode', value);
    notifyListeners();
  }

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
    await _secureStorage.writeString('server_url', _serverUrl);
    notifyListeners();
  }

  /// Clear all settings
  Future<void> clearSettings() async {
    await _secureStorage.delete('is_online_mode');
    await _secureStorage.delete('server_url');
    _isOnlineMode = false;
    _serverUrl = "http://192.168.1.5:5000";
    notifyListeners();
  }
}
