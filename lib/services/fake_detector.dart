import 'dart:io';

import 'package:image/image.dart' as img;
import 'package:tflite_flutter/tflite_flutter.dart';

class FakeDetectionResult {
  final bool isFake;
  final double confidence;

  FakeDetectionResult({required this.isFake, required this.confidence});
}

class FakeDetector {
  late Interpreter interpreter;
  Future<void> loadModel() async {
    try {
      print("==================================");
      print("START LOADING MODEL");
      final options = InterpreterOptions()..threads = 4;

      interpreter = await Interpreter.fromAsset(
        'assets/models/emergency_validator.tflite',
        options: options,
      );

      print("MODEL LOADED");

      print("Input shape:");
      print(interpreter.getInputTensor(0).shape);

      print("Output shape:");
      print(interpreter.getOutputTensor(0).shape);

      print("DONE");
      print("==================================");
    } catch (e, s) {
      print("==================================");
      print("LOAD MODEL FAILED");
      print(e);
      print(s);
      print("==================================");

      rethrow;
    }
  }

  Future<FakeDetectionResult> detect(File imageFile) async {
    // Read image
    final bytes = imageFile.readAsBytesSync();

    final image = img.decodeImage(bytes);

    if (image == null) {
      throw Exception("Unable to read image");
    }

    // Resize to model input size
    final resized = img.copyResize(image, width: 224, height: 224);

    // Create input tensor
    final input = List.generate(
      1,
      (_) => List.generate(
        224,
        (y) => List.generate(224, (x) {
          final pixel = resized.getPixel(x, y);

          return [
            (pixel.r / 127.5) - 1.0,
            (pixel.g / 127.5) - 1.0,
            (pixel.b / 127.5) - 1.0,
          ];
        }),
      ),
    );

    // Output tensor
    final output = List.generate(1, (_) => List.filled(1, 0.0));

    // Run inference
    try {
      print("Running TFLite model...");

      interpreter.run(input, output);

      print("Inference finished.");
      print(output);
    } catch (e, s) {
      print("========== TFLITE ERROR ==========");
      print(e);
      print(s);
      rethrow;
    }

    final score = output[0][0];
    print("Model Score : $score");
    final isFake = score < 0.5;

    final confidence = isFake ? (1.0 - score) : score;

    return FakeDetectionResult(isFake: isFake, confidence: confidence);
  }
}
