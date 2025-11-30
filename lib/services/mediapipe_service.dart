import 'package:flutter/services.dart';
import 'dart:typed_data';

/// Service class that handles communication with native Android MediaPipe implementation
class MediaPipeService {
  // Define the method channel for communication between Flutter and Android
  static const MethodChannel _channel = MethodChannel('com.example.hand2voice/mediapipe');
  
  /// Initialize MediaPipe Holistic model on native side
  /// Returns true if initialization is successful
  Future<bool> initializeMediaPipe() async {
    try {
      final bool result = await _channel.invokeMethod('initializeMediaPipe');
      print('MediaPipe initialization result: $result');
      return result;
    } on PlatformException catch (e) {
      print('Failed to initialize MediaPipe: ${e.message}');
      return false;
    }
  }
  
  /// Process a single frame and extract keypoints
  /// 
  /// Parameters:
  ///   - imageBytes: Raw image data as Uint8List
  ///   - width: Image width in pixels
  ///   - height: Image height in pixels
  ///   - rotation: Camera rotation (0, 90, 180, 270)
  /// 
  /// Returns a Map containing:
  ///   - 'success': boolean indicating if processing succeeded
  ///   - 'pose': List of 132 values (33 landmarks × 4 coordinates)
  ///   - 'leftHand': List of 63 values (21 landmarks × 3 coordinates)
  ///   - 'rightHand': List of 63 values (21 landmarks × 3 coordinates)
  ///   - 'totalFeatures': 258 (concatenated feature vector size)
  Future<Map<String, dynamic>> processFrame({
    required Uint8List imageBytes,
    required int width,
    required int height,
    required int rotation,
  }) async {
    try {
      final Map<dynamic, dynamic> result = await _channel.invokeMethod(
        'processFrame',
        {
          'imageBytes': imageBytes,
          'width': width,
          'height': height,
          'rotation': rotation,
        },
      );
      
      return {
        'success': result['success'] as bool,
        'pose': result['pose'] != null ? List<double>.from(result['pose']) : <double>[],
        'leftHand': result['leftHand'] != null ? List<double>.from(result['leftHand']) : <double>[],
        'rightHand': result['rightHand'] != null ? List<double>.from(result['rightHand']) : <double>[],
        'totalFeatures': result['totalFeatures'] as int? ?? 0,
      };
    } on PlatformException catch (e) {
      print('Failed to process frame: ${e.message}');
      return {
        'success': false,
        'pose': <double>[],
        'leftHand': <double>[],
        'rightHand': <double>[],
        'totalFeatures': 0,
      };
    }
  }
  
  /// Get concatenated feature vector (all keypoints flattened)
  /// Returns a List<double> of size 258
  Future<List<double>> getConcatenatedFeatures({
    required Uint8List imageBytes,
    required int width,
    required int height,
    required int rotation,
  }) async {
    final result = await processFrame(
      imageBytes: imageBytes,
      width: width,
      height: height,
      rotation: rotation,
    );
    
    if (result['success']) {
      final List<double> pose = result['pose'] as List<double>;
      final List<double> leftHand = result['leftHand'] as List<double>;
      final List<double> rightHand = result['rightHand'] as List<double>;
      
      return [...pose, ...leftHand, ...rightHand];
    }
    
    return [];
  }
  
  /// Process entire video file and extract features
  /// Returns list of feature maps for each frame
  Future<List<Map<String, dynamic>>> processVideo(String videoPath) async {
    try {
      final List<dynamic> result = await _channel.invokeMethod('processVideo', {
        'videoPath': videoPath,
      });
      
      return result.map((frame) {
        return {
          'pose': List<double>.from(frame['pose']),
          'leftHand': List<double>.from(frame['leftHand']),
          'rightHand': List<double>.from(frame['rightHand']),
        };
      }).toList();
      
    } on PlatformException catch (e) {
      print('Failed to process video: ${e.message}');
      return [];
    }
  }
  
  /// Release MediaPipe resources
  Future<void> releaseMediaPipe() async {
    try {
      await _channel.invokeMethod('releaseMediaPipe');
      print('MediaPipe resources released');
    } on PlatformException catch (e) {
      print('Failed to release MediaPipe: ${e.message}');
    }
  }
  
  /// Check if MediaPipe is initialized
  Future<bool> isInitialized() async {
    try {
      final bool result = await _channel.invokeMethod('isInitialized');
      return result;
    } on PlatformException catch (e) {
      print('Failed to check initialization: ${e.message}');
      return false;
    }
  }
}