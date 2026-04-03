import 'package:flutter/material.dart';
import 'package:hand2voice/core/services/storage_migration_service.dart';

class EncryptionSettingsTile extends StatefulWidget {
  const EncryptionSettingsTile({super.key});

  @override
  State<EncryptionSettingsTile> createState() => _EncryptionSettingsTileState();
}

class _EncryptionSettingsTileState extends State<EncryptionSettingsTile> {
  bool _isEncrypted = false;
  bool _isLoading = true;
  Map<String, dynamic>? _migrationStatus;

  @override
  void initState() {
    super.initState();
    _checkEncryptionStatus();
  }

  Future<void> _checkEncryptionStatus() async {
    setState(() => _isLoading = true);
    
    try {
      final isComplete = await StorageMigrationService.isMigrationComplete();
      final status = await StorageMigrationService.getMigrationStatus();
      
      setState(() {
        _isEncrypted = isComplete;
        _migrationStatus = status;
        _isLoading = false;
      });
    } catch (e) {
      print('Error checking encryption status: $e');
      setState(() => _isLoading = false);
    }
  }

  Future<void> _enableEncryption() async {
    // Show confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.lock, color: Colors.blue),
            SizedBox(width: 8),
            Text('Enable Encryption'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('This will encrypt all your local data including:'),
            SizedBox(height: 12),
            _buildFeatureItem('Settings and preferences'),
            _buildFeatureItem('Translation history'),
            _buildFeatureItem('Camera preferences'),
            SizedBox(height: 12),
            Text(
              'Your data will be protected with AES-256 encryption.',
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text('Enable'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    // Show loading
    if (mounted) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => Center(
          child: Card(
            child: Padding(
              padding: EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Encrypting your data...'),
                ],
              ),
            ),
          ),
        ),
      );
    }

    try {
      await StorageMigrationService.migrateToEncryptedStorage();
      await StorageMigrationService.clearOldData();
      
      if (mounted) {
        Navigator.pop(context); // Close loading dialog
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 8),
                Text('Encryption enabled successfully'),
              ],
            ),
            backgroundColor: Colors.green,
          ),
        );
        
        await _checkEncryptionStatus();
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context); // Close loading dialog
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error enabling encryption: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Widget _buildFeatureItem(String text) {
    return Padding(
      padding: EdgeInsets.only(left: 8, bottom: 4),
      child: Row(
        children: [
          Icon(Icons.check, size: 16, color: Colors.green),
          SizedBox(width: 8),
          Expanded(child: Text(text, style: TextStyle(fontSize: 14))),
        ],
      ),
    );
  }

  void _showEncryptionInfo() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.info_outline, color: Colors.blue),
            SizedBox(width: 8),
            Text('Encryption Info'),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Your data is protected with:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 12),
              _buildInfoItem('AES-256 Encryption', 'Military-grade encryption'),
              _buildInfoItem('Secure Storage', 'Device Keychain/Keystore'),
              _buildInfoItem('Offline Security', 'Works without internet'),
              _buildInfoItem('Auto-Encrypted', 'All data encrypted automatically'),
              SizedBox(height: 16),
              if (_migrationStatus != null) ...[
                Text(
                  'Status:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 8),
                Text(
                  'Encrypted keys: ${_migrationStatus!['encrypted_keys_count'] ?? 0}',
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              ],
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

  Widget _buildInfoItem(String title, String subtitle) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.shield, size: 16, color: Colors.green),
          SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(fontWeight: FontWeight.w500)),
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
    if (_isLoading) {
      return ListTile(
        leading: Icon(Icons.lock_outline, color: Colors.grey),
        title: Text('Data Encryption'),
        subtitle: Text('Checking status...'),
        trailing: SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      );
    }

    return ListTile(
      leading: Icon(
        _isEncrypted ? Icons.lock : Icons.lock_open,
        color: _isEncrypted ? Colors.green : Colors.orange,
      ),
      title: Text('Data Encryption'),
      subtitle: Text(
        _isEncrypted
            ? 'All data is encrypted with AES-256'
            : 'Tap to enable encryption',
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (_isEncrypted)
            IconButton(
              icon: Icon(Icons.info_outline, size: 20),
              onPressed: _showEncryptionInfo,
              tooltip: 'Encryption info',
            ),
          Icon(
            _isEncrypted ? Icons.check_circle : Icons.arrow_forward_ios,
            color: _isEncrypted ? Colors.green : Colors.grey,
            size: _isEncrypted ? 24 : 16,
          ),
        ],
      ),
      onTap: _isEncrypted ? _showEncryptionInfo : _enableEncryption,
    );
  }
}
