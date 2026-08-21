import 'dart:io';

import 'package:exif/exif.dart';
import 'package:image/image.dart' as img;

///==============================================================
/// IMAGE VALIDATION RESULT
///==============================================================

class ImageValidationResult {
  final bool isValidImage;

  final int validationScore;

  final String status;

  final String reason;

  final int width;

  final int height;

  final double fileSizeMB;

  final bool hasMetadata;

  final bool editedImage;

  final List<String> warnings;

  const ImageValidationResult({
    required this.isValidImage,
    required this.validationScore,
    required this.status,
    required this.reason,
    required this.width,
    required this.height,
    required this.fileSizeMB,
    required this.hasMetadata,
    required this.editedImage,
    required this.warnings,
  });
}

///==============================================================
/// EMERGENCY IMAGE VALIDATION SERVICE
///==============================================================

class EmergencyImageValidationService {
  //------------------------------------------------------------
  // CONSTANTS
  //------------------------------------------------------------

  static const int minimumWidth = 224;

  static const int minimumHeight = 224;

  static const double minimumFileSizeMB = 0.02;

  static const double maximumFileSizeMB = 20.0;

  //------------------------------------------------------------
  // MAIN VALIDATION
  //------------------------------------------------------------

  static Future<ImageValidationResult> validateImage(File imageFile) async {
    //------------------------------------------------------------
    // WARNINGS
    //------------------------------------------------------------

    final List<String> warnings = [];

    //------------------------------------------------------------
    // FILE EXISTS
    //------------------------------------------------------------

    if (!await imageFile.exists()) {
      return const ImageValidationResult(
        isValidImage: false,
        validationScore: 0,
        status: "Rejected",
        reason: "Image file does not exist.",
        width: 0,
        height: 0,
        fileSizeMB: 0,
        hasMetadata: false,
        editedImage: false,
        warnings: [],
      );
    }

    //------------------------------------------------------------
    // FILE FORMAT
    //------------------------------------------------------------

    final extension = imageFile.path.split(".").last.toLowerCase();

    const allowedFormats = ["jpg", "jpeg", "png", "heic"];

    if (!allowedFormats.contains(extension)) {
      return const ImageValidationResult(
        isValidImage: false,
        validationScore: 5,
        status: "Rejected",
        reason: "Unsupported image format.",
        width: 0,
        height: 0,
        fileSizeMB: 0,
        hasMetadata: false,
        editedImage: false,
        warnings: [],
      );
    }

    //------------------------------------------------------------
    // FILE SIZE
    //------------------------------------------------------------

    final fileSize = await imageFile.length();

    final fileSizeMB = fileSize / (1024 * 1024);

    if (fileSizeMB < minimumFileSizeMB) {
      return ImageValidationResult(
        isValidImage: false,
        validationScore: 10,
        status: "Rejected",
        reason: "Image file is too small.",
        width: 0,
        height: 0,
        fileSizeMB: fileSizeMB,
        hasMetadata: false,
        editedImage: false,
        warnings: const [],
      );
    }

    if (fileSizeMB > maximumFileSizeMB) {
      return ImageValidationResult(
        isValidImage: false,
        validationScore: 10,
        status: "Rejected",
        reason: "Image file is too large.",
        width: 0,
        height: 0,
        fileSizeMB: fileSizeMB,
        hasMetadata: false,
        editedImage: false,
        warnings: const [],
      );
    }

    //------------------------------------------------------------
    // READ IMAGE
    //------------------------------------------------------------

    final bytes = await imageFile.readAsBytes();

    final image = img.decodeImage(bytes);

    if (image == null) {
      return ImageValidationResult(
        isValidImage: false,
        validationScore: 15,
        status: "Rejected",
        reason: "Unable to decode image.",
        width: 0,
        height: 0,
        fileSizeMB: fileSizeMB,
        hasMetadata: false,
        editedImage: false,
        warnings: const [],
      );
    }

    //------------------------------------------------------------
    // RESOLUTION
    //------------------------------------------------------------

    if (image.width < minimumWidth || image.height < minimumHeight) {
      return ImageValidationResult(
        isValidImage: false,
        validationScore: 20,
        status: "Rejected",
        reason: "Image resolution is too low.",
        width: image.width,
        height: image.height,
        fileSizeMB: fileSizeMB,
        hasMetadata: false,
        editedImage: false,
        warnings: const [],
      );
    }

    //------------------------------------------------------------
    // BRIGHTNESS
    //------------------------------------------------------------

    final brightness = _calculateBrightness(image);

    if (brightness < 25) {
      return ImageValidationResult(
        isValidImage: false,
        validationScore: 25,
        status: "Rejected",
        reason: "Image is too dark.",
        width: image.width,
        height: image.height,
        fileSizeMB: fileSizeMB,
        hasMetadata: false,
        editedImage: false,
        warnings: const [],
      );
    }

    if (brightness > 245) {
      return ImageValidationResult(
        isValidImage: false,
        validationScore: 25,
        status: "Rejected",
        reason: "Image is overexposed.",
        width: image.width,
        height: image.height,
        fileSizeMB: fileSizeMB,
        hasMetadata: false,
        editedImage: false,
        warnings: const [],
      );
    }

    //------------------------------------------------------------
    // CONTINUE TO PART 3
    //------------------------------------------------------------
    //------------------------------------------------------------
    // CONTRAST
    //------------------------------------------------------------

    final contrast = _calculateContrast(image);

    if (contrast < 180) {
      return ImageValidationResult(
        isValidImage: false,
        validationScore: 35,
        status: "Rejected",
        reason: "Image has very low contrast.",
        width: image.width,
        height: image.height,
        fileSizeMB: fileSizeMB,
        hasMetadata: false,
        editedImage: false,
        warnings: warnings,
      );
    }

    //------------------------------------------------------------
    // BLUR
    //------------------------------------------------------------

    final blur = _estimateBlur(image);

    if (blur < 2) {
      warnings.add(
        "Low image clarity detected. Smoke, motion, or low-light conditions may reduce sharpness.",
      );
    }

    //------------------------------------------------------------
    // EXIF METADATA
    //------------------------------------------------------------

    final exifData = await readExifFromBytes(bytes);

    final hasMetadata = exifData.isNotEmpty;

    //------------------------------------------------------------
    // EDITED IMAGE DETECTION
    //------------------------------------------------------------

    bool editedImage = false;

    if (hasMetadata) {
      final metadata = exifData.toString().toLowerCase();

      if (metadata.contains("photoshop") ||
          metadata.contains("adobe") ||
          metadata.contains("lightroom") ||
          metadata.contains("snapseed") ||
          metadata.contains("picsart") ||
          metadata.contains("canva") ||
          metadata.contains("gimp")) {
        editedImage = true;

        warnings.add("Image appears to have been edited.");
      }
    }

    //------------------------------------------------------------
    // CONTINUE TO PART 4
    //------------------------------------------------------------
    //------------------------------------------------------------
    // SCREENSHOT DETECTION
    //------------------------------------------------------------

    if (_isLikelyScreenshot(image)) {
      warnings.add("Screenshot detected.");

      return ImageValidationResult(
        isValidImage: false,
        validationScore: 60,
        status: "Rejected",
        reason: "Please upload an actual camera photo instead of a screenshot.",
        width: image.width,
        height: image.height,
        fileSizeMB: fileSizeMB,
        hasMetadata: hasMetadata,
        editedImage: editedImage,
        warnings: warnings,
      );
    }

    //------------------------------------------------------------
    // DOCUMENT DETECTION
    //------------------------------------------------------------

    if (_isLikelyDocument(image)) {
      warnings.add("Document detected.");

      return ImageValidationResult(
        isValidImage: false,
        validationScore: 65,
        status: "Rejected",
        reason: "Document detected instead of an emergency scene.",
        width: image.width,
        height: image.height,
        fileSizeMB: fileSizeMB,
        hasMetadata: hasMetadata,
        editedImage: editedImage,
        warnings: warnings,
      );
    }

    //------------------------------------------------------------
    // CARTOON / ILLUSTRATION DETECTION
    //------------------------------------------------------------

    if (_isLikelyCartoon(image)) {
      warnings.add("Illustration detected.");

      return ImageValidationResult(
        isValidImage: false,
        validationScore: 70,
        status: "Rejected",
        reason: "Illustration or cartoon detected.",
        width: image.width,
        height: image.height,
        fileSizeMB: fileSizeMB,
        hasMetadata: hasMetadata,
        editedImage: editedImage,
        warnings: warnings,
      );
    }

    //------------------------------------------------------------
    // AI GENERATED IMAGE HEURISTIC
    //------------------------------------------------------------

    if (editedImage) {
      warnings.add("Possible AI generated or heavily edited image.");
    }
    //------------------------------------------------------------
    // NON-EMERGENCY SCENE VALIDATION
    //------------------------------------------------------------

    if (_isLikelyNonEmergency(image)) {
      warnings.add("Non-emergency scene detected.");

      return ImageValidationResult(
        isValidImage: false,
        validationScore: 75,
        status: "Rejected",
        reason:
            "The uploaded image does not appear to contain an emergency scene.",
        width: image.width,
        height: image.height,
        fileSizeMB: fileSizeMB,
        hasMetadata: hasMetadata,
        editedImage: editedImage,
        warnings: warnings,
      );
    }
    //------------------------------------------------------------
    // SUCCESS
    //------------------------------------------------------------

    return ImageValidationResult(
      isValidImage: true,
      validationScore: 100,
      status: "Passed",
      reason: "Emergency image validation passed.",
      width: image.width,
      height: image.height,
      fileSizeMB: fileSizeMB,
      hasMetadata: hasMetadata,
      editedImage: editedImage,
      warnings: warnings,
    );
  }
  //------------------------------------------------------------
  // CALCULATE BRIGHTNESS
  //------------------------------------------------------------

  static double _calculateBrightness(img.Image image) {
    double total = 0;
    int count = 0;

    for (int y = 0; y < image.height; y += 10) {
      for (int x = 0; x < image.width; x += 10) {
        final pixel = image.getPixel(x, y);

        total += (pixel.r + pixel.g + pixel.b) / 3;

        count++;
      }
    }

    return total / count;
  }

  //------------------------------------------------------------
  // CALCULATE CONTRAST
  //------------------------------------------------------------

  static double _calculateContrast(img.Image image) {
    final values = <double>[];

    for (int y = 0; y < image.height; y += 10) {
      for (int x = 0; x < image.width; x += 10) {
        final pixel = image.getPixel(x, y);

        values.add((pixel.r + pixel.g + pixel.b) / 3);
      }
    }

    final mean = values.reduce((a, b) => a + b) / values.length;

    double variance = 0;

    for (final value in values) {
      variance += (value - mean) * (value - mean);
    }

    return variance / values.length;
  }

  //------------------------------------------------------------
  // ESTIMATE BLUR
  //------------------------------------------------------------

  static double _estimateBlur(img.Image image) {
    double difference = 0;

    int samples = 0;

    for (int y = 1; y < image.height; y += 8) {
      for (int x = 1; x < image.width; x += 8) {
        final p1 = image.getPixel(x, y);

        final p2 = image.getPixel(x - 1, y);

        final b1 = (p1.r + p1.g + p1.b) / 3;

        final b2 = (p2.r + p2.g + p2.b) / 3;

        difference += (b1 - b2).abs();

        samples++;
      }
    }

    return difference / samples;
  }

  //------------------------------------------------------------
  // SCREENSHOT DETECTION
  //------------------------------------------------------------

  static bool _isLikelyScreenshot(img.Image image) {
    final ratio = image.width / image.height;

    return (ratio > 0.45 && ratio < 0.48) ||
        (ratio > 0.55 && ratio < 0.58) ||
        (ratio > 2.0 && ratio < 2.3);
  }

  //------------------------------------------------------------
  // DOCUMENT DETECTION
  //------------------------------------------------------------

  static bool _isLikelyDocument(img.Image image) {
    final brightness = _calculateBrightness(image);

    final contrast = _calculateContrast(image);

    return brightness > 210 && contrast < 350;
  }

  //------------------------------------------------------------
  // CARTOON DETECTION
  //------------------------------------------------------------

  static bool _isLikelyCartoon(img.Image image) {
    int saturated = 0;

    int total = 0;

    for (int y = 0; y < image.height; y += 15) {
      for (int x = 0; x < image.width; x += 15) {
        final pixel = image.getPixel(x, y);

        final maxColor = [
          pixel.r,
          pixel.g,
          pixel.b,
        ].reduce((a, b) => a > b ? a : b);

        final minColor = [
          pixel.r,
          pixel.g,
          pixel.b,
        ].reduce((a, b) => a < b ? a : b);

        if (maxColor - minColor > 180) {
          saturated++;
        }

        total++;
      }
    }

    return total > 0 && saturated / total > 0.55;
  }
  //------------------------------------------------------------
  // NON-EMERGENCY SCENE DETECTION
  //------------------------------------------------------------

  static bool _isLikelyNonEmergency(img.Image image) {
    final brightness = _calculateBrightness(image);
    final contrast = _calculateContrast(image);
    final blur = _estimateBlur(image);

    // Bright indoor scenes with little texture
    if (brightness > 190 && contrast < 180 && blur < 12) {
      return true;
    }

    return false;
  }
}
