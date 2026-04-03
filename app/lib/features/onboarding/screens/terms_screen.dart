import 'package:flutter/material.dart';
import 'package:hand2voice/core/theme/app_theme.dart';
import 'package:hand2voice/core/services/onboarding_service.dart';
import 'package:hand2voice/features/onboarding/screens/security_explanation_screen.dart';

class TermsScreen extends StatefulWidget {
  const TermsScreen({super.key});

  @override
  State<TermsScreen> createState() => _TermsScreenState();
}

class _TermsScreenState extends State<TermsScreen> {
  final OnboardingService _onboardingService = OnboardingService();
  bool _acceptedTerms = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.appBg,
      appBar: AppBar(
        title: const Text('Terms & Conditions'),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Terms of Service',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textMain,
                    ),
                  ),
                  const SizedBox(height: 20),
                  _buildSection(
                    'Privacy & Data Protection',
                    'Hand2Voice takes your privacy seriously. All your voice recordings and personal data are encrypted and stored securely on your device.',
                  ),
                  _buildSection(
                    'Data Encryption',
                    'All data, including voice recordings, videos, and personal information, is automatically encrypted using industry-standard encryption methods.',
                  ),
                  _buildSection(
                    'Authentication Required',
                    'To access the app, you must set up either a PIN or Pattern lock. This ensures that only you can access your private recordings.',
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
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
                Row(
                  children: [
                    SizedBox(
                      width: 18,
                      height: 18,
                      child: Checkbox(
                        value: _acceptedTerms,
                        onChanged: (value) {
                          setState(() {
                            _acceptedTerms = value ?? false;
                          });
                        },
                        activeColor: AppTheme.accentTeal,
                        side: const BorderSide(color: AppTheme.textSub),
                      ),
                    ),
                    const SizedBox(width: 10),
                    const Expanded(
                      child: Text(
                        'I accept the Terms & Conditions',
                        style: TextStyle(
                          fontSize: 14,
                          color: AppTheme.textMain,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 15),
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _acceptedTerms
                        ? () async {
                            await _onboardingService.acceptTerms();
                            if (context.mounted) {
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      const SecurityExplanationScreen(),
                                ),
                              );
                            }
                          }
                        : null,
                    child: const Text('Accept & Continue'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection(String title, String content) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppTheme.textMain,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            content,
            style: const TextStyle(
              fontSize: 14,
              color: AppTheme.textSub,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
