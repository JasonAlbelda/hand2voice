import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'dart:io';

class ResultScreen extends StatefulWidget {
  final String videoPath;
  final List<dynamic> extractedData;

  const ResultScreen({super.key, required this.videoPath, required this.extractedData});

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> {
  late VideoPlayerController _controller;
  Map<String, dynamic> _currentFrameFeatures = {};
    Map<int, Map<String, dynamic>> _frameCache = {};
  List<int> _timestamps = [];

  @override
  void initState() {
    super.initState();
        for (var frame in widget.extractedData) {
      final ts = frame['timestamp'] as int;
      _timestamps.add(ts);
      _frameCache[ts] = Map<String, dynamic>.from(frame['features']);
    }
    _timestamps.sort();

    _controller = VideoPlayerController.file(File(widget.videoPath))
      ..initialize().then((_) {
        setState(() {});
        _controller.play();
        _controller.setLooping(true);
        _controller.addListener(_updateLandmarks);
      });
  }

  void _updateLandmarks() {
    if (!_controller.value.isPlaying || _timestamps.isEmpty) return;

    final int currentMs = _controller.value.position.inMilliseconds;

    // 2. FIND THE CLOSEST FRAME (Optimized)
    // We look for a frame that is within 50ms of the video head
    // Instead of looping, we can just find the closest index mathematically if timestamps are regular,
    // or use a simple heuristic.
    
    int closestTimestamp = -1;
    int minDiff = 10000;

    // A simple loop is fine here if list < 1000 items, 
    // but for best performance, binary search is ideal. 
    // For now, let's use a "smart search" closer to where we expect it to be.
    
    for (final ts in _timestamps) {
      final diff = (ts - currentMs).abs();
      if (diff < minDiff) {
        minDiff = diff;
        closestTimestamp = ts;
      }
      // If we passed the point, break early (optimization)
      if (ts > currentMs && diff > minDiff) break; 
    }

    // Only update if the closest frame is within valid range (e.g., 50ms)
    // 33ms is standard 30fps. 
    if (minDiff < 50 && closestTimestamp != -1) {
      final features = _frameCache[closestTimestamp];
      if (features != null && features != _currentFrameFeatures) {
        setState(() {
          _currentFrameFeatures = features;
        });
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_controller.value.isInitialized) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(title: const Text("Processed Output")),
      backgroundColor: Colors.black, // Dark background for video
      body: Center(
        child: AspectRatio(
          // 1. CRITICAL: Force the Stack to match Video Aspect Ratio
          aspectRatio: _controller.value.aspectRatio, 
          child: Stack(
            fit: StackFit.expand,
            children: [
              // 2. Video Player fits perfectly into the AspectRatio container
              VideoPlayer(_controller),
              
              // 3. Painter overlays perfectly on top
              CustomPaint(
                painter: HolisticPainter(features: _currentFrameFeatures),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class HolisticPainter extends CustomPainter {
  final Map<String, dynamic> features;
  HolisticPainter({required this.features});

  static const List<List<int>> handConnections = [
    [0, 1], [1, 2], [2, 3], [3, 4], [0, 5], [5, 6], [6, 7], [7, 8],
    [5, 9], [9, 10], [10, 11], [11, 12], [9, 13], [13, 14], [14, 15], [15, 16],
    [13, 17], [0, 17], [17, 18], [18, 19], [19, 20]
  ];

  static const List<List<int>> poseConnections = [
    [11, 12], [11, 23], [12, 24], [23, 24], [11, 13], [13, 15],
    [12, 14], [14, 16], [23, 25], [25, 27], [27, 29], [29, 31],
    [24, 26], [26, 28], [28, 30], [30, 32]
  ];

  @override
  void paint(Canvas canvas, Size size) {
    if (features.isEmpty) return;

    final bonePaint = Paint()..color = Colors.white.withOpacity(0.6)..strokeWidth = 2.0;
    final posePaint = Paint()..color = Colors.blueAccent..strokeWidth = 4.0..strokeCap = StrokeCap.round;
    final leftHandPaint = Paint()..color = Colors.redAccent..strokeWidth = 3.0..strokeCap = StrokeCap.round;
    final rightHandPaint = Paint()..color = Colors.greenAccent..strokeWidth = 3.0..strokeCap = StrokeCap.round;

    // 1. Draw Pose (STRIDE = 4 because data is x,y,z,visibility)
    if (features.containsKey('pose')) {
      _drawObj(canvas, size, features['pose'], poseConnections, bonePaint, posePaint, 4);
    }

    // 2. Draw Left Hand (STRIDE = 3 because data is x,y,z)
    if (features.containsKey('left_hand')) {
      _drawObj(canvas, size, features['left_hand'], handConnections, bonePaint, leftHandPaint, 3);
    }

    // 3. Draw Right Hand (STRIDE = 3 because data is x,y,z)
    if (features.containsKey('right_hand')) {
      _drawObj(canvas, size, features['right_hand'], handConnections, bonePaint, rightHandPaint, 3);
    }
  }

  void _drawObj(Canvas canvas, Size size, List<dynamic> raw, List<List<int>> conns, Paint boneP, Paint jointP, int stride) {
    // Draw Bones
    for (var pair in conns) {
      final idx1 = pair[0];
      final idx2 = pair[1];

      // Ensure indices don't exceed array length
      if (idx1 * stride + 1 < raw.length && idx2 * stride + 1 < raw.length) {
        final x1 = raw[idx1 * stride] as double;
        final y1 = raw[idx1 * stride + 1] as double;
        final x2 = raw[idx2 * stride] as double;
        final y2 = raw[idx2 * stride + 1] as double;

        canvas.drawLine(
          Offset(x1 * size.width, y1 * size.height),
          Offset(x2 * size.width, y2 * size.height),
          boneP,
        );
      }
    }

    // Draw Joints
    final points = <Offset>[];
    for (int i = 0; i < raw.length; i += stride) {
      if (i + 1 < raw.length) {
        points.add(Offset((raw[i] as double) * size.width, (raw[i + 1] as double) * size.height));
      }
    }
    canvas.drawPoints(PointMode.points, points, jointP);
  }

  @override
  bool shouldRepaint(covariant HolisticPainter oldDelegate) => oldDelegate.features != features;
}