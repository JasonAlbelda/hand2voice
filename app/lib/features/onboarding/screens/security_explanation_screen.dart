import 'package:flutter/material.dart';
import 'package:hand2voice/core/theme/app_theme.dart';
import 'package:hand2voice/features/onboarding/screens/security_setup_screen.dart';

class SecurityExplanationScreen extends StatelessWidget {
  const SecurityExplanationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.appBg,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              const SizedBox(height: 20),
              // Security Icon
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: AppTheme.accentPurple.withOpacity(0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.security,
                  size: 28,
                  color: AppTheme.accentPurple,
                ),
              ),
              const SizedBox(height: 20),
              // Title
              const Text(
                'Secure Your App',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textMain,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              // Subtitle
              const Text(
                'Set up either a PIN or Pattern lock.',
                style: TextStyle(
                  fontSize: 14,
                  color: AppTheme.textSub,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              // Security Features
              _buildSecurityFeature(
                Icons.lock,
                'Data Encryption',
                'All your recordings and data are encrypted automatically',
                'Always ON',
              ),
              const SizedBox(height: 16),
              _buildSecurityFeature(
                Icons.block,
                'Screen Security',
                'Screenshots and screen recording are blocked',
                'Always ON',
              ),
              const SizedBox(height: 16),
              _buildSecurityFeature(
                Icons.videocam_off,
                'Video Encryption',
                'All video recordings are encrypted for your privacy',
                'Always ON',
              ),
              const Spacer(),
              const SizedBox(height: 20),
              // Continue Button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const SecuritySetupScreen(),
                      ),
                    );
                  },
                  child: const Text('Continue'),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSecurityFeature(
    IconData icon,
    String title,
    String description,
    String status,
  ) {
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
              color: AppTheme.accentTeal,
              size: 20,
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
}
