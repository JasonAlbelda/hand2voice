import 'package:flutter/material.dart';
import 'package:hand2voice/core/theme/app_theme.dart';
import 'package:hand2voice/core/services/pin_auth_service.dart';
import 'package:hand2voice/features/auth/widgets/pin_input_widget.dart';

class PinSetupScreen extends StatefulWidget {
  const PinSetupScreen({super.key});

  @override
  State<PinSetupScreen> createState() => _PinSetupScreenState();
}

class _PinSetupScreenState extends State<PinSetupScreen> {
  final PinAuthService _pinAuthService = PinAuthService();
  String? _firstPin;
  bool _isConfirming = false;
  String _message = 'Enter a 4-digit PIN';
  bool _isError = false;
  final GlobalKey<PinInputWidgetState> _pinInputKey = GlobalKey();

  void _onPinCompleted(String pin) async {
    if (!_isConfirming) {
      // First PIN entry
      setState(() {
        _firstPin = pin;
        _isConfirming = true;
        _message = 'Confirm your PIN';
        _isError = false;
      });
      // Auto-clear for confirmation
      await Future.delayed(const Duration(milliseconds: 300));
      _pinInputKey.currentState?.clear();
    } else {
      // Confirmation
      if (pin == _firstPin) {
        // PINs match, save it
        try {
          await _pinAuthService.setPin(pin);
          if (mounted) {
            Navigator.pop(context, true);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('PIN set successfully'),
                backgroundColor: Colors.green,
              ),
            );
          }
        } catch (e) {
          setState(() {
            _message = 'Error setting PIN';
            _isError = true;
            _isConfirming = false;
            _firstPin = null;
          });
          _pinInputKey.currentState?.clear();
        }
      } else {
        // PINs don't match
        setState(() {
          _message = 'PINs do not match. Try again';
          _isError = true;
          _isConfirming = false;
          _firstPin = null;
        });
        // Auto-clear on error
        await Future.delayed(const Duration(milliseconds: 500));
        _pinInputKey.currentState?.clear();
      }
    }
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
                          : AppTheme.accentPurple.withOpacity(0.15),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      _isConfirming ? Icons.check_circle_outline : Icons.lock_outline,
                      size: 28,
                      color: _isConfirming ? Colors.green : AppTheme.accentPurple,
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
                  ),
                  const SizedBox(height: 48),
                  PinInputWidget(
                    key: _pinInputKey,
                    onCompleted: _onPinCompleted,
                    onChanged: () {
                      if (_isError) {
                        setState(() {
                          _isError = false;
                          _message = _isConfirming ? 'Confirm your PIN' : 'Enter a 4-digit PIN';
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
