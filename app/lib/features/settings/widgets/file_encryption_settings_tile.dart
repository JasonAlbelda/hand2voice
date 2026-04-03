import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hand2voice/core/providers/file_encryption_provider.dart';

class FileEncryptionSettingsTile extends StatelessWidget {
  const FileEncryptionSettingsTile({super.key});

  void _showInfoDialog(BuildContext context, FileEncryptionProvider provider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.video_library_outlined, color: Colors.blue),
            SizedBox(width: 8),
            Text('Video Encryption'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Protects your recorded videos with AES-256 encryption.'),
            SizedBox(height: 16),
            Text('Status:', style: TextStyle(fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            Text('Encrypted videos: ${provider.encryptedFilesCount}'),
            Text('Encryption: ${provider.isFileEncryptionEnabled ? "Enabled" : "Disabled"}'),
          ],
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

  @override
  Widget build(BuildContext context) {
    return Consumer<FileEncryptionProvider>(
      builder: (context, fileEncryptionProvider, _) {
        if (fileEncryptionProvider.isLoading) {
          return ListTile(
            leading: Icon(Icons.video_library_outlined, color: Colors.grey),
            title: Text('Video Encryption'),
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
            fileEncryptionProvider.isFileEncryptionEnabled
                ? Icons.video_library
                : Icons.video_library_outlined,
            color: fileEncryptionProvider.isFileEncryptionEnabled
                ? Colors.green
                : Colors.grey,
          ),
          title: Text('Video Encryption'),
          subtitle: Text(
            fileEncryptionProvider.isFileEncryptionEnabled
                ? 'Videos encrypted (${fileEncryptionProvider.encryptedFilesCount} files)'
                : 'Tap to encrypt recorded videos',
          ),
          value: fileEncryptionProvider.isFileEncryptionEnabled,
          onChanged: (bool value) async {
            await fileEncryptionProvider.toggleFileEncryption(value);
            
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    value
                        ? 'Video encryption enabled'
                        : 'Video encryption disabled',
                  ),
                  backgroundColor: value ? Colors.green : Colors.orange,
                  action: SnackBarAction(
                    label: 'Info',
                    textColor: Colors.white,
                    onPressed: () => _showInfoDialog(context, fileEncryptionProvider),
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
