import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../services/emergency_image_validation_service.dart';
import '../../services/emergency_decision_engine.dart';
import '../flow/manual_guidance_screen.dart';
import '../../services/fake_detector.dart';

class ManualReportScreen extends StatefulWidget {
  const ManualReportScreen({super.key});

  @override
  State<ManualReportScreen> createState() => _ManualReportScreenState();
}

class _ManualReportScreenState extends State<ManualReportScreen> {
  //----------------------------------------------------------
  // CONTROLLERS
  //----------------------------------------------------------

  final TextEditingController _descriptionController = TextEditingController();

  final ImagePicker _picker = ImagePicker();
  final FakeDetector _fakeDetector = FakeDetector();

  File? _selectedImage;

  //----------------------------------------------------------
  // VALIDATION
  //----------------------------------------------------------

  bool _isValidating = false;

  bool _imageValidated = false;

  bool _allowSubmit = false;

  ImageValidationResult? _validationResult;
  EmergencyDecisionResult? _decisionResult;

  String _validationTitle = "";

  String _validationMessage = "";

  Color _validationColor = Colors.orange;

  IconData _validationIcon = Icons.help_outline;

  //----------------------------------------------------------
  // EMERGENCY DETAILS
  //----------------------------------------------------------

  String _selectedEmergency = "Accident";

  String _selectedVictimCount = "1";

  String _selectedVictimCondition = "Unknown";

  String _selectedDanger = "Unknown";

  bool _includeLocation = true;
  bool _modelLoaded = false;

  //----------------------------------------------------------
  // EMERGENCY TYPES
  //----------------------------------------------------------

  final List<String> emergencyTypes = [
    "Accident",

    "Fire",

    "Medical",

    "Flood",

    "Crime",

    "Building Collapse",

    "Chemical Spill",

    "Animal Rescue",

    "Other",
  ];

  //----------------------------------------------------------
  // VICTIMS
  //----------------------------------------------------------

  final List<String> victimCounts = ["1", "2", "3-5", "6+", "Unknown"];

  //----------------------------------------------------------
  // CONDITIONS
  //----------------------------------------------------------

  final List<String> victimConditions = [
    "Conscious",

    "Unconscious",

    "Bleeding",

    "Trapped",

    "Unknown",
  ];

  //----------------------------------------------------------
  // DANGERS
  //----------------------------------------------------------

  final List<String> dangers = [
    "Fire",

    "Smoke",

    "Fuel Leak",

    "Traffic",

    "None",

    "Unknown",
  ];

  //----------------------------------------------------------
  // COLORS
  //----------------------------------------------------------

  static const Color primaryBlue = Color(0xFF2F6FE4);
  //----------------------------------------------------------
  // INIT
  //----------------------------------------------------------
  @override
  void initState() {
    super.initState();
    _loadFakeDetector();
  }

  Future<void> _loadFakeDetector() async {
    print("===== START =====");

    try {
      print("Calling loadModel()");

      await _fakeDetector.loadModel();

      print("Returned from loadModel()");

      setState(() {
        _modelLoaded = true;
      });

      print("Model ready.");
    } catch (e, s) {
      print("ERROR:");
      print(e);
      print(s);
    }

    print("===== END =====");
  }
  //----------------------------------------------------------
  // TAKE PHOTO
  //----------------------------------------------------------

  Future<void> _takePhoto() async {
    final image = await _picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 90,
    );

    if (image == null) return;
    _validationResult = null;
    _decisionResult = null;

    setState(() {
      _selectedImage = File(image.path);

      _validationResult = null;
      _decisionResult = null;

      _imageValidated = false;
      _allowSubmit = false;

      _validationTitle = "";
      _validationMessage = "";

      _validationColor = Colors.orange;
      _validationIcon = Icons.help_outline;
    });
  }

  //----------------------------------------------------------
  // PICK IMAGE
  //----------------------------------------------------------

  Future<void> _pickImage() async {
    final image = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 90,
    );

    if (image == null) return;
    _validationResult = null;
    _decisionResult = null;

    setState(() {
      _selectedImage = File(image.path);

      _validationResult = null;
      _decisionResult = null;

      _imageValidated = false;
      _allowSubmit = false;

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
    if (!_modelLoaded) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("AI model is still loading. Please wait."),
        ),
      );
      return;
    }

    if (_selectedImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please upload an image first.")),
      );
      return;
    }

    setState(() {
      _isValidating = true;
    });

    try {
      // Check file, screenshot, cartoon, document, blur and image quality.
      _validationResult = await EmergencyImageValidationService.validateImage(
        _selectedImage!,
      );

      final qualityDecision = EmergencyDecisionEngine.evaluate(
        _validationResult!,
      );

      // Reject invalid file, screenshot, document, cartoon or non-emergency scene.
      if (!qualityDecision.allowAiAnalysis) {
        _decisionResult = EmergencyDecisionResult(
          status: EmergencyDecisionStatus.reject,
          allowAiAnalysis: false,
          title: "Image Rejected",
          message: "Rejected: ${_validationResult!.reason}",
          decisionScore: qualityDecision.decisionScore,
          warnings: qualityDecision.warnings,
        );
      } else {
        // Reject AI-generated image.
        final fakeResult = await _fakeDetector.detect(_selectedImage!);

        if (fakeResult.isFake) {
          _decisionResult = EmergencyDecisionResult(
            status: EmergencyDecisionStatus.reject,
            allowAiAnalysis: false,
            title: "Image Rejected",
            message:
                "Rejected: Possible AI-generated or digitally manipulated image detected.",
            decisionScore: 0,
            warnings: ["AI authenticity screening flagged this image."],
          );
        } else {
          // Accept real-looking image; preserve smoke/blur warnings.
          final hasQualityWarning =
              qualityDecision.status == EmergencyDecisionStatus.warning ||
              qualityDecision.warnings.isNotEmpty;

          _decisionResult = EmergencyDecisionResult(
            status: hasQualityWarning
                ? EmergencyDecisionStatus.warning
                : EmergencyDecisionStatus.accept,
            allowAiAnalysis: true,
            title: hasQualityWarning
                ? "Accepted With Warning"
                : "Image Accepted",
            message: hasQualityWarning
                ? "Accepted: The image can be analysed, but smoke, low light, motion, or other quality issues may reduce clarity."
                : "Accepted: Likely a real emergency image. No strong AI-generation indicators were detected.",
            decisionScore: qualityDecision.decisionScore,
            warnings: qualityDecision.warnings,
          );
        }
      }
    } catch (e) {
      _decisionResult = EmergencyDecisionResult(
        status: EmergencyDecisionStatus.reject,
        allowAiAnalysis: false,
        title: "Image Rejected",
        message: "Rejected: Unable to validate this image.",
        decisionScore: 0,
        warnings: [],
      );

      debugPrint("Image validation error: $e");
    }

    _allowSubmit = _decisionResult!.allowAiAnalysis;
    _validationTitle = _decisionResult!.title;
    _validationMessage = _decisionResult!.message;

    switch (_decisionResult!.status) {
      case EmergencyDecisionStatus.accept:
        _validationColor = Colors.green;
        _validationIcon = Icons.verified;
        break;
      case EmergencyDecisionStatus.warning:
        _validationColor = Colors.orange;
        _validationIcon = Icons.warning_amber_rounded;
        break;
      case EmergencyDecisionStatus.reject:
        _validationColor = Colors.red;
        _validationIcon = Icons.cancel;
        break;
    }

    if (!mounted) return;

    setState(() {
      _imageValidated = true;
      _isValidating = false;
    });
  }

  //----------------------------------------------------------
  // SECTION TITLE
  //----------------------------------------------------------

  Widget _buildSectionTitle(String title, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 17,
          fontWeight: FontWeight.bold,
          color: color,
        ),
      ),
    );
  }

  //----------------------------------------------------------
  // CONTINUE PART 3
  //----------------------------------------------------------
  //----------------------------------------------------------
  // CHOICE CHIP
  //----------------------------------------------------------

  Widget _buildChoiceChip({
    required String label,
    required bool selected,
    required VoidCallback onTap,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.only(right: 8, bottom: 8),
      child: ChoiceChip(
        label: Text(label),
        selected: selected,
        showCheckmark: false,
        labelStyle: TextStyle(
          color: selected
              ? Colors.white
              : isDark
              ? Colors.white
              : Colors.black87,
          fontWeight: FontWeight.w600,
        ),
        selectedColor: primaryBlue,
        backgroundColor: isDark
            ? const Color(0xFF24324A)
            : Colors.grey.shade200,
        side: BorderSide(color: selected ? primaryBlue : Colors.grey.shade400),
        onSelected: (_) => onTap(),
      ),
    );
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

    final textSoft = isDark ? Colors.white70 : const Color(0xFF71829E);

    return Scaffold(
      backgroundColor: bgColor,

      appBar: AppBar(
        backgroundColor: bgColor,

        elevation: 0,

        scrolledUnderElevation: 0,

        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: textDark),

          onPressed: () {
            Navigator.pop(context);
          },
        ),

        title: Text(
          "Manual Emergency Report",

          style: TextStyle(color: textDark, fontWeight: FontWeight.w800),
        ),
      ),

      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 10, 20, 30),

          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,

            children: [
              //------------------------------------------------
              // INCIDENT PHOTO
              //------------------------------------------------
              Text(
                "Incident Photo",

                style: TextStyle(
                  fontSize: 18,

                  fontWeight: FontWeight.bold,

                  color: textDark,
                ),
              ),

              const SizedBox(height: 15),

              //------------------------------------------------
              // CONTINUE PART 4
              //------------------------------------------------
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(color: Colors.grey.shade300, width: 1.5),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      //--------------------------------------------------
                      // IMAGE PREVIEW
                      //--------------------------------------------------
                      Container(
                        height: 240,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: isDark
                              ? Colors.grey.shade900
                              : Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(color: Colors.grey.shade400),
                        ),
                        child: _selectedImage == null
                            ? Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.add_a_photo_outlined,
                                    size: 72,
                                    color: Colors.grey,
                                  ),

                                  const SizedBox(height: 12),

                                  Text(
                                    "No Image Selected",
                                    style: TextStyle(
                                      color: textSoft,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),

                                  const SizedBox(height: 8),

                                  Text(
                                    "Take a photo or choose one from your gallery.",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: textSoft,
                                      fontSize: 13,
                                    ),
                                  ),
                                ],
                              )
                            : ClipRRect(
                                borderRadius: BorderRadius.circular(18),
                                child: Image.file(
                                  _selectedImage!,
                                  fit: BoxFit.cover,
                                  width: double.infinity,
                                ),
                              ),
                      ),

                      const SizedBox(height: 18),

                      //--------------------------------------------------
                      // CAMERA & GALLERY
                      //--------------------------------------------------
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: _takePhoto,
                              icon: const Icon(Icons.camera_alt),
                              label: const Text("Camera"),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: primaryBlue,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 15,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15),
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(width: 10),

                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: _pickImage,
                              icon: const Icon(Icons.photo_library),
                              label: const Text("Gallery"),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.orange,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 15,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 15),

                      //--------------------------------------------------
                      // VALIDATE IMAGE
                      //--------------------------------------------------
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
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                          ),
                        ),
                      ),

                      //--------------------------------------------------
                      // VALIDATION RESULT
                      //--------------------------------------------------
                      if (_imageValidated) ...[
                        const SizedBox(height: 18),

                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: _validationColor.withOpacity(0.10),
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(
                              color: _validationColor,
                              width: 1.5,
                            ),
                          ),

                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    _validationIcon,
                                    color: _validationColor,
                                  ),

                                  const SizedBox(width: 10),

                                  Expanded(
                                    child: Text(
                                      _validationTitle,
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: _validationColor,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ),
                                ],
                              ),

                              const SizedBox(height: 12),

                              Text(
                                _validationMessage,
                                style: TextStyle(color: textDark, height: 1.5),
                              ),

                              if (_decisionResult != null &&
                                  _decisionResult!.warnings.isNotEmpty) ...[
                                const SizedBox(height: 15),

                                const Divider(),

                                const SizedBox(height: 8),

                                Text(
                                  "Warnings",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: textDark,
                                  ),
                                ),

                                const SizedBox(height: 8),

                                ..._decisionResult!.warnings.map(
                                  (warning) => Padding(
                                    padding: const EdgeInsets.only(bottom: 6),
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const Icon(
                                          Icons.warning_amber_rounded,
                                          size: 18,
                                          color: Colors.orange,
                                        ),

                                        const SizedBox(width: 8),

                                        Expanded(
                                          child: Text(
                                            warning,
                                            style: TextStyle(color: textDark),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 28),

              //--------------------------------------------------
              // CONTINUE PART 5
              //--------------------------------------------------
              //--------------------------------------------------
              // EMERGENCY DETAILS
              //--------------------------------------------------
              _buildSectionTitle("Emergency Details", textDark),

              //--------------------------------------------------
              // EMERGENCY TYPE
              //--------------------------------------------------
              Text(
                "Emergency Type",
                style: TextStyle(color: textDark, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 10),

              Wrap(
                children: emergencyTypes.map((type) {
                  return _buildChoiceChip(
                    label: type,
                    selected: _selectedEmergency == type,
                    onTap: () {
                      setState(() {
                        _selectedEmergency = type;
                      });
                    },
                  );
                }).toList(),
              ),

              const SizedBox(height: 24),

              //--------------------------------------------------
              // PEOPLE INVOLVED
              //--------------------------------------------------
              Text(
                "People Involved",
                style: TextStyle(color: textDark, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 10),

              Wrap(
                children: victimCounts.map((count) {
                  return _buildChoiceChip(
                    label: count,
                    selected: _selectedVictimCount == count,
                    onTap: () {
                      setState(() {
                        _selectedVictimCount = count;
                      });
                    },
                  );
                }).toList(),
              ),

              const SizedBox(height: 24),

              //--------------------------------------------------
              // VICTIM CONDITION
              //--------------------------------------------------
              Text(
                "Victim Condition",
                style: TextStyle(color: textDark, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 10),

              Wrap(
                children: victimConditions.map((condition) {
                  return _buildChoiceChip(
                    label: condition,
                    selected: _selectedVictimCondition == condition,
                    onTap: () {
                      setState(() {
                        _selectedVictimCondition = condition;
                      });
                    },
                  );
                }).toList(),
              ),

              const SizedBox(height: 24),

              //--------------------------------------------------
              // DANGER PRESENT
              //--------------------------------------------------
              Text(
                "Danger Present",
                style: TextStyle(color: textDark, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 10),

              Wrap(
                children: dangers.map((danger) {
                  return _buildChoiceChip(
                    label: danger,
                    selected: _selectedDanger == danger,
                    onTap: () {
                      setState(() {
                        _selectedDanger = danger;
                      });
                    },
                  );
                }).toList(),
              ),

              const SizedBox(height: 30),

              //--------------------------------------------------
              // DESCRIPTION
              //--------------------------------------------------
              _buildSectionTitle("Emergency Description", textDark),

              TextFormField(
                controller: _descriptionController,
                maxLines: 5,
                decoration: InputDecoration(
                  hintText: "Briefly describe what happened...",
                  filled: true,
                  fillColor: cardColor,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(18),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                ),
              ),

              const SizedBox(height: 28),

              //--------------------------------------------------
              // LOCATION
              //--------------------------------------------------
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 15,
                ),
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Row(
                  children: [
                    Icon(Icons.location_on, color: primaryBlue),

                    const SizedBox(width: 12),

                    Expanded(
                      child: Text(
                        "Include Live Location",
                        style: TextStyle(
                          color: textDark,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),

                    Switch(
                      value: _includeLocation,
                      onChanged: (value) {
                        setState(() {
                          _includeLocation = value;
                        });
                      },
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 30),

              //--------------------------------------------------
              // CONTINUE PART 6
              //--------------------------------------------------
              //--------------------------------------------------
              // SUBMIT BUTTON
              //--------------------------------------------------
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    //------------------------------------------------
                    // IMAGE REQUIRED
                    //------------------------------------------------

                    if (_selectedImage == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Please upload an emergency image."),
                        ),
                      );

                      return;
                    }

                    //------------------------------------------------
                    // VALIDATION REQUIRED
                    //------------------------------------------------

                    if (!_imageValidated) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Please validate the image first."),
                        ),
                      );

                      return;
                    }

                    //------------------------------------------------
                    // DECISION ENGINE
                    //------------------------------------------------

                    if (!_allowSubmit) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            _decisionResult?.message ?? "Image rejected",
                          ),
                          backgroundColor: Colors.red,
                        ),
                      );

                      return;
                    }

                    //------------------------------------------------
                    // NAVIGATE
                    //------------------------------------------------

                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ManualGuidanceScreen(
                          emergencyType: _selectedEmergency,

                          victimCondition: _selectedVictimCondition,

                          victimCount: _selectedVictimCount,

                          danger: _selectedDanger,

                          includeLocation: _includeLocation,

                          description: _descriptionController.text.trim(),

                          validationScore: _decisionResult?.decisionScore ?? 0,

                          validationStatus: EmergencyDecisionEngine.statusLabel(
                            _decisionResult!,
                          ),

                          validationWarnings: _decisionResult?.warnings ?? [],
                        ),
                      ),
                    );
                  },

                  icon: const Icon(Icons.arrow_forward),

                  label: const Text(
                    "Continue to Manual Guidance",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
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

              const SizedBox(height: 25),
            ],
          ),
        ),
      ),
    );
  }

  //----------------------------------------------------------
  // DISPOSE
  //----------------------------------------------------------

  @override
  void dispose() {
    _descriptionController.dispose();

    super.dispose();
  }
}
