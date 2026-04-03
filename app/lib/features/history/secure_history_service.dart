import 'dart:convert';
import 'package:hand2voice/core/services/secure_storage_service.dart';

class TranslationRecord {
  final String id;
  final String label;
  final String videoPath;
  final DateTime timestamp;
  final dynamic rawEvents;

  TranslationRecord({
    required this.id,
    required this.label,
    required this.videoPath,
    required this.timestamp,
    required this.rawEvents,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'label': label,
    'videoPath': videoPath,
    'timestamp': timestamp.toIso8601String(),
    'rawEvents': rawEvents,
  };

  factory TranslationRecord.fromJson(Map<String, dynamic> json) {
    return TranslationRecord(
      id: json['id'],
      label: json['label'],
      videoPath: json['videoPath'],
      timestamp: DateTime.parse(json['timestamp']),
      rawEvents: json['rawEvents'],
    );
  }
}

/// Secure history service using encrypted storage
class SecureHistoryService {
  static final SecureStorageService _secureStorage = SecureStorageService();
  static const String _key = 'encrypted_translation_history';
  static bool _isInitialized = false;

  /// Initialize the service
  static Future<void> initialize() async {
    if (!_isInitialized) {
      await _secureStorage.initialize();
      _isInitialized = true;
    }
  }

  /// Save a new encrypted record
  static Future<void> addRecord(TranslationRecord record) async {
    await initialize();
    
    try {
      final List<String> history = await _secureStorage.readStringList(_key) ?? [];
      
      // Add new record to top of list
      history.insert(0, jsonEncode(record.toJson()));
      
      // Limit history to 100 records to prevent excessive storage
      if (history.length > 100) {
        history.removeRange(100, history.length);
      }
      
      await _secureStorage.writeStringList(_key, history);
    } catch (e) {
      print('Error adding encrypted record: $e');
      rethrow;
    }
  }

  /// Get all encrypted records
  static Future<List<TranslationRecord>> getHistory() async {
    await initialize();
    
    try {
      final List<String>? history = await _secureStorage.readStringList(_key);
      
      if (history == null || history.isEmpty) {
        return [];
      }
      
      return history
          .map((item) {
            try {
              return TranslationRecord.fromJson(jsonDecode(item));
            } catch (e) {
              print('Error parsing record: $e');
              return null;
            }
          })
          .whereType<TranslationRecord>()
          .toList();
    } catch (e) {
      print('Error getting encrypted history: $e');
      return [];
    }
  }

  /// Clear all encrypted history
  static Future<void> clearHistory() async {
    await initialize();
    
    try {
      await _secureStorage.delete(_key);
    } catch (e) {
      print('Error clearing encrypted history: $e');
    }
  }

  /// Delete a specific record by ID
  static Future<void> deleteRecord(String id) async {
    await initialize();
    
    try {
      final List<String> history = await _secureStorage.readStringList(_key) ?? [];
      
      history.removeWhere((item) {
        try {
          final record = TranslationRecord.fromJson(jsonDecode(item));
          return record.id == id;
        } catch (e) {
          return false;
        }
      });
      
      await _secureStorage.writeStringList(_key, history);
    } catch (e) {
      print('Error deleting encrypted record: $e');
    }
  }

  /// Get history count
  static Future<int> getHistoryCount() async {
    await initialize();
    
    try {
      final List<String>? history = await _secureStorage.readStringList(_key);
      return history?.length ?? 0;
    } catch (e) {
      print('Error getting history count: $e');
      return 0;
    }
  }

  /// Search history by label
  static Future<List<TranslationRecord>> searchHistory(String query) async {
    await initialize();
    
    try {
      final allHistory = await getHistory();
      final lowerQuery = query.toLowerCase();
      
      return allHistory.where((record) {
        return record.label.toLowerCase().contains(lowerQuery);
      }).toList();
    } catch (e) {
      print('Error searching history: $e');
      return [];
    }
  }

  /// Export history as JSON (for backup)
  static Future<String> exportHistory() async {
    await initialize();
    
    try {
      final history = await getHistory();
      final jsonList = history.map((record) => record.toJson()).toList();
      return jsonEncode(jsonList);
    } catch (e) {
      print('Error exporting history: $e');
      return '[]';
    }
  }

  /// Import history from JSON (for restore)
  static Future<void> importHistory(String jsonString) async {
    await initialize();
    
    try {
      final List<dynamic> jsonList = jsonDecode(jsonString);
      final records = jsonList
          .map((json) => TranslationRecord.fromJson(json))
          .toList();
      
      // Clear existing history
      await clearHistory();
      
      // Add all imported records
      for (final record in records) {
        await addRecord(record);
      }
    } catch (e) {
      print('Error importing history: $e');
      rethrow;
    }
  }
}
