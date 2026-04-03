import 'package:shared_preferences/shared_preferences.dart';
import 'package:hand2voice/core/services/secure_storage_service.dart';

/// Service to migrate data from SharedPreferences to encrypted storage
class StorageMigrationService {
  static final SecureStorageService _secureStorage = SecureStorageService();
  static const String _migrationCompleteKey = 'storage_migration_complete';

  /// Check if migration has been completed
  static Future<bool> isMigrationComplete() async {
    try {
      await _secureStorage.initialize();
      final result = await _secureStorage.readBool(_migrationCompleteKey);
      return result ?? false;
    } catch (e) {
      print('Error checking migration status: $e');
      return false;
    }
  }

  /// Migrate all data from SharedPreferences to encrypted storage
  static Future<void> migrateToEncryptedStorage() async {
    try {
      // Check if already migrated
      if (await isMigrationComplete()) {
        print('Migration already completed');
        return;
      }

      await _secureStorage.initialize();
      final prefs = await SharedPreferences.getInstance();

      print('Starting migration to encrypted storage...');

      // Migrate settings
      await _migrateSettings(prefs);

      // Migrate camera preferences
      await _migrateCameraPreferences(prefs);

      // Migrate history
      await _migrateHistory(prefs);

      // Mark migration as complete
      await _secureStorage.writeBool(_migrationCompleteKey, true);

      print('Migration completed successfully');
    } catch (e) {
      print('Error during migration: $e');
      rethrow;
    }
  }

  /// Migrate settings data
  static Future<void> _migrateSettings(SharedPreferences prefs) async {
    try {
      // Migrate online mode
      final isOnlineMode = prefs.getBool('is_online_mode');
      if (isOnlineMode != null) {
        await _secureStorage.writeBool('is_online_mode', isOnlineMode);
        print('Migrated: is_online_mode = $isOnlineMode');
      }

      // Migrate server URL
      final serverUrl = prefs.getString('server_url');
      if (serverUrl != null) {
        await _secureStorage.writeString('server_url', serverUrl);
        print('Migrated: server_url = $serverUrl');
      }
    } catch (e) {
      print('Error migrating settings: $e');
    }
  }

  /// Migrate camera preferences
  static Future<void> _migrateCameraPreferences(SharedPreferences prefs) async {
    try {
      // Migrate flash enabled
      final isFlashEnabled = prefs.getBool('isFlashEnabled');
      if (isFlashEnabled != null) {
        await _secureStorage.writeBool('camera_flash_enabled', isFlashEnabled);
        print('Migrated: camera_flash_enabled = $isFlashEnabled');
      }

      // Migrate lens direction
      final isFrontCamera = prefs.getBool('isFrontCamera');
      if (isFrontCamera != null) {
        await _secureStorage.writeBool('camera_is_front', isFrontCamera);
        print('Migrated: camera_is_front = $isFrontCamera');
      }
    } catch (e) {
      print('Error migrating camera preferences: $e');
    }
  }

  /// Migrate translation history
  static Future<void> _migrateHistory(SharedPreferences prefs) async {
    try {
      final history = prefs.getStringList('translation_history');
      if (history != null && history.isNotEmpty) {
        await _secureStorage.writeStringList('encrypted_translation_history', history);
        print('Migrated: translation_history (${history.length} records)');
      }
    } catch (e) {
      print('Error migrating history: $e');
    }
  }

  /// Clear old SharedPreferences data after successful migration
  static Future<void> clearOldData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Remove old keys
      await prefs.remove('is_online_mode');
      await prefs.remove('server_url');
      await prefs.remove('isFlashEnabled');
      await prefs.remove('isFrontCamera');
      await prefs.remove('translation_history');
      
      print('Cleared old SharedPreferences data');
    } catch (e) {
      print('Error clearing old data: $e');
    }
  }

  /// Force re-migration (for testing or recovery)
  static Future<void> resetMigration() async {
    try {
      await _secureStorage.initialize();
      await _secureStorage.delete(_migrationCompleteKey);
      print('Migration reset - will run again on next app start');
    } catch (e) {
      print('Error resetting migration: $e');
    }
  }

  /// Get migration status details
  static Future<Map<String, dynamic>> getMigrationStatus() async {
    try {
      await _secureStorage.initialize();
      final prefs = await SharedPreferences.getInstance();
      
      return {
        'migration_complete': await isMigrationComplete(),
        'old_data_exists': prefs.getKeys().isNotEmpty,
        'old_keys': prefs.getKeys().toList(),
        'encrypted_keys_count': (await _secureStorage.readAll()).length,
      };
    } catch (e) {
      print('Error getting migration status: $e');
      return {
        'error': e.toString(),
      };
    }
  }
}
