import 'package:flutter/material.dart';
import 'package:hand2voice/core/theme/app_theme.dart';
import 'package:hand2voice/core/services/pin_auth_service.dart';
import 'package:hand2voice/features/auth/widgets/pattern_input_widget.dart';

class PatternSetupScreen extends StatefulWidget {
  const PatternSetupScreen({super.key});

  @override
  State<PatternSetupScreen> createState() => _PatternSetupScreenState();
}

class _PatternSetupScreenState extends State<PatternSetupScreen> {
  final PinAuthService _pinAuthService = PinAuthService();
  List<int>? _firstPattern;
  bool _isConfirming = false;
  String _message = 'Draw your pattern (min 4 dots)';
  bool _isError = false;
  final GlobalKey<PatternInputWidgetState> _patternInputKey = GlobalKey();

  void _onPatternCompleted(List<int> pattern) async {
    if (pattern.length < 4) {
      setState(() {
        _message = 'Pattern too short (min 4 dots)';
        _isError = true;
      });
      // Auto-clear on error
      await Future.delayed(const Duration(milliseconds: 500));
      _patternInputKey.currentState?.clear();
      return;
    }

    if (!_isConfirming) {
      // First pattern entry
      setState(() {
        _firstPattern = pattern;
        _isConfirming = true;
        _message = 'Confirm your pattern';
        _isError = false;
      });
      // Auto-clear for confirmation
      await Future.delayed(const Duration(milliseconds: 300));
      _patternInputKey.currentState?.clear();
    } else {
      // Confirmation
      if (_patternsMatch(pattern, _firstPattern!)) {
        // Patterns match, save it
        try {
          await _pinAuthService.setPattern(pattern);
          if (mounted) {
            Navigator.pop(context, true);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Pattern set successfully'),
                backgroundColor: Colors.green,
              ),
            );
          }
        } catch (e) {
          setState(() {
            _message = 'Error setting pattern';
            _isError = true;
            _isConfirming = false;
            _firstPattern = null;
          });
          _patternInputKey.currentState?.clear();
        }
      } else {
        // Patterns don't match
        setState(() {
          _message = 'Patterns do not match. Try again';
          _isError = true;
          _isConfirming = false;
          _firstPattern = null;
        });
        // Auto-clear on error
        await Future.delayed(const Duration(milliseconds: 500));
        _patternInputKey.currentState?.clear();
      }
    }
  }

  bool _patternsMatch(List<int> pattern1, List<int> pattern2) {
    if (pattern1.length != pattern2.length) return false;
    for (int i = 0; i < pattern1.length; i++) {
      if (pattern1[i] != pattern2[i]) return false;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.appBg,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Icon(
                      Icons.arrow_back,
                      color: AppTheme.textMain,
                      size: 24,
                    ),
                  ),
                ],
              ),
            ),
            
            // Content
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: _isConfirming 
                          ? Colors.green.withOpacity(0.15)
                          : AppTheme.accentTeal.withOpacity(0.15),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      _isConfirming ? Icons.check_circle_outline : Icons.pattern,
                      size: 28,
                      color: _isConfirming ? Colors.green : AppTheme.accentTeal,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    _message,
                    style: TextStyle(
                      fontSize: 16,
                      color: _isError ? Colors.red : AppTheme.textMain,
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 48),
                  PatternInputWidget(
                    key: _patternInputKey,
                    onCompleted: _onPatternCompleted,
                    onChanged: () {
                      if (_isError) {
                        setState(() {
                          _isError = false;
                          _message = _isConfirming
                              ? 'Confirm your pattern'
                              : 'Draw your pattern (min 4 dots)';
                        });
                      }
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
