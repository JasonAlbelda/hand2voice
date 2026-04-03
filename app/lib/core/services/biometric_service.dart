import 'package:local_auth/local_auth.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class BiometricService {
  final LocalAuthentication _localAuth = LocalAuthentication();
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  
  static const String _biometricEnabledKey = 'biometric_enabled';

  /// Check if the device supports biometric authentication
  Future<bool> isBiometricAvailable() async {
    try {
      final bool canAuthenticateWithBiometrics = await _localAuth.canCheckBiometrics;
      final bool canAuthenticate = canAuthenticateWithBiometrics || await _localAuth.isDeviceSupported();
      return canAuthenticate;
    } catch (e) {
      print('Error checking biometric availability: $e');
      return false;
    }
  }

  /// Get list of available biometric types (fingerprint, face, iris)
  Future<List<BiometricType>> getAvailableBiometrics() async {
    try {
      return await _localAuth.getAvailableBiometrics();
    } catch (e) {
      print('Error getting available biometrics: $e');
      return [];
    }
  }

  /// Authenticate using biometrics
  Future<bool> authenticate({
    String reason = 'Please authenticate to access the app',
    bool useErrorDialogs = true,
    bool stickyAuth = true,
  }) async {
    try {
      final bool isAvailable = await isBiometricAvailable();
      if (!isAvailable) {
        return false;
      }

      final bool didAuthenticate = await _localAuth.authenticate(
        localizedReason: reason,
      );

      return didAuthenticate;
    } catch (e) {
      print('Error during authentication: $e');
      return false;
    }
  }

  /// Check if biometric authentication is enabled in app settings
  Future<bool> isBiometricEnabled() async {
    try {
      final String? value = await _secureStorage.read(key: _biometricEnabledKey);
      return value == 'true';
    } catch (e) {
      print('Error reading biometric setting: $e');
      return false;
    }
  }

  /// Enable or disable biometric authentication
  Future<void> setBiometricEnabled(bool enabled) async {
    try {
      await _secureStorage.write(
        key: _biometricEnabledKey,
        value: enabled.toString(),
      );
    } catch (e) {
      print('Error saving biometric setting: $e');
    }
  }

  /// Get a user-friendly description of available biometric types
  String getBiometricTypeDescription(List<BiometricType> types) {
    if (types.isEmpty) return 'None';
    
    final List<String> descriptions = [];
    if (types.contains(BiometricType.face)) descriptions.add('Face ID');
    if (types.contains(BiometricType.fingerprint)) descriptions.add('Fingerprint');
    if (types.contains(BiometricType.iris)) descriptions.add('Iris');
    if (types.contains(BiometricType.strong)) descriptions.add('Strong Biometric');
    if (types.contains(BiometricType.weak)) descriptions.add('Weak Biometric');
    
    return descriptions.join(', ');
  }
}
