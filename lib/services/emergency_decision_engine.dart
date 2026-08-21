import 'emergency_image_validation_service.dart';

///==============================================================
/// DECISION STATUS
///==============================================================

enum EmergencyDecisionStatus { accept, warning, reject }

///==============================================================
/// DECISION RESULT
///==============================================================

class EmergencyDecisionResult {
  final EmergencyDecisionStatus status;

  final bool allowAiAnalysis;

  final String title;

  final String message;

  final int decisionScore;

  final List<String> warnings;

  const EmergencyDecisionResult({
    required this.status,
    required this.allowAiAnalysis,
    required this.title,
    required this.message,
    required this.decisionScore,
    required this.warnings,
  });
}

///==============================================================
/// EMERGENCY DECISION ENGINE
///==============================================================

class EmergencyDecisionEngine {
  //------------------------------------------------------------
  // EVALUATE VALIDATION RESULT
  //------------------------------------------------------------

  static EmergencyDecisionResult evaluate(ImageValidationResult validation) {
    //----------------------------------------------------------
    // START SCORE
    //----------------------------------------------------------

    int score = validation.validationScore;

    final warnings = <String>[...validation.warnings];

    //----------------------------------------------------------
    // IMAGE REJECTED BY VALIDATION
    //----------------------------------------------------------

    if (!validation.isValidImage) {
      return EmergencyDecisionResult(
        status: EmergencyDecisionStatus.reject,
        allowAiAnalysis: false,
        title: "Image Rejected",
        message: validation.reason,
        decisionScore: score,
        warnings: warnings,
      );
    }

    //----------------------------------------------------------
    // EDITED IMAGE
    //----------------------------------------------------------

    if (validation.editedImage) {
      score -= 20;

      warnings.add("Edited image detected.");
    }

    //----------------------------------------------------------
    // NO METADATA
    //----------------------------------------------------------

    if (!validation.hasMetadata) {
      score -= 10;

      warnings.add("No camera metadata found.");
    }

    //----------------------------------------------------------
    // LIMIT SCORE
    //----------------------------------------------------------

    if (score < 0) {
      score = 0;
    }

    if (score > 100) {
      score = 100;
    }

    //----------------------------------------------------------
    // CONTINUE PART 3
    //------------------------------------------------------------
    //----------------------------------------------------------
    // ACCEPT
    //----------------------------------------------------------

    if (score >= 85) {
      return EmergencyDecisionResult(
        status: EmergencyDecisionStatus.accept,
        allowAiAnalysis: true,
        title: "Image Accepted",
        message:
            "The uploaded image passed validation and is suitable for AI emergency analysis.",
        decisionScore: score,
        warnings: warnings,
      );
    }

    //----------------------------------------------------------
    // ACCEPT WITH WARNING
    //----------------------------------------------------------

    if (score >= 60) {
      return EmergencyDecisionResult(
        status: EmergencyDecisionStatus.warning,
        allowAiAnalysis: true,
        title: "Accepted With Warning",
        message:
            "The image can be analysed, but some quality issues were detected.",
        decisionScore: score,
        warnings: warnings,
      );
    }

    //----------------------------------------------------------
    // REJECT
    //----------------------------------------------------------

    return EmergencyDecisionResult(
      status: EmergencyDecisionStatus.reject,
      allowAiAnalysis: false,
      title: "Image Rejected",
      message:
          "The uploaded image did not meet the minimum validation requirements.",
      decisionScore: score,
      warnings: warnings,
    );
  }

  //------------------------------------------------------------
  // CONTINUE PART 4
  //------------------------------------------------------------
  //------------------------------------------------------------
  // HELPER METHODS
  //------------------------------------------------------------

  static bool isAccepted(EmergencyDecisionResult result) {
    return result.status == EmergencyDecisionStatus.accept;
  }

  static bool isWarning(EmergencyDecisionResult result) {
    return result.status == EmergencyDecisionStatus.warning;
  }

  static bool isRejected(EmergencyDecisionResult result) {
    return result.status == EmergencyDecisionStatus.reject;
  }

  //------------------------------------------------------------
  // STATUS LABEL
  //------------------------------------------------------------

  static String statusLabel(EmergencyDecisionResult result) {
    switch (result.status) {
      case EmergencyDecisionStatus.accept:
        return "Accepted";

      case EmergencyDecisionStatus.warning:
        return "Accepted With Warning";

      case EmergencyDecisionStatus.reject:
        return "Rejected";
    }
  }

  //------------------------------------------------------------
  // STATUS COLOR
  //------------------------------------------------------------

  static String statusColor(EmergencyDecisionResult result) {
    switch (result.status) {
      case EmergencyDecisionStatus.accept:
        return "green";

      case EmergencyDecisionStatus.warning:
        return "orange";

      case EmergencyDecisionStatus.reject:
        return "red";
    }
  }
}
