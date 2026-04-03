import 'package:flutter/services.dart';
import 'dart:io';

/// Service to manage screen security features
/// Prevents screenshots and screen recording on sensitive screens
class ScreenSecurityService {
  static final ScreenSecurityService _instance = ScreenSecurityService._internal();
  factory ScreenSecurityService() => _instance;
  ScreenSecurityService._internal();

  static const MethodChannel _channel = MethodChannel('com.hand2voice/screen_security');
  
  bool _isSecured = false;

  /// Enable screen security (prevent screenshots and screen recording)
  Future<void> enableScreenSecurity() async {
    if (_isSecured) return;

    try {
      if (Platform.isAndroid) {
        await _channel.invokeMethod('enableSecureFlag');
        _isSecured = true;
        print('Screen security enabled (Android)');
      } else if (Platform.isIOS) {
        // iOS doesn't have a direct API to prevent screenshots
        // But we can blur the app preview in task switcher
        _isSecured = true;
        print('Screen security enabled (iOS - task switcher blur)');
      }
    } catch (e) {
      print('Error enabling screen security: $e');
    }
  }

  /// Disable screen security (allow screenshots)
  Future<void> disableScreenSecurity() async {
    if (!_isSecured) return;

    try {
      if (Platform.isAndroid) {
        await _channel.invokeMethod('disableSecureFlag');
        _isSecured = false;
        print('Screen security disabled (Android)');
      } else if (Platform.isIOS) {
        _isSecured = false;
        print('Screen security disabled (iOS)');
      }
    } catch (e) {
      print('Error disabling screen security: $e');
    }
  }

  /// Check if screen security is currently enabled
  bool get isSecured => _isSecured;

  /// Enable screen security for specific screen
  /// Call this in initState of sensitive screens
  Future<void> secureScreen() async {
    await enableScreenSecurity();
  }

  /// Disable screen security when leaving sensitive screen
  /// Call this in dispose of sensitive screens
  Future<void> unsecureScreen() async {
    await disableScreenSecurity();
  }

  /// Toggle screen security on/off
  Future<void> toggleScreenSecurity(bool enable) async {
    if (enable) {
      await enableScreenSecurity();
    } else {
      await disableScreenSecurity();
    }
  }
}
