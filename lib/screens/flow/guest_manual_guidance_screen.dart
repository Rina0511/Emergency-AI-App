import 'package:flutter/material.dart';

import '../../routes.dart';
import '../../l10n/app_localizations.dart';

class GuestManualGuidanceScreen extends StatefulWidget {
  final String emergencyType;
  final String victimCondition;
  final String victimCount;
  final String danger;
  final bool includeLocation;
  final String description;

  // NEW
  // VALIDATION RESULT
  final int validationScore;

  final String validationStatus;

  final List<String> validationWarnings;

  const GuestManualGuidanceScreen({
    super.key,
    required this.emergencyType,
    required this.victimCondition,
    required this.victimCount,
    required this.danger,
    required this.includeLocation,
    required this.description,

    // NEW
    required this.validationScore,
    required this.validationStatus,
    required this.validationWarnings,
  });
  @override
  State<GuestManualGuidanceScreen> createState() =>
      _GuestManualGuidanceScreenState();
}

class _GuestManualGuidanceScreenState extends State<GuestManualGuidanceScreen> {
  //----------------------------------------------------------
  // UI COLORS
  //----------------------------------------------------------

  final Color primaryBlue = const Color(0xFF2F6FE4);

  late List<String> _guidance;

  late String _severity;

  late IconData _emergencyIcon;

  late Color _severityColor;
  late AppLocalizations _t;
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _generateGuidance();
  }

  //----------------------------------------------------------
  // GENERATE RULE-BASED GUIDANCE
  //----------------------------------------------------------

  void _generateGuidance() {
    _t = AppLocalizations.of(context)!;
    switch (widget.emergencyType) {
      case "Fire":
        _buildFireGuidance();
        break;

      case "Medical":
        _buildMedicalGuidance();
        break;

      case "Accident":
        _buildAccidentGuidance();
        break;

      case "Crime":
        _buildCrimeGuidance();
        break;

      case "Hazard":
        _buildHazardGuidance();
        break;

      case "Animal Rescue":
        _buildAnimalRescueGuidance();

        break;

      case "Flood":
        _buildFloodGuidance();
        break;

      case "Building Collapse":
        _buildBuildingCollapseGuidance();
        break;

      case "Gas Leak":
        _buildGasLeakGuidance();
        break;

      case "Electrical Hazard":
        _buildElectricalGuidance();
        break;

      case "Landslide":
        _buildLandslideGuidance();
        break;
      case "Chemical Spill":
        _buildHazardGuidance();
        break;

      default:
        _buildGeneralGuidance();
    }
  }

  //----------------------------------------------------------
  // RULE METHODS
  //----------------------------------------------------------

  //----------------------------------------------------------
  // FIRE
  //----------------------------------------------------------
  void _buildFireGuidance() {
    _severity = "HIGH";
    _severityColor = Colors.red;
    _emergencyIcon = Icons.local_fire_department;

    _guidance = [
      _t.fireGuidanceMoveAway,
      _t.fireGuidanceStayLow,
      _t.fireGuidanceNoElevators,
      _t.fireGuidanceTurnOffUtilities,
      _t.fireGuidanceGetHelp,
      _t.fireGuidanceWaitSafe,
    ];

    if (widget.victimCondition == "Trapped") {
      _guidance.insert(1, _t.fireGuidancePersonTrapped);
    }

    if (widget.danger == "Fuel Leak") {
      _guidance.insert(2, _t.fireGuidanceFuelLeak);
    }
  }

  //----------------------------------------------------------
  // MEDICAL
  //----------------------------------------------------------

  void _buildMedicalGuidance() {
    _severity = "HIGH";

    _severityColor = Colors.red;

    _emergencyIcon = Icons.medical_services;

    _guidance = [
      "Check whether the victim is breathing.",

      "Keep the victim calm and still.",

      "Do not move the victim unless necessary.",

      "Apply first aid if you are trained.",

      "Call 999 immediately.",
    ];

    if (widget.victimCondition == "Unconscious") {
      _guidance.insert(
        1,
        "Place the victim in the recovery position if breathing normally.",
      );
    }

    if (widget.victimCondition == "Bleeding") {
      _guidance.insert(2, "Apply direct pressure using a clean cloth.");
    }
  }

  //----------------------------------------------------------
  // ACCIDENT
  //----------------------------------------------------------

  void _buildAccidentGuidance() {
    _severity = "MEDIUM";

    _severityColor = Colors.orange;

    _emergencyIcon = Icons.car_crash;

    _guidance = [
      "Ensure your own safety before helping others.",

      "Switch on hazard lights if it is a road accident.",

      "Move to a safe location if possible.",

      "Check all victims for injuries.",

      "Call 999 if anyone is injured.",

      "Do not move seriously injured victims unless there is immediate danger.",
    ];

    if (widget.danger == "Traffic") {
      _guidance.insert(1, "Stay away from moving vehicles.");
    }

    if (widget.victimCount == "6+") {
      _severity = "HIGH";

      _severityColor = Colors.red;

      _guidance.insert(
        0,
        "Multiple victims detected. Inform emergency responders immediately.",
      );
    }
  }

  //----------------------------------------------------------
  // CRIME
  //----------------------------------------------------------

  void _buildCrimeGuidance() {
    _severity = "HIGH";

    _severityColor = Colors.red;

    _emergencyIcon = Icons.gpp_bad;

    _guidance = [
      "Do not confront the suspect.",

      "Move to a safe location.",

      "Call 999 immediately.",

      "Observe important details only if it is safe.",

      "Wait for police officers.",
    ];
  }

  //----------------------------------------------------------
  // HAZARD
  //----------------------------------------------------------

  void _buildHazardGuidance() {
    _severity = "MEDIUM";

    _severityColor = Colors.orange;

    _emergencyIcon = Icons.warning_amber;

    _guidance = [
      "Keep people away from the hazardous area.",

      "Avoid touching unknown substances.",

      "Wear protective equipment if available.",

      "Call emergency services if the hazard is dangerous.",

      "Warn nearby people.",
    ];

    if (widget.danger == "Smoke") {
      _guidance.insert(1, "Avoid breathing smoke and move to fresh air.");
    }

    if (widget.danger == "Fuel Leak") {
      _severity = "HIGH";

      _severityColor = Colors.red;

      _guidance.insert(0, "Keep everyone away from the leaking fuel.");
    }
  }
  //----------------------------------------------------------
  // ANIMAL RESCUE
  //----------------------------------------------------------

  void _buildAnimalRescueGuidance() {
    _severity = "LOW";

    _severityColor = Colors.orange;

    _emergencyIcon = Icons.pets;

    _guidance = [
      "Stay calm and assess the situation.",
      "Do not climb the tree or enter dangerous areas.",
      "Keep people away from the rescue area.",
      "Do not scare or chase the animal.",
      "Call the Fire & Rescue Department (Bomba) if professional rescue is required.",
      "Wait for trained rescuers to arrive.",
    ];

    if (widget.danger == "Traffic") {
      _severity = "MEDIUM";
      _guidance.insert(
        1,
        "Keep yourself away from moving vehicles while observing the animal.",
      );
    }

    if (widget.danger == "Electrical Hazard") {
      _severity = "HIGH";
      _severityColor = Colors.red;
      _guidance.insert(
        0,
        "Stay away from electrical wires or power poles near the animal.",
      );
    }
  }
  //----------------------------------------------------------
  // FLOOD
  //----------------------------------------------------------

  void _buildFloodGuidance() {
    _severity = "HIGH";

    _severityColor = Colors.red;

    _emergencyIcon = Icons.flood;

    _guidance = [
      "Move immediately to higher ground.",
      "Avoid walking or driving through flood water.",
      "Switch off electricity if it is safe.",
      "Stay away from fast-moving water.",
      "Call 999 if anyone is trapped.",
      "Follow instructions from emergency authorities.",
    ];

    if (widget.victimCount == "6+") {
      _guidance.insert(
        0,
        "Multiple victims reported. Inform emergency responders immediately.",
      );
    }
  }
  //----------------------------------------------------------
  // BUILDING COLLAPSE
  //----------------------------------------------------------

  void _buildBuildingCollapseGuidance() {
    _severity = "HIGH";

    _severityColor = Colors.red;

    _emergencyIcon = Icons.apartment;

    _guidance = [
      "Move away from the collapsed structure immediately.",
      "Do not enter unstable buildings.",
      "Call 999 immediately.",
      "Listen for trapped victims from a safe distance.",
      "Keep bystanders away.",
      "Wait for Fire & Rescue personnel.",
    ];

    if (widget.victimCondition == "Trapped") {
      _guidance.insert(
        3,
        "Inform responders about trapped victims and their last known location.",
      );
    }
  }
  //----------------------------------------------------------
  // GAS LEAK
  //----------------------------------------------------------

  void _buildGasLeakGuidance() {
    _severity = "HIGH";

    _severityColor = Colors.red;

    _emergencyIcon = Icons.gas_meter;

    _guidance = [
      "Leave the area immediately.",
      "Do not switch electrical devices on or off.",
      "Do not smoke or create sparks.",
      "Turn off the gas supply only if it is safe.",
      "Call the Fire & Rescue Department (Bomba).",
      "Keep everyone away from the affected area.",
    ];
  }
  //----------------------------------------------------------
  // ELECTRICAL HAZARD
  //----------------------------------------------------------

  void _buildElectricalGuidance() {
    _severity = "HIGH";

    _severityColor = Colors.red;

    _emergencyIcon = Icons.electrical_services;

    _guidance = [
      "Do not touch exposed electrical wires.",
      "Keep everyone away from the hazard.",
      "Switch off the main power supply if it is safe.",
      "Do not touch a victim until the power source is isolated.",
      "Call 999 immediately.",
      "Wait for qualified personnel.",
    ];

    if (widget.victimCondition == "Unconscious") {
      _guidance.insert(
        4,
        "Begin CPR only after ensuring there is no electrical danger.",
      );
    }
  }
  //----------------------------------------------------------
  // LANDSLIDE
  //----------------------------------------------------------

  void _buildLandslideGuidance() {
    _severity = "HIGH";

    _severityColor = Colors.red;

    _emergencyIcon = Icons.landscape;

    _guidance = [
      "Move immediately away from the landslide area.",
      "Watch for additional falling rocks or soil.",
      "Do not return until authorities declare the area safe.",
      "Call 999 if anyone is trapped.",
      "Help injured victims only if it is safe.",
      "Follow emergency authority instructions.",
    ];

    if (widget.victimCondition == "Trapped") {
      _guidance.insert(
        3,
        "Inform emergency responders that victims are trapped.",
      );
    }
  }
  //----------------------------------------------------------
  // GENERAL
  //----------------------------------------------------------

  void _buildGeneralGuidance() {
    _severity = "LOW";

    _severityColor = Colors.green;

    _emergencyIcon = Icons.info;

    _guidance = [
      "Stay calm.",

      "Keep yourself safe.",

      "Observe the situation carefully.",

      "Contact emergency services if necessary.",
    ];
  }

  String _emergencyLabel(AppLocalizations t, String value) {
    switch (value) {
      case "Accident":
        return t.accident;
      case "Fire":
        return t.fire;
      case "Medical":
        return t.medical;
      case "Flood":
        return t.flood;
      case "Crime":
        return t.crime;
      case "Building Collapse":
        return t.buildingCollapse;
      case "Chemical Spill":
        return t.chemicalSpill;
      case "Animal Rescue":
        return t.animalRescue;
      case "Other":
        return t.other;
      default:
        return value;
    }
  }

  String _conditionLabel(AppLocalizations t, String value) {
    switch (value) {
      case "Conscious":
        return t.conscious;
      case "Unconscious":
        return t.unconscious;
      case "Bleeding":
        return t.bleeding;
      case "Trapped":
        return t.trapped;
      case "Unknown":
        return t.unknown;
      default:
        return value;
    }
  }

  String _dangerLabel(AppLocalizations t, String value) {
    switch (value) {
      case "Fire":
        return t.fire;
      case "Smoke":
        return t.smoke;
      case "Fuel Leak":
        return t.fuelLeak;
      case "Traffic":
        return t.traffic;
      case "None":
        return t.none;
      case "Unknown":
        return t.unknown;
      default:
        return value;
    }
  }

  String _severityLabel(AppLocalizations t) {
    switch (_severity) {
      case "HIGH":
        return t.high;
      case "MEDIUM":
        return t.medium;
      default:
        return t.low;
    }
  }

  String _validationStatusLabel(AppLocalizations t) {
    switch (widget.validationStatus) {
      case "Accepted":
        return t.validationImageAcceptedTitle;
      case "Accepted With Warning":
        return t.validationAcceptedWarningTitle;
      default:
        return t.validationImageRejectedTitle;
    }
  }
  //----------------------------------------------------------
  // BUILD
  //----------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final bgColor = isDark ? const Color(0xFF0B1220) : const Color(0xFFEAF1FB);

    final cardColor = isDark ? const Color(0xFF162033) : Colors.white;

    final textDark = isDark ? Colors.white : const Color(0xFF0B1B3A);

    final textSoft = isDark ? Colors.white70 : Colors.grey.shade700;
    final t = AppLocalizations.of(context)!;
    final localizedValidationStatus = _validationStatusLabel(t);
    final needsManualVerification = widget.validationStatus != "Accepted";

    final validationColor = needsManualVerification
        ? Colors.orange
        : Colors.green;

    final validationIcon = needsManualVerification
        ? Icons.warning_amber_rounded
        : Icons.verified;

    return Scaffold(
      backgroundColor: bgColor,

      appBar: AppBar(
        backgroundColor: bgColor,
        elevation: 0,
        scrolledUnderElevation: 0,

        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: textDark),
          onPressed: () {
            Navigator.pop(context);
          },
        ),

        title: Text(
          t.emergencyGuidance,
          style: TextStyle(color: textDark, fontWeight: FontWeight.bold),
        ),
      ),

      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),

          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,

            children: [
              //----------------------------------------------------------
              // VALIDATION SUMMARY
              //----------------------------------------------------------
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: widget.validationStatus == "Accepted"
                      ? Colors.green.withOpacity(0.08)
                      : widget.validationStatus == "Accepted With Warning"
                      ? Colors.orange.withOpacity(0.08)
                      : Colors.red.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: widget.validationStatus == "Accepted"
                        ? Colors.green
                        : widget.validationStatus == "Accepted With Warning"
                        ? Colors.orange
                        : Colors.red,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          widget.validationStatus == "Accepted"
                              ? Icons.verified
                              : widget.validationStatus ==
                                    "Accepted With Warning"
                              ? Icons.warning_amber_rounded
                              : Icons.cancel,
                          color: widget.validationStatus == "Accepted"
                              ? Colors.green
                              : widget.validationStatus ==
                                    "Accepted With Warning"
                              ? Colors.orange
                              : Colors.red,
                        ),

                        const SizedBox(width: 10),

                        Expanded(
                          child: Text(
                            localizedValidationStatus,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 15),

                    Text(
                      t.imageQualityScore,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.grey.shade700,
                      ),
                    ),

                    const SizedBox(height: 4),

                    Text(
                      "${widget.validationScore} / 100",
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    if (widget.validationWarnings.isNotEmpty) ...[
                      const SizedBox(height: 18),

                      const Divider(),

                      const SizedBox(height: 10),

                      Text(
                        t.warnings,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),

                      ...widget.validationWarnings.map(
                        (warning) => Padding(
                          padding: const EdgeInsets.only(bottom: 6),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Icon(
                                Icons.warning_amber_rounded,
                                color: Colors.orange,
                                size: 18,
                              ),

                              const SizedBox(width: 8),

                              Expanded(child: Text(warning)),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              const SizedBox(height: 25),
              //--------------------------------------------------
              // HEADER CARD
              //--------------------------------------------------
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),

                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(22),
                ),

                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 36,
                      backgroundColor: primaryBlue.withValues(alpha: 0.15),

                      child: Icon(_emergencyIcon, size: 38, color: primaryBlue),
                    ),

                    const SizedBox(height: 15),

                    Text(
                      _emergencyLabel(t, widget.emergencyType),
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: textDark,
                      ),
                    ),

                    const SizedBox(height: 8),

                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 15,
                        vertical: 8,
                      ),

                      decoration: BoxDecoration(
                        color: _severityColor.withValues(alpha: .15),
                        borderRadius: BorderRadius.circular(30),
                      ),

                      child: Text(
                        _severityLabel(t),
                        style: TextStyle(
                          color: _severityColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 25),

              //--------------------------------------------------
              // INCIDENT SUMMARY
              //--------------------------------------------------
              Text(
                t.incidentSummary,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: textDark,
                ),
              ),

              const SizedBox(height: 12),

              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),

                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(20),
                ),

                child: Column(
                  children: [
                    _infoRow(
                      Icons.person,
                      t.victimCondition,
                      _conditionLabel(t, widget.victimCondition),
                      textDark,
                      textSoft,
                    ),

                    const Divider(),

                    _infoRow(
                      Icons.groups,
                      t.peopleInvolved,
                      widget.victimCount,
                      textDark,
                      textSoft,
                    ),

                    const Divider(),

                    _infoRow(
                      Icons.warning,
                      t.danger,
                      _dangerLabel(t, widget.danger),
                      textDark,
                      textSoft,
                    ),

                    const Divider(),

                    _infoRow(
                      Icons.location_on,
                      t.location,
                      widget.includeLocation ? t.included : t.notIncluded,
                      textDark,
                      textSoft,
                    ),

                    const Divider(),

                    _infoRow(
                      Icons.image,
                      t.validationStatus,
                      localizedValidationStatus,
                      textDark,
                      textSoft,
                    ),
                    const Divider(),

                    _infoRow(
                      Icons.verified,
                      t.validationScore,
                      "${widget.validationScore}%",
                      textDark,
                      textSoft,
                    ),
                    const Divider(),

                    _infoRow(
                      widget.validationStatus == "Accepted"
                          ? Icons.check_circle
                          : widget.validationStatus == "Accepted With Warning"
                          ? Icons.warning_amber
                          : Icons.cancel,
                      t.validationResult,
                      localizedValidationStatus,
                      textDark,
                      widget.validationStatus == "Accepted"
                          ? Colors.green
                          : widget.validationStatus == "Accepted With Warning"
                          ? Colors.orange
                          : Colors.red,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 25),

              //--------------------------------------------------
              // DESCRIPTION
              //--------------------------------------------------
              Text(
                t.description,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: textDark,
                ),
              ),

              const SizedBox(height: 12),

              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),

                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(20),
                ),

                child: Text(
                  widget.description.isEmpty
                      ? t.noAdditionalDescription
                      : widget.description,
                  style: TextStyle(color: textSoft, height: 1.6),
                ),
              ),

              const SizedBox(height: 25),

              //--------------------------------------------------
              // GUIDANCE TITLE
              //--------------------------------------------------
              Text(
                t.recommendedActions,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: textDark,
                ),
              ),

              const SizedBox(height: 15),

              //--------------------------------------------------
              // GUIDANCE LIST
              //--------------------------------------------------
              ..._guidance.map(
                (item) => _guidanceCard(item, cardColor, textDark),
              ),

              const SizedBox(height: 35),

              //--------------------------------------------------
              // ACTION BUTTONS
              //--------------------------------------------------
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pushNamedAndRemoveUntil(
                      context,
                      AppRoutes.emergencyNow,
                      (route) => false,
                    );
                  },
                  icon: const Icon(Icons.check_circle_outline),
                  label: Text(
                    t.guestFinishGuidance,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryBlue,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 15),

              const SizedBox(height: 25),
            ],
          ),
        ),
      ),
    );
  }

  //----------------------------------------------------------
  // INFO ROW
  //----------------------------------------------------------

  Widget _infoRow(
    IconData icon,
    String title,
    String value,
    Color titleColor,
    Color valueColor,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, color: primaryBlue),

          const SizedBox(width: 12),

          Expanded(
            child: Text(
              title,
              style: TextStyle(color: titleColor, fontWeight: FontWeight.bold),
            ),
          ),

          Text(value, style: TextStyle(color: valueColor)),
        ],
      ),
    );
  }

  //----------------------------------------------------------
  // GUIDANCE CARD
  //----------------------------------------------------------

  Widget _guidanceCard(String text, Color cardColor, Color textColor) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),

      padding: const EdgeInsets.all(18),

      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(18),
      ),

      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,

        children: [
          const Icon(Icons.check_circle, color: Colors.green),

          const SizedBox(width: 12),

          Expanded(
            child: Text(text, style: TextStyle(color: textColor, height: 1.5)),
          ),
        ],
      ),
    );
  }
}
