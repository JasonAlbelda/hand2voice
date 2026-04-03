import 'package:flutter/material.dart';
import 'package:hand2voice/core/theme/app_theme.dart';
import 'package:hand2voice/features/auth/screens/pin_setup_screen.dart';
import 'package:hand2voice/features/auth/screens/pattern_setup_screen.dart';
import 'package:hand2voice/features/onboarding/screens/optional_features_screen.dart';

class SecuritySetupScreen extends StatelessWidget {
  const SecuritySetupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.appBg,
      appBar: AppBar(
        title: const Text('Secure Your App'),
        automaticallyImplyLeading: false,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            const SizedBox(height: 20),
            // Icon
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: AppTheme.accentPurple.withOpacity(0.15),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.lock,
                size: 28,
                color: AppTheme.accentPurple,
              ),
            ),
            const SizedBox(height: 20),
            // Title
            const Text(
              'Choose Your Lock',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppTheme.textMain,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            // Description
            const Text(
              'Set up either a PIN or Pattern lock.',
              style: TextStyle(
                fontSize: 14,
                color: AppTheme.textSub,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 40),
            // PIN Option
            _buildLockOption(
              context,
              icon: Icons.dialpad,
              title: 'PIN Lock',
              description: '4-digit PIN code',
              onTap: () async {
                final result = await Navigator.push<bool>(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const PinSetupScreen(),
                  ),
                );
                
                if (result == true && context.mounted) {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const OptionalFeaturesScreen(),
                    ),
                  );
                }
              },
            ),
            const SizedBox(height: 12),
            // Pattern Option
            _buildLockOption(
              context,
              icon: Icons.pattern,
              title: 'Pattern Lock',
              description: 'Draw a pattern on 3x3 grid',
              onTap: () async {
                final result = await Navigator.push<bool>(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const PatternSetupScreen(),
                  ),
                );
                
                if (result == true && context.mounted) {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const OptionalFeaturesScreen(),
                    ),
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLockOption(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String description,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.borderColor),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
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
              const Icon(
                Icons.chevron_right,
                color: AppTheme.borderColor,
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
