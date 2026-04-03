import 'package:flutter/material.dart';
import 'package:hand2voice/core/services/biometric_service.dart';
import 'package:hand2voice/core/services/pin_auth_service.dart';
import 'package:hand2voice/core/services/auto_lock_service.dart';
import 'package:local_auth/local_auth.dart';

/// Unified provider for all authentication methods
class AuthProvider extends ChangeNotifier {
  final BiometricService _biometricService = BiometricService();
  final PinAuthService _pinAuthService = PinAuthService();
  final AutoLockService _autoLockService = AutoLockService();

  bool _isAuthenticated = false;
  bool _isBiometricEnabled = false;
  bool _isBiometricAvailable = false;
  bool _isPinEnabled = false;
  bool _isPatternEnabled = false;
  bool _isAutoLockEnabled = false;
  int _autoLockTimeout = 5;
  List<BiometricType> _availableBiometrics = [];
  bool _isLoading = false;

  bool get isAuthenticated => _isAuthenticated;
  bool get isBiometricEnabled => _isBiometricEnabled;
  bool get isBiometricAvailable => _isBiometricAvailable;
  bool get isPinEnabled => _isPinEnabled;
  bool get isPatternEnabled => _isPatternEnabled;
  bool get isAutoLockEnabled => _isAutoLockEnabled;
  int get autoLockTimeout => _autoLockTimeout;
  List<BiometricType> get availableBiometrics => _availableBiometrics;
  bool get isLoading => _isLoading;
  bool get isAnyAuthEnabled =>
      _isBiometricEnabled || _isPinEnabled || _isPatternEnabled;

  /// Initialize all authentication settings
  Future<void> initialize() async {
    _isLoading = true;
    notifyListeners();

    _isBiometricAvailable = await _biometricService.isBiometricAvailable();
    _availableBiometrics = await _biometricService.getAvailableBiometrics();
    _isBiometricEnabled = await _biometricService.isBiometricEnabled();
    _isPinEnabled = await _pinAuthService.isPinEnabled();
    _isPatternEnabled = await _pinAuthService.isPatternEnabled();
    _isAutoLockEnabled = await _autoLockService.isAutoLockEnabled();
    _autoLockTimeout = await _autoLockService.getAutoLockTimeout();

    // If any auth is enabled, start in locked state
    if (isAnyAuthEnabled) {
      _isAuthenticated = false;
    } else {
      _isAuthenticated = true;
    }

    _isLoading = false;
    notifyListeners();

    // Start auto-lock timer if enabled
    if (_isAutoLockEnabled && isAnyAuthEnabled) {
      _autoLockService.startAutoLockTimer(() {
        logout();
      });
    }
  }

  /// Authenticate the user (tries biometric first if available)
  Future<bool> authenticate({String? reason}) async {
    if (!isAnyAuthEnabled) {
      _isAuthenticated = true;
      notifyListeners();
      return true;
    }

    _isLoading = true;
    notifyListeners();

    bool success = false;

    // Try biometric first if enabled and available
    if (_isBiometricEnabled && _isBiometricAvailable) {
      success = await _biometricService.authenticate(
        reason: reason ?? 'Please authenticate to access Hand2Voice',
      );
    }

    _isAuthenticated = success;
    _isLoading = false;
    notifyListeners();

    // Reset auto-lock timer on successful authentication
    if (success && _isAutoLockEnabled) {
      _autoLockService.resetActivityTimer();
    }

    return success;
  }

  /// Verify PIN
  Future<bool> verifyPin(String pin) async {
    final success = await _pinAuthService.verifyPin(pin);
    if (success) {
      _isAuthenticated = true;
      notifyListeners();
      
      // Reset auto-lock timer
      if (_isAutoLockEnabled) {
        _autoLockService.resetActivityTimer();
      }
    }
    return success;
  }

  /// Verify Pattern
  Future<bool> verifyPattern(List<int> pattern) async {
    final success = await _pinAuthService.verifyPattern(pattern);
    if (success) {
      _isAuthenticated = true;
      notifyListeners();
      
      // Reset auto-lock timer
      if (_isAutoLockEnabled) {
        _autoLockService.resetActivityTimer();
      }
    }
    return success;
  }

  /// Toggle biometric authentication
  Future<void> toggleBiometric(bool enabled) async {
    if (enabled && _isBiometricAvailable) {
      final bool authenticated = await _biometricService.authenticate(
        reason: 'Authenticate to enable biometric security',
      );

      if (!authenticated) {
        return;
      }
    }

    await _biometricService.setBiometricEnabled(enabled);
    _isBiometricEnabled = enabled;
    notifyListeners();

    _updateAutoLockTimer();
  }

  /// Enable PIN authentication
  Future<void> enablePin(String pin) async {
    await _pinAuthService.setPin(pin);
    _isPinEnabled = true;
    notifyListeners();

    _updateAutoLockTimer();
  }

  /// Disable PIN authentication
  Future<void> disablePin() async {
    await _pinAuthService.disablePin();
    _isPinEnabled = false;
    notifyListeners();

    _updateAutoLockTimer();
  }

  /// Enable Pattern authentication
  Future<void> enablePattern(List<int> pattern) async {
    await _pinAuthService.setPattern(pattern);
    _isPatternEnabled = true;
    notifyListeners();

    _updateAutoLockTimer();
  }

  /// Disable Pattern authentication
  Future<void> disablePattern() async {
    await _pinAuthService.disablePattern();
    _isPatternEnabled = false;
    notifyListeners();

    _updateAutoLockTimer();
  }

  /// Toggle auto-lock
  Future<void> toggleAutoLock(bool enabled) async {
    await _autoLockService.setAutoLockEnabled(enabled);
    _isAutoLockEnabled = enabled;
    notifyListeners();

    _updateAutoLockTimer();
  }

  /// Set auto-lock timeout
  Future<void> setAutoLockTimeout(int minutes) async {
    await _autoLockService.setAutoLockTimeout(minutes);
    _autoLockTimeout = minutes;
    notifyListeners();

    _updateAutoLockTimer();
  }

  /// Update auto-lock timer based on current settings
  void _updateAutoLockTimer() {
    if (_isAutoLockEnabled && isAnyAuthEnabled) {
      _autoLockService.startAutoLockTimer(() {
        logout();
      });
    } else {
      _autoLockService.stopAutoLockTimer();
    }
  }

  /// Reset activity (for auto-lock)
  void resetActivity() {
    if (_isAutoLockEnabled) {
      _autoLockService.resetActivityTimer();
    }
  }

  /// Logout (reset authentication state)
  void logout() {
    _isAuthenticated = false;
    notifyListeners();
  }

  /// Get biometric type description
  String getBiometricDescription() {
    return _biometricService.getBiometricTypeDescription(_availableBiometrics);
  }

  @override
  void dispose() {
    _autoLockService.dispose();
    super.dispose();
  }
}
