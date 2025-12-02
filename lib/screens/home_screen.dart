import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'camera_screen.dart';
import 'result_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ImagePicker _picker = ImagePicker();

  // 1. Define Channels
  static const methodChannel = MethodChannel('com.hand2voice/mediapipe');
  static const eventChannel = EventChannel('com.hand2voice/progress');

  bool _isProcessing = false;
  int _progressPercent = 0;
  StreamSubscription? _progressSubscription;

  Future<void> _processVideo(String path) async {
    setState(() {
      _isProcessing = true;
      _progressPercent = 0;
    });

    // 2. Start Listening to Progress Updates
    _progressSubscription = eventChannel.receiveBroadcastStream().listen(
      (event) {
        if (event is int) {
          setState(() {
            _progressPercent = event;
          });
        }
      },
      onError: (error) {
        print("Progress Stream Error: $error");
      },
    );

    try {
      print("--- STARTING FEATURE EXTRACTION ---");
      // 3. Call Native Method
      final List<dynamic> result = await methodChannel.invokeMethod(
        'extractFeatures',
        {'videoPath': path},
      );

      // Stop listening to progress
      _progressSubscription?.cancel();

      print("--- EXTRACTION COMPLETE ---");
      print("Total Frames Processed: ${result.length}");

      // 4. PRINT COORDINATES TO TERMINAL
      // _printCoordinates(result);

       await _saveFeaturesToFile(result);

      if (mounted) {
        setState(() => _isProcessing = false);
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                ResultScreen(videoPath: path, extractedData: result),
          ),
        );
      }
    } on PlatformException catch (e) {
      _progressSubscription?.cancel();
      setState(() => _isProcessing = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Error: ${e.message}"),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

   Future<void> _saveFeaturesToFile(List<dynamic> data) async {
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

  void _printCoordinates(List<dynamic> data) {
    if (data.isEmpty) {
      print("No features extracted.");
      return;
    }

    print("--------------------------------------------------");
    print("      EXTRACTED LANDMARKS (HOLISTIC MODEL)        ");
    print("--------------------------------------------------");

    for (int i = 0; i < data.length; i++) {
      final frame = data[i];
      final ts = frame['timestamp'];
      final features = frame['features'] as Map<dynamic, dynamic>;

      print("\n=== FRAME $i (Timestamp: ${ts}ms) ===");

      bool hasData = false;

      // 1. PRINT POSE
      if (features.containsKey('pose')) {
        hasData = true;
        final pose = features['pose'] as List<dynamic>;
        print("  [BODY POSE] - ${pose.length ~/ 3} points detected");
        
        // Print the first point (Nose) and Shoulders as a sample to verify data
        if (pose.length >= 39) { // Ensure enough points exist
           _printPoint("Nose", pose, 0); 
           _printPoint("Left Shoulder", pose, 11);
           _printPoint("Right Shoulder", pose, 12);
        }
        // Uncomment the line below to dump ALL pose numbers (it will be huge)
        // print("    Raw Data: $pose");
      }

      // 2. PRINT LEFT HAND
      if (features.containsKey('left_hand')) {
        hasData = true;
        final left = features['left_hand'] as List<dynamic>;
        print("  [LEFT HAND] - ${left.length ~/ 3} points detected");
        
        if (left.isNotEmpty) {
           _printPoint("Wrist", left, 0);
           _printPoint("Index Tip", left, 8);
        }
        print("    Raw Data (First 10 coords): ${left.take(10).toList()}...");
      }

      // 3. PRINT RIGHT HAND
      if (features.containsKey('right_hand')) {
        hasData = true;
        final right = features['right_hand'] as List<dynamic>;
        print("  [RIGHT HAND] - ${right.length ~/ 3} points detected");

        if (right.isNotEmpty) {
           _printPoint("Wrist", right, 0);
           _printPoint("Index Tip", right, 8);
        }
        print("    Raw Data (First 10 coords): ${right.take(10).toList()}...");
      }

      if (!hasData) {
        print("  (Frame processed but no skeleton detected)");
      }
    }
    print("\n--------------------------------------------------");
  }

  // Helper to format a single point x,y,z cleanly
  void _printPoint(String label, List<dynamic> data, int index) {
    // Stride is 3 because data is [x, y, z, x, y, z...]
    int offset = index * 3;
    if (offset + 2 < data.length) {
      double x = data[offset] as double;
      double y = data[offset+1] as double;
      double z = data[offset+2] as double;
      print("    -> $label: [x: ${x.toStringAsFixed(4)}, y: ${y.toStringAsFixed(4)}, z: ${z.toStringAsFixed(4)}]");
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
                      "Extracting Features: $_progressPercent%",
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    // Linear Progress Bar
                    LinearProgressIndicator(value: _progressPercent / 100.0),
                    const SizedBox(height: 10),
                    const Text(
                      "Please wait, this may take a moment...",
                      style: TextStyle(color: Colors.grey),
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
                ],
              ),
      ),
    );
  }
}
