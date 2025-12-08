import 'package:tflite_flutter/tflite_flutter.dart';

class PredictionService {
  Interpreter? _interpreter;
  final int sequenceLength = 30;
  final int numLandmarks = 21;
  final int numCoordinates = 3;

  List<List<List<double>>> _sequenceBuffer = [];

  Future<void> initialize(String modelPath) async {
    try {
      _interpreter = await Interpreter.fromAsset(modelPath);
      print('LSTM Model loaded successfully');
    } catch (e) {
      print('Error loading model: $e');
    }
  }

  String predict(List<dynamic> landmarks) {
    if (_interpreter == null || landmarks.isEmpty) return '';

    try {
      List<List<double>> frame = [];
      for (var landmark in landmarks) {
        frame.add([
          landmark['x'] as double,
          landmark['y'] as double,
          landmark['z'] as double,
        ]);
      }

      _sequenceBuffer.add(frame);

      if (_sequenceBuffer.length > sequenceLength) {
        _sequenceBuffer.removeAt(0);
      }

      if (_sequenceBuffer.length == sequenceLength) {
        // Prepare input tensor [1, sequenceLength, numLandmarks * numCoordinates]
        var input = List.generate(
          1,
          (_) => List.generate(
            sequenceLength,
            (i) => _sequenceBuffer[i].expand((coords) => coords).toList(),
          ),
        );

        // Prepare output tensor
        var output = List.filled(
          1,
          List.filled(getNumClasses(), 0.0),
        ).cast<List<double>>();

        // Run inference
        _interpreter!.run(input, output);

        // Get prediction
        int predictedIndex = _argMax(output[0]);
        return _indexToLabel(predictedIndex);
      }

      return '';
    } catch (e) {
      print('Error during prediction: $e');
      return '';
    }
  }

  int _argMax(List<double> list) {
    double maxValue = list[0];
    int maxIndex = 0;
    for (int i = 1; i < list.length; i++) {
      if (list[i] > maxValue) {
        maxValue = list[i];
        maxIndex = i;
      }
    }
    return maxIndex;
  }

  String _indexToLabel(int index) {
    // Map your model's output indices to Filipino Sign Language labels
    // Example mapping - replace with your actual labels
    final labels = [
      'Good Afternoon',
      'Good Morning',
      'Good Evening',
      'Yes',
      'No',
      // Add all your FSL labels here
    ];

    if (index >= 0 && index < labels.length) {
      return labels[index];
    }
    return 'Unknown';
  }

  int getNumClasses() {
    // Return the number of classes your model was trained on
    return 50; // Adjust based on your model
  }

  void resetSequence() {
    _sequenceBuffer.clear();
  }

  void dispose() {
    _interpreter?.close();
  }
}
