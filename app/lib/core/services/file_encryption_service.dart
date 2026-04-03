import 'dart:io';
import 'dart:typed_data';
import 'package:encrypt/encrypt.dart' as encrypt;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

/// Service for encrypting and decrypting video files
/// Uses AES-256 encryption to protect cached videos
class FileEncryptionService {
  static final FileEncryptionService _instance = FileEncryptionService._internal();
  factory FileEncryptionService() => _instance;
  FileEncryptionService._internal();

  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  static const String _fileEncryptionKeyName = 'file_encryption_key';
  
  encrypt.Key? _encryptionKey;
  encrypt.IV? _iv;

  /// Initialize encryption keys for file encryption
  Future<void> initialize() async {
    try {
      // Get or create encryption key
      String? keyString = await _secureStorage.read(key: _fileEncryptionKeyName);
      
      if (keyString == null) {
        // Generate new key
        final key = encrypt.Key.fromSecureRandom(32); // 256-bit key
        keyString = key.base64;
        await _secureStorage.write(key: _fileEncryptionKeyName, value: keyString);
        _encryptionKey = key;
      } else {
        _encryptionKey = encrypt.Key.fromBase64(keyString);
      }

      // Generate IV (Initialization Vector)
      _iv = encrypt.IV.fromLength(16);
      
      print('File encryption initialized');
    } catch (e) {
      print('Error initializing file encryption: $e');
      rethrow;
    }
  }

  /// Encrypt a video file
  /// Returns the path to the encrypted file
  Future<String> encryptVideoFile(String sourcePath) async {
    if (_encryptionKey == null) {
      await initialize();
    }

    try {
      // Read the source file
      final File sourceFile = File(sourcePath);
      if (!await sourceFile.exists()) {
        throw Exception('Source file does not exist: $sourcePath');
      }

      final Uint8List fileBytes = await sourceFile.readAsBytes();
      
      // Encrypt the file data
      final encrypter = encrypt.Encrypter(encrypt.AES(_encryptionKey!));
      final encrypted = encrypter.encryptBytes(fileBytes, iv: _iv!);
      
      // Create encrypted file path
      final String encryptedPath = _getEncryptedFilePath(sourcePath);
      final File encryptedFile = File(encryptedPath);
      
      // Write encrypted data
      await encryptedFile.writeAsBytes(encrypted.bytes);
      
      // Delete original file for security
      await sourceFile.delete();
      
      print('File encrypted: $encryptedPath');
      return encryptedPath;
    } catch (e) {
      print('Error encrypting file: $e');
      rethrow;
    }
  }

  /// Decrypt a video file
  /// Returns the path to the decrypted file
  Future<String> decryptVideoFile(String encryptedPath) async {
    if (_encryptionKey == null) {
      await initialize();
    }

    try {
      // Read the encrypted file
      final File encryptedFile = File(encryptedPath);
      if (!await encryptedFile.exists()) {
        throw Exception('Encrypted file does not exist: $encryptedPath');
      }

      final Uint8List encryptedBytes = await encryptedFile.readAsBytes();
      
      // Decrypt the file data
      final encrypter = encrypt.Encrypter(encrypt.AES(_encryptionKey!));
      final encrypted = encrypt.Encrypted(encryptedBytes);
      final decrypted = encrypter.decryptBytes(encrypted, iv: _iv!);
      
      // Create decrypted file path
      final String decryptedPath = _getDecryptedFilePath(encryptedPath);
      final File decryptedFile = File(decryptedPath);
      
      // Write decrypted data
      await decryptedFile.writeAsBytes(decrypted);
      
      print('File decrypted: $decryptedPath');
      return decryptedPath;
    } catch (e) {
      print('Error decrypting file: $e');
      rethrow;
    }
  }

  /// Encrypt a file in place (overwrites original)
  Future<void> encryptFileInPlace(String filePath) async {
    final encryptedPath = await encryptVideoFile(filePath);
    // Rename encrypted file back to original name
    final File encryptedFile = File(encryptedPath);
    await encryptedFile.rename(filePath);
  }

  /// Decrypt a file temporarily for playback
  /// Returns path to temporary decrypted file
  Future<String> decryptForPlayback(String encryptedPath) async {
    return await decryptVideoFile(encryptedPath);
  }

  /// Delete temporary decrypted file after playback
  Future<void> cleanupDecryptedFile(String decryptedPath) async {
    try {
      final File file = File(decryptedPath);
      if (await file.exists()) {
        await file.delete();
        print('Cleaned up decrypted file: $decryptedPath');
      }
    } catch (e) {
      print('Error cleaning up decrypted file: $e');
    }
  }

  /// Check if a file is encrypted
  bool isEncryptedFile(String filePath) {
    return filePath.endsWith('.encrypted') || filePath.contains('.encrypted.');
  }

  /// Get encrypted file path from original path
  String _getEncryptedFilePath(String originalPath) {
    final String dir = path.dirname(originalPath);
    final String filename = path.basenameWithoutExtension(originalPath);
    final String ext = path.extension(originalPath);
    return path.join(dir, '$filename.encrypted$ext');
  }

  /// Get decrypted file path from encrypted path
  String _getDecryptedFilePath(String encryptedPath) {
    final String dir = path.dirname(encryptedPath);
    final String filename = path.basename(encryptedPath).replaceAll('.encrypted', '');
    return path.join(dir, 'temp_$filename');
  }

  /// Encrypt all video files in a directory
  Future<List<String>> encryptAllVideosInDirectory(String directoryPath) async {
    final List<String> encryptedPaths = [];
    
    try {
      final Directory dir = Directory(directoryPath);
      if (!await dir.exists()) {
        return encryptedPaths;
      }

      final List<FileSystemEntity> files = dir.listSync();
      
      for (final file in files) {
        if (file is File) {
          final String filePath = file.path;
          // Check if it's a video file and not already encrypted
          if (_isVideoFile(filePath) && !isEncryptedFile(filePath)) {
            try {
              final String encryptedPath = await encryptVideoFile(filePath);
              encryptedPaths.add(encryptedPath);
            } catch (e) {
              print('Error encrypting file $filePath: $e');
            }
          }
        }
      }
    } catch (e) {
      print('Error encrypting directory: $e');
    }

    return encryptedPaths;
  }

  /// Check if file is a video file
  bool _isVideoFile(String filePath) {
    final String ext = path.extension(filePath).toLowerCase();
    return ['.mp4', '.mov', '.avi', '.mkv', '.webm', '.flv'].contains(ext);
  }

  /// Get app's secure video directory
  Future<Directory> getSecureVideoDirectory() async {
    final Directory appDir = await getApplicationDocumentsDirectory();
    final Directory videoDir = Directory(path.join(appDir.path, 'secure_videos'));
    
    if (!await videoDir.exists()) {
      await videoDir.create(recursive: true);
    }
    
    return videoDir;
  }

  /// Move and encrypt a video file to secure directory
  Future<String> moveAndEncryptVideo(String sourcePath) async {
    try {
      final Directory secureDir = await getSecureVideoDirectory();
      final String filename = path.basename(sourcePath);
      final String targetPath = path.join(secureDir.path, filename);
      
      // Copy file to secure directory
      final File sourceFile = File(sourcePath);
      await sourceFile.copy(targetPath);
      
      // Encrypt the file
      final String encryptedPath = await encryptVideoFile(targetPath);
      
      // Delete original source file
      await sourceFile.delete();
      
      return encryptedPath;
    } catch (e) {
      print('Error moving and encrypting video: $e');
      rethrow;
    }
  }

  /// Get file size
  Future<int> getFileSize(String filePath) async {
    try {
      final File file = File(filePath);
      if (await file.exists()) {
        return await file.length();
      }
      return 0;
    } catch (e) {
      print('Error getting file size: $e');
      return 0;
    }
  }

  /// Delete encrypted file
  Future<void> deleteEncryptedFile(String filePath) async {
    try {
      final File file = File(filePath);
      if (await file.exists()) {
        await file.delete();
        print('Deleted encrypted file: $filePath');
      }
    } catch (e) {
      print('Error deleting encrypted file: $e');
    }
  }
}
