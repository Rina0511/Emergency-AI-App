import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../routes.dart';
import '../common/app_bottom_nav.dart';

class FakeDetectionUploadScreen extends StatefulWidget {
  const FakeDetectionUploadScreen({super.key});

  @override
  State<FakeDetectionUploadScreen> createState() =>
      _FakeDetectionUploadScreenState();
}

class _FakeDetectionUploadScreenState extends State<FakeDetectionUploadScreen> {
  File? _selectedImage;
  String? _imageName;

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
      _imageName = picked.name;
    });
  }

  void _checkImage() {
    if (_selectedImage == null) return;

    Navigator.pushNamed(
      context,

      AppRoutes.fakeDetectionResult,

      arguments: {'imagePath': _selectedImage!.path, 'imageName': _imageName},
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final bgColor = isDark ? const Color(0xFF0B1220) : const Color(0xFFEAF1FB);

    final cardColor = isDark ? const Color(0xFF162033) : Colors.white;

    final innerColor = isDark
        ? const Color(0xFF0F172A)
        : const Color(0xFFF5F8FD);

    final textDark = isDark ? Colors.white : const Color(0xFF0B1B3A);

    final textSoft = isDark ? Colors.white70 : const Color(0xFF71829E);

    const primaryBlue = Color(0xFF2F6FE4);

    return Scaffold(
      backgroundColor: bgColor,

      bottomNavigationBar: const AppBottomNav(currentIndex: 1),

      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 14, 20, 24),

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
                      onPressed: () {
                        Navigator.pop(context);
                      },

                      icon: Icon(Icons.arrow_back_ios_new, color: textDark),
                    ),
                  ),

                  const SizedBox(width: 12),

                  Text(
                    "Fake Image Detection",

                    style: TextStyle(
                      fontSize: 18,

                      fontWeight: FontWeight.w800,

                      color: textDark,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 25),

              Text(
                "Upload Image To Verify",

                textAlign: TextAlign.center,

                style: TextStyle(
                  fontSize: 27,

                  fontWeight: FontWeight.w900,

                  color: textDark,
                ),
              ),

              const SizedBox(height: 8),

              Text(
                "Check whether an emergency image may be edited, manipulated, or unreliable.",

                textAlign: TextAlign.center,

                style: TextStyle(color: textSoft, fontSize: 15),
              ),

              const SizedBox(height: 25),

              Container(
                padding: const EdgeInsets.all(20),

                decoration: BoxDecoration(
                  color: cardColor,

                  borderRadius: BorderRadius.circular(25),
                ),

                child: Column(
                  children: [
                    Container(
                      height: 250,

                      width: double.infinity,

                      decoration: BoxDecoration(
                        color: innerColor,

                        borderRadius: BorderRadius.circular(22),

                        border: Border.all(color: const Color(0xFF8BB2FF)),
                      ),

                      child: _selectedImage == null
                          ? Column(
                              mainAxisAlignment: MainAxisAlignment.center,

                              children: [
                                const Icon(
                                  Icons.image_search,

                                  size: 70,

                                  color: primaryBlue,
                                ),

                                const SizedBox(height: 15),

                                Text(
                                  "No Image Selected",

                                  style: TextStyle(
                                    fontSize: 17,

                                    fontWeight: FontWeight.w800,

                                    color: textDark,
                                  ),
                                ),

                                const SizedBox(height: 5),

                                Text(
                                  "Upload suspicious image for checking",

                                  style: TextStyle(color: textSoft),
                                ),
                              ],
                            )
                          : ClipRRect(
                              borderRadius: BorderRadius.circular(22),

                              child: Image.file(
                                _selectedImage!,

                                fit: BoxFit.cover,

                                width: double.infinity,
                              ),
                            ),
                    ),

                    if (_imageName != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 10),

                        child: Text(
                          _imageName!,

                          style: TextStyle(color: textSoft),
                        ),
                      ),

                    const SizedBox(height: 20),

                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () {
                              _pickImage(ImageSource.camera);
                            },

                            icon: const Icon(Icons.camera_alt),

                            label: const Text("Camera"),
                          ),
                        ),

                        const SizedBox(width: 12),

                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () {
                              _pickImage(ImageSource.gallery);
                            },

                            icon: const Icon(Icons.photo),

                            label: const Text("Gallery"),

                            style: ElevatedButton.styleFrom(
                              backgroundColor: primaryBlue,

                              foregroundColor: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              Container(
                padding: const EdgeInsets.all(18),

                decoration: BoxDecoration(
                  color: cardColor,

                  borderRadius: BorderRadius.circular(20),
                ),

                child: Row(
                  children: [
                    const Icon(Icons.info_outline, color: primaryBlue),

                    const SizedBox(width: 10),

                    Expanded(
                      child: Text(
                        "This feature helps identify possible manipulated images. It does not replace human verification.",

                        style: TextStyle(color: textSoft, fontSize: 14),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 22),

              ElevatedButton(
                onPressed: _selectedImage == null ? null : _checkImage,

                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryBlue,

                  foregroundColor: Colors.white,

                  padding: const EdgeInsets.symmetric(vertical: 18),

                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                ),

                child: const Text(
                  "Check Image",

                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
