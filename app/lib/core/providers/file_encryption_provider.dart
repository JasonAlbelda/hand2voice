import 'package:flutter/material.dart';
import 'package:hand2voice/core/services/file_encryption_service.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Provider for managing file encryption settings
class FileEncryptionProvider extends ChangeNotifier {
  final FileEncryptionService _fileEncryptionService = FileEncryptionService();
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  
  static const String _fileEncryptionEnabledKey = 'file_encryption_enabled';
  
  bool _isFileEncryptionEnabled = false;
  bool _isLoading = false;
  int _encryptedFilesCount = 0;

  bool get isFileEncryptionEnabled => _isFileEncryptionEnabled;
  bool get isLoading => _isLoading;
  int get encryptedFilesCount => _encryptedFilesCount;

  /// Initialize file encryption settings
  Future<void> initialize() async {
    _isLoading = true;
    notifyListeners();

    try {
      await _fileEncryptionService.initialize();
      
      // Load saved preference
      final String? value = await _secureStorage.read(key: _fileEncryptionEnabledKey);
      _isFileEncryptionEnabled = value == 'true';
    } catch (e) {
      print('Error initializing file encryption: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  /// Toggle file encryption on/off
  Future<void> toggleFileEncryption(bool enabled) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _secureStorage.write(
        key: _fileEncryptionEnabledKey,
        value: enabled.toString(),
      );
      _isFileEncryptionEnabled = enabled;
      
      // If enabling, encrypt existing videos
      if (enabled) {
        await _encryptExistingVideos();
      }
    } catch (e) {
      print('Error toggling file encryption: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  /// Encrypt existing videos in the app directory
  Future<void> _encryptExistingVideos() async {
    try {
      final secureDir = await _fileEncryptionService.getSecureVideoDirectory();
      final encryptedPaths = await _fileEncryptionService.encryptAllVideosInDirectory(secureDir.path);
      _encryptedFilesCount = encryptedPaths.length;
      notifyListeners();
    } catch (e) {
      print('Error encrypting existing videos: $e');
    }
  }

  /// Encrypt a video file
  Future<String?> encryptVideo(String videoPath) async {
    if (!_isFileEncryptionEnabled) {
      return videoPath; // Return original path if encryption is disabled
    }

    try {
      final String encryptedPath = await _fileEncryptionService.moveAndEncryptVideo(videoPath);
      _encryptedFilesCount++;
      notifyListeners();
      return encryptedPath;
    } catch (e) {
      print('Error encrypting video: $e');
      return null;
    }
  }

  /// Decrypt a video file for playback
  Future<String?> decryptVideoForPlayback(String encryptedPath) async {
    try {
      return await _fileEncryptionService.decryptForPlayback(encryptedPath);
    } catch (e) {
      print('Error decrypting video: $e');
      return null;
    }
  }

  /// Cleanup temporary decrypted file
  Future<void> cleanupDecryptedFile(String filePath) async {
    try {
      await _fileEncryptionService.cleanupDecryptedFile(filePath);
    } catch (e) {
      print('Error cleaning up file: $e');
    }
  }

  /// Check if a file is encrypted
  bool isEncrypted(String filePath) {
    return _fileEncryptionService.isEncryptedFile(filePath);
  }

  /// Delete encrypted file
  Future<void> deleteEncryptedFile(String filePath) async {
    try {
      await _fileEncryptionService.deleteEncryptedFile(filePath);
      if (_encryptedFilesCount > 0) {
        _encryptedFilesCount--;
        notifyListeners();
      }
    } catch (e) {
      print('Error deleting encrypted file: $e');
    }
  }
}
