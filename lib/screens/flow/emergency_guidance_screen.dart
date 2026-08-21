import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../l10n/app_localizations.dart';
import '../../routes.dart';

class EmergencyGuidanceScreen extends StatefulWidget {
  const EmergencyGuidanceScreen({super.key});

  @override
  State<EmergencyGuidanceScreen> createState() =>
      _EmergencyGuidanceScreenState();
}

class _EmergencyGuidanceScreenState extends State<EmergencyGuidanceScreen> {
  Map<String, dynamic> _data = {};

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is Map<String, dynamic>) {
      _data = Map<String, dynamic>.from(args);
    }
  }

  double _parseConfidence(dynamic value) {
    if (value is double) return value > 1 ? value / 100 : value;
    if (value is int) return value > 1 ? value / 100 : value.toDouble();
    if (value is String) {
      final parsed = double.tryParse(value);
      if (parsed != null) return parsed > 1 ? parsed / 100 : parsed;
    }
    return 0.0;
  }

  List<String> _parseList(dynamic value, List<String> fallback) {
    if (value is List) return value.map((e) => e.toString()).toList();

    if (value is String && value.trim().isNotEmpty) {
      return value.split(',').map((e) => e.trim()).toList();
    }

    return fallback;
  }

  String _emergencyType(AppLocalizations l10n) {
    return (_data['emergencyType'] ?? _data['type'] ?? l10n.accident)
        .toString();
  }

  String _severity(AppLocalizations l10n) {
    return (_data['severity'] ?? l10n.high).toString();
  }

  String _location() {
    return (_data['location'] ?? 'Location not available').toString();
  }

  List<String> _safetySteps(AppLocalizations l10n) {
    return _parseList(_data['safetySteps'], [
      l10n.stayCalmAssessScene,
      l10n.moveSafeArea,
      l10n.dontMoveSeriouslyInjured,
      l10n.warnOthersNearby,
      l10n.callEmergency,
    ]);
  }

  List<String> _equipment() {
    return _parseList(_data['equipment'], [
      'First aid kit',
      'Phone',
      'Flashlight',
      'Clean cloth',
    ]);
  }

  List<String> _responders(AppLocalizations l10n) {
    return _parseList(_data['responders'], [l10n.ambulance, l10n.police]);
  }

  Future<void> _call999() async {
    final uri = Uri(scheme: 'tel', path: '999');

    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      _showSnackBar('Unable to open phone dialer.');
    }
  }

  Future<void> _openMap() async {
    final location = _location();

    if (!location.startsWith('http')) {
      _showSnackBar('Valid map location is not available.');
      return;
    }

    final uri = Uri.parse(location);

    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      _showSnackBar('Unable to open map.');
    }
  }

  void _viewCallScript() {
    Navigator.pushNamed(
      context,
      AppRoutes.emergencyCallScript,
      arguments: _data,
    );
  }

  void _goToStatus() {
    Navigator.pushNamed(
      context,
      AppRoutes.emergencyReportStatus,
      arguments: _data,
    );
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
    const red = Color(0xFFE12529);

    final emergencyType = _emergencyType(l10n);
    final severity = _severity(l10n);
    final confidence = _parseConfidence(_data['confidence']);
    final safetySteps = _safetySteps(l10n);
    final responders = _responders(l10n);
    final equipment = _equipment();
    final location = _location();

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
                      l10n.emergencyGuidance,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: textDark,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 22),

              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 18,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFEEF0),
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(color: const Color(0xFFF3B4BC)),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.warning_amber_rounded,
                      color: red,
                      size: 30,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '$emergencyType — ${(confidence * 100).toStringAsFixed(0)}%',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              color: textDark,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${l10n.severity}: $severity',
                            style: const TextStyle(
                              color: textSoft,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 18),

              _InfoCard(
                title: l10n.immediateSafetySteps,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ...safetySteps.map((step) => _Step(text: step)),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 7,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEAF1FF),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        l10n.quickEmergencyGuidance,
                        style: const TextStyle(
                          fontSize: 12.5,
                          color: primaryBlue,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 18),

              _InfoCard(
                title: l10n.recommendedResponders,
                child: Column(
                  children: responders.map((responder) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _Responder(
                        emoji: _responderEmoji(responder),
                        title: responder,
                        subtitle: _responderSubtitle(responder, l10n),
                      ),
                    );
                  }).toList(),
                ),
              ),

              const SizedBox(height: 18),

              _InfoCard(
                title: 'Suggested Equipment',
                child: Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: equipment.map((item) {
                    return Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF5F8FD),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        item,
                        style: const TextStyle(
                          color: textDark,
                          fontSize: 13.5,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),

              const SizedBox(height: 18),

              _InfoCard(
                title: 'Detected Location',
                child: Row(
                  children: [
                    const Icon(Icons.location_on_outlined, color: primaryBlue),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        location,
                        style: const TextStyle(
                          color: textSoft,
                          fontSize: 14.5,
                          fontWeight: FontWeight.w600,
                          height: 1.4,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: _openMap,
                      icon: const Icon(Icons.map_outlined, color: primaryBlue),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 22),

              ElevatedButton.icon(
                onPressed: _call999,
                icon: const Icon(Icons.call),
                label: Text(
                  l10n.call999,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: red,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                ),
              ),

              const SizedBox(height: 12),

              OutlinedButton.icon(
                onPressed: _viewCallScript,
                icon: const Icon(Icons.chat_bubble_outline),
                label: Text(
                  l10n.viewWhatToSay,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  foregroundColor: textDark,
                  backgroundColor: Colors.white,
                  side: BorderSide.none,
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                ),
              ),

              const SizedBox(height: 12),

              OutlinedButton.icon(
                onPressed: _goToStatus,
                icon: const Icon(Icons.track_changes_outlined),
                label: const Text(
                  'Go To Report Status',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
                ),
                style: OutlinedButton.styleFrom(
                  foregroundColor: textDark,
                  backgroundColor: Colors.white,
                  side: BorderSide.none,
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _responderEmoji(String responder) {
    final lower = responder.toLowerCase();

    if (lower.contains('ambulance')) return '🚑';
    if (lower.contains('police')) return '🚓';
    if (lower.contains('fire') || lower.contains('bomba')) return '🚒';

    return '🚨';
  }

  String _responderSubtitle(String responder, AppLocalizations l10n) {
    final lower = responder.toLowerCase();

    if (lower.contains('ambulance')) {
      return l10n.possibleInjuredPersonsDetected;
    }

    if (lower.contains('police')) {
      return l10n.roadTrafficAccidentSupport;
    }

    if (lower.contains('fire') || lower.contains('bomba')) {
      return 'Fire and rescue support may be required.';
    }

    return 'Emergency response support recommended.';
  }
}

class _InfoCard extends StatelessWidget {
  final String title;
  final Widget child;

  const _InfoCard({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    const textDark = Color(0xFF0B1B3A);

    return Container(
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
              fontWeight: FontWeight.w800,
              color: textDark,
            ),
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }
}

class _Step extends StatelessWidget {
  final String text;

  const _Step({required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.check_circle, color: Color(0xFF77D68D), size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 15.5,
                color: Color(0xFF0B1B3A),
                fontWeight: FontWeight.w500,
                height: 1.35,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Responder extends StatelessWidget {
  final String emoji;
  final String title;
  final String subtitle;

  const _Responder({
    required this.emoji,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F8FD),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 26)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Color(0xFF0B1B3A),
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF71829E),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
