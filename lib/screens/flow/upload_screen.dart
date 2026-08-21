import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../l10n/app_localizations.dart';
import '../../routes.dart';
import '../../services/emergency_decision_engine.dart';
import '../../services/emergency_image_validation_service.dart';
import '../common/app_bottom_nav.dart';
import '../../services/fake_detector.dart';

class UploadScreen extends StatefulWidget {
  const UploadScreen({super.key});

  @override
  State<UploadScreen> createState() => _UploadScreenState();
}

class _UploadScreenState extends State<UploadScreen> {
  //----------------------------------------------------------
  // REPORT
  //----------------------------------------------------------

  bool _includeLocation = true;

  File? _selectedImage;

  String? _selectedImageName;

  String _role = "witness";

  //----------------------------------------------------------
  // VALIDATION
  //----------------------------------------------------------

  bool _isValidating = false;

  bool _imageValidated = false;

  bool _allowAiAnalysis = false;

  ImageValidationResult? _validationResult;

  EmergencyDecisionResult? _decisionResult;

  String _validationTitle = "";

  String _validationMessage = "";

  Color _validationColor = Colors.orange;

  IconData _validationIcon = Icons.help_outline;
  final FakeDetector _fakeDetector = FakeDetector();
  bool _modelLoaded = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final args = ModalRoute.of(context)?.settings.arguments;

    if (args is Map<String, dynamic>) {
      _role = (args['role'] ?? 'witness').toString();
    } else if (args is String) {
      _role = args;
    }
  }

  @override
  void initState() {
    super.initState();
    _loadFakeDetector();
  }

  Future<void> _loadFakeDetector() async {
    try {
      await _fakeDetector.loadModel();

      if (!mounted) return;

      setState(() {
        _modelLoaded = true;
      });
    } catch (e) {
      debugPrint("Fake detector loading error: $e");
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    final picker = ImagePicker();

    final picked = await picker.pickImage(
      source: source,
      imageQuality: 85,
      maxWidth: 1280,
    );

    if (picked == null) return;

    setState(() {
      _selectedImage = File(picked.path);

      _selectedImageName = picked.name;

      _validationResult = null;

      _decisionResult = null;

      _imageValidated = false;

      _allowAiAnalysis = false;

      _validationTitle = "";

      _validationMessage = "";

      _validationColor = Colors.orange;

      _validationIcon = Icons.help_outline;
    });
  }

  //----------------------------------------------------------
  // VALIDATE IMAGE
  //----------------------------------------------------------

  Future<void> _validateImage() async {
    if (_selectedImage == null) return;

    if (!_modelLoaded) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Authenticity screening model is still loading."),
        ),
      );
      return;
    }

    setState(() {
      _isValidating = true;
    });

    bool possibleAiImage = false;

    try {
      final fakeResult = await _fakeDetector.detect(_selectedImage!);
      possibleAiImage = fakeResult.isFake;

      _validationResult = await EmergencyImageValidationService.validateImage(
        _selectedImage!,
      );

      final qualityDecision = EmergencyDecisionEngine.evaluate(
        _validationResult!,
      );

      final warnings = <String>{
        ...qualityDecision.warnings,
        if (possibleAiImage)
          "Possible AI-generated or edited image. Manual verification is recommended.",
      }.toList();

      final needsManualVerification =
          possibleAiImage ||
          qualityDecision.status != EmergencyDecisionStatus.accept;

      _decisionResult = EmergencyDecisionResult(
        status: needsManualVerification
            ? EmergencyDecisionStatus.warning
            : EmergencyDecisionStatus.accept,

        // Allow emergency analysis, but clearly show warnings.
        allowAiAnalysis: true,

        title: needsManualVerification
            ? "Manual Verification Recommended"
            : "Image Ready for Analysis",

        message: needsManualVerification
            ? "AI analysis can continue, but this image should be manually verified."
            : "Image quality is sufficient for analysis. "
                  "Authenticity screening found no strong AI-generation indicators.",

        decisionScore: qualityDecision.decisionScore,
        warnings: warnings,
      );

      _allowAiAnalysis = true;
      _validationTitle = _decisionResult!.title;
      _validationMessage = _decisionResult!.message;

      _validationColor = needsManualVerification ? Colors.orange : Colors.green;

      _validationIcon = needsManualVerification
          ? Icons.warning_amber_rounded
          : Icons.verified;
    } catch (e) {
      debugPrint("Image validation error: $e");

      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Image validation failed: $e")));
      }
    } finally {
      if (mounted) {
        setState(() {
          _imageValidated = _decisionResult != null;
          _isValidating = false;
        });
      }
    }
  }

  //----------------------------------------------------------
  // ANALYZE
  //----------------------------------------------------------

  Future<void> _analyzeNow() async {
    //----------------------------------------------------------
    // IMAGE REQUIRED
    //----------------------------------------------------------

    if (_selectedImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please upload an image first.")),
      );

      return;
    }

    //----------------------------------------------------------
    // VALIDATE FIRST
    //----------------------------------------------------------

    if (!_imageValidated) {
      await _validateImage();
    }

    //----------------------------------------------------------
    // DECISION ENGINE
    //----------------------------------------------------------

    if (!_allowAiAnalysis) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.red,

          content: Text(_validationMessage),
        ),
      );

      return;
    }

    //----------------------------------------------------------
    // AI ANALYSIS
    //----------------------------------------------------------

    if (!mounted) return;

    Navigator.pushNamed(
      context,

      AppRoutes.analysisResult,

      arguments: {
        "role": _role,

        "includeLocation": _includeLocation,

        "imagePath": _selectedImage!.path,

        "imageName": _selectedImageName,

        "validationScore": _decisionResult!.decisionScore,

        "validationStatus": EmergencyDecisionEngine.statusLabel(
          _decisionResult!,
        ),

        "validationWarnings": _decisionResult!.warnings,
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    final isDark = Theme.of(context).brightness == Brightness.dark;

    final bgColor = isDark ? const Color(0xFF0B1220) : const Color(0xFFEAF1FB);

    final cardColor = isDark ? const Color(0xFF162033) : Colors.white;

    final innerCardColor = isDark
        ? const Color(0xFF0F172A)
        : const Color(0xFFF5F8FD);

    final textDark = isDark ? Colors.white : const Color(0xFF0B1B3A);

    final textSoft = isDark ? Colors.white70 : const Color(0xFF71829E);

    final softBlueBg = isDark
        ? const Color(0xFF1E2A44)
        : const Color(0xFFEAF1FF);

    final aiInfoBg = isDark
        ? const Color(0xFF162033).withOpacity(0.85)
        : Colors.white.withOpacity(0.65);

    final disabledButtonColor = isDark
        ? const Color(0xFF334155)
        : const Color(0xFFB8C7E6);

    const primaryBlue = Color(0xFF2F6FE4);

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: SingleChildScrollView(
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
                        color: textDark,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    l10n.uploadReport,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: textDark,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 22),
              Text(
                l10n.uploadIncidentPhoto,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                  color: textDark,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                l10n.uploadIncidentPhotoDesc,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 15,
                  color: textSoft,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 14),
              Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: cardColor,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    _role == 'witness'
                        ? 'Someone Needs Help'
                        : 'Other Emergency',
                    style: const TextStyle(
                      fontSize: 15,
                      color: primaryBlue,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 22),
              Container(
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(28),
                ),
                child: Column(
                  children: [
                    Container(
                      height: 240,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: innerCardColor,
                        borderRadius: BorderRadius.circular(22),
                        border: Border.all(
                          color: const Color(0xFF8BB2FF),
                          width: 1.4,
                        ),
                      ),
                      child: _selectedImage == null
                          ? Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(
                                  Icons.cloud_upload_outlined,
                                  size: 62,
                                  color: primaryBlue,
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  l10n.noPhotoSelected,
                                  style: TextStyle(
                                    fontSize: 17,
                                    color: textDark,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  l10n.captureOrUpload,
                                  style: TextStyle(
                                    fontSize: 14.5,
                                    color: textSoft,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            )
                          : ClipRRect(
                              borderRadius: BorderRadius.circular(22),
                              child: Image.file(
                                _selectedImage!,
                                width: double.infinity,
                                height: 240,
                                fit: BoxFit.cover,
                              ),
                            ),
                    ),

                    if (_selectedImageName != null) ...[
                      const SizedBox(height: 10),

                      Text(
                        _selectedImageName!,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 13.5,
                          color: textSoft,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],

                    const SizedBox(height: 18),

                    //----------------------------------------------------------
                    // EMERGENCY IMAGE VALIDATION
                    //----------------------------------------------------------
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _isValidating ? null : _validateImage,

                        icon: _isValidating
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Icon(Icons.verified_user),

                        label: Text(
                          _isValidating
                              ? "Validating..."
                              : "Emergency Image Validation",
                        ),

                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,

                          foregroundColor: Colors.white,

                          padding: const EdgeInsets.symmetric(vertical: 15),

                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18),
                          ),
                        ),
                      ),
                    ),

                    //----------------------------------------------------------
                    // VALIDATION RESULT
                    //----------------------------------------------------------
                    if (_imageValidated) ...[
                      const SizedBox(height: 16),

                      Container(
                        width: double.infinity,

                        padding: const EdgeInsets.all(16),

                        decoration: BoxDecoration(
                          color: _validationColor.withOpacity(0.08),

                          borderRadius: BorderRadius.circular(18),

                          border: Border.all(color: _validationColor),
                        ),

                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,

                          children: [
                            Row(
                              children: [
                                Icon(_validationIcon, color: _validationColor),

                                const SizedBox(width: 10),

                                Expanded(
                                  child: Text(
                                    _validationTitle,

                                    style: TextStyle(
                                      color: _validationColor,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 10),

                            Text(
                              _validationMessage,
                              style: TextStyle(color: textDark, height: 1.4),
                            ),

                            if (_decisionResult != null &&
                                _decisionResult!.warnings.isNotEmpty) ...[
                              const SizedBox(height: 12),

                              const Divider(),

                              const SizedBox(height: 8),

                              const Text(
                                "Warnings",
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),

                              const SizedBox(height: 6),

                              ..._decisionResult!.warnings.map(
                                (warning) => Padding(
                                  padding: const EdgeInsets.only(bottom: 6),
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
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
                    ],

                    const SizedBox(height: 18),

                    Row(
                      children: [
                        Expanded(
                          child: SizedBox(
                            height: 54,
                            child: OutlinedButton.icon(
                              onPressed: () => _pickImage(ImageSource.camera),
                              icon: const Icon(
                                Icons.photo_camera_outlined,
                                color: primaryBlue,
                              ),
                              label: Text(
                                l10n.takePhoto,
                                style: const TextStyle(
                                  color: primaryBlue,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              style: OutlinedButton.styleFrom(
                                backgroundColor: cardColor,
                                side: const BorderSide(color: primaryBlue),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(18),
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: SizedBox(
                            height: 54,
                            child: ElevatedButton.icon(
                              onPressed: () => _pickImage(ImageSource.gallery),
                              icon: const Icon(Icons.photo_library_outlined),
                              label: Text(
                                l10n.gallery,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: primaryBlue,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(18),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 18,
                ),
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Row(
                  children: [
                    Container(
                      height: 56,
                      width: 56,
                      decoration: BoxDecoration(
                        color: softBlueBg,
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: const Icon(
                        Icons.location_on_outlined,
                        color: primaryBlue,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l10n.includeGps,
                            style: TextStyle(
                              fontSize: 16,
                              color: textDark,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            l10n.shareLocation,
                            style: TextStyle(
                              fontSize: 14,
                              color: textSoft,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Switch(
                      value: _includeLocation,
                      onChanged: (value) {
                        setState(() {
                          _includeLocation = value;
                        });
                      },
                      activeColor: Colors.white,
                      activeTrackColor: primaryBlue,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 18,
                ),
                decoration: BoxDecoration(
                  color: aiInfoBg,
                  borderRadius: BorderRadius.circular(22),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.auto_awesome_outlined, color: primaryBlue),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        l10n.aiAnalysisInfo,
                        style: TextStyle(
                          fontSize: 14.5,
                          color: textSoft,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 22),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _selectedImage == null ? null : _analyzeNow,

                  icon: const Icon(Icons.auto_awesome),

                  label: Text(
                    _allowAiAnalysis
                        ? "Continue to AI Analysis"
                        : "Validate & Analyze",

                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                    ),
                  ),

                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryBlue,

                    foregroundColor: Colors.white,

                    disabledBackgroundColor: disabledButtonColor,

                    disabledForegroundColor: isDark
                        ? Colors.white54
                        : Colors.white,

                    padding: const EdgeInsets.symmetric(vertical: 18),

                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: const AppBottomNav(currentIndex: 1),
    );
  }
}
