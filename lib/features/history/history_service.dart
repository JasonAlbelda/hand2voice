import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class TranslationRecord {
  final String id;
  final String label; // The main predicted text (e.g., "Hello")
  final String videoPath;
  final DateTime timestamp;
  final List<dynamic> rawEvents; // To restore the ResultScreen details

  TranslationRecord({
    required this.id,
    required this.label,
    required this.videoPath,
    required this.timestamp,
    required this.rawEvents,
  });

  // Convert to JSON
  Map<String, dynamic> toJson() => {
    'id': id,
    'label': label,
    'videoPath': videoPath,
    'timestamp': timestamp.toIso8601String(),
    'rawEvents': rawEvents,
  };

  // Create from JSON
  factory TranslationRecord.fromJson(Map<String, dynamic> json) {
    return TranslationRecord(
      id: json['id'],
      label: json['label'],
      videoPath: json['videoPath'],
      timestamp: DateTime.parse(json['timestamp']),
      rawEvents: json['rawEvents'] ?? [],
    );
  }
}

class HistoryService {
  static const String _key = 'translation_history';

  // Save a new record
  static Future<void> addRecord(TranslationRecord record) async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> history = prefs.getStringList(_key) ?? [];

    // Add new record to top of list
    history.insert(0, jsonEncode(record.toJson()));

    await prefs.setStringList(_key, history);
  }

  // Get all records
  static Future<List<TranslationRecord>> getHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> history = prefs.getStringList(_key) ?? [];

    return history
        .map((item) => TranslationRecord.fromJson(jsonDecode(item)))
        .toList();
  }

  // Clear history
  static Future<void> clearHistory() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }
}
