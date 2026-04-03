import 'dart:async';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:hand2voice/core/services/secure_storage_service.dart';

/// Secure camera provider using encrypted storage
class SecureCameraProvider with ChangeNotifier {
  final SecureStorageService _secureStorage = SecureStorageService();
  
  static const String _flashEnabledKey = 'camera_flash_enabled';
  static const String _lensDirectionKey = 'camera_is_front';

  bool _isFlashEnabled = false;
  CameraLensDirection _lensDirection = CameraLensDirection.back;
  bool _isInitialized = false;

  final Completer<void> _initCompleter = Completer<void>();

  bool get isFlashEnabled => _isFlashEnabled;
  CameraLensDirection get lensDirection => _lensDirection;
  Future<void> get initializationComplete => _initCompleter.future;
  bool get isInitialized => _isInitialized;

  SecureCameraProvider() {
    _loadAllPreferences();
  }

  Future<void> _loadAllPreferences() async {
    try {
      await _secureStorage.initialize();
      
      _isFlashEnabled = await _secureStorage.readBool(_flashEnabledKey) ?? false;

      final isFrontCamera = await _secureStorage.readBool(_lensDirectionKey) ?? false;
      _lensDirection = isFrontCamera
          ? CameraLensDirection.front
          : CameraLensDirection.back;
      
      _isInitialized = true;
    } catch (e) {
      print("Error loading camera preferences: $e");
      _isFlashEnabled = false;
      _lensDirection = CameraLensDirection.back;
      _isInitialized = true;
    } finally {
      if (!_initCompleter.isCompleted) {
        _initCompleter.complete();
      }
      notifyListeners();
    }
  }

  Future<void> toggleFlash() async {
    _isFlashEnabled = !_isFlashEnabled;
    await _secureStorage.writeBool(_flashEnabledKey, _isFlashEnabled);
    notifyListeners();
  }

  Future<void> setFlashMode(bool flashMode) async {
    _isFlashEnabled = flashMode;
    await _secureStorage.writeBool(_flashEnabledKey, _isFlashEnabled);
    notifyListeners();
  }

  Future<void> toggleCameraLens() async {
    _lensDirection = _lensDirection == CameraLensDirection.back
        ? CameraLensDirection.front
        : CameraLensDirection.back;
    await _secureStorage.writeBool(
      _lensDirectionKey,
      _lensDirection == CameraLensDirection.front,
    );
    notifyListeners();
  }

  /// Clear all camera preferences
  Future<void> clearPreferences() async {
    await _secureStorage.delete(_flashEnabledKey);
    await _secureStorage.delete(_lensDirectionKey);
    _isFlashEnabled = false;
    _lensDirection = CameraLensDirection.back;
    notifyListeners();
  }
}
