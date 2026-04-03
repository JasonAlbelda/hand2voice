/// Example usage of SecureStorageService
/// This file demonstrates how to use encrypted storage in your app

import 'package:hand2voice/core/services/secure_storage_service.dart';

class EncryptedStorageExample {
  final SecureStorageService _storage = SecureStorageService();

  /// Initialize storage (call once at app start)
  Future<void> initialize() async {
    await _storage.initialize();
    print('Encrypted storage initialized');
  }

  /// Example 1: Store and retrieve a string
  Future<void> exampleString() async {
    // Write
    await _storage.writeString('user_name', 'John Doe');
    
    // Read
    String? name = await _storage.readString('user_name');
    print('User name: $name');
  }

  /// Example 2: Store and retrieve a boolean
  Future<void> exampleBoolean() async {
    // Write
    await _storage.writeBool('is_premium', true);
    
    // Read
    bool? isPremium = await _storage.readBool('is_premium');
    print('Is premium: $isPremium');
  }

  /// Example 3: Store and retrieve an integer
  Future<void> exampleInteger() async {
    // Write
    await _storage.writeInt('login_count', 42);
    
    // Read
    int? count = await _storage.readInt('login_count');
    print('Login count: $count');
  }

  /// Example 4: Store and retrieve JSON
  Future<void> exampleJson() async {
    // Write
    await _storage.writeJson('user_profile', {
      'name': 'John Doe',
      'age': 30,
      'email': 'john@example.com',
      'preferences': {
        'theme': 'dark',
        'notifications': true,
      }
    });
    
    // Read
    Map<String, dynamic>? profile = await _storage.readJson('user_profile');
    print('User profile: $profile');
  }

  /// Example 5: Store and retrieve a list
  Future<void> exampleList() async {
    // Write
    await _storage.writeStringList('favorite_signs', [
      'Hello',
      'Thank you',
      'Good morning',
    ]);
    
    // Read
    List<String>? favorites = await _storage.readStringList('favorite_signs');
    print('Favorites: $favorites');
  }

  /// Example 6: Check if key exists
  Future<void> exampleExists() async {
    bool exists = await _storage.containsKey('user_name');
    print('User name exists: $exists');
  }

  /// Example 7: Delete a key
  Future<void> exampleDelete() async {
    await _storage.delete('user_name');
    print('User name deleted');
  }

  /// Example 8: Hash sensitive data
  void exampleHash() {
    String password = 'mySecretPassword123';
    String hashed = _storage.hashData(password);
    print('Hashed password: $hashed');
    
    // Use for verification (one-way, cannot decrypt)
    String inputPassword = 'mySecretPassword123';
    bool matches = _storage.hashData(inputPassword) == hashed;
    print('Password matches: $matches');
  }

  /// Example 9: Store user settings
  Future<void> exampleUserSettings() async {
    // Store multiple settings
    await _storage.writeBool('dark_mode', true);
    await _storage.writeString('language', 'en');
    await _storage.writeInt('font_size', 16);
    await _storage.writeBool('notifications_enabled', true);
    
    // Read settings
    bool? darkMode = await _storage.readBool('dark_mode');
    String? language = await _storage.readString('language');
    int? fontSize = await _storage.readInt('font_size');
    bool? notifications = await _storage.readBool('notifications_enabled');
    
    print('Settings loaded:');
    print('  Dark mode: $darkMode');
    print('  Language: $language');
    print('  Font size: $fontSize');
    print('  Notifications: $notifications');
  }

  /// Example 10: Store API credentials (SECURE)
  Future<void> exampleApiCredentials() async {
    // Store API key securely
    await _storage.writeString('api_key', 'sk_live_abc123xyz789');
    await _storage.writeString('api_secret', 'secret_key_here');
    
    // Retrieve when needed
    String? apiKey = await _storage.readString('api_key');
    String? apiSecret = await _storage.readString('api_secret');
    
    // Use in API calls
    print('Making API call with key: ${apiKey?.substring(0, 10)}...');
  }

  /// Example 11: Store complex user data
  Future<void> exampleComplexData() async {
    // Store user profile with nested data
    await _storage.writeJson('user_data', {
      'id': '12345',
      'profile': {
        'name': 'John Doe',
        'email': 'john@example.com',
        'avatar': 'https://example.com/avatar.jpg',
      },
      'settings': {
        'theme': 'dark',
        'language': 'en',
        'notifications': {
          'email': true,
          'push': false,
          'sms': false,
        }
      },
      'stats': {
        'signs_learned': 150,
        'practice_time': 3600,
        'streak_days': 7,
      }
    });
    
    // Read and use
    Map<String, dynamic>? userData = await _storage.readJson('user_data');
    if (userData != null) {
      print('User: ${userData['profile']['name']}');
      print('Signs learned: ${userData['stats']['signs_learned']}');
    }
  }

  /// Example 12: Secure session management
  Future<void> exampleSession() async {
    // Store session token
    await _storage.writeString('session_token', 'eyJhbGciOiJIUzI1NiIs...');
    await _storage.writeInt('session_expires', DateTime.now().add(Duration(hours: 24)).millisecondsSinceEpoch);
    
    // Check if session is valid
    int? expiresAt = await _storage.readInt('session_expires');
    if (expiresAt != null) {
      bool isValid = DateTime.now().millisecondsSinceEpoch < expiresAt;
      print('Session valid: $isValid');
      
      if (!isValid) {
        // Clear expired session
        await _storage.delete('session_token');
        await _storage.delete('session_expires');
        print('Session cleared');
      }
    }
  }

  /// Example 13: Backup and restore
  Future<void> exampleBackup() async {
    // Get all data for backup
    Map<String, String> allData = await _storage.readAll();
    print('Backup created with ${allData.length} keys');
    
    // In a real app, you would:
    // 1. Convert to JSON
    // 2. Optionally compress
    // 3. Save to file or cloud
    // 4. Encrypt the backup file itself
  }

  /// Example 14: Clear all data (logout)
  Future<void> exampleLogout() async {
    // Clear all encrypted data
    await _storage.deleteAll();
    print('All data cleared - user logged out');
    
    // Note: This will also regenerate encryption keys
    // You'll need to re-initialize after this
    await _storage.initialize();
  }

  /// Example 15: Migration from old storage
  Future<void> exampleMigration() async {
    // Simulate old data
    Map<String, dynamic> oldData = {
      'username': 'john_doe',
      'email': 'john@example.com',
      'settings': {'theme': 'dark'},
    };
    
    // Migrate to encrypted storage
    for (var entry in oldData.entries) {
      if (entry.value is String) {
        await _storage.writeString(entry.key, entry.value);
      } else if (entry.value is Map) {
        await _storage.writeJson(entry.key, entry.value);
      }
    }
    
    print('Migration completed');
  }

  /// Run all examples
  Future<void> runAllExamples() async {
    print('=== Encrypted Storage Examples ===\n');
    
    await initialize();
    
    print('\n1. String Example:');
    await exampleString();
    
    print('\n2. Boolean Example:');
    await exampleBoolean();
    
    print('\n3. Integer Example:');
    await exampleInteger();
    
    print('\n4. JSON Example:');
    await exampleJson();
    
    print('\n5. List Example:');
    await exampleList();
    
    print('\n6. Exists Example:');
    await exampleExists();
    
    print('\n7. Delete Example:');
    await exampleDelete();
    
    print('\n8. Hash Example:');
    exampleHash();
    
    print('\n9. User Settings Example:');
    await exampleUserSettings();
    
    print('\n10. API Credentials Example:');
    await exampleApiCredentials();
    
    print('\n11. Complex Data Example:');
    await exampleComplexData();
    
    print('\n12. Session Management Example:');
    await exampleSession();
    
    print('\n=== All Examples Completed ===');
  }
}

/// Usage in your app:
/// 
/// ```dart
/// // In main.dart or initialization
/// final storage = SecureStorageService();
/// await storage.initialize();
/// 
/// // Store data
/// await storage.writeString('key', 'value');
/// 
/// // Read data
/// String? value = await storage.readString('key');
/// ```
