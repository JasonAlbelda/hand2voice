import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:hand2voice/common/providers/camera_provider.dart';
import 'package:hand2voice/features/home/screens/home_screen.dart';
import 'package:hand2voice/features/settings/providers/settings_provider.dart';
import 'package:provider/provider.dart';

List<CameraDescription> cameras = [];

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    cameras = await availableCameras();
  } on CameraException catch (e) {
    print('Error initializing camera: $e');
  }
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => CameraProvider()),
        ChangeNotifierProvider(create: (_) => SettingsProvider()),
      ],
      child: const Hand2VoiceApp(),
    ),
  );
}

class Hand2VoiceApp extends StatelessWidget {
  const Hand2VoiceApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Hand2Voice',
      theme: ThemeData(primarySwatch: Colors.blue, useMaterial3: true),
      home: HomeScreen(),
    );
  }
}
