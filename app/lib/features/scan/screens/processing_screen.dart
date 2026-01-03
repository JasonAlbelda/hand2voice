import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hand2voice/features/scan/screens/result_screen.dart';
import 'package:hand2voice/features/settings/providers/settings_provider.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

import 'package:hand2voice/features/history/history_service.dart';

class ProcessingScreen extends StatefulWidget {
  final String videoPath;
  final bool isOnlineMode;

  const ProcessingScreen({
    Key? key,
    required this.videoPath,
    required this.isOnlineMode,
  }) : super(key: key);

  @override
  State<ProcessingScreen> createState() => _ProcessingScreenState();
}

class _ProcessingScreenState extends State<ProcessingScreen> {
  final Uuid _uuid = const Uuid();
  late String serverBaseUrl;

  static const methodChannel = MethodChannel('com.hand2voice/mediapipe');
  static const eventChannel = EventChannel('com.hand2voice/progress');

  String _statusMessage = "Initializing...";
  int _progressPercent = 0;
  String? _currentRequestId;

  // Keep the Client for better online cancellation
  http.Client _client = http.Client();

  StreamSubscription? _progressSubscription;
  bool _isCancelled = false;

  @override
  void initState() {
    super.initState();

    serverBaseUrl = Provider.of<SettingsProvider>(
      context,
      listen: false,
    ).serverUrl;
    _startProcessing();
  }

  Future<void> _startProcessing() async {
    dynamic results;

    // 1. Try Online
    if (widget.isOnlineMode) {
      try {
        results = await _extractOnline(widget.videoPath);
      } catch (e) {
        if (_isCancelled) return;
        print("⚠️ Online Error: $e");
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Falling back to Offline Mode..."),
              duration: Duration(seconds: 1),
            ),
          );
        }
      }
    }

    // 2. Offline Fallback
    if (results == null && !_isCancelled) {
      try {
        results = await _extractOffline(widget.videoPath);
      } catch (e) {
        if (!_isCancelled) _handleError("Processing Failed: $e");
        return;
      }
    }

    // 3. Save & Go
    if (results != null && !_isCancelled) {
      await _saveAndNavigate(results);
    }
  }

  // --- ONLINE LOGIC (Kept same) ---
  Future<dynamic> _extractOnline(String path) async {
    _currentRequestId = _uuid.v4();
    final uploadUrl = Uri.parse("$serverBaseUrl/process/$_currentRequestId");
    final statusUrl = Uri.parse("$serverBaseUrl/status/$_currentRequestId");

    setState(() => _statusMessage = "Uploading Video...");

    var request = http.MultipartRequest('POST', uploadUrl);
    request.files.add(await http.MultipartFile.fromPath('video', path));

    final streamedResponse = await _client
        .send(request)
        .timeout(const Duration(seconds: 300));
    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode != 202)
      throw Exception("Server returned ${response.statusCode}");

    if (mounted) setState(() => _statusMessage = "Extracting Features...");

    int attempts = 0;
    while (attempts < 60) {
      if (_isCancelled) throw Exception("Cancelled");
      await Future.delayed(const Duration(seconds: 1));

      try {
        final resp = await _client.get(statusUrl);
        if (resp.statusCode == 200) {
          final body = jsonDecode(resp.body);
          if (body['status'] == 'done') return body;
          if (body['status'] == 'failed') throw Exception(body['error']);
        }
      } catch (_) {}
      attempts++;
    }
    throw Exception("Timeout");
  }

  // --- REVERTED OFFLINE LOGIC ---
  Future<dynamic> _extractOffline(String path) async {
    setState(() {
      _statusMessage = "Processing on Device...";
      _progressPercent = 0;
    });

    _progressSubscription = eventChannel.receiveBroadcastStream().listen((
      event,
    ) {
      if (mounted) setState(() => _progressPercent = event);
    });

    try {
      // Direct Native call. Returns Map directly.
      // NOTE: This will crash if data > 1MB (TransactionTooLargeException)
      final dynamic result = await methodChannel.invokeMethod(
        'extractFeatures',
        {'videoPath': path},
      );
      return result;
    } finally {
      _progressSubscription?.cancel();
    }
  }

  Future<void> _saveAndNavigate(dynamic results) async {
    String mainLabel = "Unrecognized Sequence";
    if (results is Map && results['events'] != null) {
      List<dynamic> ev = results['events'];
      if (ev.isNotEmpty) {
        mainLabel = ev.map((e) => e['label']).toSet().take(3).join(", ");
      }
    }

    final record = TranslationRecord(
      id: _uuid.v4(),
      label: mainLabel,
      videoPath: widget.videoPath,
      timestamp: DateTime.now(),
      rawEvents: results,
    );
    await HistoryService.addRecord(record);

    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) =>
              ResultScreen(videoPath: widget.videoPath, extractedData: results),
        ),
      );
    }
  }

  Future<void> _cancelProcessing() async {
    _isCancelled = true;
    setState(() => _statusMessage = "Cancelling...");

    _client.close();
    await methodChannel.invokeMethod('cancelExtraction');
    _progressSubscription?.cancel();

    if (_currentRequestId != null) {
      try {
        http.post(Uri.parse("$serverBaseUrl/cancel/$_currentRequestId"));
      } catch (_) {}
    }

    if (mounted) Navigator.pop(context);
  }

  void _handleError(String msg) {
    if (mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(msg), backgroundColor: Colors.red));
      Navigator.pop(context);
    }
  }

  @override
  void dispose() {
    _client.close();
    _progressSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(),
              const SizedBox(height: 20),
              Text(
                _statusMessage,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              if (_progressPercent > 0) ...[
                LinearProgressIndicator(value: _progressPercent / 100.0),
                Text("$_progressPercent%"),
              ],
              const SizedBox(height: 30),
              ElevatedButton.icon(
                onPressed: _cancelProcessing,
                icon: const Icon(Icons.cancel),
                label: const Text("Cancel"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
