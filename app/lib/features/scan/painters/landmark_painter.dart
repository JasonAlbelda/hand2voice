import 'package:flutter/material.dart';
import 'dart:ui' as ui;

/// Custom painter to draw MediaPipe landmarks and connections on camera preview
class LandmarkPainter extends CustomPainter {
  final List<double> pose;
  final List<double> leftHand;
  final List<double> rightHand;
  final Size imageSize;
  
  LandmarkPainter({
    required this.pose,
    required this.leftHand,
    required this.rightHand,
    required this.imageSize,
  });
  
  @override
  void paint(Canvas canvas, Size size) {
    // Draw pose
    if (pose.isNotEmpty && pose.any((p) => p != 0.0)) {
      _drawPoseLandmarks(canvas, size);
      _drawPoseConnections(canvas, size);
    }
    
    // Draw left hand
    if (leftHand.isNotEmpty && leftHand.any((h) => h != 0.0)) {
      _drawHandLandmarks(canvas, size, leftHand, Colors.purple);
      _drawHandConnections(canvas, size, leftHand, Colors.purple);
    }
    
    // Draw right hand
    if (rightHand.isNotEmpty && rightHand.any((h) => h != 0.0)) {
      _drawHandLandmarks(canvas, size, rightHand, Colors.orange);
      _drawHandConnections(canvas, size, rightHand, Colors.orange);
    }
  }
  
  /// Draw pose landmarks (33 points)
  void _drawPoseLandmarks(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.red
      ..style = PaintingStyle.fill;
    
    // Extract and draw each pose landmark
    for (int i = 0; i < 33; i++) {
      final index = i * 4;
      if (index + 2 < pose.length) {
        final x = pose[index];
        final y = pose[index + 1];
        
        if (x != 0.0 || y != 0.0) {
          final point = _scalePoint(x, y, size);
          canvas.drawCircle(point, 5, paint);
        }
      }
    }
  }
  
  /// Draw pose connections (skeleton)
  void _drawPoseConnections(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.blue
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;
    
    // Define pose connections (based on MediaPipe Pose topology)
    final connections = [
      // Face
      [0, 1], [1, 2], [2, 3], [3, 7],
      [0, 4], [4, 5], [5, 6], [6, 8],
      [9, 10],
      
      // Torso
      [11, 12], [11, 13], [13, 15], [15, 17], [15, 19], [15, 21], [17, 19],
      [12, 14], [14, 16], [16, 18], [16, 20], [16, 22], [18, 20],
      [11, 23], [12, 24], [23, 24],
      
      // Legs
      [23, 25], [25, 27], [27, 29], [29, 31],
      [24, 26], [26, 28], [28, 30], [30, 32],
    ];
    
    for (final connection in connections) {
      final start = connection[0];
      final end = connection[1];
      
      final startIndex = start * 4;
      final endIndex = end * 4;
      
      if (startIndex + 2 < pose.length && endIndex + 2 < pose.length) {
        final x1 = pose[startIndex];
        final y1 = pose[startIndex + 1];
        final x2 = pose[endIndex];
        final y2 = pose[endIndex + 1];
        
        if ((x1 != 0.0 || y1 != 0.0) && (x2 != 0.0 || y2 != 0.0)) {
          final p1 = _scalePoint(x1, y1, size);
          final p2 = _scalePoint(x2, y2, size);
          canvas.drawLine(p1, p2, paint);
        }
      }
    }
  }
  
  /// Draw hand landmarks (21 points per hand)
  void _drawHandLandmarks(Canvas canvas, Size size, List<double> hand, Color color) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    
    for (int i = 0; i < 21; i++) {
      final index = i * 3;
      if (index + 2 < hand.length) {
        final x = hand[index];
        final y = hand[index + 1];
        
        if (x != 0.0 || y != 0.0) {
          final point = _scalePoint(x, y, size);
          canvas.drawCircle(point, 4, paint);
        }
      }
    }
  }
  
  /// Draw hand connections (skeleton)
  void _drawHandConnections(Canvas canvas, Size size, List<double> hand, Color color) {
    final paint = Paint()
      ..color = color.withOpacity(0.8)
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke;
    
    // Hand connections (MediaPipe Hand topology)
    final connections = [
      // Thumb
      [0, 1], [1, 2], [2, 3], [3, 4],
      
      // Index finger
      [0, 5], [5, 6], [6, 7], [7, 8],
      
      // Middle finger
      [0, 9], [9, 10], [10, 11], [11, 12],
      
      // Ring finger
      [0, 13], [13, 14], [14, 15], [15, 16],
      
      // Pinky
      [0, 17], [17, 18], [18, 19], [19, 20],
      
      // Palm
      [5, 9], [9, 13], [13, 17],
    ];
    
    for (final connection in connections) {
      final start = connection[0];
      final end = connection[1];
      
      final startIndex = start * 3;
      final endIndex = end * 3;
      
      if (startIndex + 2 < hand.length && endIndex + 2 < hand.length) {
        final x1 = hand[startIndex];
        final y1 = hand[startIndex + 1];
        final x2 = hand[endIndex];
        final y2 = hand[endIndex + 1];
        
        if ((x1 != 0.0 || y1 != 0.0) && (x2 != 0.0 || y2 != 0.0)) {
          final p1 = _scalePoint(x1, y1, size);
          final p2 = _scalePoint(x2, y2, size);
          canvas.drawLine(p1, p2, paint);
        }
      }
    }
  }
  
  /// Scale normalized coordinates (0-1) to screen coordinates
  Offset _scalePoint(double x, double y, Size size) {
    // MediaPipe returns normalized coordinates (0-1)
    // We need to flip X for front camera mirror effect
    return Offset(
      size.width * (1 - x),  // Flip X for mirror effect
      size.height * y,
    );
  }
  
  @override
  bool shouldRepaint(LandmarkPainter oldDelegate) {
    return pose != oldDelegate.pose ||
        leftHand != oldDelegate.leftHand ||
        rightHand != oldDelegate.rightHand;
  }
}