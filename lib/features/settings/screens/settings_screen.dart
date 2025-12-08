import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:hand2voice/common/providers/camera_provider.dart';
import 'package:provider/provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<CameraProvider>(
      builder: (context, cameraProvider, child) {
        return Scaffold(
          appBar: AppBar(title: const Text('Settings')),
          body: ListView(
            padding: const EdgeInsets.all(16.0),
            children: [
              Text(
                'Camera',
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
              ),
              SwitchListTile(
                title: const Text('Flashlight'),
                value: cameraProvider.isFlashEnabled,
                onChanged: (bool value) {
                  cameraProvider.toggleFlash();
                },
                secondary: const Icon(Icons.flash_on),
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
                    ),
                    const SizedBox(width: 8),
                    Switch(
                      value:
                          cameraProvider.lensDirection ==
                          CameraLensDirection.front,
                      onChanged: (bool value) {
                        cameraProvider.toggleCameraLens();
                      },
                    ),
                  ],
                ),
              ),
              const Divider(),
            ],
          ),
        );
      },
    );
  }
}
