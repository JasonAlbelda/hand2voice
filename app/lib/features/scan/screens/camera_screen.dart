import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:hand2voice/main.dart';
import 'package:image_picker/image_picker.dart';

class CameraScreen extends StatefulWidget {
  final Function(String) onVideoRecorded;

  const CameraScreen({super.key, required this.onVideoRecorded});

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  CameraController? _controller;
  bool _isRecording = false;
  int _selectedCameraIdx = 0;
  FlashMode _flashMode = FlashMode.off;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _initCamera(_selectedCameraIdx);
  }

  Future<void> _initCamera(int index) async {
    if (cameras.isEmpty) return;
    _controller = CameraController(
      cameras[index],
      ResolutionPreset.high,
      enableAudio: false, // FSL usually doesn't need audio for analysis
    );

    try {
      await _controller!.initialize();
      setState(() {});
    } catch (e) {
      print("Camera init error: $e");
    }
  }

  Future<void> _importVideo() async {
    try {
      final XFile? video = await _picker.pickVideo(source: ImageSource.gallery);
      if (video != null) {
        // Pass the file path exactly like a recorded video
        widget.onVideoRecorded(video.path);
      }
    } catch (e) {
      print("Error picking video: $e");
    }
  }

  void _toggleFlash() async {
    if (_controller == null) return;
    FlashMode newMode = _flashMode == FlashMode.off
        ? FlashMode.torch
        : FlashMode.off;
    await _controller!.setFlashMode(newMode);
    setState(() {
      _flashMode = newMode;
    });
  }

  Future<void> _flipCamera() async {
    if (cameras.length < 2) return;
    
    // Dispose current controller
    await _controller?.dispose();
    
    // Toggle camera index
    _selectedCameraIdx = (_selectedCameraIdx + 1) % cameras.length;
    
    // Initialize new camera
    await _initCamera(_selectedCameraIdx);
    
    // Restore flash mode if needed
    if (_flashMode != FlashMode.off) {
      await _controller?.setFlashMode(_flashMode);
    }
  }

  Future<void> _recordVideo() async {
    if (_controller == null || !_controller!.value.isInitialized) return;

    if (_isRecording) {
      final file = await _controller!.stopVideoRecording();
      setState(() => _isRecording = false);
      widget.onVideoRecorded(file.path);
    } else {
      await _controller!.startVideoRecording();
      setState(() => _isRecording = true);
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_controller == null || !_controller!.value.isInitialized) {
      return Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(
                color: Colors.white,
              ),
              const SizedBox(height: 16),
              Text(
                "Initializing Camera...",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      body: Stack(
        children: [
          // Full screen camera preview
          SizedBox.expand(child: CameraPreview(_controller!)),

          // Controls Overlay
          Positioned(
            bottom: 30,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                IconButton(
                  icon: Icon(
                    _flashMode == FlashMode.off
                        ? Icons.flash_off
                        : Icons.flash_on,
                    color: Colors.white,
                    size: 30,
                  ),
                  onPressed: _toggleFlash,
                ),
                FloatingActionButton(
                  backgroundColor: _isRecording ? Colors.red : Colors.white,
                  foregroundColor: _isRecording ? Colors.white : Colors.black,
                  child: AnimatedSwitcher(
                    duration: Duration(milliseconds: 200),
                    child: Icon(
                      _isRecording ? Icons.stop : Icons.videocam,
                      key: ValueKey(_isRecording),
                    ),
                  ),
                  onPressed: _recordVideo,
                ),
                IconButton(
                  icon: const Icon(
                    Icons.video_library_rounded, // Gallery Icon
                    color: Colors.white,
                    size: 30,
                  ),
                  onPressed: _importVideo,
                ),
              ],
            ),
          ),
          // Recording indicator overlay
          if (_isRecording)
            Positioned(
              top: 50,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                      ),
                      SizedBox(width: 8),
                      Text(
                        "REC",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          Positioned(
            top: 40,
            left: 10,
            child: BackButton(color: Colors.white),
          ),
          
          // Flip camera button
          Positioned(
            top: 40,
            right: 10,
            child: IconButton(
              icon: const Icon(
                Icons.flip_camera_ios,
                color: Colors.white,
                size: 30,
              ),
              onPressed: _flipCamera,
              tooltip: 'Flip Camera',
            ),
          ),
        ],
      ),
    );
  }
}
