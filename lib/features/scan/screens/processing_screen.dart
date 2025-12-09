import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hand2voice/features/scan/screens/result_screen.dart';
import 'package:http/http.dart' as http;
import 'package:uuid/uuid.dart';

import 'package:hand2voice/features/history/history_service.dart';

class ProcessingScreen extends StatefulWidget {
  final String videoPath;
  final bool isOnlineMode;

  const ProcessingScreen({
    Key? key,
    required this.videoPath,
    this.isOnlineMode = true,
  }) : super(key: key);

  @override
  State<ProcessingScreen> createState() => _ProcessingScreenState();
}

class _ProcessingScreenState extends State<ProcessingScreen> {
  // === CONFIG ===
  final Uuid _uuid = const Uuid();
  // Ensure this IP is correct for your network
  final String serverBaseUrl = "http://192.168.1.2:5000";

  static const methodChannel = MethodChannel('com.hand2voice/mediapipe');
  static const eventChannel = EventChannel('com.hand2voice/progress');

  // === STATE ===
  String _statusMessage = "Initializing...";
  int _progressPercent = 0;
  String? _currentRequestId;

  // Create a Client to manage the connection life-cycle.
  // Calling .close() on this makes cancellation immediate.
  http.Client? _client;

  StreamSubscription? _progressSubscription;
  bool _isCancelled = false;

  @override
  void initState() {
    super.initState();
    _startProcessing();
  }

  Future<void> _startProcessing() async {
    dynamic results;
    _client = http.Client(); // Initialize client

    // 1. Try Online Mode
    if (widget.isOnlineMode) {
      try {
        results = await _extractOnline(widget.videoPath);
      } catch (e) {
        if (_isCancelled) return; // Stop if user cancelled

        print("⚠️ Online failed: $e");
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Server offline. Switching to On-Device mode..."),
              duration: Duration(seconds: 2),
            ),
          );
        }
      }
    }

    // 2. Offline Fallback
    // Run if results are missing AND user hasn't cancelled
    if (results == null && !_isCancelled) {
      try {
        results = await _extractOffline(widget.videoPath);
      } catch (e) {
        if (!e.toString().contains("CANCELLED") && !_isCancelled) {
          _handleError("Processing Failed: $e");
        }
        return;
      }
    }

    // 3. Success -> Save & Navigate
    if (results != null && !_isCancelled) {
      await _saveAndNavigate(results);
    }
  }

  // --- ONLINE LOGIC ---
  Future<dynamic> _extractOnline(String path) async {
    _currentRequestId = _uuid.v4();
    final uploadUrl = Uri.parse("$serverBaseUrl/process/$_currentRequestId");
    final statusUrl = Uri.parse("$serverBaseUrl/status/$_currentRequestId");

    // A. ESTABLISH CONNECTION (PING)
    if (_isCancelled) throw Exception("Cancelled");
    setState(() => _statusMessage = "Establishing connection...");

    try {
      // Ping the server root or health check
      // Timeout set to 30 seconds as requested
      final healthCheck = await _client!
          .get(Uri.parse(serverBaseUrl))
          .timeout(const Duration(seconds: 30));

      if (healthCheck.statusCode != 200 && healthCheck.statusCode != 404) {
        // 404 is technically a response, meaning server is Alive but root path is empty.
        // Connection refused or timeout throws an exception.
        throw Exception("Server responded with ${healthCheck.statusCode}");
      }
    } catch (e) {
      throw Exception("Connection Failed: $e");
    }

    // B. UPLOAD VIDEO
    if (_isCancelled) throw Exception("Cancelled");
    setState(() => _statusMessage = "Uploading Video...");

    // Create Request
    var request = http.MultipartRequest('POST', uploadUrl);
    request.files.add(await http.MultipartFile.fromPath('video', path));

    // Send using the cancellable client
    final streamedResponse = await _client!
        .send(request)
        .timeout(const Duration(seconds: 60));
    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode != 202) throw Exception("Upload Failed");

    // C. POLL FOR RESULTS
    if (mounted) setState(() => _statusMessage = "Server Extracting...");

    int attempts = 0;
    while (attempts < 60) {
      if (_isCancelled) throw Exception("Cancelled");

      // Wait 1 second
      await Future.delayed(const Duration(seconds: 1));

      try {
        final statusResponse = await _client!.get(statusUrl);
        if (statusResponse.statusCode == 200) {
          final body = jsonDecode(statusResponse.body);
          if (body['status'] == 'done') return body; // Return Map
          if (body['status'] == 'failed') throw Exception(body['error']);
          if (body['status'] == 'cancelled') throw Exception("Cancelled");
        }
      } catch (_) {
        // Ignore polling errors (retry)
      }
      attempts++;
    }
    throw Exception("Timeout");
  }

  // --- OFFLINE LOGIC ---
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
      // Use dynamic to accept the Map returned by Kotlin
      final dynamic result = await methodChannel.invokeMethod(
        'extractFeatures',
        {'videoPath': path},
      );
      return result;
    } finally {
      _progressSubscription?.cancel();
    }
  }

  // --- SAVE & NAVIGATE ---
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
    // 1. Set Flags
    _isCancelled = true;
    setState(() => _statusMessage = "Cancelling...");

    // 2. Kill Network Immediately
    _client?.close();

    // 3. Kill Offline Processing
    await methodChannel.invokeMethod('cancelExtraction');
    _progressSubscription?.cancel();

    // 4. Notify Server (Fire and forget, create new temporary client since old one is closed)
    if (_currentRequestId != null) {
      try {
        await http
            .post(Uri.parse("$serverBaseUrl/cancel/$_currentRequestId"))
            .timeout(const Duration(seconds: 2));
      } catch (_) {}
    }

    // 5. Exit Screen
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
    _client?.close(); // Ensure client is closed on exit
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
