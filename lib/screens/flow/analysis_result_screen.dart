import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

import '../../routes.dart';
import '../../services/ai_emergency_service.dart';
import '../common/app_bottom_nav.dart';
import '../../l10n/app_localizations.dart';

class AnalysisResultScreen extends StatefulWidget {
  const AnalysisResultScreen({super.key});

  @override
  State<AnalysisResultScreen> createState() => _AnalysisResultScreenState();
}

class _AnalysisResultScreenState extends State<AnalysisResultScreen> {
  bool _loading = true;
  bool _saving = false;
  String? _error;

  EmergencyAiResult? _result;
  File? _imageFile;
  //----------------------------------------------------------
  // VALIDATION
  //----------------------------------------------------------

  int _validationScore = 0;

  String _validationStatus = "";

  List<String> _validationWarnings = [];

  String _role = "someoneElse";
  bool _includeLocation = true;
  bool _started = false;
  bool get _hasVerifiedEmergency {
    if (_result == null) return false;

    return _result!.incidentCategory.toLowerCase() != "non-emergency" &&
        _result!.incidentSubType.toLowerCase() != "animal observation" &&
        _result!.emergencyType.toLowerCase() != "unknown" &&
        _result!.confidence >= 60;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (_started) return;
    _started = true;

    final args = ModalRoute.of(context)?.settings.arguments;

    if (args is Map<String, dynamic>) {
      _role = (args['role'] ?? 'someoneElse').toString();

      _includeLocation = args['includeLocation'] == true;

      _validationScore = args["validationScore"] ?? 0;

      _validationStatus = args["validationStatus"] ?? "";

      _validationWarnings = List<String>.from(args["validationWarnings"] ?? []);

      final imagePath = args['imagePath']?.toString();

      if (imagePath != null && imagePath.isNotEmpty) {
        _imageFile = File(imagePath);
      }
    }

    _runAnalysis();
  }

  Future<void> _runAnalysis() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      if (_imageFile == null) {
        throw Exception('No image selected.');
      }

      // STEP 1: CHECK IMAGE FIRST

      // STEP 2: AI ASSISTANCE ONLY

      final result = await AiEmergencyService.analyzeImage(
        _imageFile!,
        role: _role,
        languageCode: Localizations.localeOf(context).languageCode,
      );

      if (!mounted) return;
      setState(() {
        _result = result;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  Future<String> _getRealLocation() async {
    if (!_includeLocation) return 'Location not shared';

    try {
      LocationPermission permission = await Geolocator.checkPermission();

      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        return 'Location permission denied';
      }

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      return 'https://maps.google.com/?q=${position.latitude},${position.longitude}';
    } catch (e) {
      return 'Location unavailable';
    }
  }

  Future<void> _confirmAndSave() async {
    if (_result == null) return;
    if (!_hasVerifiedEmergency) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "No emergency incident was identified. Report not saved.",
          ),
        ),
      );
      return;
    }

    setState(() => _saving = true);

    try {
      final user = FirebaseAuth.instance.currentUser;
      final uid = user?.uid ?? 'guest';

      final location = await _getRealLocation();

      final reportRef = await FirebaseFirestore.instance
          .collection('emergency_reports')
          .add({
            'userId': uid,
            'reporterRole': _role,
            'incidentCategory': _result!.incidentCategory,
            'incidentSubType': _result!.incidentSubType,
            'emergencyType': _result!.emergencyType,
            'confidence': _result!.confidence,
            'severity': _result!.severity,
            'evidence': _result!.evidence,
            'summary': _result!.summary,
            'responders': _result!.responders,
            'equipment': _result!.equipment,
            'safetySteps': _result!.safetySteps,
            'includeLocation': _includeLocation,
            'location': location,
            'status': 'active',
            'trackingStage': 'sent',
            'emergencyId': '',
            'createdAt': FieldValue.serverTimestamp(),
            'updatedAt': FieldValue.serverTimestamp(),
            'validationScore': _validationScore,
            'validationStatus': _validationStatus,
            'validationWarnings': _validationWarnings,
          });

      await reportRef.update({'emergencyId': reportRef.id});

      await FirebaseFirestore.instance.collection('notifications').add({
        'userId': uid,
        'title': 'Emergency result detected',
        'message':
            '${_result!.emergencyType} detected with ${_result!.confidence}% confidence.',
        'type': 'ai_detection',
        'isRead': false,
        'reportId': reportRef.id,
        'emergencyId': reportRef.id,
        'createdAt': FieldValue.serverTimestamp(),
      });

      if (!mounted) return;

      Navigator.pushNamed(
        context,
        AppRoutes.guidance,
        arguments: {
          'reportId': reportRef.id,
          'emergencyId': reportRef.id,
          'role': _role,
          'incidentCategory': _result!.incidentCategory,
          'incidentSubType': _result!.incidentSubType,
          'emergencyType': _result!.emergencyType,
          'confidence': _result!.confidence,
          'severity': _result!.severity,
          'summary': _result!.summary,
          'evidence': _result!.evidence,
          'responders': _result!.responders,
          'equipment': _result!.equipment,
          'safetySteps': _result!.safetySteps,
          'location': location,
          'status': 'active',
          'trackingStage': 'sent',
          'validationScore': _validationScore,
          'validationStatus': _validationStatus,
          'validationWarnings': _validationWarnings,
        },
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _saving = false);

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Save failed: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final bgColor = isDark ? const Color(0xFF0B1220) : const Color(0xFFEAF1FB);

    final cardColor = isDark ? const Color(0xFF162033) : Colors.white;

    final textDark = isDark ? Colors.white : const Color(0xFF0B1B3A);

    final textSoft = isDark ? Colors.white70 : const Color(0xFF71829E);
    final t = AppLocalizations.of(context)!;

    const primaryBlue = Color(0xFF2F6FE4);

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: _loading
            ? const _LoadingView()
            : _error != null
            ? _ErrorView(error: _error!, onRetry: _runAnalysis)
            : SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 10, 20, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        Container(
                          height: 44,
                          width: 44,
                          decoration: BoxDecoration(
                            color: cardColor,
                            shape: BoxShape.circle,
                          ),
                          child: IconButton(
                            onPressed: () => Navigator.pop(context),
                            icon: Icon(
                              Icons.arrow_back_ios_new_rounded,
                              size: 20,
                              color: textDark,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            t.emergencyAnalysisResult,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              color: textDark,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),
                    if (_imageFile != null)
                      ClipRRect(
                        borderRadius: BorderRadius.circular(24),
                        child: Image.file(
                          _imageFile!,
                          height: 185,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        ),
                      ),

                    const SizedBox(height: 18),

                    _ValidationSummaryCard(
                      validationScore: _validationScore,
                      validationStatus: _validationStatus,
                      validationWarnings: _validationWarnings,
                    ),

                    const SizedBox(height: 20),

                    //const SizedBox(height: 20),
                    _ResultCard(result: _result!),
                    const SizedBox(height: 16),
                    _ListCard(
                      title: t.analysisEvidenceDetected,
                      icon: Icons.check_circle_outline,
                      items: _result!.evidence,
                    ),
                    const SizedBox(height: 16),
                    _SummaryCard(summary: _result!.summary),
                    const SizedBox(height: 16),
                    _ListCard(
                      title: t.analysisRecommendedResponders,
                      icon: Icons.local_hospital_outlined,
                      items: _result!.responders,
                    ),
                    const SizedBox(height: 16),
                    _ListCard(
                      title: t.analysisSuggestedEquipment,
                      icon: Icons.medical_services_outlined,
                      items: _result!.equipment,
                    ),
                    const SizedBox(height: 18),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _saving ? null : _confirmAndSave,
                        icon: _saving
                            ? const SizedBox(
                                height: 18,
                                width: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Icon(Icons.check_circle_outline),
                        label: Text(
                          _saving
                              ? t.analysisSaving
                              : _hasVerifiedEmergency
                              ? t.analysisConfirmGetHelp
                              : t.analysisNoEmergencyIdentified,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryBlue,
                          foregroundColor: Colors.white,
                          disabledBackgroundColor: primaryBlue.withOpacity(
                            0.55,
                          ),
                          disabledForegroundColor: Colors.white70,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(vertical: 18),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: _saving ? null : _runAnalysis,
                            icon: const Icon(Icons.refresh),
                            label: Text(t.analysisReanalyze),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: textDark,
                              backgroundColor: cardColor.withOpacity(0.9),
                              disabledForegroundColor: textSoft,
                              side: BorderSide.none,
                              padding: const EdgeInsets.symmetric(vertical: 15),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: _saving
                                ? null
                                : () => Navigator.pop(context),
                            icon: const Icon(Icons.cancel_outlined),
                            label: Text(t.analysisFalseAlarm),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: textSoft,
                              backgroundColor: cardColor.withOpacity(0.9),
                              disabledForegroundColor: textSoft,
                              side: BorderSide.none,
                              padding: const EdgeInsets.symmetric(vertical: 15),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
      ),
      bottomNavigationBar: const AppBottomNav(currentIndex: 1),
    );
  }
}

class _LoadingView extends StatelessWidget {
  const _LoadingView();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final textSoft = isDark ? Colors.white70 : const Color(0xFF71829E);

    const primaryBlue = Color(0xFF2F6FE4);
    final t = AppLocalizations.of(context)!;

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CircularProgressIndicator(color: primaryBlue),
          const SizedBox(height: 16),
          Text(
            t.analysisLoading,
            style: TextStyle(fontWeight: FontWeight.w700, color: textSoft),
          ),
        ],
      ),
    );
  }
}

class _ResultCard extends StatelessWidget {
  final EmergencyAiResult result;

  const _ResultCard({required this.result});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final cardColor = isDark ? const Color(0xFF162033) : Colors.white;

    final textDark = isDark ? Colors.white : const Color(0xFF0B1B3A);

    final textSoft = isDark ? Colors.white70 : const Color(0xFF71829E);

    final t = AppLocalizations.of(context)!;

    final progressBg = isDark
        ? const Color(0xFF334155)
        : const Color(0xFFE2E8F3);

    const primaryBlue = Color(0xFF2F6FE4);

    final confidence = result.confidence.clamp(0, 100);
    final progress = confidence / 100;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.warning_amber_rounded,
                color: Colors.redAccent,
                size: 28,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  t.analysisEmergencyDetected,
                  style: TextStyle(
                    fontSize: 19,
                    fontWeight: FontWeight.w900,
                    color: textDark,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Column(
                  children: [
                    _MetaLine(
                      label: t.analysisType,
                      value: result.emergencyType,
                    ),
                    const SizedBox(height: 10),
                    _MetaLine(
                      label: t.analysisSeverity,
                      value: result.severity,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Container(
                height: 86,
                width: 86,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: primaryBlue,
                ),
                child: Center(
                  child: Text(
                    '$confidence%',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Text(
                t.analysisConfidenceLevel,
                style: TextStyle(
                  color: textSoft,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              Text(
                '$confidence%',
                style: const TextStyle(
                  color: primaryBlue,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 10,
              backgroundColor: progressBg,
              color: primaryBlue,
            ),
          ),
        ],
      ),
    );
  }
}

class _MetaLine extends StatelessWidget {
  final String label;
  final String value;

  const _MetaLine({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final textDark = isDark ? Colors.white : const Color(0xFF0B1B3A);

    final textSoft = isDark ? Colors.white70 : const Color(0xFF71829E);

    return Row(
      children: [
        Text(
          '$label: ',
          style: TextStyle(
            color: textSoft,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              color: textDark,
              fontSize: 20,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
      ],
    );
  }
}

class _ListCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final List<String> items;

  const _ListCard({
    required this.title,
    required this.icon,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final cardColor = isDark ? const Color(0xFF162033) : Colors.white;

    final textDark = isDark ? Colors.white : const Color(0xFF0B1B3A);
    final t = AppLocalizations.of(context)!;

    const primaryBlue = Color(0xFF2F6FE4);

    final safeItems = items.isEmpty ? [t.analysisNoSpecificDetails] : items;

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: primaryBlue, size: 24),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 19,
                    fontWeight: FontWeight.w900,
                    color: textDark,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...safeItems.map(
            (text) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.check_circle_outline,
                    color: primaryBlue,
                    size: 22,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      text,
                      style: TextStyle(
                        fontSize: 16,
                        height: 1.4,
                        color: textDark,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final String summary;

  const _SummaryCard({required this.summary});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final cardColor = isDark ? const Color(0xFF162033) : Colors.white;

    final textDark = isDark ? Colors.white : const Color(0xFF0B1B3A);

    final textSoft = isDark ? Colors.white70 : Colors.black.withOpacity(0.55);
    final t = AppLocalizations.of(context)!;

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 18),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            t.analysisIncidentSummary,
            style: TextStyle(
              fontSize: 19,
              fontWeight: FontWeight.w900,
              color: textDark,
            ),
          ),
          const SizedBox(height: 14),
          Text(
            summary.isEmpty ? t.analysisNoSummary : summary,
            style: TextStyle(
              fontSize: 16,
              height: 1.55,
              color: textSoft,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _ValidationSummaryCard extends StatelessWidget {
  final int validationScore;
  final String validationStatus;
  final List<String> validationWarnings;

  const _ValidationSummaryCard({
    required this.validationScore,
    required this.validationStatus,
    required this.validationWarnings,
  });

  String _statusLabel(AppLocalizations t) {
    switch (validationStatus) {
      case "Accepted":
        return t.validationImageAcceptedTitle;
      case "Accepted With Warning":
        return t.validationAcceptedWarningTitle;
      default:
        return t.validationImageRejectedTitle;
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final cardColor = isDark ? const Color(0xFF162033) : Colors.white;
    final textDark = isDark ? Colors.white : const Color(0xFF0B1B3A);
    final textSoft = isDark ? Colors.white70 : const Color(0xFF71829E);

    final isAccepted = validationStatus == "Accepted";
    final isWarning = validationStatus == "Accepted With Warning";

    final color = isAccepted
        ? Colors.green
        : isWarning
        ? Colors.orange
        : Colors.red;

    final icon = isAccepted
        ? Icons.verified
        : isWarning
        ? Icons.warning_amber_rounded
        : Icons.cancel;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: color),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  t.emergencyImageValidation,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 18),

          _ValidationRow(
            label: t.validationStatus,
            value: _statusLabel(t),
            labelColor: textSoft,
            valueColor: textDark,
          ),

          _ValidationRow(
            label: t.imageQualityScore,
            value: "$validationScore / 100",
            labelColor: textSoft,
            valueColor: textDark,
          ),

          if (validationWarnings.isNotEmpty) ...[
            const SizedBox(height: 15),
            Divider(color: isDark ? Colors.white24 : Colors.black12),
            const SizedBox(height: 10),

            Text(
              t.warnings,
              style: TextStyle(color: textDark, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 8),

            ...validationWarnings.map(
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
                    Expanded(
                      child: Text(warning, style: TextStyle(color: textDark)),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _ValidationRow extends StatelessWidget {
  final String label;
  final String value;
  final Color labelColor;
  final Color valueColor;

  const _ValidationRow({
    required this.label,
    required this.value,
    required this.labelColor,
    required this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          SizedBox(
            width: 140,
            child: Text(
              label,
              style: TextStyle(color: labelColor, fontWeight: FontWeight.w600),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(color: valueColor, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  final String error;
  final VoidCallback onRetry;

  const _ErrorView({required this.error, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final cardColor = isDark ? const Color(0xFF162033) : Colors.white;

    final textDark = isDark ? Colors.white : const Color(0xFF0B1B3A);

    final textSoft = isDark ? Colors.white70 : const Color(0xFF71829E);

    const primaryBlue = Color(0xFF2F6FE4);
    final t = AppLocalizations.of(context)!;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Container(
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(24),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.error_outline,
                color: Colors.redAccent,
                size: 42,
              ),
              const SizedBox(height: 12),
              Text(
                t.analysisFailed,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  color: textDark,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                error,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: textSoft,
                  height: 1.4,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: onRetry,
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryBlue,
                  foregroundColor: Colors.white,
                ),
                child: Text(t.analysisTryAgain),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
