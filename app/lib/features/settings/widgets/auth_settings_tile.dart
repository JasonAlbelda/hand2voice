import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hand2voice/core/providers/auth_provider.dart';
import 'package:hand2voice/features/auth/screens/pin_setup_screen.dart';
import 'package:hand2voice/features/auth/screens/pattern_setup_screen.dart';

class AuthSettingsTile extends StatelessWidget {
  const AuthSettingsTile({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, _) {
        return Card(
          margin: const EdgeInsets.all(16),
          child: Column(
            children: [
              ListTile(
                leading: Icon(Icons.security, color: Colors.blue.shade700),
                title: const Text(
                  'Security & Authentication',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ),
              const Divider(),
              
              // Biometric Authentication
              if (authProvider.isBiometricAvailable)
                SwitchListTile(
                  secondary: const Icon(Icons.fingerprint),
                  title: Text(
                    '${authProvider.getBiometricDescription()} Lock',
                  ),
                  subtitle: const Text('Use biometric to unlock app'),
                  value: authProvider.isBiometricEnabled,
                  onChanged: (value) async {
                    await authProvider.toggleBiometric(value);
                  },
                ),
              
              // PIN Authentication
              ListTile(
                leading: const Icon(Icons.dialpad),
                title: const Text('PIN Lock'),
                subtitle: Text(
                  authProvider.isPinEnabled
                      ? 'PIN is enabled'
                      : 'Set up PIN authentication',
                ),
                trailing: authProvider.isPinEnabled
                    ? IconButton(
                        icon: const Icon(Icons.delete_outline, color: Colors.red),
                        onPressed: () async {
                          final confirm = await showDialog<bool>(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text('Disable PIN'),
                              content: const Text(
                                'Are you sure you want to disable PIN authentication?',
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context, false),
                                  child: const Text('Cancel'),
                                ),
                                TextButton(
                                  onPressed: () => Navigator.pop(context, true),
                                  child: const Text(
                                    'Disable',
                                    style: TextStyle(color: Colors.red),
                                  ),
                                ),
                              ],
                            ),
                          );
                          
                          if (confirm == true) {
                            await authProvider.disablePin();
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('PIN disabled'),
                                ),
                              );
                            }
                          }
                        },
                      )
                    : const Icon(Icons.chevron_right),
                onTap: authProvider.isPinEnabled
                    ? null
                    : () async {
                        final result = await Navigator.push<bool>(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const PinSetupScreen(),
                          ),
                        );
                        
                        if (result == true && context.mounted) {
                          await authProvider.initialize();
                        }
                      },
              ),
              
              // Pattern Authentication
              ListTile(
                leading: const Icon(Icons.pattern),
                title: const Text('Pattern Lock'),
                subtitle: Text(
                  authProvider.isPatternEnabled
                      ? 'Pattern is enabled'
                      : 'Set up pattern authentication',
                ),
                trailing: authProvider.isPatternEnabled
                    ? IconButton(
                        icon: const Icon(Icons.delete_outline, color: Colors.red),
                        onPressed: () async {
                          final confirm = await showDialog<bool>(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text('Disable Pattern'),
                              content: const Text(
                                'Are you sure you want to disable pattern authentication?',
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context, false),
                                  child: const Text('Cancel'),
                                ),
                                TextButton(
                                  onPressed: () => Navigator.pop(context, true),
                                  child: const Text(
                                    'Disable',
                                    style: TextStyle(color: Colors.red),
                                  ),
                                ),
                              ],
                            ),
                          );
                          
                          if (confirm == true) {
                            await authProvider.disablePattern();
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Pattern disabled'),
                                ),
                              );
                            }
                          }
                        },
                      )
                    : const Icon(Icons.chevron_right),
                onTap: authProvider.isPatternEnabled
                    ? null
                    : () async {
                        final result = await Navigator.push<bool>(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const PatternSetupScreen(),
                          ),
                        );
                        
                        if (result == true && context.mounted) {
                          await authProvider.initialize();
                        }
                      },
              ),
              
              const Divider(),
              
              // Auto-Lock Settings
              SwitchListTile(
                secondary: const Icon(Icons.timer),
                title: const Text('Auto-Lock'),
                subtitle: Text(
                  authProvider.isAutoLockEnabled
                      ? 'Lock after ${authProvider.autoLockTimeout} min of inactivity'
                      : 'Automatically lock app after inactivity',
                ),
                value: authProvider.isAutoLockEnabled,
                onChanged: authProvider.isAnyAuthEnabled
                    ? (value) async {
                        await authProvider.toggleAutoLock(value);
                      }
                    : null,
              ),
              
              // Auto-Lock Timeout
              if (authProvider.isAutoLockEnabled)
                ListTile(
                  leading: const SizedBox(width: 40),
                  title: const Text('Auto-Lock Timeout'),
                  subtitle: Text('${authProvider.autoLockTimeout} minutes'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () async {
                    final timeout = await showDialog<int>(
                      context: context,
                      builder: (context) => _AutoLockTimeoutDialog(
                        currentTimeout: authProvider.autoLockTimeout,
                      ),
                    );
                    
                    if (timeout != null) {
                      await authProvider.setAutoLockTimeout(timeout);
                    }
                  },
                ),
              
              const SizedBox(height: 8),
              
              // Manual Lock Button (for testing)
              if (authProvider.isAnyAuthEnabled)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: ElevatedButton.icon(
                    onPressed: () {
                      authProvider.logout();
                      Navigator.of(context).popUntil((route) => route.isFirst);
                    },
                    icon: const Icon(Icons.lock),
                    label: const Text('Lock App Now'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      foregroundColor: Colors.white,
                      minimumSize: const Size(double.infinity, 48),
                    ),
                  ),
                ),
              
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }
}

class _AutoLockTimeoutDialog extends StatefulWidget {
  final int currentTimeout;

  const _AutoLockTimeoutDialog({required this.currentTimeout});

  @override
  State<_AutoLockTimeoutDialog> createState() => _AutoLockTimeoutDialogState();
}

class _AutoLockTimeoutDialogState extends State<_AutoLockTimeoutDialog> {
  late int _selectedTimeout;
  final List<int> _timeoutOptions = [1, 2, 5, 10, 15, 30];

  @override
  void initState() {
    super.initState();
    _selectedTimeout = widget.currentTimeout;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Auto-Lock Timeout'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: _timeoutOptions.map((timeout) {
          return RadioListTile<int>(
            title: Text('$timeout ${timeout == 1 ? 'minute' : 'minutes'}'),
            value: timeout,
            groupValue: _selectedTimeout,
            onChanged: (value) {
              setState(() {
                _selectedTimeout = value!;
              });
            },
          );
        }).toList(),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context, _selectedTimeout),
          child: const Text('Save'),
        ),
      ],
    );
  }
}
