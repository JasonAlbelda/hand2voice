import 'package:flutter/material.dart';
import 'package:hand2voice/core/services/screen_security_service.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Provider for managing screen security settings
class ScreenSecurityProvider extends ChangeNotifier {
  final ScreenSecurityService _screenSecurityService = ScreenSecurityService();
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  
  static const String _screenSecurityEnabledKey = 'screen_security_enabled';
  
  bool _isScreenSecurityEnabled = false;
  bool _isLoading = false;

  bool get isScreenSecurityEnabled => _isScreenSecurityEnabled;
  bool get isLoading => _isLoading;
  bool get isSecured => _screenSecurityService.isSecured;

  /// Initialize screen security settings
  Future<void> initialize() async {
    _isLoading = true;
    notifyListeners();

    try {
      // Load saved preference
      final String? value = await _secureStorage.read(key: _screenSecurityEnabledKey);
      _isScreenSecurityEnabled = value == 'true';

      // Apply screen security if enabled
      if (_isScreenSecurityEnabled) {
        await _screenSecurityService.enableScreenSecurity();
      }
    } catch (e) {
      print('Error initializing screen security: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  /// Toggle screen security on/off
  Future<void> toggleScreenSecurity(bool enabled) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _screenSecurityService.toggleScreenSecurity(enabled);
      await _secureStorage.write(
        key: _screenSecurityEnabledKey,
        value: enabled.toString(),
      );
      _isScreenSecurityEnabled = enabled;
    } catch (e) {
      print('Error toggling screen security: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  /// Enable screen security
  Future<void> enableScreenSecurity() async {
    await toggleScreenSecurity(true);
  }

  /// Disable screen security
  Future<void> disableScreenSecurity() async {
    await toggleScreenSecurity(false);
  }
}
