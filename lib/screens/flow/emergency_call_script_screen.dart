import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../l10n/app_localizations.dart';
import '../../routes.dart';

class EmergencyCallScriptScreen extends StatelessWidget {
  const EmergencyCallScriptScreen({super.key});

  Future<void> _call999(BuildContext context) async {
    final uri = Uri(scheme: 'tel', path: '999');

    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Unable to open phone dialer.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final args = ModalRoute.of(context)?.settings.arguments;
    final data = args is Map<String, dynamic> ? args : <String, dynamic>{};

    final String role = (data['role'] ?? 'victim').toString();
    final bool isVictim = role.toLowerCase() == 'victim';

    final String location = (data['location'] ?? 'Location not available')
        .toString();

    final String emergencyType =
        (data['emergencyType'] ?? data['type'] ?? 'Emergency').toString();

    final String severity = (data['severity'] ?? 'High').toString();

    final String injuredCount =
        (data['injuredCount'] ?? data['victimCount'] ?? 'Unknown').toString();

    final String condition =
        (data['condition'] ??
                data['summary'] ??
                'Emergency assistance required')
            .toString();

    final List<dynamic> rawEquipment =
        (data['equipment'] as List?) ?? <dynamic>[];

    final List<String> equipment = rawEquipment
        .map((e) => e.toString())
        .toList();

    final String equipmentText = equipment.isEmpty
        ? '${l10n.firstAidKit}, ${l10n.flashlight}'
        : equipment.join(', ');

    final String script = isVictim
        ? '''
Hello, I need emergency assistance.

Emergency Type:
$emergencyType

Severity:
$severity

My location is:
$location

Number of injured people:
$injuredCount

Current condition:
$condition

Suggested equipment:
$equipmentText

Please send help immediately.
'''
        : '''
Hello, I want to report an emergency.

Emergency Type:
$emergencyType

Severity:
$severity

Location:
$location

Number of injured people:
$injuredCount

Current condition:
$condition

Suggested equipment:
$equipmentText

Please send emergency responders immediately.
''';

    const bgColor = Color(0xFFEAF1FB);
    const textDark = Color(0xFF0B1B3A);
    const textSoft = Color(0xFF71829E);
    const primaryBlue = Color(0xFF2F6FE4);
    const dangerRed = Color(0xFFE12529);

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: textDark),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          l10n.emergencyCallScript,
          style: const TextStyle(
            color: textDark,
            fontWeight: FontWeight.w800,
            fontSize: 20,
          ),
        ),
      ),
      body: SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                isVictim
                    ? l10n.readScriptDuringCall
                    : l10n.useScriptClearlyExplain,
                style: const TextStyle(
                  fontSize: 15,
                  height: 1.45,
                  color: textSoft,
                  fontWeight: FontWeight.w500,
                ),
              ),

              const SizedBox(height: 20),

              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFEEF0),
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(color: const Color(0xFFF3B4BC)),
                ),
                child: Row(
                  children: [
                    Container(
                      height: 52,
                      width: 52,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Icon(
                        Icons.call_outlined,
                        color: dangerRed,
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l10n.emergencyCallGuide,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              color: textDark,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            l10n.speakClearlyImportantDetails,
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

              Container(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 18),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          l10n.whatToSay,
                          style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w800,
                            color: textDark,
                          ),
                        ),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFEAF1FF),
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text(
                            isVictim ? l10n.victimScript : l10n.witnessScript,
                            style: const TextStyle(
                              fontSize: 12,
                              color: primaryBlue,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF6F8FC),
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: Text(
                        script.trim(),
                        style: const TextStyle(
                          fontSize: 15.2,
                          color: textDark,
                          height: 1.6,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 18),

              Container(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 18),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.importantDetails,
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                        color: textDark,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _DetailItem(l10n.yourExactLocation),
                    _DetailItem(l10n.typeOfEmergency),
                    _DetailItem(l10n.numberOfInjuredPeople),
                    _DetailItem(l10n.dangerAroundArea),
                    _DetailItem(l10n.equipmentRespondersNeed),
                    _DetailItem(l10n.yourContactNumberIfAsked),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              ElevatedButton.icon(
                onPressed: () => _call999(context),
                icon: const Icon(Icons.call),
                label: Text(
                  l10n.call999,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: dangerRed,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                ),
              ),

              const SizedBox(height: 12),

              OutlinedButton.icon(
                onPressed: () {
                  Navigator.pushNamed(
                    context,
                    AppRoutes.emergencyReportStatus,
                    arguments: {
                      ...data,
                      'role': role,
                      'emergencyType': emergencyType,
                      'severity': severity,
                      'location': location,
                      'injuredCount': injuredCount,
                      'condition': condition,
                      'equipment': equipment,
                    },
                  );
                },
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
}

class _DetailItem extends StatelessWidget {
  final String text;

  const _DetailItem(this.text);

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
                fontSize: 15.2,
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
