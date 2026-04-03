import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hand2voice/core/theme/app_theme.dart';
import 'package:hand2voice/core/providers/auth_provider.dart';
import 'package:hand2voice/core/services/onboarding_service.dart';
import 'package:hand2voice/features/home/screens/home_screen.dart';

class OptionalFeaturesScreen extends StatefulWidget {
  const OptionalFeaturesScreen({super.key});

  @override
  State<OptionalFeaturesScreen> createState() => _OptionalFeaturesScreenState();
}

class _OptionalFeaturesScreenState extends State<OptionalFeaturesScreen> {
  final OnboardingService _onboardingService = OnboardingService();
  bool _biometricEnabled = false;
  bool _autoLockEnabled = false;
  int _autoLockTimeout = 5;

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();

    return Scaffold(
      backgroundColor: AppTheme.appBg,
      appBar: AppBar(
        title: const Text('Optional Features'),
        automaticallyImplyLeading: false,
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Icon
                  Center(
                    child: Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: AppTheme.accentTeal.withOpacity(0.15),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.tune,
                        size: 28,
                        color: AppTheme.accentTeal,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Title
                  const Text(
                    'Enhance Your Security',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textMain,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  // Description
                  const Text(
                    'These features are optional but recommended.',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppTheme.textSub,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 40),
                  // Biometric Option
                  if (authProvider.isBiometricAvailable)
                    _buildOptionalFeature(
                      icon: Icons.fingerprint,
                      title: '${authProvider.getBiometricDescription()} Lock',
                      description: 'Unlock faster with biometric authentication',
                      value: _biometricEnabled,
                      onChanged: (value) {
                        setState(() {
                          _biometricEnabled = value;
                        });
                      },
                      badge: 'Recommended',
                    ),
                  if (authProvider.isBiometricAvailable) const SizedBox(height: 16),
                  // Auto-Lock Option
                  _buildOptionalFeature(
                    icon: Icons.timer,
                    title: 'Auto-Lock',
                    description: 'Automatically lock app after inactivity',
                    value: _autoLockEnabled,
                    onChanged: (value) {
                      setState(() {
                        _autoLockEnabled = value;
                      });
                    },
                    badge: 'Recommended',
                  ),
                  if (_autoLockEnabled) ...[
                    const SizedBox(height: 16),
                    Padding(
                      padding: const EdgeInsets.only(left: 60),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Lock after: $_autoLockTimeout minutes',
                            style: const TextStyle(
                              fontSize: 14,
                              color: AppTheme.textSub,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Slider(
                            value: _autoLockTimeout.toDouble(),
                            min: 1,
                            max: 30,
                            divisions: 5,
                            label: '$_autoLockTimeout min',
                            onChanged: (value) {
                              setState(() {
                                _autoLockTimeout = value.toInt();
                              });
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
          // Bottom Buttons
          Container(
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(
              color: AppTheme.appBg,
              border: Border(
                top: BorderSide(color: AppTheme.borderColor, width: 1),
              ),
            ),
            child: Column(
              children: [
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: () => _completeSetup(context, authProvider),
                    child: const Text('Complete Setup'),
                  ),
                ),
                const SizedBox(height: 15),
                Center(
                  child: TextButton(
                    onPressed: () => _skipOptionalFeatures(context),
                    child: const Text(
                      'Skip for Now',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: AppTheme.textSub,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOptionalFeature({
    required IconData icon,
    required String title,
    required String description,
    required bool value,
    required ValueChanged<bool> onChanged,
    String? badge,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.borderColor),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              size: 20,
              color: AppTheme.accentTeal,
            ),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textMain,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppTheme.textSub,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }

  Future<void> _completeSetup(
    BuildContext context,
    AuthProvider authProvider,
  ) async {
    // Apply optional settings
    if (_biometricEnabled && authProvider.isBiometricAvailable) {
      await authProvider.toggleBiometric(true);
    }
    
    if (_autoLockEnabled) {
      await authProvider.toggleAutoLock(true);
      await authProvider.setAutoLockTimeout(_autoLockTimeout);
    }

    // Mark onboarding as complete
    await _onboardingService.completeOnboarding();

    // Navigate to home
    if (context.mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const HomeScreen()),
        (route) => false,
      );
    }
  }

  Future<void> _skipOptionalFeatures(BuildContext context) async {
    // Mark onboarding as complete
    await _onboardingService.completeOnboarding();

    // Navigate to home
    if (context.mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const HomeScreen()),
        (route) => false,
      );
    }
  }
}
