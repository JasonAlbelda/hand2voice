import 'package:flutter/material.dart';
import 'package:hand2voice/features/scan/widgets/speech_screen.dart';
import 'package:hand2voice/features/scan/screens/camera_screen.dart';
import 'package:hand2voice/features/home/screens/home_screen.dart';

class ScanScreen extends StatefulWidget {
  const ScanScreen({Key? key}) : super(key: key);

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
                Navigator.pop(context);
                // Call HomeScreen's processVideo via the global key.
                HomeScreen.globalKey.currentState?.processVideo(path);
              },
            ),
      ),
    );
  }

  void _selectSpeechMode() {
    //ScaffoldMessenger.of(context).showSnackBar(
    //  const SnackBar(content: Text('Speech To Text feature coming soon!')),
    //);

    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => SpeechToTextScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: _buildSelectionOverlay());
  }

  Widget _buildSelectionOverlay() {
    return Container(
      color: Colors.grey[700],
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
        elevation: 0,
        color: Colors.grey[400],
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          width: MediaQuery.of(context).size.width * 0.7,
          height: 180,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 80, color: Colors.black54),
              const SizedBox(height: 10),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black54,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
