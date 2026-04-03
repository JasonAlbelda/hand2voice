import 'package:flutter/material.dart';
import 'package:hand2voice/core/theme/app_theme.dart';

/// Widget for PIN input with visual feedback
class PinInputWidget extends StatefulWidget {
  final int pinLength;
  final Function(String) onCompleted;
  final VoidCallback? onChanged;
  final bool obscureText;

  const PinInputWidget({
    super.key,
    this.pinLength = 4,
    required this.onCompleted,
    this.onChanged,
    this.obscureText = true,
  });

  @override
  State<PinInputWidget> createState() => PinInputWidgetState();
}

class PinInputWidgetState extends State<PinInputWidget> {
  String _pin = '';

  void _addDigit(String digit) {
    if (_pin.length < widget.pinLength) {
      setState(() {
        _pin += digit;
      });
      widget.onChanged?.call();
      
      if (_pin.length == widget.pinLength) {
        widget.onCompleted(_pin);
      }
    }
  }

  void _removeDigit() {
    if (_pin.isNotEmpty) {
      setState(() {
        _pin = _pin.substring(0, _pin.length - 1);
      });
      widget.onChanged?.call();
    }
  }

  void clear() {
    setState(() {
      _pin = '';
    });
    widget.onChanged?.call();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // PIN display
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            widget.pinLength,
            (index) => Container(
              margin: const EdgeInsets.symmetric(horizontal: 8),
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: index < _pin.length
                    ? AppTheme.accentTeal
                    : Colors.transparent,
                border: Border.all(
                  color: index < _pin.length 
                      ? AppTheme.accentTeal 
                      : AppTheme.textSub,
                  width: 2,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 48),
        // Number pad
        GridView.count(
          shrinkWrap: true,
          crossAxisCount: 3,
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          padding: const EdgeInsets.symmetric(horizontal: 32),
          children: [
            ...List.generate(9, (index) {
              final digit = (index + 1).toString();
              return _buildNumberButton(digit);
            }),
            _buildActionButton(
              icon: Icons.backspace_outlined,
              onPressed: _removeDigit,
            ),
            _buildNumberButton('0'),
            _buildActionButton(
              icon: Icons.clear,
              onPressed: clear,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildNumberButton(String number) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.cardBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.borderColor),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _addDigit(number),
          borderRadius: BorderRadius.circular(20),
          child: Center(
            child: Text(
              number,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w600,
                color: AppTheme.textMain,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(20),
        child: Center(
          child: Icon(
            icon,
            size: 28,
            color: AppTheme.textSub,
          ),
        ),
      ),
    );
  }
}
