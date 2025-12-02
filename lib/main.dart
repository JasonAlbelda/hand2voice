import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'screens/home_screen.dart';

List<CameraDescription> cameras = [];

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    cameras = await availableCameras();
  } on CameraException catch (e) {
    print('Error initializing camera: $e');
  }
  runApp(const Hand2VoiceApp());
}

class Hand2VoiceApp extends StatelessWidget {
  const Hand2VoiceApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Hand2Voice',
      theme: ThemeData(primarySwatch: Colors.blue, useMaterial3: true),
      home: const HomeScreen(),
    );
  }
}
