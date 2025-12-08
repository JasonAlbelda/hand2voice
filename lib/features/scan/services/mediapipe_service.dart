import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import '../screens/camera_screen.dart';
import '../screens/result_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ImagePicker _picker = ImagePicker();
  static const platform = MethodChannel('com.hand2voice/mediapipe');
  bool _isProcessing = false;

  Future<void> _processVideo(String path) async {
    setState(() => _isProcessing = true);
    try {
      // Call Android Native Code
      print("Sending video to MediaPipe: $path");
      final List<dynamic> result = await platform.invokeMethod(
        'extractFeatures',
        {'videoPath': path},
      );

      print("Feature Extraction Complete. Frames processed: ${result.length}");
      // Navigate to result screen to show output
      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                ResultScreen(videoPath: path, extractedData: result),
          ),
        );
      }
    } on PlatformException catch (e) {
      print("Failed to extract features: '${e.message}'.");
    } finally {
      setState(() => _isProcessing = false);
    }
  }

  Future<void> _importVideo() async {
    final XFile? video = await _picker.pickVideo(source: ImageSource.gallery);
    if (video != null) {
      _processVideo(video.path);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Hand2Voice FSL")),
      body: Center(
        child: _isProcessing
            ? const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 20),
                  Text("Extracting MediaPipe Features..."),
                ],
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
                              Navigator.pop(context); // Close camera
                              _processVideo(path); // Process result
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
