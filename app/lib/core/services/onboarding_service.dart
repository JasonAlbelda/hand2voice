import 'package:shared_preferences/shared_preferences.dart';

/// Service to manage onboarding state
class OnboardingService {
  static const String _onboardingCompleteKey = 'onboarding_complete';
  static const String _termsAcceptedKey = 'terms_accepted';
  static const String _securitySetupCompleteKey = 'security_setup_complete';

  /// Check if onboarding is complete
  Future<bool> isOnboardingComplete() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_onboardingCompleteKey) ?? false;
  }

  /// Check if terms are accepted
  Future<bool> areTermsAccepted() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_termsAcceptedKey) ?? false;
  }

  /// Check if security setup is complete
  Future<bool> isSecuritySetupComplete() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_securitySetupCompleteKey) ?? false;
  }

  /// Mark terms as accepted
  Future<void> acceptTerms() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_termsAcceptedKey, true);
  }

  /// Mark security setup as complete
  Future<void> completeSecuritySetup() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_securitySetupCompleteKey, true);
  }

  /// Mark onboarding as complete
  Future<void> completeOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_onboardingCompleteKey, true);
  }

  /// Reset onboarding (for testing)
  Future<void> resetOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_onboardingCompleteKey);
    await prefs.remove(_termsAcceptedKey);
    await prefs.remove(_securitySetupCompleteKey);
  }
}
