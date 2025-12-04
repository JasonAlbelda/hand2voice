import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'camera_screen.dart';
import 'result_screen.dart';
import 'package:uuid/uuid.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ImagePicker _picker = ImagePicker();
  final Uuid _uuid = const Uuid();

  // 1. Define Channels
  static const methodChannel = MethodChannel('com.hand2voice/mediapipe');
  static const eventChannel = EventChannel('com.hand2voice/progress');
  final String serverBaseUrl = "http://192.168.1.2:5000";

  bool _isProcessing = false;
  int _progressPercent = 0;
  StreamSubscription? _progressSubscription;
  bool _useOnlineProcessing = true;
  String _statusMessage = "";

  String? _currentRequestId;

  Future<void> _processVideo(String path) async {
    setState(() {
      _isProcessing = true;
      _progressPercent = 0;
      _statusMessage = "Starting...";
    });

    dynamic results;

    // 1. ONLINE ATTEMPT
    if (_useOnlineProcessing) {
      try {
        results = await _extractOnline(path);
      } catch (e) {
        // If it was manually cancelled, don't fall back
        if (_statusMessage == "Cancelled") return;

        print("⚠️ Online failed/timed out: $e");
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Server slow/error. Switching to Offline..."),
              duration: Duration(seconds: 2),
            ),
          );
        }
      }
    }

    // 2. OFFLINE FALLBACK (If online failed or disabled)
    if (results == null && _statusMessage != "Cancelled") {
      try {
        results = await _extractOffline(path);
      } catch (e) {
        if (e.toString().contains("CANCELLED")) {
          print("Offline processing cancelled.");
        } else {
          _handleError("Offline Error: $e");
        }
        return;
      }
    }

    // 3. Success -> Navigate
    if (results != null && results.isNotEmpty) {
      await _saveFeaturesToFile(results);
      if (mounted) {
        setState(() => _isProcessing = false);
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                ResultScreen(videoPath: path, extractedData: results!),
          ),
        );
      }
    } else {
      _handleError("No features were extracted.");
    }
  }

  Future<dynamic> _extractOnline(String path) async {
    _currentRequestId = _uuid.v4();
    final uploadUrl = Uri.parse("$serverBaseUrl/process/$_currentRequestId");
    final statusUrl = Uri.parse("$serverBaseUrl/status/$_currentRequestId");

    // --- STEP 1: UPLOAD ---
    setState(() => _statusMessage = "Uploading Video...");
    print("--- ONLINE: UPLOADING ID: $_currentRequestId ---");

    var request = http.MultipartRequest('POST', uploadUrl);
    request.files.add(await http.MultipartFile.fromPath('video', path));

    // Send request (waits for upload to finish)
    final streamedResponse = await request.send().timeout(
      const Duration(seconds: 60),
    );
    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode != 202) {
      throw Exception(
        "Upload Failed: ${response.statusCode} - ${response.body}",
      );
    }

    // --- STEP 2: POLLING (CHECK STATUS) ---
    print("--- UPLOAD DONE. POLLING FOR RESULTS... ---");
    if (mounted) {
      setState(() {
        _statusMessage = "Extracting Features";
      });
    }

    // Loop until done or timeout (e.g., 60 seconds max processing time)
    int attempts = 0;
    while (attempts < 60) {
      // Check cancellation
      if (_currentRequestId == null) throw Exception("Cancelled");

      // Wait 1 second before checking
      await Future.delayed(const Duration(seconds: 1));

      try {
        final statusResponse = await http.get(statusUrl);

        if (statusResponse.statusCode == 200) {
          final body = jsonDecode(statusResponse.body);
          final status = body['status'];

          if (status == 'done') {
            print("✅ Processing Complete!");
            return body;
          } else if (status == 'failed') {
            throw Exception("Server Processing Error: ${body['error']}");
          } else if (status == 'cancelled') {
            throw Exception("Cancelled by Server");
          }
        } else {
          // 404 or other errors
          print("Status check failed: ${statusResponse.statusCode}");
        }
      } catch (e) {
        print("Polling error: $e");
      }

      attempts++;
    }

    throw Exception("Processing Timed Out");
  }

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
      final List<dynamic> result = await methodChannel.invokeMethod(
        'extractFeatures',
        {'videoPath': path},
      );
      return result;
    } finally {
      _progressSubscription?.cancel();
    }
  }

  Future<void> _cancelProcessing() async {
    setState(() => _statusMessage = "Cancelled");

    // 1. Cancel Offline
    await methodChannel.invokeMethod('cancelExtraction');
    _progressSubscription?.cancel();

    // 2. Cancel Online
    if (_currentRequestId != null) {
      print("Sending Cancel Request for ID: $_currentRequestId");
      try {
        // Call the separate cancel endpoint
        final cancelUrl = Uri.parse("$serverBaseUrl/cancel/$_currentRequestId");
        await http.post(cancelUrl);
      } catch (e) {
        print("Failed to contact server for cancel: $e");
      }
      _currentRequestId = null;
    }

    // Reset UI
    setState(() {
      _isProcessing = false;
      _progressPercent = 0;
    });
  }

  void _handleError(String msg) {
    print("❌ $msg");
    setState(() => _isProcessing = false);
    if (mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(msg), backgroundColor: Colors.red));
    }
  }

  Future<void> _saveFeaturesToFile(dynamic data) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/extracted_landmarks.txt');

      // Pretty print JSON
      JsonEncoder encoder = const JsonEncoder.withIndent('  ');
      String prettyprint = encoder.convert(data);

      await file.writeAsString(prettyprint);

      print("✅ DATA SAVED TO FILE:");
      print("📂 ${file.path}");
      print("You can inspect this file using Android Studio Device Explorer");
    } catch (e) {
      print("❌ Failed to save file: $e");
    }
  }

  Future<void> _importVideo() async {
    final XFile? video = await _picker.pickVideo(source: ImageSource.gallery);
    if (video != null) {
      _processVideo(video.path);
    }
  }

  @override
  void dispose() {
    _progressSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Hand2Voice FSL")),
      body: Center(
        child: _isProcessing
            ? Container(
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
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 20),
                    if (_progressPercent > 0) ...[
                      LinearProgressIndicator(value: _progressPercent / 100.0),
                      Text("$_progressPercent%"),
                    ],
                    const SizedBox(height: 50),
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
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton.icon(
                    icon: const Icon(Icons.video_library),
                    label: const Text("Import Video"),
                    onPressed: _importVideo,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.all(20),
                    ),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.camera_alt),
                    label: const Text("Record Action"),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => CameraScreen(
                            onVideoRecorded: (path) {
                              Navigator.pop(context);
                              _processVideo(path);
                            },
                          ),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.all(20),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Container(
                    width: 250,
                    margin: const EdgeInsets.only(bottom: 30),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 5,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(50),
                    ),
                    child: SwitchListTile(
                      title: _useOnlineProcessing
                          ? const Text("Online")
                          : const Text("Offline"),
                      //subtitle: const Text("Faster, requires laptop server"),
                      value: _useOnlineProcessing,
                      onChanged: (val) =>
                          setState(() => _useOnlineProcessing = val),
                      secondary: Icon(
                        _useOnlineProcessing ? Icons.cloud : Icons.cloud_off,
                        color: _useOnlineProcessing ? Colors.blue : Colors.grey,
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
