import 'package:flutter/material.dart';
import 'package:hand2voice/features/scan/widgets/speech_screen.dart';
import 'package:hand2voice/features/scan/screens/camera_screen.dart';
import 'package:hand2voice/features/scan/screens/processing_screen.dart'; // Import New Screen

class ScanScreen extends StatefulWidget {
  final bool isOnlineMode; // Receive preference from Home
  const ScanScreen({Key? key, this.isOnlineMode = true}) : super(key: key);

  @override
  State<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends State<ScanScreen> {
  void _selectCameraMode() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CameraScreen(
          onVideoRecorded: (path) {
            // 1. Close Camera
            Navigator.pop(context);

            // 2. Push Processing Screen (REPLACES ScanScreen temporarily in visual stack)
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ProcessingScreen(
                  videoPath: path,
                  isOnlineMode: widget.isOnlineMode,
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  void _selectSpeechMode() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => SpeechToTextScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Select Mode"),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: _buildSelectionOverlay(),
    );
  }

  // ... rest of your UI code (_buildSelectionOverlay, _buildOptionButton) stays the same ...
  Widget _buildSelectionOverlay() {
    return Container(
      color: Colors.grey[200], // Changed to lighter color for better UI
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildOptionButton(
              icon: Icons.camera_alt_outlined,
              label: 'Translate Sign Language',
              onTap: _selectCameraMode,
            ),
            const SizedBox(height: 30),
            _buildOptionButton(
              icon: Icons.mic_none,
              label: 'Speech To Text',
              onTap: _selectSpeechMode,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOptionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          width: MediaQuery.of(context).size.width * 0.7,
          height: 150,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: Colors.white,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 60, color: Colors.orange),
              const SizedBox(height: 10),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
