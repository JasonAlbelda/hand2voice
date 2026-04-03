import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:hand2voice/common/providers/camera_provider.dart';
import 'package:hand2voice/core/providers/biometric_provider.dart';
import 'package:hand2voice/core/providers/auth_provider.dart';
import 'package:hand2voice/core/providers/screen_security_provider.dart';
import 'package:hand2voice/core/providers/file_encryption_provider.dart';
import 'package:hand2voice/core/services/onboarding_service.dart';
import 'package:hand2voice/core/theme/app_theme.dart';
import 'package:hand2voice/features/auth/screens/unified_lock_screen.dart';
import 'package:hand2voice/features/home/screens/home_screen.dart';
import 'package:hand2voice/features/onboarding/screens/welcome_screen.dart';
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
        ChangeNotifierProvider(create: (_) => BiometricProvider()),
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => ScreenSecurityProvider()),
        ChangeNotifierProvider(create: (_) => FileEncryptionProvider()),
      ],
      child: const Hand2VoiceApp(),
    ),
  );
}

class Hand2VoiceApp extends StatefulWidget {
  const Hand2VoiceApp({super.key});

  @override
  State<Hand2VoiceApp> createState() => _Hand2VoiceAppState();
}

class _Hand2VoiceAppState extends State<Hand2VoiceApp> {
  bool _isLoading = true;
  bool _needsOnboarding = false;

  @override
  void initState() {
    super.initState();
    // Use post frame callback to avoid calling context.read during build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeApp();
    });
  }

  Future<void> _initializeApp() async {
    if (!mounted) return;
    
    // Initialize providers
    await Future.wait([
      context.read<BiometricProvider>().initialize(),
      context.read<AuthProvider>().initialize(),
      context.read<ScreenSecurityProvider>().initialize(),
      context.read<FileEncryptionProvider>().initialize(),
    ]);

    if (!mounted) return;

    // Auto-enable encryption features (always on)
    final screenSecurityProvider = context.read<ScreenSecurityProvider>();
    final fileEncryptionProvider = context.read<FileEncryptionProvider>();
    
    if (!screenSecurityProvider.isScreenSecurityEnabled) {
      await screenSecurityProvider.toggleScreenSecurity(true);
    }
    
    if (!fileEncryptionProvider.isFileEncryptionEnabled) {
      await fileEncryptionProvider.toggleFileEncryption(true);
    }

    // Check if onboarding is needed
    final onboardingService = OnboardingService();
    final isComplete = await onboardingService.isOnboardingComplete();

    if (mounted) {
      setState(() {
        _needsOnboarding = !isComplete;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return MaterialApp(
        title: 'Hand2Voice',
        theme: AppTheme.darkTheme,
        home: Scaffold(
          body: Center(
            child: CircularProgressIndicator(
              color: AppTheme.accentTeal,
            ),
          ),
        ),
      );
    }

    return MaterialApp(
      title: 'Hand2Voice',
      theme: AppTheme.darkTheme,
      debugShowCheckedModeBanner: false,
      home: _needsOnboarding
          ? WelcomeScreen()
          : UnifiedLockScreen(
              child: HomeScreen(),
            ),
    );
  }
}
