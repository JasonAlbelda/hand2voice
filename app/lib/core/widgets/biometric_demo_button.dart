import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hand2voice/core/providers/biometric_provider.dart';

/// Demo button to test biometric authentication
/// Can be added to any screen for testing purposes
class BiometricDemoButton extends StatelessWidget {
  const BiometricDemoButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<BiometricProvider>(
      builder: (context, biometricProvider, _) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ElevatedButton.icon(
              onPressed: () async {
                final success = await biometricProvider.authenticate(
                  reason: 'Test biometric authentication',
                );
                
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        success 
                            ? '✅ Authentication successful!' 
                            : '❌ Authentication failed',
                      ),
                      backgroundColor: success ? Colors.green : Colors.red,
                    ),
                  );
                }
              },
              icon: Icon(Icons.fingerprint),
              label: Text('Test Biometric'),
            ),
            const SizedBox(height: 8),
            Text(
              'Available: ${biometricProvider.getBiometricDescription()}',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        );
      },
    );
  }
}
