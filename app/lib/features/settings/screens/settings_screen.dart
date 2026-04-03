import 'package:flutter/material.dart';
import 'package:hand2voice/common/providers/camera_provider.dart';
import 'package:hand2voice/core/theme/app_theme.dart';
import 'package:hand2voice/features/settings/widgets/auth_settings_tile.dart';
import 'package:provider/provider.dart';
import 'package:camera/camera.dart';
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
        backgroundColor: AppTheme.cardBg,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: const BorderSide(color: AppTheme.borderColor),
        ),
        title: const Text("Set Server URL", style: TextStyle(color: AppTheme.textMain)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              "Enter IP address and port (e.g., http://192.168.1.5:5000)",
              style: TextStyle(fontSize: 12, color: AppTheme.textSub),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: controller,
              decoration: const InputDecoration(
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
    final cameraProvider = Provider.of<CameraProvider>(context);
    final settingsProvider = Provider.of<SettingsProvider>(context);

    return Scaffold(
      backgroundColor: AppTheme.appBg,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Icon(
                      Icons.arrow_back,
                      color: AppTheme.textMain,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  const Text(
                    'Settings',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textMain,
                    ),
                  ),
                ],
              ),
            ),

            // Content
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                children: [
                  // Section Header
                  _buildSectionHeader('SECURITY'),
                  const SizedBox(height: 16),
                  
                  // Auth Settings
                  const AuthSettingsTile(),
                  const SizedBox(height: 12),
                  
                  // Always-On Security Card
                  Container(
                    decoration: BoxDecoration(
                      color: AppTheme.cardBg,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppTheme.borderColor),
                    ),
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            children: [
                              Container(
                                width: 44,
                                height: 44,
                                decoration: BoxDecoration(
                                  color: AppTheme.accentPurple.withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Icon(
                                  Icons.shield,
                                  color: AppTheme.accentPurple,
                                  size: 20,
                                ),
                              ),
                              const SizedBox(width: 15),
                              const Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Security & Authentication',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 16,
                                        color: AppTheme.textMain,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Divider(height: 1),
                        _buildSecurityItem(
                          Icons.lock,
                          'Data Encryption',
                          'All data is encrypted',
                        ),
                        _buildSecurityItem(
                          Icons.block,
                          'Screen Security',
                          'Screenshots blocked',
                        ),
                        _buildSecurityItem(
                          Icons.videocam_off,
                          'Video Encryption',
                          'Videos are encrypted',
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 30),
                  
                  // Processing Section
                  _buildSectionHeader('PROCESSING'),
                  const SizedBox(height: 16),
                  
                  _buildListCard(
                    leading: Icon(
                      settingsProvider.isOnlineMode ? Icons.cloud : Icons.cloud_off,
                      color: settingsProvider.isOnlineMode ? AppTheme.accentTeal : AppTheme.textSub,
                    ),
                    title: 'Use Online Server',
                    subtitle: 'Uses Laptop/Cloud for faster prediction',
                    trailing: Switch(
                      value: settingsProvider.isOnlineMode,
                      onChanged: (value) => settingsProvider.toggleProcessingMode(value),
                    ),
                  ),
                  
                  const SizedBox(height: 12),
                  
                  _buildListCard(
                    leading: const Icon(Icons.dns, color: AppTheme.accentTeal),
                    title: 'Server Address',
                    subtitle: settingsProvider.serverUrl,
                    trailing: const Icon(Icons.chevron_right, color: AppTheme.borderColor),
                    onTap: settingsProvider.isOnlineMode
                        ? () => _showUrlDialog(context, settingsProvider)
                        : null,
                  ),
                  
                  const SizedBox(height: 30),
                  
                  // Camera Section
                  _buildSectionHeader('CAMERA'),
                  const SizedBox(height: 16),
                  
                  _buildListCard(
                    leading: Icon(
                      cameraProvider.isFlashEnabled ? Icons.flash_on : Icons.flash_off,
                      color: cameraProvider.isFlashEnabled ? AppTheme.accentTeal : AppTheme.textSub,
                    ),
                    title: 'Flashlight',
                    subtitle: cameraProvider.isFlashEnabled ? 'Enabled' : 'Disabled',
                    trailing: Switch(
                      value: cameraProvider.isFlashEnabled,
                      onChanged: (value) => cameraProvider.toggleFlash(),
                    ),
                  ),
                  
                  const SizedBox(height: 12),
                  
                  _buildListCard(
                    leading: const Icon(Icons.flip_camera_ios, color: AppTheme.accentTeal),
                    title: 'Camera Lens',
                    subtitle: cameraProvider.lensDirection == CameraLensDirection.back
                        ? 'Back Camera'
                        : 'Front Camera',
                    trailing: Switch(
                      value: cameraProvider.lensDirection == CameraLensDirection.front,
                      onChanged: (value) => cameraProvider.toggleCameraLens(),
                    ),
                  ),
                  
                  const SizedBox(height: 100), // Space for bottom nav
                ],
              ),
            ),

            // Bottom Navigation
            Container(
              margin: const EdgeInsets.all(24),
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppTheme.cardBg,
                borderRadius: BorderRadius.circular(30),
                border: Border.all(color: AppTheme.borderColor),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildNavItem(Icons.home, 0, () => Navigator.pop(context)),
                  _buildNavItem(Icons.access_time, 1, () {}),
                  _buildNavItem(Icons.settings, 2, () {}),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(IconData icon, int index, VoidCallback onTap) {
    final isSelected = index == 2; // Settings is always selected on this screen
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: isSelected
              ? AppTheme.accentPurple.withOpacity(0.15)
              : Colors.transparent,
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          color: isSelected ? AppTheme.accentPurple : AppTheme.textSub,
          size: 22,
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w600,
        color: AppTheme.textSub,
        letterSpacing: 1,
      ),
    );
  }

  Widget _buildSecurityItem(IconData icon, String title, String subtitle) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: AppTheme.borderColor, width: 1),
        ),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.green, size: 20),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                    color: AppTheme.textMain,
                  ),
                ),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppTheme.textSub,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.15),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Text(
              'Always ON',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildListCard({
    required Widget leading,
    required String title,
    required String subtitle,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.borderColor),
      ),
      child: ListTile(
        leading: leading,
        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            color: AppTheme.textMain,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: const TextStyle(
            fontSize: 12,
            color: AppTheme.textSub,
          ),
        ),
        trailing: trailing,
        onTap: onTap,
        enabled: onTap != null,
      ),
    );
  }
}
