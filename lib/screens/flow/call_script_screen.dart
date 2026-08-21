import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../routes.dart';
import '../../services/ai_emergency_service.dart';
import '../common/app_bottom_nav.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CallScriptScreen extends StatefulWidget {
  const CallScriptScreen({super.key});

  @override
  State<CallScriptScreen> createState() => _CallScriptScreenState();
}

class _CallScriptScreenState extends State<CallScriptScreen> {
  bool _loading = true;
  bool _usedFallback = false;
  bool _loadedArgs = false;

  late String role;
  late String emergencyType;
  late String severity;
  late String location;
  late List<String> evidence;
  late List<String> responders;
  late List<String> equipment;
  late List<String> emergencyPhones;

  String _script = '';

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (_loadedArgs) return;
    _loadedArgs = true;

    final args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;

    role = (args?['role'] ?? 'victim').toString();
    emergencyType = (args?['emergencyType'] ?? 'Accident').toString();
    severity = (args?['severity'] ?? 'High').toString();
    location = (args?['location'] ?? 'Current GPS location shared').toString();

    evidence = ((args?['evidence'] as List?) ?? <dynamic>[])
        .map((e) => e.toString())
        .toList();

    responders = ((args?['responders'] as List?) ?? _defaultResponders())
        .map((e) => e.toString())
        .toList();

    equipment = ((args?['equipment'] as List?) ?? _defaultEquipment())
        .map((e) => e.toString())
        .toList();

    emergencyPhones = _extractEmergencyPhones(args);

    _generateScript();
  }

  List<String> _extractEmergencyPhones(Map<String, dynamic>? args) {
    final phones = <String>[];

    final rawPhones = args?['emergencyPhones'];
    if (rawPhones is List) {
      phones.addAll(rawPhones.map((e) => e.toString()));
    }

    final rawContacts = args?['emergencyContacts'];
    if (rawContacts is List) {
      for (final item in rawContacts) {
        if (item is Map && item['phone'] != null) {
          phones.add(item['phone'].toString());
        }
      }
    }

    return phones
        .map((e) => e.replaceAll(' ', '').replaceAll('-', ''))
        .where((e) => e.isNotEmpty)
        .toSet()
        .toList();
  }

  List<String> _defaultResponders() {
    final type = emergencyType.toLowerCase();

    if (type.contains('fire') || type.contains('hazard')) {
      return ['Fire Rescue / Bomba'];
    }

    if (type.contains('crime') || type.contains('police')) {
      return ['Police'];
    }

    if (type.contains('medical')) {
      return ['Ambulance'];
    }

    return ['Ambulance', 'Police'];
  }

  List<String> _defaultEquipment() {
    final type = emergencyType.toLowerCase();

    if (type.contains('fire')) {
      return ['Fire extinguisher', 'First aid kit', 'Torchlight'];
    }

    if (type.contains('medical')) {
      return ['First aid kit', 'Clean cloth', 'Gloves'];
    }

    if (type.contains('accident')) {
      return ['First aid kit', 'Warning triangle', 'Torchlight'];
    }

    return ['First aid kit', 'Torchlight'];
  }

  Future<void> _generateScript() async {
    try {
      final script = await AiEmergencyService.generateCallScript(
        emergencyType: emergencyType,
        severity: severity,
        location: location,
        evidence: evidence,
        responders: responders,
        equipment: equipment,
        role: role,
      );

      if (!mounted) return;

      setState(() {
        _script = script.trim().isEmpty ? _localFallbackScript() : script;
        _loading = false;
        _usedFallback = script.trim().isEmpty;
      });
    } catch (_) {
      if (!mounted) return;

      setState(() {
        _script = _localFallbackScript();
        _loading = false;
        _usedFallback = true;
      });
    }
  }

  String _localFallbackScript() {
    final isVictim = role.toLowerCase() == 'victim';
    final evidenceText = evidence.isEmpty
        ? 'No extra visual evidence available.'
        : evidence.join(', ');

    return '''
Hello, I need emergency assistance.

I am reporting as: ${isVictim ? 'Victim / I need help' : 'Witness / Someone needs help'}.

Emergency type: $emergencyType.
Severity level: $severity.

My current location is:
$location.

Situation details:
$evidenceText.

Recommended responder:
${responders.join(', ')}.

Suggested emergency equipment:
${equipment.join(', ')}.

Please send help as soon as possible. I will stay on the line and follow your instructions.
''';
  }

  String _sosMessage() {
    return '''
SOS EMERGENCY ALERT

Emergency Type: $emergencyType
Severity: $severity

Location:
$location

Recommended Responders:
${responders.join(', ')}

Suggested Equipment:
${equipment.join(', ')}

Call Script:
$_script
''';
  }

  Future<void> _call999() async {
    final uri = Uri(scheme: 'tel', path: '999');

    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      _showSnack('Unable to open phone dialer.');
    }
  }

  Future<void> _sendSmsToContacts() async {
    final phones = <String>[...emergencyPhones];

    final user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      final snap = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('emergency_contacts')
          .get();

      for (final doc in snap.docs) {
        final data = doc.data();
        final phone = (data['phone'] ?? '').toString().trim();

        if (phone.isNotEmpty) {
          phones.add(phone);
        }
      }
    }

    final cleanedPhones = phones
        .map((phone) => phone.replaceAll(' ', '').replaceAll('-', ''))
        .where((phone) => phone.isNotEmpty)
        .toSet()
        .toList();

    if (cleanedPhones.isEmpty) {
      _showSnack('No emergency contact phone number found.');
      return;
    }

    final message = Uri.encodeComponent(_sosMessage());
    final recipients = cleanedPhones.join(',');

    final uri = Uri.parse('sms:$recipients?body=$message');

    try {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (e) {
      _showSnack('Unable to open SMS app.');
    }
  }

  Future<void> _sendWhatsapp() async {
    final message = Uri.encodeComponent(_sosMessage());

    final Uri uri = emergencyPhones.isNotEmpty
        ? Uri.parse('https://wa.me/${emergencyPhones.first}?text=$message')
        : Uri.parse('https://wa.me/?text=$message');

    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      _showSnack('Unable to open WhatsApp.');
    }
  }

  void _goToReportStatus() {
    Navigator.pushNamed(
      context,
      AppRoutes.reportStatus,
      arguments: {
        'role': role,
        'emergencyType': emergencyType,
        'severity': severity,
        'location': location,
        'evidence': evidence,
        'responders': responders,
        'equipment': equipment,
        'emergencyPhones': emergencyPhones,
        'callReady': true,
        'guidanceGenerated': true,
        'emergencyDetected': true,
        'sosSent': true,
        'locationShared': true,
        'contactsReady': true,
      },
    );
  }

  void _showSnack(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final bgColor = isDark ? const Color(0xFF0B1220) : const Color(0xFFEAF1FB);

    final cardColor = isDark ? const Color(0xFF162033) : Colors.white;

    final innerCardColor = isDark
        ? const Color(0xFF0F172A)
        : const Color(0xFFF5F8FD);

    final textDark = isDark ? Colors.white : const Color(0xFF0B1B3A);

    final textSoft = isDark ? Colors.white70 : const Color(0xFF71829E);

    final warningBg = isDark
        ? const Color(0xFF2B2113)
        : const Color(0xFFFFF7ED);

    final warningBorder = isDark
        ? const Color(0xFF7C4A03)
        : const Color(0xFFF97316);

    final callIconBg = isDark
        ? const Color(0xFF2A1720)
        : const Color(0xFFFFE8E8);

    const primaryBlue = Color(0xFF2F6FE4);
    const dangerRed = Color(0xFFE12529);
    const whatsappGreen = Color(0xFF22C55E);

    final isVictim = role.toLowerCase() == 'victim';

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: _loading
            ? const Center(child: CircularProgressIndicator(color: primaryBlue))
            : SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(18, 12, 18, 28),
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
                              size: 19,
                              color: textDark,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Call Script',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w900,
                              color: textDark,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 22),

                    Container(
                      padding: const EdgeInsets.all(22),
                      decoration: BoxDecoration(
                        color: cardColor,
                        borderRadius: BorderRadius.circular(26),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(
                              alpha: isDark ? 0.18 : 0.04,
                            ),
                            blurRadius: 18,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          Container(
                            height: 86,
                            width: 86,
                            decoration: BoxDecoration(
                              color: callIconBg,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.call_outlined,
                              color: dangerRed,
                              size: 42,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Emergency Call Guide',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 23,
                              fontWeight: FontWeight.w900,
                              color: textDark,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Call 999, read the script clearly, and share your location with emergency contacts.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 14.5,
                              height: 1.45,
                              color: textSoft,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),

                    if (_usedFallback) ...[
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: warningBg,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: warningBorder.withValues(alpha: 0.30),
                          ),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(
                              Icons.info_outline_rounded,
                              color: Color(0xFFF97316),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'AI is busy right now, so a safe emergency script was prepared automatically.',
                                style: TextStyle(
                                  fontSize: 14,
                                  height: 1.45,
                                  color: textDark,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],

                    const SizedBox(height: 16),

                    _SectionCard(
                      title: 'Emergency Details',
                      child: Column(
                        children: [
                          _DetailRow(
                            icon: Icons.warning_amber_rounded,
                            label: 'Emergency Type',
                            value: emergencyType,
                          ),
                          const SizedBox(height: 12),
                          _DetailRow(
                            icon: Icons.priority_high_rounded,
                            label: 'Severity',
                            value: severity,
                          ),
                          const SizedBox(height: 12),
                          _DetailRow(
                            icon: Icons.location_on_outlined,
                            label: 'Location',
                            value: location,
                          ),
                          const SizedBox(height: 12),
                          _DetailRow(
                            icon: Icons.health_and_safety_outlined,
                            label: 'Responders',
                            value: responders.join(', '),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    _SectionCard(
                      title: 'Script to Read',
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          color: innerCardColor,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          _script,
                          style: TextStyle(
                            fontSize: 15,
                            height: 1.55,
                            color: textDark,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 22),

                    ElevatedButton.icon(
                      onPressed: _call999,
                      icon: const Icon(Icons.call),
                      label: const Text(
                        'Call 999',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: dangerRed,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 17),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                        ),
                      ),
                    ),

                    if (isVictim) ...[
                      const SizedBox(height: 12),

                      ElevatedButton.icon(
                        onPressed: _sendSmsToContacts,
                        icon: const Icon(Icons.sms_outlined),
                        label: const Text(
                          'Send SMS to Emergency Contacts',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryBlue,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(vertical: 17),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18),
                          ),
                        ),
                      ),

                      const SizedBox(height: 12),

                      ElevatedButton.icon(
                        onPressed: _sendWhatsapp,
                        icon: const Icon(Icons.chat_bubble_outline),
                        label: const Text(
                          'Send WhatsApp',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: whatsappGreen,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(vertical: 17),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18),
                          ),
                        ),
                      ),
                    ],
                    const SizedBox(height: 12),

                    OutlinedButton.icon(
                      onPressed: _goToReportStatus,
                      icon: const Icon(Icons.fact_check_outlined),
                      label: const Text(
                        'Go to Report Status',
                        style: TextStyle(
                          fontSize: 15.5,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: textDark,
                        backgroundColor: cardColor,
                        side: BorderSide.none,
                        padding: const EdgeInsets.symmetric(vertical: 17),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
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

class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final cardColor = isDark ? const Color(0xFF162033) : Colors.white;

    final textDark = isDark ? Colors.white : const Color(0xFF0B1B3A);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
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

class _DetailRow extends StatelessWidget {
  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final textDark = isDark ? Colors.white : const Color(0xFF0B1B3A);

    final textSoft = isDark ? Colors.white70 : const Color(0xFF71829E);

    final iconBg = isDark ? const Color(0xFF1E2A44) : const Color(0xFFEAF1FF);

    const primaryBlue = Color(0xFF2F6FE4);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          height: 42,
          width: 42,
          decoration: BoxDecoration(
            color: iconBg,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(icon, color: primaryBlue, size: 22),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 13.5,
                  color: textSoft,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                value,
                softWrap: true,
                style: TextStyle(
                  fontSize: 14.8,
                  color: textDark,
                  height: 1.35,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
