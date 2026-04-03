import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hand2voice/core/providers/screen_security_provider.dart';
import 'dart:io';

class ScreenSecuritySettingsTile extends StatelessWidget {
  const ScreenSecuritySettingsTile({super.key});

  void _showInfoDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.security, color: Colors.blue),
            SizedBox(width: 8),
            Text('Screen Security'),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'When enabled, this feature protects your privacy by:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 12),
              _buildInfoItem(
                Icons.screenshot_monitor,
                'Prevents Screenshots',
                'Users cannot take screenshots of the app',
              ),
              _buildInfoItem(
                Icons.videocam_off,
                'Blocks Screen Recording',
                'Screen recording is disabled',
              ),
              _buildInfoItem(
                Icons.visibility_off,
                'Hides in Task Switcher',
                'App preview is blurred in recent apps',
              ),
              SizedBox(height: 16),
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, color: Colors.blue, size: 20),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        Platform.isAndroid
                            ? 'Full protection on Android'
                            : 'Partial protection on iOS',
                        style: TextStyle(fontSize: 12, color: Colors.blue.shade900),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem(IconData icon, String title, String subtitle) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: Colors.green),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(fontWeight: FontWeight.w500),
                ),
                Text(
                  subtitle,
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ScreenSecurityProvider>(
      builder: (context, screenSecurityProvider, _) {
        if (screenSecurityProvider.isLoading) {
          return ListTile(
            leading: Icon(Icons.security, color: Colors.grey),
            title: Text('Screen Security'),
            subtitle: Text('Loading...'),
            trailing: SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          );
        }

        return SwitchListTile(
          secondary: Icon(
            screenSecurityProvider.isScreenSecurityEnabled
                ? Icons.security
                : Icons.security_outlined,
            color: screenSecurityProvider.isScreenSecurityEnabled
                ? Colors.green
                : Colors.grey,
          ),
          title: Text('Screen Security'),
          subtitle: Text(
            screenSecurityProvider.isScreenSecurityEnabled
                ? 'Screenshots and recording blocked'
                : 'Tap to prevent screenshots',
          ),
          value: screenSecurityProvider.isScreenSecurityEnabled,
          onChanged: (bool value) async {
            await screenSecurityProvider.toggleScreenSecurity(value);
            
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Row(
                    children: [
                      Icon(
                        value ? Icons.check_circle : Icons.info,
                        color: Colors.white,
                      ),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          value
                              ? 'Screen security enabled - Screenshots blocked'
                              : 'Screen security disabled - Screenshots allowed',
                        ),
                      ),
                    ],
                  ),
                  backgroundColor: value ? Colors.green : Colors.orange,
                  duration: Duration(seconds: 3),
                  action: SnackBarAction(
                    label: 'Info',
                    textColor: Colors.white,
                    onPressed: () => _showInfoDialog(context),
                  ),
                ),
              );
            }
          },
        );
      },
    );
  }
}
