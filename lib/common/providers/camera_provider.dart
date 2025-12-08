import 'dart:async';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CameraProvider with ChangeNotifier {
  static const String _flashEnabledKey = 'isFlashEnabled';
  static const String _lensDirectionKey = 'isFrontCamera';

  bool _isFlashEnabled = false;
  CameraLensDirection _lensDirection = CameraLensDirection.back;

  final Completer<void> _initCompleter = Completer<void>();

  bool get isFlashEnabled => _isFlashEnabled;
  CameraLensDirection get lensDirection => _lensDirection;
  Future<void> get initializationComplete => _initCompleter.future;

  CameraProvider() {
    _loadAllPreferences();
  }

  Future<void> _loadAllPreferences() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      _isFlashEnabled = prefs.getBool(_flashEnabledKey) ?? false;

      final isFrontCamera = prefs.getBool(_lensDirectionKey) ?? false;
      _lensDirection = isFrontCamera
          ? CameraLensDirection.front
          : CameraLensDirection.back;
    } catch (e) {
      print("Error loading camera preferences: $e");
      _isFlashEnabled = false;
      _lensDirection = CameraLensDirection.back;
    } finally {
      if (!_initCompleter.isCompleted) {
        _initCompleter.complete();
      }
      notifyListeners();
    }
  }

  Future<void> toggleFlash() async {
    _isFlashEnabled = !_isFlashEnabled;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_flashEnabledKey, _isFlashEnabled);
    notifyListeners();
  }

  Future<void> setFlashMode(bool flashMode) async {
    _isFlashEnabled = flashMode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_flashEnabledKey, _isFlashEnabled);
    notifyListeners();
  }

  Future<void> toggleCameraLens() async {
    _lensDirection = _lensDirection == CameraLensDirection.back
        ? CameraLensDirection.front
        : CameraLensDirection.back;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(
      _lensDirectionKey,
      _lensDirection == CameraLensDirection.front,
    );
    notifyListeners();
  }
}
