import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hand2voice/core/providers/biometric_provider.dart';

class BiometricSettingsTile extends StatelessWidget {
  const BiometricSettingsTile({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<BiometricProvider>(
      builder: (context, biometricProvider, _) {
        if (!biometricProvider.isBiometricAvailable) {
          return ListTile(
            leading: Icon(Icons.fingerprint, color: Colors.grey),
            title: Text('Biometric Authentication'),
            subtitle: Text('Not available on this device'),
            enabled: false,
          );
        }

        return SwitchListTile(
          secondary: Icon(
            Icons.fingerprint,
            color: biometricProvider.isBiometricEnabled 
                ? Colors.blue 
                : Colors.grey,
          ),
          title: Text('Biometric Authentication'),
          subtitle: Text(
            biometricProvider.isBiometricEnabled
                ? 'Enabled (${biometricProvider.getBiometricDescription()})'
                : 'Tap to enable ${biometricProvider.getBiometricDescription()}',
          ),
          value: biometricProvider.isBiometricEnabled,
          onChanged: (bool value) async {
            await biometricProvider.toggleBiometric(value);
            
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    value
                        ? 'Biometric authentication enabled'
                        : 'Biometric authentication disabled',
                  ),
                  duration: Duration(seconds: 2),
                ),
              );
            }
          },
        );
      },
    );
  }
}
