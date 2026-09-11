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
    final score = validation.validationScore;
    final warnings = <String>[...validation.warnings];

    if (!validation.isValidImage) {
      return EmergencyDecisionResult(
        status: EmergencyDecisionStatus.reject,
        allowAiAnalysis: false,
        title: "Image Rejected",
        message: "Rejected: ${validation.reason}",
        decisionScore: score,
        warnings: warnings,
      );
    }

    if (score >= 85 && warnings.isEmpty) {
      return EmergencyDecisionResult(
        status: EmergencyDecisionStatus.accept,
        allowAiAnalysis: true,
        title: "Image Accepted",
        message:
            "Technical image-quality checks passed. Image Quality Score: $score/100.",
        decisionScore: score,
        warnings: warnings,
      );
    }

    if (score >= 60) {
      return EmergencyDecisionResult(
        status: EmergencyDecisionStatus.warning,
        allowAiAnalysis: true,
        title: "Accepted With Warning",
        message:
            "Technical image-quality checks passed with warnings. Image Quality Score: $score/100.",
        decisionScore: score,
        warnings: warnings,
      );
    }

    return EmergencyDecisionResult(
      status: EmergencyDecisionStatus.reject,
      allowAiAnalysis: false,
      title: "Image Rejected",
      message:
          "Rejected: Image quality is too low for reliable emergency assessment. Image Quality Score: $score/100.",
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
