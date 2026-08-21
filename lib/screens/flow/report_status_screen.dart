import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../l10n/app_localizations.dart';
import '../../routes.dart';

class ReportStatusScreen extends StatelessWidget {
  const ReportStatusScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final localeCode = Localizations.localeOf(context).languageCode;

    final args =
        (ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?) ??
        {};

    final String emergencyType = (args['emergencyType'] ?? l10n.accident)
        .toString();

    final String severity =
        (args['severity'] ?? _tr(localeCode, 'High', 'Tinggi')).toString();

    final String location = (args['location'] ?? 'Current GPS location shared')
        .toString();

    final List<String> responders =
        ((args['responders'] as List?) ??
                <dynamic>[
                  _tr(localeCode, 'Ambulance', 'Ambulans'),
                  _tr(localeCode, 'Police', 'Polis'),
                ])
            .map((e) => e.toString())
            .toList();

    final String emergencyId =
        (args['emergencyId'] ??
                'MY-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}')
            .toString();

    final String sosChannel = (args['sosChannel'] ?? 'SOS').toString();

    final bool incidentDetected = (args['emergencyDetected'] ?? true) == true;
    final bool guidanceGenerated = (args['guidanceGenerated'] ?? true) == true;
    final bool callScriptReady = (args['callReady'] ?? true) == true;
    final bool sosSent = (args['sosSent'] ?? true) == true;
    final bool locationShared = (args['locationShared'] ?? true) == true;
    final bool contactsNotified = (args['contactsReady'] ?? true) == true;

    final isDark = Theme.of(context).brightness == Brightness.dark;

    final bgColor = isDark ? const Color(0xFF0B1220) : const Color(0xFFEAF1FB);

    final cardColor = isDark ? const Color(0xFF162033) : Colors.white;

    final innerCardColor = isDark
        ? const Color(0xFF0F172A)
        : const Color(0xFFF5F8FD);

    final textDark = isDark ? Colors.white : const Color(0xFF0B1B3A);

    final textSoft = isDark ? Colors.white70 : const Color(0xFF71829E);

    final successBg = isDark
        ? const Color(0xFF123524)
        : const Color(0xFFEAFBF0);

    const successGreen = Color(0xFF34C759);
    const primaryBlue = Color(0xFF2F6FE4);
    const dangerRed = Color(0xFFE12529);

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: SingleChildScrollView(
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
                      _tr(
                        localeCode,
                        'Emergency Report Status',
                        'Status Laporan Kecemasan',
                      ),
                      style: TextStyle(
                        fontSize: 18,
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
                      height: 92,
                      width: 92,
                      decoration: BoxDecoration(
                        color: successBg,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.check_circle_rounded,
                        size: 56,
                        color: successGreen,
                      ),
                    ),
                    const SizedBox(height: 18),
                    Text(
                      _tr(
                        localeCode,
                        'Emergency Report Sent',
                        'Laporan Kecemasan Dihantar',
                      ),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w900,
                        color: textDark,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _tr(
                        localeCode,
                        'Your emergency details, location, and safety guidance are ready. Continue to live tracking and keep your phone nearby.',
                        'Maklumat kecemasan, lokasi, dan panduan keselamatan telah tersedia. Teruskan ke penjejakan langsung dan pastikan telefon berdekatan.',
                      ),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14.5,
                        height: 1.45,
                        color: textSoft,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: innerCardColor,
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.confirmation_number_outlined,
                            color: primaryBlue,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              _tr(localeCode, 'Emergency ID', 'ID Kecemasan'),
                              style: TextStyle(
                                fontSize: 13.5,
                                color: textSoft,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          Flexible(
                            child: Text(
                              emergencyId,
                              textAlign: TextAlign.right,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 14.5,
                                color: textDark,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              _CardSection(
                title: _tr(
                  localeCode,
                  'Emergency Action Checklist',
                  'Senarai Tindakan Kecemasan',
                ),
                child: Column(
                  children: [
                    _StatusItem(
                      icon: Icons.warning_amber_rounded,
                      title: _tr(
                        localeCode,
                        'Incident detected',
                        'Insiden dikesan',
                      ),
                      subtitle: _tr(
                        localeCode,
                        'AI analysis identified the emergency type and priority level.',
                        'Analisis AI mengenal pasti jenis kecemasan dan tahap keutamaan.',
                      ),
                      completed: incidentDetected,
                    ),
                    const SizedBox(height: 16),
                    _StatusItem(
                      icon: Icons.health_and_safety_outlined,
                      title: _tr(
                        localeCode,
                        'Safety guidance generated',
                        'Panduan keselamatan dijana',
                      ),
                      subtitle: _tr(
                        localeCode,
                        'Immediate safety steps are ready.',
                        'Langkah keselamatan segera telah tersedia.',
                      ),
                      completed: guidanceGenerated,
                    ),
                    const SizedBox(height: 16),
                    _StatusItem(
                      icon: Icons.call_outlined,
                      title: _tr(
                        localeCode,
                        '999 call script ready',
                        'Skrip panggilan 999 sedia',
                      ),
                      subtitle: _tr(
                        localeCode,
                        'Key details are prepared to explain clearly to the operator.',
                        'Maklumat penting disediakan untuk diterangkan kepada operator.',
                      ),
                      completed: callScriptReady,
                    ),
                    const SizedBox(height: 16),
                    _StatusItem(
                      icon: Icons.send_outlined,
                      title: _tr(
                        localeCode,
                        '$sosChannel message sent',
                        'Mesej $sosChannel dihantar',
                      ),
                      subtitle: _tr(
                        localeCode,
                        'Emergency message has been shared with selected emergency contacts.',
                        'Mesej kecemasan telah dikongsi kepada kenalan kecemasan yang dipilih.',
                      ),
                      completed: sosSent,
                    ),
                    const SizedBox(height: 16),
                    _StatusItem(
                      icon: Icons.location_on_outlined,
                      title: _tr(
                        localeCode,
                        'Live location attached',
                        'Lokasi langsung dilampirkan',
                      ),
                      subtitle: _tr(
                        localeCode,
                        'Current GPS location is included for faster assistance.',
                        'Lokasi GPS semasa disertakan untuk bantuan yang lebih cepat.',
                      ),
                      completed: locationShared,
                    ),
                    const SizedBox(height: 16),
                    _StatusItem(
                      icon: Icons.people_outline,
                      title: _tr(
                        localeCode,
                        'Emergency contacts notified',
                        'Kenalan kecemasan dimaklumkan',
                      ),
                      subtitle: _tr(
                        localeCode,
                        'Trusted contacts can receive updates about your emergency status.',
                        'Kenalan dipercayai boleh menerima kemas kini status kecemasan anda.',
                      ),
                      completed: contactsNotified,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              _CardSection(
                title: _tr(
                  localeCode,
                  'Response Summary',
                  'Ringkasan Tindak Balas',
                ),
                child: Column(
                  children: [
                    _SummaryRow(
                      label: _tr(
                        localeCode,
                        'Emergency Type',
                        'Jenis Kecemasan',
                      ),
                      value: emergencyType,
                    ),
                    const SizedBox(height: 12),
                    _SummaryRow(
                      label: _tr(localeCode, 'Severity', 'Tahap'),
                      value: severity,
                    ),
                    const SizedBox(height: 12),
                    _SummaryRow(
                      label: _tr(localeCode, 'Location', 'Lokasi'),
                      value: location,
                    ),
                    const SizedBox(height: 12),
                    _SummaryRow(
                      label: _tr(
                        localeCode,
                        'Recommended Responders',
                        'Responder Dicadangkan',
                      ),
                      value: responders.join(', '),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 22),

              ElevatedButton.icon(
                onPressed: () => _call999(context),
                icon: const Icon(Icons.call),
                label: Text(
                  _tr(localeCode, 'Call 999 Now', 'Hubungi 999 Sekarang'),
                  style: const TextStyle(
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

              const SizedBox(height: 12),

              ElevatedButton.icon(
                onPressed: () {
                  Navigator.pushNamed(
                    context,
                    AppRoutes.liveTracking,
                    arguments: {
                      'emergencyType': emergencyType,
                      'emergencyId': emergencyId,
                      'locationText': location,
                      'location': location,
                      'responders': responders,
                      'severity': severity,
                    },
                  );
                },
                icon: const Icon(Icons.emergency_share_outlined),
                label: Text(
                  _tr(
                    localeCode,
                    'Continue to Live Tracking',
                    'Teruskan ke Penjejakan Langsung',
                  ),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
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

              OutlinedButton.icon(
                onPressed: () {
                  Navigator.pushNamedAndRemoveUntil(
                    context,
                    AppRoutes.mainShell,
                    (route) => false,
                  );
                },
                icon: const Icon(Icons.home_outlined),
                label: Text(
                  _tr(localeCode, 'Back to Home', 'Kembali ke Laman Utama'),
                  style: const TextStyle(
                    fontSize: 15.5,
                    fontWeight: FontWeight.w800,
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
    );
  }

  static Future<void> _call999(BuildContext context) async {
    final Uri phoneUri = Uri(scheme: 'tel', path: '999');

    if (await canLaunchUrl(phoneUri)) {
      await launchUrl(phoneUri);
    } else {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Unable to open phone dialer on this device.'),
        ),
      );
    }
  }

  static String _tr(String localeCode, String en, String ms) {
    return localeCode == 'ms' || localeCode == 'bm' ? ms : en;
  }
}

class _CardSection extends StatelessWidget {
  const _CardSection({required this.title, required this.child});

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
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }
}

class _StatusItem extends StatelessWidget {
  const _StatusItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.completed,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final bool completed;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final textDark = isDark ? Colors.white : const Color(0xFF0B1B3A);

    final textSoft = isDark ? Colors.white70 : const Color(0xFF71829E);

    final completedBg = isDark
        ? const Color(0xFF123524)
        : const Color(0xFFEAFBF0);

    final pendingBg = isDark
        ? const Color(0xFF1E293B)
        : const Color(0xFFF3F4F6);

    final pendingIcon = isDark ? Colors.white38 : const Color(0xFF94A3B8);

    const successGreen = Color(0xFF34C759);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          height: 42,
          width: 42,
          decoration: BoxDecoration(
            color: completed ? completedBg : pendingBg,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(
            completed ? Icons.check_circle_rounded : icon,
            color: completed ? successGreen : pendingIcon,
            size: 23,
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                softWrap: true,
                style: TextStyle(
                  fontSize: 15.5,
                  fontWeight: FontWeight.w900,
                  color: textDark,
                  height: 1.25,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                subtitle,
                softWrap: true,
                style: TextStyle(
                  fontSize: 13.8,
                  height: 1.4,
                  color: textSoft,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final textDark = isDark ? Colors.white : const Color(0xFF0B1B3A);

    final textSoft = isDark ? Colors.white70 : const Color(0xFF71829E);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 4,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: textSoft,
              fontWeight: FontWeight.w700,
              height: 1.35,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          flex: 6,
          child: Text(
            value,
            textAlign: TextAlign.right,
            softWrap: true,
            style: TextStyle(
              fontSize: 14.2,
              color: textDark,
              fontWeight: FontWeight.w800,
              height: 1.35,
            ),
          ),
        ),
      ],
    );
  }
}
