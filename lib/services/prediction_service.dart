import 'package:flutter/services.dart';

/// Service for running predictions using TFLite model
class PredictionService {
  static const MethodChannel _channel = MethodChannel('com.example.hand2voice/prediction');
  
  // Action labels (update with your FSL-105 labels)
  static const List<String> actionLabels = [
    "GOOD MORNING",
    "GOOD AFTERNOON",
    "UNDERSTAND",
    "TEA",
    "BEER",
    "WINE",
    "SUGAR",
    "NO SUGAR",
    "DON'T UNDERSTAND",
    "KNOW",
    "DON'T KNOW",
    "NO",
    "YES",
    "WRONG",
    "CORRECT",
    "SLOW",
    "FAST",
    "GOOD EVENING",
    "ONE",
    "TWO"
  ];
  
  /// Load TFLite model from assets
  Future<bool> loadModel() async {
    try {
      final bool result = await _channel.invokeMethod('loadModel', {
        'modelPath': 'hand2voice-fslr.tflite',
      });
      print('Model loading result: $result');
      return result;
    } on PlatformException catch (e) {
      print('Failed to load model: ${e.message}');
      return false;
    }
  }
  
  /// Predict action from a sequence of frames
  /// 
  /// Parameters:
  ///   - frames: List of feature maps, each containing pose, leftHand, rightHand
  /// 
  /// Returns: List of predicted action labels
  Future<List<String>> predictSequence(List<Map<String, dynamic>> frames) async {
    if (frames.isEmpty) {
      return [];
    }
    
    try {
      // Convert frames to flat array for native processing
      final List<List<double>> sequenceData = [];
      
      for (final frame in frames) {
        final List<double> pose = frame['pose'] as List<double>;
        final List<double> leftHand = frame['leftHand'] as List<double>;
        final List<double> rightHand = frame['rightHand'] as List<double>;
        
        // Concatenate all features (258 dimensions)
        sequenceData.add([...pose, ...leftHand, ...rightHand]);
      }
      
      // Send to native for prediction
      final Map<dynamic, dynamic> result = await _channel.invokeMethod('predict', {
        'sequence': sequenceData,
        'sequenceLength': sequenceData.length,
      });
      
      // Parse predictions
      final List<int> predictedIndices = List<int>.from(result['predictions']);
      final List<double> confidences = List<double>.from(result['confidences']);
      
      // Convert indices to labels
      final List<String> predictions = [];
      for (int i = 0; i < predictedIndices.length; i++) {
        final index = predictedIndices[i];
        final confidence = confidences[i];
        
        if (index >= 0 && index < actionLabels.length) {
          predictions.add('${actionLabels[index]} (${(confidence * 100).toStringAsFixed(1)}%)');
        }
      }
      
      return predictions;
      
    } on PlatformException catch (e) {
      print('Prediction failed: ${e.message}');
      return [];
    }
  }
  
  /// Predict single frame (for real-time)
  Future<String?> predictFrame(List<double> features) async {
    try {
      final int result = await _channel.invokeMethod('predictFrame', {
        'features': features,
      });
      
      if (result >= 0 && result < actionLabels.length) {
        return actionLabels[result];
      }
      
      return null;
    } on PlatformException catch (e) {
      print('Frame prediction failed: ${e.message}');
      return null;
    }
  }
  
  /// Release model resources
  Future<void> releaseModel() async {
    try {
      await _channel.invokeMethod('releaseModel');
      print('Model resources released');
    } on PlatformException catch (e) {
      print('Failed to release model: ${e.message}');
    }
  }
}