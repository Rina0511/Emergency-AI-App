import 'dart:io';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

import '../../l10n/app_localizations.dart';
import '../../routes.dart';
import '../../services/ai_emergency_service.dart';

class EmergencyAnalysisResultScreen extends StatefulWidget {
  const EmergencyAnalysisResultScreen({super.key});

  @override
  State<EmergencyAnalysisResultScreen> createState() =>
      _EmergencyAnalysisResultScreenState();
}

class _EmergencyAnalysisResultScreenState
    extends State<EmergencyAnalysisResultScreen> {
  bool _started = false;
  bool _loading = true;
  String? _error;

  File? _imageFile;
  EmergencyAiResult? _result;
  String _location = 'Location not shared';

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (_started) return;
    _started = true;

    final args = ModalRoute.of(context)?.settings.arguments;

    if (args is Map<String, dynamic>) {
      final imagePath = args['imagePath']?.toString();
      if (imagePath != null && imagePath.isNotEmpty) {
        _imageFile = File(imagePath);
      }
    }

    _runGeminiAnalysis();
  }

  Future<void> _runGeminiAnalysis() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      if (_imageFile == null) {
        throw Exception('No image selected.');
      }

      //final result = await AiEmergencyService.analyzeImage(_imageFile!);
      final location = await _getRealLocation();

      if (!mounted) return;

      setState(() {
        //_result = result;
        _location = location;
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

  void _continueToGuidance() {
    final result = _result;
    if (result == null) return;

    Navigator.pushNamed(
      context,
      AppRoutes.emergencyGuidance,
      arguments: {
        'role': 'victim',
        'emergencyType': result.emergencyType,
        'confidence': result.confidence,
        'severity': result.severity,
        'summary': result.summary,
        'evidence': result.evidence,
        'responders': result.responders,
        'equipment': result.equipment,
        'safetySteps': result.safetySteps,
        'location': _location,
        'isGuest': true,
        'noLoginRequired': true,
      },
    );
  }

  void _goBackToUpload() {
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    const bgColor = Color(0xFFEAF1FB);
    const textDark = Color(0xFF0B1B3A);
    const textSoft = Color(0xFF71829E);
    const primaryBlue = Color(0xFF2F6FE4);

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: _loading
            ? const _LoadingView()
            : _error != null
            ? _ErrorView(
                error: _error!,
                onRetry: _runGeminiAnalysis,
                onBack: _goBackToUpload,
              )
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
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                          child: IconButton(
                            onPressed: () => Navigator.pop(context),
                            icon: const Icon(
                              Icons.arrow_back_ios_new_rounded,
                              size: 20,
                              color: textDark,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            l10n.emergencyAiResult,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              color: textDark,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    if (_imageFile != null)
                      ClipRRect(
                        borderRadius: BorderRadius.circular(24),
                        child: Image.file(
                          _imageFile!,
                          height: 180,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        ),
                      )
                    else
                      Container(
                        height: 170,
                        decoration: BoxDecoration(
                          color: const Color(0xFFF5F8FD),
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: const Center(
                          child: Icon(
                            Icons.image_not_supported_outlined,
                            size: 48,
                            color: Color(0xFF7E8DA7),
                          ),
                        ),
                      ),

                    const SizedBox(height: 18),

                    _ResultCard(result: _result!),

                    const SizedBox(height: 18),

                    _SectionCard(
                      title: 'AI Incident Summary',
                      child: Text(
                        _result!.summary.isEmpty
                            ? 'No summary generated.'
                            : _result!.summary,
                        style: const TextStyle(
                          fontSize: 15,
                          height: 1.5,
                          color: textSoft,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),

                    const SizedBox(height: 18),

                    _ListCard(
                      title: 'AI Evidence Detected',
                      icon: Icons.check_circle_outline,
                      items: _result!.evidence,
                    ),

                    const SizedBox(height: 18),

                    _ListCard(
                      title: 'Recommended Responders',
                      icon: Icons.local_hospital_outlined,
                      items: _result!.responders,
                    ),

                    const SizedBox(height: 18),

                    _ListCard(
                      title: 'Suggested Equipment',
                      icon: Icons.medical_services_outlined,
                      items: _result!.equipment,
                    ),

                    const SizedBox(height: 18),

                    _SectionCard(
                      title: 'Emergency Information',
                      child: Column(
                        children: [
                          _EmergencyInfoRow(
                            icon: Icons.access_time,
                            label: l10n.timestamp,
                            value: DateTime.now().toString().substring(0, 16),
                          ),
                          const SizedBox(height: 14),
                          _EmergencyInfoRow(
                            icon: Icons.location_on_outlined,
                            label: l10n.location,
                            value: _location,
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 22),

                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _continueToGuidance,
                        icon: const Icon(Icons.check_circle_outline),
                        label: Text(
                          l10n.continueText,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryBlue,
                          foregroundColor: Colors.white,
                          elevation: 0,
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
                      child: OutlinedButton.icon(
                        onPressed: _runGeminiAnalysis,
                        icon: const Icon(Icons.refresh),
                        label: Text(
                          l10n.reAnalyze,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: textDark,
                          backgroundColor: Colors.white,
                          side: BorderSide.none,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 12),

                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: _goBackToUpload,
                        icon: const Icon(Icons.camera_alt_outlined),
                        label: const Text(
                          'Choose Another Image',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: textSoft,
                          backgroundColor: Colors.white,
                          side: BorderSide.none,
                          padding: const EdgeInsets.symmetric(vertical: 16),
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
    );
  }
}

class _LoadingView extends StatelessWidget {
  const _LoadingView();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircularProgressIndicator(color: Color(0xFF2F6FE4)),
          SizedBox(height: 16),
          Text(
            'Analyzing image with Gemini AI...',
            style: TextStyle(
              fontWeight: FontWeight.w700,
              color: Color(0xFF71829E),
            ),
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
    const textDark = Color(0xFF0B1B3A);
    const textSoft = Color(0xFF71829E);
    const primaryBlue = Color(0xFF2F6FE4);

    final confidence = result.confidence.clamp(0, 100);
    final progress = confidence / 100;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(
                Icons.warning_amber_rounded,
                color: Colors.redAccent,
                size: 26,
              ),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Emergency Detected',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
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
                    _MetaLine(label: 'Type', value: result.emergencyType),
                    const SizedBox(height: 10),
                    _MetaLine(label: 'Severity', value: result.severity),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Container(
                height: 78,
                width: 78,
                decoration: const BoxDecoration(
                  color: primaryBlue,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    '$confidence%',
                    style: const TextStyle(
                      fontSize: 18,
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
              const Text(
                'Confidence Level',
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
              backgroundColor: const Color(0xFFE2E8F3),
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
    const textDark = Color(0xFF0B1B3A);
    const textSoft = Color(0xFF71829E);

    return Row(
      children: [
        Text(
          '$label: ',
          style: const TextStyle(
            color: textSoft,
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              color: textDark,
              fontSize: 17,
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
    const textDark = Color(0xFF0B1B3A);
    const primaryBlue = Color(0xFF2F6FE4);

    final safeItems = items.isEmpty ? ['No specific details detected'] : items;

    return _SectionCard(
      title: title,
      child: Column(
        children: safeItems.map((text) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(icon, color: primaryBlue, size: 21),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    text,
                    style: const TextStyle(
                      fontSize: 15,
                      height: 1.4,
                      color: textDark,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final Widget child;

  const _SectionCard({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    const textDark = Color(0xFF0B1B3A);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w900,
              color: textDark,
            ),
          ),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }
}

class _EmergencyInfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _EmergencyInfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    const textSoft = Color(0xFF71829E);
    const textDark = Color(0xFF0B1B3A);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: textSoft),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 15,
              color: textSoft,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.right,
            softWrap: true,
            style: const TextStyle(
              fontSize: 15,
              color: textDark,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ],
    );
  }
}

class _ErrorView extends StatelessWidget {
  final String error;
  final VoidCallback onRetry;
  final VoidCallback onBack;

  const _ErrorView({
    required this.error,
    required this.onRetry,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    const textDark = Color(0xFF0B1B3A);
    const textSoft = Color(0xFF71829E);
    const primaryBlue = Color(0xFF2F6FE4);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Container(
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            color: Colors.white,
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
              const Text(
                'AI analysis failed',
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
                style: const TextStyle(
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
                child: const Text('Try Again'),
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: onBack,
                child: const Text('Choose Another Image'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
