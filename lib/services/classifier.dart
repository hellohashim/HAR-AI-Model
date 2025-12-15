import 'package:flutter/services.dart';
import 'package:tflite_flutter/tflite_flutter.dart';

class ActivityClassifier {
  Interpreter? _interpreter;
  bool _isLoaded = false;

  static const List<String> _labels = [
    'Falling', 
    'Jogging', 
    'Sitting', 
    'Standing', 
    'Walking'
  ];

  // EXACT NORMALIZATION VALUES FROM YOUR CSV
  // Order: acc_x, acc_y, acc_z, gyro_x, gyro_y, gyro_z, ori_y, ori_z
  static const List<double> _means = [
    -0.4989, 7.7963, 0.6473, 
    -0.0128, -0.0222, -0.0091, 
    -76.6113, -2.3850
  ];
  
  static const List<double> _stds = [
    4.1898, 4.9028, 4.0901, 
    1.0966, 1.1744, 0.7965, 
    49.8061, 21.5945
  ];

  Future<void> loadModel() async {
    try {
      final options = InterpreterOptions();
      _interpreter = await Interpreter.fromAsset('assets/model.tflite', options: options);
      
      // Force input shape to be exactly [1, 128, 8]
      _interpreter!.resizeInputTensor(0, [1, 128, 8]);
      _interpreter!.allocateTensors();
      
      _isLoaded = true;
      print('✅ Model Loaded');
    } catch (e) {
      print('❌ Error loading model: $e');
    }
  }

  String predict(List<List<double>> rawBuffer) {
    if (!_isLoaded || _interpreter == null) return "Loading...";

    try {
      // 1. STRICT SHAPE ENFORCEMENT
      // If buffer has more than 128, take the LAST 128. 
      // If less, return error (shouldn't happen with service logic)
      if (rawBuffer.length < 128) return "Buffering...";
      
      List<List<double>> window = rawBuffer.length > 128 
          ? rawBuffer.sublist(rawBuffer.length - 128) 
          : rawBuffer;

      // 2. NORMALIZE
      List<List<double>> inputData = [];
      for (var row in window) {
        List<double> normRow = [];
        for (int i = 0; i < 8; i++) {
          // (Value - Mean) / StdDev
          normRow.add((row[i] - _means[i]) / _stds[i]);
        }
        inputData.add(normRow);
      }

      // 3. INFERENCE
      var input = [inputData]; // Shape: [1, 128, 8]
      var output = List.filled(1 * 5, 0.0).reshape([1, 5]);

      _interpreter!.run(input, output);

      // 4. RESULT
      List<double> probs = List<double>.from(output[0]);
      int maxIndex = 0;
      double maxScore = -999.0;

      for (int i = 0; i < probs.length; i++) {
        if (probs[i] > maxScore) {
          maxScore = probs[i];
          maxIndex = i;
        }
      }
      return _labels[maxIndex];

    } catch (e) {
      print("Predict Error: $e");
      return "Error";
    }
  }
}