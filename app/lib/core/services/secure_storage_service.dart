import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:crypto/crypto.dart';
import 'dart:typed_data';
import 'package:encrypt/encrypt.dart' as encrypt;

/// Secure encrypted storage service for sensitive user data
/// Uses AES-256 encryption with device-specific keys
class SecureStorageService {
  static final SecureStorageService _instance = SecureStorageService._internal();
  factory SecureStorageService() => _instance;
  SecureStorageService._internal();

  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage(
    aOptions: AndroidOptions(
      encryptedSharedPreferences: true,
    ),
    iOptions: IOSOptions(
      accessibility: KeychainAccessibility.first_unlock,
    ),
  );

  static const String _encryptionKeyName = 'app_encryption_key';
  encrypt.Key? _encryptionKey;
  encrypt.IV? _iv;

  /// Initialize encryption keys
  Future<void> initialize() async {
    try {
      // Get or create encryption key
      String? keyString = await _secureStorage.read(key: _encryptionKeyName);
      
      if (keyString == null) {
        // Generate new key
        final key = encrypt.Key.fromSecureRandom(32); // 256-bit key
        keyString = base64Encode(key.bytes);
        await _secureStorage.write(key: _encryptionKeyName, value: keyString);
        _encryptionKey = key;
      } else {
        _encryptionKey = encrypt.Key(base64Decode(keyString));
      }

      // Generate IV (Initialization Vector)
      _iv = encrypt.IV.fromLength(16);
    } catch (e) {
      print('Error initializing encryption: $e');
      rethrow;
    }
  }

  /// Encrypt data using AES-256
  String _encrypt(String plainText) {
    if (_encryptionKey == null) {
      throw Exception('Encryption key not initialized. Call initialize() first.');
    }

    final encrypter = encrypt.Encrypter(encrypt.AES(_encryptionKey!));
    final encrypted = encrypter.encrypt(plainText, iv: _iv!);
    return encrypted.base64;
  }

  /// Decrypt data
  String _decrypt(String encryptedText) {
    if (_encryptionKey == null) {
      throw Exception('Encryption key not initialized. Call initialize() first.');
    }

    final encrypter = encrypt.Encrypter(encrypt.AES(_encryptionKey!));
    final decrypted = encrypter.decrypt64(encryptedText, iv: _iv!);
    return decrypted;
  }

  /// Write encrypted string
  Future<void> writeString(String key, String value) async {
    try {
      final encrypted = _encrypt(value);
      await _secureStorage.write(key: key, value: encrypted);
    } catch (e) {
      print('Error writing encrypted string: $e');
      rethrow;
    }
  }

  /// Read encrypted string
  Future<String?> readString(String key) async {
    try {
      final encrypted = await _secureStorage.read(key: key);
      if (encrypted == null) return null;
      return _decrypt(encrypted);
    } catch (e) {
      print('Error reading encrypted string: $e');
      return null;
    }
  }

  /// Write encrypted boolean
  Future<void> writeBool(String key, bool value) async {
    await writeString(key, value.toString());
  }

  /// Read encrypted boolean
  Future<bool?> readBool(String key) async {
    final value = await readString(key);
    if (value == null) return null;
    return value.toLowerCase() == 'true';
  }

  /// Write encrypted integer
  Future<void> writeInt(String key, int value) async {
    await writeString(key, value.toString());
  }

  /// Read encrypted integer
  Future<int?> readInt(String key) async {
    final value = await readString(key);
    if (value == null) return null;
    return int.tryParse(value);
  }

  /// Write encrypted double
  Future<void> writeDouble(String key, double value) async {
    await writeString(key, value.toString());
  }

  /// Read encrypted double
  Future<double?> readDouble(String key) async {
    final value = await readString(key);
    if (value == null) return null;
    return double.tryParse(value);
  }

  /// Write encrypted JSON object
  Future<void> writeJson(String key, Map<String, dynamic> json) async {
    final jsonString = jsonEncode(json);
    await writeString(key, jsonString);
  }

  /// Read encrypted JSON object
  Future<Map<String, dynamic>?> readJson(String key) async {
    final jsonString = await readString(key);
    if (jsonString == null) return null;
    try {
      return jsonDecode(jsonString) as Map<String, dynamic>;
    } catch (e) {
      print('Error parsing JSON: $e');
      return null;
    }
  }

  /// Write encrypted list of strings
  Future<void> writeStringList(String key, List<String> values) async {
    final jsonString = jsonEncode(values);
    await writeString(key, jsonString);
  }

  /// Read encrypted list of strings
  Future<List<String>?> readStringList(String key) async {
    final jsonString = await readString(key);
    if (jsonString == null) return null;
    try {
      final List<dynamic> decoded = jsonDecode(jsonString);
      return decoded.map((e) => e.toString()).toList();
    } catch (e) {
      print('Error parsing string list: $e');
      return null;
    }
  }

  /// Delete a key
  Future<void> delete(String key) async {
    try {
      await _secureStorage.delete(key: key);
    } catch (e) {
      print('Error deleting key: $e');
    }
  }

  /// Delete all keys
  Future<void> deleteAll() async {
    try {
      await _secureStorage.deleteAll();
      // Reinitialize encryption key after deletion
      await initialize();
    } catch (e) {
      print('Error deleting all keys: $e');
    }
  }

  /// Check if key exists
  Future<bool> containsKey(String key) async {
    try {
      final value = await _secureStorage.read(key: key);
      return value != null;
    } catch (e) {
      print('Error checking key existence: $e');
      return false;
    }
  }

  /// Get all keys
  Future<Map<String, String>> readAll() async {
    try {
      return await _secureStorage.readAll();
    } catch (e) {
      print('Error reading all keys: $e');
      return {};
    }
  }

  /// Hash sensitive data (one-way, for verification only)
  String hashData(String data) {
    final bytes = utf8.encode(data);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }
}
