import 'dart:async';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Service for auto-lock functionality
class AutoLockService {
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  
  static const String _autoLockEnabledKey = 'auto_lock_enabled';
  static const String _autoLockTimeoutKey = 'auto_lock_timeout';
  
  Timer? _lockTimer;
  DateTime? _lastActivityTime;

  /// Check if auto-lock is enabled
  Future<bool> isAutoLockEnabled() async {
    try {
      final String? value = await _secureStorage.read(key: _autoLockEnabledKey);
      return value == 'true';
    } catch (e) {
      print('Error reading auto-lock setting: $e');
      return false;
    }
  }

  /// Get auto-lock timeout in minutes
  Future<int> getAutoLockTimeout() async {
    try {
      final String? value = await _secureStorage.read(key: _autoLockTimeoutKey);
      return int.tryParse(value ?? '5') ?? 5; // Default 5 minutes
    } catch (e) {
      print('Error reading auto-lock timeout: $e');
      return 5;
    }
  }

  /// Set auto-lock enabled/disabled
  Future<void> setAutoLockEnabled(bool enabled) async {
    try {
      await _secureStorage.write(
        key: _autoLockEnabledKey,
        value: enabled.toString(),
      );
    } catch (e) {
      print('Error setting auto-lock: $e');
    }
  }

  /// Set auto-lock timeout in minutes
  Future<void> setAutoLockTimeout(int minutes) async {
    try {
      await _secureStorage.write(
        key: _autoLockTimeoutKey,
        value: minutes.toString(),
      );
    } catch (e) {
      print('Error setting auto-lock timeout: $e');
    }
  }

  /// Start the auto-lock timer
  Future<void> startAutoLockTimer(Function onLock) async {
    final bool enabled = await isAutoLockEnabled();
    if (!enabled) return;

    final int timeoutMinutes = await getAutoLockTimeout();
    _lastActivityTime = DateTime.now();

    _lockTimer?.cancel();
    _lockTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
      if (_lastActivityTime != null) {
        final difference = DateTime.now().difference(_lastActivityTime!);
        if (difference.inMinutes >= timeoutMinutes) {
          onLock();
          timer.cancel();
        }
      }
    });
  }

  /// Reset the activity timer
  void resetActivityTimer() {
    _lastActivityTime = DateTime.now();
  }

  /// Stop the auto-lock timer
  void stopAutoLockTimer() {
    _lockTimer?.cancel();
    _lockTimer = null;
    _lastActivityTime = null;
  }

  /// Check if should lock based on last activity
  Future<bool> shouldLock() async {
    final bool enabled = await isAutoLockEnabled();
    if (!enabled || _lastActivityTime == null) return false;

    final int timeoutMinutes = await getAutoLockTimeout();
    final difference = DateTime.now().difference(_lastActivityTime!);
    return difference.inMinutes >= timeoutMinutes;
  }

  /// Dispose resources
  void dispose() {
    stopAutoLockTimer();
  }
}
