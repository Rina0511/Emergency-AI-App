import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../routes.dart';

class EmergencyProfileScreen extends StatefulWidget {
  const EmergencyProfileScreen({super.key});

  @override
  State<EmergencyProfileScreen> createState() => _EmergencyProfileScreenState();
}

class _EmergencyProfileScreenState extends State<EmergencyProfileScreen> {
  //--------------------------------------------------
  // Controllers
  //--------------------------------------------------

  final _nameController = TextEditingController();
  final _ageController = TextEditingController();

  final _allergyController = TextEditingController();

  final _medicalConditionController = TextEditingController();

  final _medicationController = TextEditingController();

  final _nextOfKinNameController = TextEditingController();

  final _nextOfKinPhoneController = TextEditingController();

  bool _loading = true;

  String _selectedBloodGroup = "Unknown";

  final List<String> _bloodGroups = [
    "A+",
    "A-",
    "B+",
    "B-",
    "O+",
    "O-",
    "AB+",
    "AB-",
    "Unknown",
  ];

  //--------------------------------------------------
  // Init
  //--------------------------------------------------

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  //--------------------------------------------------
  // Load Firestore
  //--------------------------------------------------

  Future<void> _loadProfile() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) return;

    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get();

    if (doc.exists) {
      final data = doc.data()!;

      _nameController.text = data['name'] ?? '';

      _ageController.text = data['age'] ?? '';

      _selectedBloodGroup = data['bloodType'] ?? 'Unknown';

      _allergyController.text = data['allergy'] ?? '';

      _medicalConditionController.text = data['medicalCondition'] ?? '';

      _medicationController.text = data['currentMedication'] ?? '';

      _nextOfKinNameController.text = data['nextOfKinName'] ?? '';

      _nextOfKinPhoneController.text = data['nextOfKinPhone'] ?? '';
    }

    setState(() {
      _loading = false;
    });
  }

  //--------------------------------------------------
  // Save Firestore
  //--------------------------------------------------

  Future<void> _saveProfile() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) return;

    await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
      "name": _nameController.text.trim(),

      "age": _ageController.text.trim(),

      "bloodType": _selectedBloodGroup,

      "allergy": _allergyController.text.trim(),

      "medicalCondition": _medicalConditionController.text.trim(),

      "currentMedication": _medicationController.text.trim(),

      "nextOfKinName": _nextOfKinNameController.text.trim(),

      "nextOfKinPhone": _nextOfKinPhoneController.text.trim(),

      "updatedAt": FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));

    if (!mounted) return;

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text("Emergency profile saved")));
  }

  //--------------------------------------------------
  // Dispose
  //--------------------------------------------------

  @override
  void dispose() {
    _nameController.dispose();
    _ageController.dispose();

    _allergyController.dispose();

    _medicalConditionController.dispose();

    _medicationController.dispose();

    _nextOfKinNameController.dispose();

    _nextOfKinPhoneController.dispose();

    super.dispose();
  }

  //--------------------------------------------------
  // Helper Text Field
  //--------------------------------------------------

  Widget _textField({
    required TextEditingController controller,
    required String hint,
    int maxLines = 1,
  }) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      decoration: InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: const Color(0xFFF3F6FA),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  //--------------------------------------------------
  // Build
  //--------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final bgColor = isDark ? const Color(0xFF0B1220) : const Color(0xFFEAF1FB);

    final cardColor = isDark ? const Color(0xFF182335) : Colors.white;

    final textColor = isDark ? Colors.white : const Color(0xFF0B1B3A);

    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: bgColor,

        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: textColor, size: 22),
          onPressed: () {
            Navigator.pushNamedAndRemoveUntil(
              context,
              AppRoutes.mainShell,
              (route) => false,
              arguments: 0, // Home tab
            );
          },
        ),

        title: Text(
          "Emergency Profile",
          style: TextStyle(color: textColor, fontWeight: FontWeight.bold),
        ),

        iconTheme: IconThemeData(color: textColor),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              //--------------------------------------------------
              // Information Banner
              //--------------------------------------------------
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF2F2),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFFFFCACA)),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Icon(
                        Icons.favorite_border,
                        color: Colors.red,
                        size: 28,
                      ),
                    ),

                    const SizedBox(width: 14),

                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text(
                            "Medical info shared with responders",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),

                          SizedBox(height: 4),

                          Text(
                            "Attached automatically to every SOS report",
                            style: TextStyle(color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 22),

              //--------------------------------------------------
              // PERSONAL
              //--------------------------------------------------
              Container(
                width: double.infinity,
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
                        Icon(Icons.person_outline, color: Colors.blue.shade600),

                        const SizedBox(width: 10),

                        Text(
                          "Personal",
                          style: TextStyle(
                            color: textColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    _textField(controller: _nameController, hint: "Full Name"),

                    const SizedBox(height: 16),

                    _textField(controller: _ageController, hint: "Age"),
                  ],
                ),
              ),

              const SizedBox(height: 22),

              //--------------------------------------------------
              // BLOOD GROUP
              //--------------------------------------------------
              Container(
                width: double.infinity,
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
                        Icon(
                          Icons.bloodtype_outlined,
                          color: Colors.red.shade400,
                        ),

                        const SizedBox(width: 10),

                        Text(
                          "Blood Group",
                          style: TextStyle(
                            color: textColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: _bloodGroups.map((group) {
                        final selected = group == _selectedBloodGroup;

                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              _selectedBloodGroup = group;
                            });
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            width: 96,
                            height: 46,
                            decoration: BoxDecoration(
                              color: selected
                                  ? Colors.red
                                  : const Color(0xFFF3F6FA),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Center(
                              child: Text(
                                group,
                                style: TextStyle(
                                  color: selected
                                      ? Colors.white
                                      : Colors.black87,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 22),

              //--------------------------------------------------
              // ALLERGIES
              //--------------------------------------------------
              Container(
                width: double.infinity,
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
                        Icon(
                          Icons.warning_amber_rounded,
                          color: Colors.orange.shade700,
                        ),

                        const SizedBox(width: 10),

                        Text(
                          "Allergies",
                          style: TextStyle(
                            color: textColor,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 18),

                    _textField(
                      controller: _allergyController,
                      hint: "Example: Penicillin, Peanuts",
                      maxLines: 2,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 22),

              //--------------------------------------------------
              // MEDICAL CONDITIONS
              //--------------------------------------------------
              Container(
                width: double.infinity,
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
                        Icon(
                          Icons.favorite_outline,
                          color: Colors.blue.shade600,
                        ),

                        const SizedBox(width: 10),

                        Text(
                          "Medical Conditions",
                          style: TextStyle(
                            color: textColor,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 18),

                    _textField(
                      controller: _medicalConditionController,
                      hint: "Example: Asthma, Diabetes",
                      maxLines: 3,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 22),

              //--------------------------------------------------
              // CURRENT MEDICATION
              //--------------------------------------------------
              Container(
                width: double.infinity,
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
                        Icon(
                          Icons.medication_outlined,
                          color: Colors.green.shade600,
                        ),

                        const SizedBox(width: 10),

                        Text(
                          "Current Medication",
                          style: TextStyle(
                            color: textColor,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 18),

                    _textField(
                      controller: _medicationController,
                      hint: "Example: Ventolin inhaler",
                      maxLines: 3,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 22),

              //--------------------------------------------------
              // NEXT OF KIN
              //--------------------------------------------------
              Container(
                width: double.infinity,
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
                        Icon(Icons.phone_outlined, color: Colors.blue.shade600),

                        const SizedBox(width: 10),

                        Text(
                          "Next of Kin",
                          style: TextStyle(
                            color: textColor,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 18),

                    _textField(
                      controller: _nextOfKinNameController,
                      hint: "Name (Relationship)",
                    ),

                    const SizedBox(height: 16),

                    _textField(
                      controller: _nextOfKinPhoneController,
                      hint: "Phone Number",
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 30),

              //--------------------------------------------------
              // SAVE BUTTON
              //--------------------------------------------------
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _saveProfile,
                  icon: const Icon(Icons.save_outlined),
                  label: const Text(
                    "Save Emergency Profile",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFE53935),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}
