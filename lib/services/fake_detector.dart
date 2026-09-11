import 'dart:io';

import 'package:image/image.dart' as img;
import 'package:tflite_flutter/tflite_flutter.dart';

enum ImageClassification { ai, nonEmergency, realEmergency }

class FakeDetectionResult {
  final ImageClassification classification;
  final double confidence;
  final List<double> probabilities;

  FakeDetectionResult({
    required this.classification,
    required this.confidence,
    required this.probabilities,
  });

  bool get isFake => classification == ImageClassification.ai;

  bool get isNonEmergency => classification == ImageClassification.nonEmergency;

  bool get isRealEmergency =>
      classification == ImageClassification.realEmergency;

  String get label {
    switch (classification) {
      case ImageClassification.ai:
        return "AI";
      case ImageClassification.nonEmergency:
        return "Non_Emergency";
      case ImageClassification.realEmergency:
        return "Real";
    }
  }
}

class FakeDetector {
  late Interpreter interpreter;

  Future<void> loadModel() async {
    final options = InterpreterOptions()..threads = 4;

    interpreter = await Interpreter.fromAsset(
      'assets/models/emergency_validator.tflite',
      options: options,
    );

    print("Model input: ${interpreter.getInputTensor(0).shape}");
    print("Model output: ${interpreter.getOutputTensor(0).shape}");
  }

  Future<FakeDetectionResult> detect(File imageFile) async {
    final bytes = await imageFile.readAsBytes();
    final image = img.decodeImage(bytes);

    if (image == null) {
      throw Exception("Unable to read image.");
    }

    final resized = img.copyResize(image, width: 224, height: 224);

    // Keep raw pixel values here.
    // MobileNetV2 preprocessing is already inside your trained TFLite model.
    final input = List.generate(
      1,
      (_) => List.generate(
        224,
        (y) => List.generate(224, (x) {
          final pixel = resized.getPixel(x, y);

          return [pixel.r.toDouble(), pixel.g.toDouble(), pixel.b.toDouble()];
        }),
      ),
    );

    // New model output: [AI, Non_Emergency, Real].
    final output = List.generate(1, (_) => List.filled(3, 0.0));

    interpreter.run(input, output);

    final probabilities = List<double>.from(output[0]);

    int predictedIndex = 0;
    for (int i = 1; i < probabilities.length; i++) {
      if (probabilities[i] > probabilities[predictedIndex]) {
        predictedIndex = i;
      }
    }

    final classification = switch (predictedIndex) {
      0 => ImageClassification.ai,
      1 => ImageClassification.nonEmergency,
      _ => ImageClassification.realEmergency,
    };

    return FakeDetectionResult(
      classification: classification,
      confidence: probabilities[predictedIndex],
      probabilities: probabilities,
    );
  }
}
