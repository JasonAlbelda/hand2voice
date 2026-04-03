import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';

/// Service for PIN/Pattern authentication
class PinAuthService {
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  
  static const String _pinEnabledKey = 'pin_enabled';
  static const String _pinHashKey = 'pin_hash';
  static const String _patternEnabledKey = 'pattern_enabled';
  static const String _patternHashKey = 'pattern_hash';

  /// Check if PIN authentication is enabled
  Future<bool> isPinEnabled() async {
    try {
      final String? value = await _secureStorage.read(key: _pinEnabledKey);
      return value == 'true';
    } catch (e) {
      print('Error reading PIN setting: $e');
      return false;
    }
  }

  /// Check if Pattern authentication is enabled
  Future<bool> isPatternEnabled() async {
    try {
      final String? value = await _secureStorage.read(key: _patternEnabledKey);
      return value == 'true';
    } catch (e) {
      print('Error reading Pattern setting: $e');
      return false;
    }
  }

  /// Set PIN (hashed for security)
  Future<void> setPin(String pin) async {
    try {
      final String hashedPin = _hashValue(pin);
      await _secureStorage.write(key: _pinHashKey, value: hashedPin);
      await _secureStorage.write(key: _pinEnabledKey, value: 'true');
    } catch (e) {
      print('Error setting PIN: $e');
      rethrow;
    }
  }

  /// Set Pattern (hashed for security)
  Future<void> setPattern(List<int> pattern) async {
    try {
      final String patternString = pattern.join(',');
      final String hashedPattern = _hashValue(patternString);
      await _secureStorage.write(key: _patternHashKey, value: hashedPattern);
      await _secureStorage.write(key: _patternEnabledKey, value: 'true');
    } catch (e) {
      print('Error setting Pattern: $e');
      rethrow;
    }
  }

  /// Verify PIN
  Future<bool> verifyPin(String pin) async {
    try {
      final String? storedHash = await _secureStorage.read(key: _pinHashKey);
      if (storedHash == null) return false;
      
      final String inputHash = _hashValue(pin);
      return storedHash == inputHash;
    } catch (e) {
      print('Error verifying PIN: $e');
      return false;
    }
  }

  /// Verify Pattern
  Future<bool> verifyPattern(List<int> pattern) async {
    try {
      final String? storedHash = await _secureStorage.read(key: _patternHashKey);
      if (storedHash == null) return false;
      
      final String patternString = pattern.join(',');
      final String inputHash = _hashValue(patternString);
      return storedHash == inputHash;
    } catch (e) {
      print('Error verifying Pattern: $e');
      return false;
    }
  }

  /// Disable PIN authentication
  Future<void> disablePin() async {
    try {
      await _secureStorage.delete(key: _pinEnabledKey);
      await _secureStorage.delete(key: _pinHashKey);
    } catch (e) {
      print('Error disabling PIN: $e');
    }
  }

  /// Disable Pattern authentication
  Future<void> disablePattern() async {
    try {
      await _secureStorage.delete(key: _patternEnabledKey);
      await _secureStorage.delete(key: _patternHashKey);
    } catch (e) {
      print('Error disabling Pattern: $e');
    }
  }

  /// Hash a value using SHA-256
  String _hashValue(String value) {
    final bytes = utf8.encode(value);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  /// Check if any authentication method is enabled
  Future<bool> isAnyAuthEnabled() async {
    final pinEnabled = await isPinEnabled();
    final patternEnabled = await isPatternEnabled();
    return pinEnabled || patternEnabled;
  }
}
