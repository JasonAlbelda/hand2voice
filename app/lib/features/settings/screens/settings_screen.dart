import 'package:flutter/material.dart';
import 'package:hand2voice/common/providers/camera_provider.dart';
import 'package:provider/provider.dart';
import 'package:camera/camera.dart';
// Import your providers
import 'package:hand2voice/features/settings/providers/settings_provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  void _showUrlDialog(BuildContext context, SettingsProvider provider) {
    final TextEditingController controller = TextEditingController(
      text: provider.serverUrl,
    );

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Set Server URL"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              "Enter IP address and port (e.g., http://192.168.1.5:5000)",
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: controller,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: "Server URL",
              ),
              keyboardType: TextInputType.url,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () {
              provider.setServerUrl(controller.text);
              Navigator.pop(ctx);
            },
            child: const Text("Save"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Watch both providers
    final cameraProvider = Provider.of<CameraProvider>(context);
    final settingsProvider = Provider.of<SettingsProvider>(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          //Section 1: Processing
          const Text(
            'Processing',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w600,
              color: Colors.blue,
            ),
          ),
          const SizedBox(height: 10),
          SwitchListTile(
            title: const Text('Use Online Server'),
            subtitle: const Text(
              'Uses Laptop/Cloud for faster prediction. Requires running server.',
            ),
            value: settingsProvider.isOnlineMode,
            secondary: Icon(
              settingsProvider.isOnlineMode ? Icons.cloud : Icons.cloud_off,
              color: settingsProvider.isOnlineMode ? Colors.blue : Colors.grey,
            ),
            onChanged: (bool value) {
              settingsProvider.toggleProcessingMode(value);
            },
          ),

          const Divider(height: 30),

          ListTile(
            enabled: settingsProvider
                .isOnlineMode, // Only enable if Online Mode is ON
            title: const Text("Server Address"),
            subtitle: Text(settingsProvider.serverUrl),
            trailing: const Icon(Icons.edit),
            onTap: () => _showUrlDialog(context, settingsProvider),
          ),

          const Divider(height: 30),

          // Section 2: Camera
          const Text(
            'Camera',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w600,
              color: Colors.blue,
            ),
          ),
          const SizedBox(height: 10),
          SwitchListTile(
            title: const Text('Flashlight'),
            value: cameraProvider.isFlashEnabled,
            onChanged: (bool value) {
              cameraProvider.toggleFlash();
            },
            secondary: Icon(
              cameraProvider.isFlashEnabled ? Icons.flash_on : Icons.flash_off,
              color: Colors.orange,
            ),
          ),
          ListTile(
            leading: const Icon(Icons.flip_camera_ios),
            title: const Text('Camera Lens'),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  cameraProvider.lensDirection == CameraLensDirection.back
                      ? 'Back'
                      : 'Front',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(width: 8),
                Switch(
                  value:
                      cameraProvider.lensDirection == CameraLensDirection.front,
                  onChanged: (bool value) {
                    cameraProvider.toggleCameraLens();
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
