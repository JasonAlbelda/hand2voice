import 'package:flutter/material.dart';
import 'package:hand2voice/core/services/biometric_service.dart';
import 'package:local_auth/local_auth.dart';

class BiometricProvider extends ChangeNotifier {
  final BiometricService _biometricService = BiometricService();
  
  bool _isAuthenticated = false;
  bool _isBiometricEnabled = false;
  bool _isBiometricAvailable = false;
  List<BiometricType> _availableBiometrics = [];
  bool _isLoading = false;

  bool get isAuthenticated => _isAuthenticated;
  bool get isBiometricEnabled => _isBiometricEnabled;
  bool get isBiometricAvailable => _isBiometricAvailable;
  List<BiometricType> get availableBiometrics => _availableBiometrics;
  bool get isLoading => _isLoading;

  /// Initialize biometric settings
  Future<void> initialize() async {
    _isLoading = true;
    notifyListeners();

    _isBiometricAvailable = await _biometricService.isBiometricAvailable();
    _availableBiometrics = await _biometricService.getAvailableBiometrics();
    _isBiometricEnabled = await _biometricService.isBiometricEnabled();

    _isLoading = false;
    notifyListeners();
  }

  /// Authenticate the user
  Future<bool> authenticate({String? reason}) async {
    if (!_isBiometricEnabled || !_isBiometricAvailable) {
      _isAuthenticated = true;
      notifyListeners();
      return true;
    }

    _isLoading = true;
    notifyListeners();

    final bool success = await _biometricService.authenticate(
      reason: reason ?? 'Please authenticate to access Hand2Voice',
    );

    _isAuthenticated = success;
    _isLoading = false;
    notifyListeners();

    return success;
  }

  /// Toggle biometric authentication on/off
  Future<void> toggleBiometric(bool enabled) async {
    if (enabled && _isBiometricAvailable) {
      // Require authentication before enabling
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
}
