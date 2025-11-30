import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:video_player/video_player.dart';
import '../services/mediapipe_service.dart';
import '../services/prediction_service.dart';
import '../painters/landmark_painter.dart';
import 'dart:io';
import 'dart:typed_data';

class VideoRecordScreen extends StatefulWidget {
  const VideoRecordScreen({Key? key}) : super(key: key);

  @override
  State<VideoRecordScreen> createState() => _VideoRecordScreenState();
}

class _VideoRecordScreenState extends State<VideoRecordScreen> {
  CameraController? _cameraController;
  VideoPlayerController? _videoPlayerController;
  final MediaPipeService _mediaPipeService = MediaPipeService();
  final PredictionService _predictionService = PredictionService();
  
  bool _isInitialized = false;
  bool _isRecording = false;
  bool _isProcessing = false;
  bool _isMediaPipeReady = false;
  bool _isModelLoaded = false;
  
  String? _recordedVideoPath;
  List<String> _predictedActions = [];
  List<Map<String, dynamic>> _allFrameFeatures = [];
  int _currentFrame = 0;
  
  // Processing state
  String _processingStatus = '';
  double _processingProgress = 0.0;
  
  @override
  void initState() {
    super.initState();
    _initializeApp();
  }
  
  Future<void> _initializeApp() async {
    final status = await Permission.camera.request();
    if (status.isGranted) {
      await _initializeCamera();
      await _initializeMediaPipe();
      await _loadModel();
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
      
      final frontCamera = cameras.firstWhere(
        (camera) => camera.lensDirection == CameraLensDirection.front,
        orElse: () => cameras.first,
      );
      
      _cameraController = CameraController(
        frontCamera,
        ResolutionPreset.high,
        enableAudio: false,
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
      } else {
        _showError('Failed to initialize MediaPipe');
      }
    } catch (e) {
      _showError('MediaPipe initialization error: $e');
    }
  }
  
  Future<void> _loadModel() async {
    try {
      final success = await _predictionService.loadModel();
      setState(() {
        _isModelLoaded = success;
      });
      
      if (success) {
        print('TFLite model loaded successfully');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Model loaded and ready for prediction'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
      } else {
        _showError('Failed to load TFLite model');
      }
    } catch (e) {
      _showError('Model loading error: $e');
    }
  }
  
  Future<void> _startRecording() async {
    if (!_isMediaPipeReady || _cameraController == null) {
      _showError('Camera or MediaPipe not ready');
      return;
    }
    
    try {
      await _cameraController!.startVideoRecording();
      setState(() {
        _isRecording = true;
        _recordedVideoPath = null;
        _predictedActions = [];
        _allFrameFeatures = [];
      });
      
      print('Recording started');
    } catch (e) {
      _showError('Failed to start recording: $e');
    }
  }
  
  Future<void> _stopRecording() async {
    if (!_isRecording) return;
    
    try {
      final video = await _cameraController!.stopVideoRecording();
      setState(() {
        _isRecording = false;
        _recordedVideoPath = video.path;
      });
      
      print('Recording stopped: ${video.path}');
      
      // Start processing
      await _processVideoAndPredict();
      
    } catch (e) {
      _showError('Failed to stop recording: $e');
    }
  }
  
  Future<void> _processVideoAndPredict() async {
    if (_recordedVideoPath == null || !_isModelLoaded) {
      _showError('Video or model not ready');
      return;
    }
    
    setState(() {
      _isProcessing = true;
      _processingStatus = 'Extracting features from video...';
      _processingProgress = 0.0;
    });
    
    try {
      // Extract features from video
      await _extractFeaturesFromVideo();
      
      setState(() {
        _processingStatus = 'Running prediction model...';
        _processingProgress = 0.8;
      });
      
      // Run prediction
      final predictions = await _predictionService.predictSequence(_allFrameFeatures);
      
      setState(() {
        _predictedActions = predictions;
        _processingProgress = 1.0;
        _processingStatus = 'Complete!';
        _isProcessing = false;
      });
      
      // Play video with predictions
      await _playVideo();
      
    } catch (e) {
      setState(() {
        _isProcessing = false;
      });
      _showError('Processing failed: $e');
    }
  }
  
  Future<void> _extractFeaturesFromVideo() async {
    _allFrameFeatures.clear();
    
    setState(() {
      _processingStatus = 'Extracting features from video...';
      _processingProgress = 0.1;
    });
    
    // Use native video processor
    final features = await _mediaPipeService.processVideo(_recordedVideoPath!);
    
    setState(() {
      _allFrameFeatures = features;
      _processingStatus = 'Features extracted: ${features.length} frames';
      _processingProgress = 0.7;
    });
    
    print('Extracted ${features.length} frames from video');
  }
  
  Future<void> _playVideo() async {
    if (_recordedVideoPath == null) return;
    
    _videoPlayerController = VideoPlayerController.file(File(_recordedVideoPath!));
    await _videoPlayerController!.initialize();
    
    setState(() {});
    
    _videoPlayerController!.play();
    
    // Update current frame for landmark display
    _videoPlayerController!.addListener(() {
      if (_videoPlayerController!.value.isPlaying) {
        final position = _videoPlayerController!.value.position.inMilliseconds;
        final duration = _videoPlayerController!.value.duration.inMilliseconds;
        
        if (duration > 0) {
          final frameIndex = ((position / duration) * _allFrameFeatures.length).floor();
          if (frameIndex != _currentFrame && frameIndex < _allFrameFeatures.length) {
            setState(() {
              _currentFrame = frameIndex;
            });
          }
        }
      }
    });
  }
  
  void _resetRecording() {
    _videoPlayerController?.dispose();
    _videoPlayerController = null;
    
    setState(() {
      _recordedVideoPath = null;
      _predictedActions = [];
      _allFrameFeatures = [];
      _currentFrame = 0;
      _processingProgress = 0.0;
      _processingStatus = '';
    });
  }
  
  void _showPermissionDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Camera Permission Required'),
        content: const Text('This app needs camera access to record sign language gestures.'),
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
    _cameraController?.dispose();
    _videoPlayerController?.dispose();
    _mediaPipeService.releaseMediaPipe();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(16),
              color: Colors.blue,
              child: Row(
                children: [
                  const Icon(Icons.sign_language, color: Colors.white, size: 32),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'FSL Recognition',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  _buildStatusDot('Camera', _isInitialized),
                  const SizedBox(width: 12),
                  _buildStatusDot('MediaPipe', _isMediaPipeReady),
                  const SizedBox(width: 12),
                  _buildStatusDot('Model', _isModelLoaded),
                ],
              ),
            ),
            
            // Camera/Video Preview (LARGER)
            Expanded(
              child: Container(
                width: double.infinity,
                color: Colors.black,
                child: _buildPreview(),
              ),
            ),
            
            // Prediction Results
            if (_predictedActions.isNotEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.blue[900]!, Colors.blue[700]!],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Predicted Actions:',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _predictedActions.map((action) {
                        return Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            action,
                            style: const TextStyle(
                              color: Colors.blue,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
            
            // Processing Status
            if (_isProcessing)
              Container(
                padding: const EdgeInsets.all(16),
                color: Colors.grey[900],
                child: Column(
                  children: [
                    Text(
                      _processingStatus,
                      style: const TextStyle(color: Colors.white, fontSize: 16),
                    ),
                    const SizedBox(height: 12),
                    LinearProgressIndicator(
                      value: _processingProgress,
                      backgroundColor: Colors.grey[700],
                      valueColor: const AlwaysStoppedAnimation<Color>(Colors.blue),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${(_processingProgress * 100).toInt()}%',
                      style: const TextStyle(color: Colors.white70, fontSize: 14),
                    ),
                  ],
                ),
              ),
            
            // Control Buttons
            Container(
              padding: const EdgeInsets.all(16),
              color: Colors.grey[900],
              child: _buildControlButtons(),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildPreview() {
    if (_videoPlayerController != null && _videoPlayerController!.value.isInitialized) {
      // Show video playback with landmarks
      return Stack(
        fit: StackFit.expand,
        children: [
          Center(
            child: AspectRatio(
              aspectRatio: _videoPlayerController!.value.aspectRatio,
              child: VideoPlayer(_videoPlayerController!),
            ),
          ),
          
          // Overlay landmarks on video
          if (_currentFrame < _allFrameFeatures.length)
            CustomPaint(
              painter: LandmarkPainter(
                pose: _allFrameFeatures[_currentFrame]['pose'] as List<double>,
                leftHand: _allFrameFeatures[_currentFrame]['leftHand'] as List<double>,
                rightHand: _allFrameFeatures[_currentFrame]['rightHand'] as List<double>,
                imageSize: Size(640, 480),
              ),
            ),
          
          // Video controls overlay
          Positioned(
            bottom: 16,
            left: 16,
            right: 16,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.black54,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () {
                      setState(() {
                        if (_videoPlayerController!.value.isPlaying) {
                          _videoPlayerController!.pause();
                        } else {
                          _videoPlayerController!.play();
                        }
                      });
                    },
                    icon: Icon(
                      _videoPlayerController!.value.isPlaying
                          ? Icons.pause
                          : Icons.play_arrow,
                      color: Colors.white,
                    ),
                  ),
                  Expanded(
                    child: VideoProgressIndicator(
                      _videoPlayerController!,
                      allowScrubbing: true,
                      colors: const VideoProgressColors(
                        playedColor: Colors.blue,
                        bufferedColor: Colors.grey,
                        backgroundColor: Colors.white24,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      );
    }
    
    // Show camera preview
    if (_isInitialized && _cameraController != null) {
      return Center(
        child: AspectRatio(
          aspectRatio: 1 / _cameraController!.value.aspectRatio,
          child: Stack(
            fit: StackFit.expand,
            children: [
              CameraPreview(_cameraController!),
              
              // Recording indicator
              if (_isRecording)
                Positioned(
                  top: 16,
                  left: 16,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 12,
                          height: 12,
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          'RECORDING',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      );
    }
    
    return const Center(
      child: CircularProgressIndicator(color: Colors.white),
    );
  }
  
  Widget _buildControlButtons() {
    if (_videoPlayerController != null) {
      // Show reset button when video is playing
      return SizedBox(
        width: double.infinity,
        child: ElevatedButton.icon(
          onPressed: _resetRecording,
          icon: const Icon(Icons.refresh),
          label: const Text('Record New Video'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue,
            padding: const EdgeInsets.all(16),
            textStyle: const TextStyle(fontSize: 18),
          ),
        ),
      );
    }
    
    if (_isProcessing) {
      return const SizedBox.shrink();
    }
    
    // Show record/stop buttons
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: !_isRecording && _isMediaPipeReady && _isModelLoaded
                ? _startRecording
                : null,
            icon: const Icon(Icons.fiber_manual_record),
            label: const Text('Start Recording'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              padding: const EdgeInsets.all(16),
              textStyle: const TextStyle(fontSize: 18),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: _isRecording ? _stopRecording : null,
            icon: const Icon(Icons.stop),
            label: const Text('Stop & Predict'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              padding: const EdgeInsets.all(16),
              textStyle: const TextStyle(fontSize: 18),
            ),
          ),
        ),
      ],
    );
  }
  
  Widget _buildStatusDot(String label, bool isActive) {
    return Container(
      width: 12,
      height: 12,
      decoration: BoxDecoration(
        color: isActive ? Colors.greenAccent : Colors.red,
        shape: BoxShape.circle,
        boxShadow: isActive
            ? [
                BoxShadow(
                  color: Colors.greenAccent.withOpacity(0.5),
                  blurRadius: 8,
                  spreadRadius: 2,
                )
              ]
            : null,
      ),
    );
  }
}