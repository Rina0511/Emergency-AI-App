import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../l10n/app_localizations.dart';
import '../../routes.dart';

class EmergencyNowScreen extends StatelessWidget {
  const EmergencyNowScreen({super.key});

  Future<void> _callNumber(BuildContext context, String number) async {
    final uri = Uri(scheme: 'tel', path: number);

    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Unable to open phone dialer for $number')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    const bgColor = Color(0xFFEAF1FB);
    const textDark = Color(0xFF0B1B3A);
    const textSoft = Color(0xFF71829E);
    const red = Color(0xFFE12529);
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
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(
                        Icons.arrow_back_ios_new_rounded,
                        color: textDark,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    l10n.emergencySos,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: textDark,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              const Icon(Icons.warning_amber_rounded, size: 46, color: red),

              const SizedBox(height: 8),

              Text(
                l10n.fastEmergencyResponse,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 15,
                  color: textSoft,
                  fontWeight: FontWeight.w500,
                ),
              ),

              const SizedBox(height: 18),

              Center(
                child: GestureDetector(
                  onTap: () => _callNumber(context, '999'),
                  child: Container(
                    height: 185,
                    width: 185,
                    decoration: BoxDecoration(
                      color: red,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          blurRadius: 22,
                          color: red.withOpacity(0.28),
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.call, color: Colors.white, size: 42),
                        const SizedBox(height: 8),
                        Text(
                          l10n.call999,
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 12),

              Text(
                l10n.tapToCallEmergency,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: textSoft,
                  fontWeight: FontWeight.w500,
                ),
              ),

              const SizedBox(height: 18),

              ElevatedButton.icon(
                onPressed: () {
                  Navigator.pushNamed(context, AppRoutes.emergencyUpload);
                },
                icon: const Icon(Icons.camera_alt_outlined),
                label: Text(
                  l10n.quickAiDetection,
                  style: const TextStyle(fontWeight: FontWeight.w800),
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

              const SizedBox(height: 18),

              _QuickTile(
                title: l10n.police,
                number: '999',
                subtitle: 'Call Police emergency line',
                icon: Icons.local_police_outlined,
                onTap: () => _callNumber(context, '999'),
              ),

              const SizedBox(height: 12),

              _QuickTile(
                title: l10n.ambulance,
                number: '999',
                subtitle: 'Call Ambulance emergency line',
                icon: Icons.local_hospital_outlined,
                onTap: () => _callNumber(context, '999'),
              ),

              const SizedBox(height: 12),

              _QuickTile(
                title: l10n.fireDepartment,
                number: '999',
                subtitle: 'Call Fire & Rescue / Bomba',
                icon: Icons.local_fire_department_outlined,
                onTap: () => _callNumber(context, '999'),
              ),

              const SizedBox(height: 16),

              const Text(
                'In Malaysia, dial 999 for Police, Ambulance, Fire & Rescue (Bomba), and other emergency services.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: textSoft,
                  fontSize: 13,
                  height: 1.4,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _QuickTile extends StatelessWidget {
  final String title;
  final String number;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;

  const _QuickTile({
    required this.title,
    required this.number,
    required this.subtitle,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    const textDark = Color(0xFF0B1B3A);
    const textSoft = Color(0xFF71829E);
    const red = Color(0xFFE12529);

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(22),
      child: InkWell(
        borderRadius: BorderRadius.circular(22),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(22)),
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: const Color(0xFFEAF1FF),
                child: Icon(icon, color: red),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '$title • $number',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: textDark,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: textSoft,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.call_outlined, color: red),
            ],
          ),
        ),
      ),
    );
  }
}
