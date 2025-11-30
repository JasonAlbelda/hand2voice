import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:permission_handler/permission_handler.dart';
import '../services/mediapipe_service.dart';
import '../painters/landmark_painter.dart';
import 'dart:typed_data';

class CameraScreen extends StatefulWidget {
  const CameraScreen({Key? key}) : super(key: key);

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  CameraController? _cameraController;
  final MediaPipeService _mediaPipeService = MediaPipeService();
  
  bool _isInitialized = false;
  bool _isProcessing = false;
  bool _isMediaPipeReady = false;
  
  // Feature extraction results
  Map<String, dynamic>? _lastFeatures;
  int _frameCount = 0;
  DateTime? _lastProcessTime;
  
  @override
  void initState() {
    super.initState();
    _initializeApp();
  }
  
  Future<void> _initializeApp() async {
    // Request camera permission
    final status = await Permission.camera.request();
    if (status.isGranted) {
      await _initializeCamera();
      await _initializeMediaPipe();
    } else {
      _showPermissionDialog();
    }
  }
  
  Future<void> _initializeCamera() async {
    try {
      final cameras = await availableCameras();
      if (cameras.isEmpty) {
        _showError('No cameras available');
        return;
      }
      
      // Use front camera for sign language
      final frontCamera = cameras.firstWhere(
        (camera) => camera.lensDirection == CameraLensDirection.front,
        orElse: () => cameras.first,
      );
      
      _cameraController = CameraController(
        frontCamera,
        ResolutionPreset.medium,
        enableAudio: false,
        imageFormatGroup: ImageFormatGroup.yuv420,
      );
      
      await _cameraController!.initialize();
      
      setState(() {
        _isInitialized = true;
      });
      
      print('Camera initialized successfully');
    } catch (e) {
      _showError('Failed to initialize camera: $e');
    }
  }
  
  Future<void> _initializeMediaPipe() async {
    try {
      final success = await _mediaPipeService.initializeMediaPipe();
      setState(() {
        _isMediaPipeReady = success;
      });
      
      if (success) {
        print('MediaPipe initialized successfully');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('MediaPipe ready for feature extraction'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
      } else {
        _showError('Failed to initialize MediaPipe');
      }
    } catch (e) {
      _showError('MediaPipe initialization error: $e');
    }
  }
  
  void _startProcessing() {
    if (!_isMediaPipeReady || _cameraController == null) {
      _showError('Camera or MediaPipe not ready');
      return;
    }
    
    setState(() {
      _isProcessing = true;
      _frameCount = 0;
    });
    
    _cameraController!.startImageStream(_processImageFrame);
  }
  
  void _stopProcessing() {
    if (_cameraController != null && _cameraController!.value.isStreamingImages) {
      _cameraController!.stopImageStream();
    }
    
    setState(() {
      _isProcessing = false;
    });
  }
  
  Future<void> _processImageFrame(CameraImage image) async {
    // Skip if already processing a frame
    if (_lastProcessTime != null) {
      final elapsed = DateTime.now().difference(_lastProcessTime!);
      if (elapsed.inMilliseconds < 100) { // Process max 10 FPS
        return;
      }
    }
    
    _lastProcessTime = DateTime.now();
    
    try {
      // Convert CameraImage to bytes
      final Uint8List bytes = _convertYUV420ToBytes(image);
      
      // Get camera rotation
      final rotation = _cameraController!.description.sensorOrientation;
      
      // Process frame through MediaPipe
      final result = await _mediaPipeService.processFrame(
        imageBytes: bytes,
        width: image.width,
        height: image.height,
        rotation: rotation,
      );
      
      if (result['success']) {
        setState(() {
          _lastFeatures = result;
          _frameCount++;
        });
        
        // Print features to console (for debugging)
        _printFeatures(result);
      }
    } catch (e) {
      print('Error processing frame: $e');
    }
  }
  
  Uint8List _convertYUV420ToBytes(CameraImage image) {
    // Get Y plane (luminance)
    final int yPlaneSize = image.planes[0].bytes.length;
    final int uvPlaneSize = image.planes[1].bytes.length + image.planes[2].bytes.length;
    
    final Uint8List bytes = Uint8List(yPlaneSize + uvPlaneSize);
    
    // Copy Y plane
    bytes.setRange(0, yPlaneSize, image.planes[0].bytes);
    
    // Copy UV planes
    int uvIndex = yPlaneSize;
    for (int i = 1; i < image.planes.length; i++) {
      final plane = image.planes[i].bytes;
      bytes.setRange(uvIndex, uvIndex + plane.length, plane);
      uvIndex += plane.length;
    }
    
    return bytes;
  }
  
  void _printFeatures(Map<String, dynamic> features) {
    final pose = features['pose'] as List<double>;
    final leftHand = features['leftHand'] as List<double>;
    final rightHand = features['rightHand'] as List<double>;
    
    print('\n========== FRAME $_frameCount ==========');
    print('Pose features (${pose.length} values):');
    print('  First 12: ${pose.take(12).toList()}');
    print('Left hand features (${leftHand.length} values):');
    print('  First 9: ${leftHand.take(9).toList()}');
    print('Right hand features (${rightHand.length} values):');
    print('  First 9: ${rightHand.take(9).toList()}');
    print('Total feature vector size: ${features['totalFeatures']}');
    print('=====================================\n');
  }
  
  void _showPermissionDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Camera Permission Required'),
        content: const Text('This app needs camera access to detect sign language gestures.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              openAppSettings();
            },
            child: const Text('Open Settings'),
          ),
        ],
      ),
    );
  }
  
  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }
  
  @override
  void dispose() {
    _stopProcessing();
    _cameraController?.dispose();
    _mediaPipeService.releaseMediaPipe();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('FSL Recognition'),
        backgroundColor: Colors.blue,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Camera Preview with Overlay
          Expanded(
            flex: 3,
            child: Container(
              color: Colors.black,
              child: _isInitialized && _cameraController != null
                  ? Stack(
                      fit: StackFit.expand,
                      children: [
                        // Camera preview
                        CameraPreview(_cameraController!),
                        
                        // Landmark overlay
                        if (_lastFeatures != null && _isProcessing)
                          CustomPaint(
                            painter: LandmarkPainter(
                              pose: _lastFeatures!['pose'] as List<double>,
                              leftHand: _lastFeatures!['leftHand'] as List<double>,
                              rightHand: _lastFeatures!['rightHand'] as List<double>,
                              imageSize: Size(
                                _cameraController!.value.previewSize?.height ?? 480,
                                _cameraController!.value.previewSize?.width ?? 640,
                              ),
                            ),
                          ),
                      ],
                    )
                  : const Center(
                      child: CircularProgressIndicator(color: Colors.white),
                    ),
            ),
          ),
          
          // Status Indicators
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.grey[900],
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatusIndicator(
                  'Camera',
                  _isInitialized,
                  Icons.camera_alt,
                ),
                _buildStatusIndicator(
                  'MediaPipe',
                  _isMediaPipeReady,
                  Icons.psychology,
                ),
                _buildStatusIndicator(
                  'Processing',
                  _isProcessing,
                  Icons.play_arrow,
                ),
              ],
            ),
          ),
          
          // Feature Display
          Expanded(
            flex: 2,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              color: Colors.grey[100],
              child: _lastFeatures != null
                  ? SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Frame: $_frameCount',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          _buildFeatureDisplay(
                            'Pose',
                            _lastFeatures!['pose'] as List<double>,
                            Colors.blue,
                          ),
                          const SizedBox(height: 8),
                          _buildFeatureDisplay(
                            'Left Hand',
                            _lastFeatures!['leftHand'] as List<double>,
                            Colors.purple,
                          ),
                          const SizedBox(height: 8),
                          _buildFeatureDisplay(
                            'Right Hand',
                            _lastFeatures!['rightHand'] as List<double>,
                            Colors.orange,
                          ),
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.green[100],
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              'Total Features: ${_lastFeatures!['totalFeatures']} dimensions',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    )
                  : const Center(
                      child: Text(
                        'Start processing to see features',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey,
                        ),
                      ),
                    ),
            ),
          ),
          
          // Control Buttons
          Container(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _isMediaPipeReady && !_isProcessing
                        ? _startProcessing
                        : null,
                    icon: const Icon(Icons.play_arrow),
                    label: const Text('Start'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      padding: const EdgeInsets.all(16),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _isProcessing ? _stopProcessing : null,
                    icon: const Icon(Icons.stop),
                    label: const Text('Stop'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      padding: const EdgeInsets.all(16),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildStatusIndicator(String label, bool isActive, IconData icon) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          color: isActive ? Colors.green : Colors.grey,
          size: 32,
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            color: isActive ? Colors.green : Colors.grey,
            fontSize: 12,
          ),
        ),
      ],
    );
  }
  
  Widget _buildFeatureDisplay(String label, List<double> features, Color color) {
    final hasFeatures = features.isNotEmpty && features.any((f) => f != 0.0);
    
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: color,
          width: 2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                hasFeatures ? Icons.check_circle : Icons.cancel,
                color: hasFeatures ? Colors.green : Colors.red,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                '$label (${features.length} values)',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
          if (hasFeatures) ...[
            const SizedBox(height: 4),
            Text(
              'Sample: ${features.take(6).map((f) => f.toStringAsFixed(3)).join(", ")}...',
              style: const TextStyle(fontSize: 12),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ],
      ),
    );
  }
}