import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'dart:io';

class ResultScreen extends StatefulWidget {
  final String videoPath;
  final dynamic extractedData; // Can be List (Offline) or Map (Online)

  const ResultScreen({
    super.key,
    required this.videoPath,
    required this.extractedData,
  });

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> {
  late VideoPlayerController _controller;

  // Data Containers
  List<dynamic> _events = []; // Predicted Actions (Online only)
  List<dynamic> _rawFrames = []; // Landmarks for Drawing (Online & Offline)

  // State for UI
  Map<String, dynamic> _currentFrameFeatures = {};
  String _currentLabel = "";

  @override
  void initState() {
    super.initState();
    _parseData();

    _controller = VideoPlayerController.file(File(widget.videoPath))
      ..initialize().then((_) {
        setState(() {});
        _controller.play();
        _controller.setLooping(true);
        _controller.addListener(_updateUI);
      });
  }

  void _parseData() {
    // Case A: Online Mode (Returns Map with 'events' and 'frames')
    if (widget.extractedData is Map) {
      if (widget.extractedData.containsKey('events')) {
        _events = widget.extractedData['events'];
      }
      if (widget.extractedData.containsKey('frames')) {
        _rawFrames = widget.extractedData['frames'];
      }
    }
    // Case B: Offline Mode (Returns List of frames directly)
    else if (widget.extractedData is List) {
      _rawFrames = widget.extractedData;
    }
  }

  void _updateUI() {
    if (!_controller.value.isPlaying) return;

    final currentMs = _controller.value.position.inMilliseconds;
    final currentSeconds = currentMs / 1000.0;

    // 1. UPDATE PREDICTION LABEL (Events)
    String foundLabel = "";
    for (var event in _events) {
      final double start = (event['start_time'] as num).toDouble();
      final double end = (event['end_time'] as num).toDouble();

      if (currentSeconds >= start && currentSeconds <= end) {
        foundLabel =
            "${event['label']} (${(event['confidence'] * 100).toInt()}%)";
        break;
      }
    }
    if (foundLabel != _currentLabel) {
      setState(() => _currentLabel = foundLabel);
    }

    // 2. UPDATE DRAWING (Landmarks)
    // Find frame closest to current timestamp (within 100ms)
    // Optimization: In a real app, use binary search. Here we use linear for simplicity.
    Map<String, dynamic> foundFeatures = {};

    for (var frame in _rawFrames) {
      final int ts = frame['timestamp'] as int;
      if ((ts - currentMs).abs() < 100) {
        foundFeatures = Map<String, dynamic>.from(frame['features']);
        break;
      }
    }

    // Only update if changed to avoid unnecessary repaints
    if (foundFeatures.isNotEmpty && foundFeatures != _currentFrameFeatures) {
      setState(() => _currentFrameFeatures = foundFeatures);
    } else if (foundFeatures.isEmpty && _currentFrameFeatures.isNotEmpty) {
      // Clear dots if no data for this frame
      setState(() => _currentFrameFeatures = {});
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Even if controller not init, show loading.
    // If init, show video immediately regardless of data.
    if (!_controller.value.isInitialized) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(title: const Text("Result")),
      body: Column(
        children: [
          // ================= VIDEO AREA =================
          Expanded(
            flex: 3,
            child: Container(
              color: Colors.black,
              child: Center(
                child: AspectRatio(
                  aspectRatio: _controller.value.aspectRatio,
                  child: Stack(
                    alignment: Alignment.bottomCenter,
                    fit: StackFit.expand,
                    children: [
                      // 1. The Video
                      VideoPlayer(_controller),

                      // 2. The Landmarks (Clipped)
                      // ClipRect prevents "spider webs" flying off screen
                      ClipRect(
                        child: CustomPaint(
                          painter: HolisticPainter(
                            features: _currentFrameFeatures,
                          ),
                          size: Size.infinite,
                        ),
                      ),

                      // 3. The Label Overlay
                      if (_currentLabel.isNotEmpty)
                        Positioned(
                          bottom: 0,
                          left: 0,
                          right: 0,
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            color: Colors.black54,
                            child: Text(
                              _currentLabel,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                color: Colors.greenAccent,
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // ================= LIST / TIMELINE AREA =================
          Expanded(
            flex: 2,
            child: Container(
              color: Colors.white,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Text(
                      "Detected Actions:",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Expanded(
                    child: _events.isEmpty
                        ? _rawFrames.isEmpty
                              ? const Center(
                                  child: Text(
                                    "No features extracted.",
                                    style: TextStyle(color: Colors.red),
                                  ),
                                )
                              : const Center(
                                  child: Text(
                                    "Features extracted, but no specific actions recognized.",
                                    style: TextStyle(color: Colors.grey),
                                  ),
                                )
                        : ListView.separated(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            itemCount: _events.length,
                            separatorBuilder: (_, __) => const Divider(),
                            itemBuilder: (context, index) {
                              final event = _events[index];
                              return ListTile(
                                leading: CircleAvatar(
                                  backgroundColor: Colors.blue.shade100,
                                  child: Text("${index + 1}"),
                                ),
                                title: Text(
                                  event['label'],
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                  ),
                                ),
                                subtitle: Text(
                                  "${event['start_time']}s - ${event['end_time']}s",
                                ),
                                trailing: Text(
                                  "${(event['confidence'] * 100).toInt()}%",
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.blue,
                                  ),
                                ),
                                onTap: () {
                                  _controller.seekTo(
                                    Duration(
                                      milliseconds: (event['start_time'] * 1000)
                                          .toInt(),
                                    ),
                                  );
                                  _controller.play();
                                },
                              );
                            },
                          ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ================= PAINTER (Handles drawing dots/lines) =================
class HolisticPainter extends CustomPainter {
  final Map<String, dynamic> features;
  HolisticPainter({required this.features});

  // Stride 4 for Pose (x,y,z,vis), Stride 3 for Hands (x,y,z)

  static const List<List<int>> handConnections = [
    [0, 1],
    [1, 2],
    [2, 3],
    [3, 4],
    [0, 5],
    [5, 6],
    [6, 7],
    [7, 8],
    [5, 9],
    [9, 10],
    [10, 11],
    [11, 12],
    [9, 13],
    [13, 14],
    [14, 15],
    [15, 16],
    [13, 17],
    [0, 17],
    [17, 18],
    [18, 19],
    [19, 20],
  ];

  static const List<List<int>> poseConnections = [
    [11, 12],
    [11, 23],
    [12, 24],
    [23, 24],
    [11, 13],
    [13, 15],
    [12, 14],
    [14, 16],
    [23, 25],
    [25, 27],
    [27, 29],
    [29, 31],
    [24, 26],
    [26, 28],
    [28, 30],
    [30, 32],
  ];

  @override
  void paint(Canvas canvas, Size size) {
    if (features.isEmpty) return;

    final bonePaint = Paint()
      ..color = Colors.white.withOpacity(0.6)
      ..strokeWidth = 2.0;
    final posePaint = Paint()
      ..color = Colors.blueAccent
      ..strokeWidth = 4.0
      ..strokeCap = StrokeCap.round;
    final leftHandPaint = Paint()
      ..color = Colors.redAccent
      ..strokeWidth = 3.0
      ..strokeCap = StrokeCap.round;
    final rightHandPaint = Paint()
      ..color = Colors.greenAccent
      ..strokeWidth = 3.0
      ..strokeCap = StrokeCap.round;

    // Draw Pose (Stride 4)
    if (features.containsKey('pose')) {
      _drawObj(
        canvas,
        size,
        features['pose'],
        poseConnections,
        bonePaint,
        posePaint,
        4,
      );
    }
    // Draw Left Hand (Stride 3)
    if (features.containsKey('left_hand')) {
      _drawObj(
        canvas,
        size,
        features['left_hand'],
        handConnections,
        bonePaint,
        leftHandPaint,
        3,
      );
    }
    // Draw Right Hand (Stride 3)
    if (features.containsKey('right_hand')) {
      _drawObj(
        canvas,
        size,
        features['right_hand'],
        handConnections,
        bonePaint,
        rightHandPaint,
        3,
      );
    }
  }

  void _drawObj(
    Canvas canvas,
    Size size,
    List<dynamic> raw,
    List<List<int>> conns,
    Paint boneP,
    Paint jointP,
    int stride,
  ) {
    // 1. Draw Bones
    for (var pair in conns) {
      final i1 = pair[0];
      final i2 = pair[1];

      if (i1 * stride + 1 < raw.length && i2 * stride + 1 < raw.length) {
        final x1 = (raw[i1 * stride] as num).toDouble();
        final y1 = (raw[i1 * stride + 1] as num).toDouble();
        final x2 = (raw[i2 * stride] as num).toDouble();
        final y2 = (raw[i2 * stride + 1] as num).toDouble();

        // Safety check: Don't draw if coordinate is 0.0 (often means undetected)
        if (x1 > 0 && y1 > 0 && x2 > 0 && y2 > 0) {
          canvas.drawLine(
            Offset(x1 * size.width, y1 * size.height),
            Offset(x2 * size.width, y2 * size.height),
            boneP,
          );
        }
      }
    }

    // 2. Draw Joints
    final points = <Offset>[];
    for (int i = 0; i < raw.length; i += stride) {
      if (i + 1 < raw.length) {
        final x = (raw[i] as num).toDouble();
        final y = (raw[i + 1] as num).toDouble();
        if (x > 0 && y > 0) {
          points.add(Offset(x * size.width, y * size.height));
        }
      }
    }
    canvas.drawPoints(PointMode.points, points, jointP);
  }

  @override
  bool shouldRepaint(covariant HolisticPainter oldDelegate) =>
      oldDelegate.features != features;
}
