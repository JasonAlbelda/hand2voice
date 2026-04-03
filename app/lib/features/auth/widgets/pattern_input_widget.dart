import 'package:flutter/material.dart';
import 'package:hand2voice/core/theme/app_theme.dart';
import 'dart:math' as math;

/// Widget for pattern lock input
class PatternInputWidget extends StatefulWidget {
  final int gridSize;
  final Function(List<int>) onCompleted;
  final VoidCallback? onChanged;

  const PatternInputWidget({
    super.key,
    this.gridSize = 3,
    required this.onCompleted,
    this.onChanged,
  });

  @override
  State<PatternInputWidget> createState() => PatternInputWidgetState();
}

class PatternInputWidgetState extends State<PatternInputWidget> {
  final List<int> _selectedDots = [];
  Offset? _currentDragPosition;

  void _onDotSelected(int index) {
    if (!_selectedDots.contains(index)) {
      setState(() {
        _selectedDots.add(index);
      });
      widget.onChanged?.call();
    }
  }

  void _onPanUpdate(DragUpdateDetails details, Size size) {
    setState(() {
      _currentDragPosition = details.localPosition;
    });

    // Check if finger is over any dot
    final dotSize = size.width / widget.gridSize;
    for (int i = 0; i < widget.gridSize * widget.gridSize; i++) {
      final row = i ~/ widget.gridSize;
      final col = i % widget.gridSize;
      final dotCenter = Offset(
        col * dotSize + dotSize / 2,
        row * dotSize + dotSize / 2,
      );

      final distance = (details.localPosition - dotCenter).distance;
      if (distance < dotSize / 2 && !_selectedDots.contains(i)) {
        _onDotSelected(i);
      }
    }
  }

  void _onPanEnd() {
    if (_selectedDots.length >= 4) {
      widget.onCompleted(_selectedDots);
    }
    setState(() {
      _selectedDots.clear();
      _currentDragPosition = null;
    });
  }

  void clear() {
    setState(() {
      _selectedDots.clear();
      _currentDragPosition = null;
    });
    widget.onChanged?.call();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          _selectedDots.isEmpty
              ? 'Draw your pattern'
              : 'Pattern: ${_selectedDots.length} dots',
          style: const TextStyle(
            fontSize: 14,
            color: AppTheme.textSub,
          ),
        ),
        const SizedBox(height: 32),
        LayoutBuilder(
          builder: (context, constraints) {
            final size = math.min(constraints.maxWidth, 300.0);
            return SizedBox(
              width: size,
              height: size,
              child: GestureDetector(
                onPanUpdate: (details) => _onPanUpdate(details, Size(size, size)),
                onPanEnd: (_) => _onPanEnd(),
                child: CustomPaint(
                  painter: PatternPainter(
                    gridSize: widget.gridSize,
                    selectedDots: _selectedDots,
                    currentDragPosition: _currentDragPosition,
                  ),
                  child: Container(),
                ),
              ),
            );
          },
        ),
        const SizedBox(height: 32),
        if (_selectedDots.isNotEmpty)
          TextButton.icon(
            onPressed: clear,
            icon: const Icon(Icons.refresh, color: AppTheme.textSub),
            label: const Text(
              'Clear',
              style: TextStyle(color: AppTheme.textSub),
            ),
          ),
      ],
    );
  }
}

class PatternPainter extends CustomPainter {
  final int gridSize;
  final List<int> selectedDots;
  final Offset? currentDragPosition;

  PatternPainter({
    required this.gridSize,
    required this.selectedDots,
    this.currentDragPosition,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final dotSize = size.width / gridSize;
    final dotRadius = dotSize / 6;

    // Draw lines between selected dots
    if (selectedDots.length > 1) {
      final linePaint = Paint()
        ..color = AppTheme.accentTeal.withOpacity(0.8)
        ..strokeWidth = 4
        ..strokeCap = StrokeCap.round;

      for (int i = 0; i < selectedDots.length - 1; i++) {
        final start = _getDotCenter(selectedDots[i], dotSize);
        final end = _getDotCenter(selectedDots[i + 1], dotSize);
        canvas.drawLine(start, end, linePaint);
      }

      // Draw line to current drag position
      if (currentDragPosition != null && selectedDots.isNotEmpty) {
        final lastDot = _getDotCenter(selectedDots.last, dotSize);
        canvas.drawLine(lastDot, currentDragPosition!, linePaint);
      }
    }

    // Draw dots
    for (int i = 0; i < gridSize * gridSize; i++) {
      final center = _getDotCenter(i, dotSize);
      final isSelected = selectedDots.contains(i);

      // Outer circle
      final outerPaint = Paint()
        ..color = isSelected
            ? AppTheme.accentTeal
            : AppTheme.textSub.withOpacity(0.5)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2;
      canvas.drawCircle(center, dotRadius * 1.5, outerPaint);

      // Inner circle
      if (isSelected) {
        final innerPaint = Paint()
          ..color = AppTheme.accentTeal
          ..style = PaintingStyle.fill;
        canvas.drawCircle(center, dotRadius, innerPaint);
      }
    }
  }

  Offset _getDotCenter(int index, double dotSize) {
    final row = index ~/ gridSize;
    final col = index % gridSize;
    return Offset(
      col * dotSize + dotSize / 2,
      row * dotSize + dotSize / 2,
    );
  }

  @override
  bool shouldRepaint(PatternPainter oldDelegate) {
    return oldDelegate.selectedDots != selectedDots ||
        oldDelegate.currentDragPosition != currentDragPosition;
  }
}
