import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hand2voice/core/providers/biometric_provider.dart';

class BiometricLockScreen extends StatefulWidget {
  final Widget child;

  const BiometricLockScreen({
    super.key,
    required this.child,
  });

  @override
  State<BiometricLockScreen> createState() => _BiometricLockScreenState();
}

class _BiometricLockScreenState extends State<BiometricLockScreen> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _authenticate();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Lock app when it goes to background
    if (state == AppLifecycleState.paused || state == AppLifecycleState.inactive) {
      final biometricProvider = context.read<BiometricProvider>();
      if (biometricProvider.isBiometricEnabled) {
        biometricProvider.logout();
      }
    }
    // Require authentication when app comes back to foreground
    else if (state == AppLifecycleState.resumed) {
      final biometricProvider = context.read<BiometricProvider>();
      if (biometricProvider.isBiometricEnabled && !biometricProvider.isAuthenticated) {
        _authenticate();
      }
    }
  }

  Future<void> _authenticate() async {
    final biometricProvider = context.read<BiometricProvider>();
    await biometricProvider.authenticate();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<BiometricProvider>(
      builder: (context, biometricProvider, _) {
        // Show lock screen if biometric is enabled and user is not authenticated
        if (biometricProvider.isBiometricEnabled && !biometricProvider.isAuthenticated) {
          return Scaffold(
            body: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.blue.shade400,
                    Colors.blue.shade700,
                  ],
                ),
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.lock_outline,
                      size: 100,
                      color: Colors.white,
                    ),
                    const SizedBox(height: 32),
                    Text(
                      'Hand2Voice',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'App is locked',
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.white70,
                      ),
                    ),
                    const SizedBox(height: 48),
                    if (biometricProvider.isLoading)
                      CircularProgressIndicator(
                        color: Colors.white,
                      )
                    else
                      ElevatedButton.icon(
                        onPressed: _authenticate,
                        icon: Icon(Icons.fingerprint),
                        label: Text('Unlock with ${biometricProvider.getBiometricDescription()}'),
                        style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.blue.shade700,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          );
        }

        // Show the actual app if authenticated or biometric is disabled
        return widget.child;
      },
    );
  }
}
