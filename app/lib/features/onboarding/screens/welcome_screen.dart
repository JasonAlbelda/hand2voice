import 'package:flutter/material.dart';
import 'package:hand2voice/core/theme/app_theme.dart';
import 'package:hand2voice/features/onboarding/screens/terms_screen.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.appBg,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),
              // App Icon with modern styling
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: AppTheme.cardBg,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: AppTheme.borderColor, width: 1),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.accentTeal.withOpacity(0.1),
                      blurRadius: 20,
                      spreadRadius: 0,
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.waving_hand,
                  size: 40,
                  color: AppTheme.accentTeal,
                ),
              ),
              const SizedBox(height: 30),
              // App Name
              const Text(
                'Hand2Voice',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textMain,
                ),
              ),
              const SizedBox(height: 5),
              // Tagline
              const Text(
                'Your voice, your privacy',
                style: TextStyle(
                  fontSize: 14,
                  color: AppTheme.textSub,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),
              // Features
              _buildFeature(
                Icons.lock,
                'Secure & Private',
                'All data is encrypted',
                AppTheme.accentPurple,
              ),
              const SizedBox(height: 15),
              _buildFeature(
                Icons.mic,
                'Voice Recognition',
                'Convert sign to voice',
                AppTheme.accentTeal,
              ),
              const Spacer(),
              // Get Started Button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const TermsScreen(),
                      ),
                    );
                  },
                  child: const Text('Get Started'),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeature(IconData icon, String title, String description, Color iconColor) {
    return Row(
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
            color: iconColor,
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
              Text(
                description,
                style: const TextStyle(
                  fontSize: 13,
                  color: AppTheme.textSub,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
