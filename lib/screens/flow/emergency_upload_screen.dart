import 'dart:io';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';

import '../../l10n/app_localizations.dart';
import '../../routes.dart';

class EmergencyUploadScreen extends StatefulWidget {
  const EmergencyUploadScreen({super.key});

  @override
  State<EmergencyUploadScreen> createState() => _EmergencyUploadScreenState();
}

class _EmergencyUploadScreenState extends State<EmergencyUploadScreen> {
  final ImagePicker _picker = ImagePicker();

  File? _selectedImage;
  String? _selectedImageName;
  bool _includeLocation = true;
  bool _isAnalyzing = false;

  Future<void> _takePhoto() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 85,
      );

      if (image == null) return;

      setState(() {
        _selectedImage = File(image.path);
        _selectedImageName = image.name;
      });
    } catch (e) {
      _showSnackBar('Camera error: $e');
    }
  }

  Future<void> _uploadGallery() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );

      if (image == null) return;

      setState(() {
        _selectedImage = File(image.path);
        _selectedImageName = image.name;
      });
    } catch (e) {
      _showSnackBar('Gallery error: $e');
    }
  }

  void _removeImage() {
    setState(() {
      _selectedImage = null;
      _selectedImageName = null;
    });
  }

  Future<String?> _getCurrentLocationLink() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        _showSnackBar('Please enable location service.');
        return null;
      }

      LocationPermission permission = await Geolocator.checkPermission();

      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.denied) {
        _showSnackBar('Location permission denied.');
        return null;
      }

      if (permission == LocationPermission.deniedForever) {
        _showSnackBar('Location permission permanently denied.');
        return null;
      }

      final Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      return 'https://maps.google.com/?q=${position.latitude},${position.longitude}';
    } catch (e) {
      _showSnackBar('Location error: $e');
      return null;
    }
  }

  Future<void> _analyzeNow() async {
    final l10n = AppLocalizations.of(context)!;

    if (_selectedImage == null) {
      _showSnackBar(l10n.pleaseSelectPhotoFirst);
      return;
    }

    setState(() {
      _isAnalyzing = true;
    });

    String? locationLink;

    if (_includeLocation) {
      locationLink = await _getCurrentLocationLink();
    }

    if (!mounted) return;

    setState(() {
      _isAnalyzing = false;
    });

    Navigator.pushNamed(
      context,
      AppRoutes.emergencyAnalysisResult,
      arguments: {
        'imagePath': _selectedImage!.path,
        'imageName': _selectedImageName ?? 'emergency_photo.jpg',
        'includeLocation': _includeLocation,
        'location': locationLink ?? 'Location not available',
      },
    );
  }

  void _cancelUpload() {
    Navigator.pop(context);
  }

  void _showSnackBar(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    const bgColor = Color(0xFFEAF1FB);
    const textDark = Color(0xFF0B1B3A);
    const textSoft = Color(0xFF71829E);
    const primaryBlue = Color(0xFF2F6FE4);
    const dangerRed = Color(0xFFE53935);

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
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      onPressed: _isAnalyzing
                          ? null
                          : () => Navigator.pop(context),
                      icon: const Icon(
                        Icons.arrow_back_ios_new_rounded,
                        size: 20,
                        color: textDark,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    l10n.emergencyUpload,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: textDark,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 22),

              Text(
                l10n.uploadEmergencyPhoto,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w900,
                  color: textDark,
                ),
              ),

              const SizedBox(height: 8),

              Text(
                l10n.uploadEmergencyPhotoDesc,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 15,
                  height: 1.4,
                  color: textSoft,
                  fontWeight: FontWeight.w500,
                ),
              ),

              const SizedBox(height: 24),

              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Column(
                  children: [
                    Container(
                      height: 230,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF5F8FD),
                        borderRadius: BorderRadius.circular(22),
                        border: Border.all(
                          color: const Color(0xFFD9E3F2),
                          width: 1.5,
                        ),
                      ),
                      child: _selectedImage == null
                          ? Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(
                                  Icons.image_outlined,
                                  size: 58,
                                  color: textSoft,
                                ),
                                const SizedBox(height: 14),
                                Text(
                                  l10n.tapUploadOrCapture,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    color: textSoft,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            )
                          : ClipRRect(
                              borderRadius: BorderRadius.circular(22),
                              child: Stack(
                                children: [
                                  Positioned.fill(
                                    child: Image.file(
                                      _selectedImage!,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                  Positioned(
                                    right: 10,
                                    top: 10,
                                    child: InkWell(
                                      onTap: _isAnalyzing ? null : _removeImage,
                                      child: Container(
                                        padding: const EdgeInsets.all(8),
                                        decoration: const BoxDecoration(
                                          color: Colors.white,
                                          shape: BoxShape.circle,
                                        ),
                                        child: const Icon(
                                          Icons.close_rounded,
                                          color: dangerRed,
                                          size: 20,
                                        ),
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                    left: 12,
                                    right: 12,
                                    bottom: 12,
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 10,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.black.withOpacity(0.55),
                                        borderRadius: BorderRadius.circular(14),
                                      ),
                                      child: Text(
                                        _selectedImageName ?? 'Selected image',
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 13.5,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                    ),

                    const SizedBox(height: 18),

                    Row(
                      children: [
                        Expanded(
                          child: _EmergencyActionButton(
                            icon: Icons.photo_camera_outlined,
                            label: l10n.takePhoto,
                            onTap: _isAnalyzing ? null : _takePhoto,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _EmergencyActionButton(
                            icon: Icons.photo_library_outlined,
                            label: l10n.uploadGallery,
                            onTap: _isAnalyzing ? null : _uploadGallery,
                          ),
                        ),
                      ],
                    ),

                    if (_selectedImage != null) ...[
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: OutlinedButton.icon(
                          onPressed: _isAnalyzing ? null : _removeImage,
                          icon: const Icon(Icons.delete_outline_rounded),
                          label: const Text('Remove Image'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: dangerRed,
                            side: const BorderSide(color: dangerRed),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18),
                            ),
                          ),
                        ),
                      ),
                    ],
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
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.location_on_outlined, color: primaryBlue),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        l10n.includeLocationReport,
                        style: const TextStyle(
                          fontSize: 16,
                          color: textDark,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    Switch(
                      value: _includeLocation,
                      onChanged: _isAnalyzing
                          ? null
                          : (value) {
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

              const SizedBox(height: 22),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _isAnalyzing ? null : _analyzeNow,
                  icon: _isAnalyzing
                      ? const SizedBox(
                          height: 18,
                          width: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.3,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.auto_awesome_rounded),
                  label: Text(
                    _isAnalyzing ? 'Analyzing...' : l10n.analyzeNow,
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

              const SizedBox(height: 12),

              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: _isAnalyzing ? null : _cancelUpload,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: textDark,
                    padding: const EdgeInsets.symmetric(vertical: 17),
                    side: const BorderSide(color: Color(0xFFD9E3F2)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                  ),
                  child: const Text(
                    'Cancel',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmergencyActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onTap;

  const _EmergencyActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    const textDark = Color(0xFF0B1B3A);
    const primaryBlue = Color(0xFF2F6FE4);

    return SizedBox(
      height: 56,
      child: OutlinedButton.icon(
        onPressed: onTap,
        icon: Icon(icon, color: primaryBlue),
        label: Text(
          label,
          style: const TextStyle(
            fontSize: 15.5,
            color: textDark,
            fontWeight: FontWeight.w700,
          ),
        ),
        style: OutlinedButton.styleFrom(
          backgroundColor: Colors.white,
          side: const BorderSide(color: Color(0xFFD9E3F2)),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
        ),
      ),
    );
  }
}
