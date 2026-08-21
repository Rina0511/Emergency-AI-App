import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../l10n/app_localizations.dart';
import '../../routes.dart';

class SosPreviewScreen extends StatefulWidget {
  final String emergencyType;
  final String victimCondition;
  final String victimCount;
  final String danger;
  final String description;
  final bool includeLocation;
  final String severity;

  const SosPreviewScreen({
    super.key,
    required this.emergencyType,
    required this.victimCondition,
    required this.victimCount,
    required this.danger,
    required this.description,
    required this.includeLocation,
    required this.severity,
  });

  @override
  State<SosPreviewScreen> createState() => _SosPreviewScreenState();
}

class _SosPreviewScreenState extends State<SosPreviewScreen> {
  late Map<String, dynamic> _data;
  bool _loadedArgs = false;
  bool _isSending = false;

  String _role = 'victim';
  String? _reportId;
  List<String> _emergencyPhones = [];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (_loadedArgs) return;
    _loadedArgs = true;

    final args = ModalRoute.of(context)?.settings.arguments;

    if (args is Map<String, dynamic>) {
      _data = Map<String, dynamic>.from(args);
    } else {
      _data = {
        'role': 'victim',
        'injuredCount': '1',
        'condition': 'Unknown',
        'dangerPresent': 'Unknown',
        'notes': '',
        'emergencyType': 'Accident',
        'severity': 'High',
        'confidence': 92,
        'location': 'Location not shared',
        'responders': ['Ambulance', 'Police'],
      };
    }

    _role = (_data['role'] ?? 'victim').toString();
    _reportId =
        _data['reportId']?.toString() ?? _data['emergencyId']?.toString();
    _emergencyPhones = _extractEmergencyPhones(_data);

    _loadSavedContacts();
    _fixLocationIfNeeded();
  }

  bool get _isMalay {
    final code = Localizations.localeOf(context).languageCode.toLowerCase();
    return code == 'ms' || code == 'bm';
  }

  String _tr(String en, String ms) => _isMalay ? ms : en;

  bool get _isVictim => _role.toLowerCase() == 'victim';

  double _parseConfidence(dynamic value) {
    if (value is double) return value > 1 ? value / 100 : value;
    if (value is int) return value > 1 ? value / 100 : value.toDouble();
    if (value is String) {
      final parsed = double.tryParse(value);
      if (parsed != null) return parsed > 1 ? parsed / 100 : parsed;
    }
    return 0.92;
  }

  String _emergencyId() {
    if (_reportId != null && _reportId!.trim().isNotEmpty) {
      return _reportId!;
    }

    final existing = _data['emergencyId'];
    if (existing != null && existing.toString().trim().isNotEmpty) {
      return existing.toString();
    }

    final id =
        'MY-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}';
    _data['emergencyId'] = id;
    return id;
  }

  String _cleanPhone(String phone) {
    var cleaned = phone.replaceAll(RegExp(r'[^0-9+]'), '');

    if (cleaned.startsWith('+')) {
      cleaned = cleaned.substring(1);
    }

    if (cleaned.startsWith('0')) {
      cleaned = '60${cleaned.substring(1)}';
    }

    return cleaned;
  }

  List<String> _extractEmergencyPhones(Map<String, dynamic> args) {
    final phones = <String>[];

    final rawPhones = args['emergencyPhones'];
    if (rawPhones is List) {
      phones.addAll(rawPhones.map((e) => e.toString()));
    }

    final rawContacts = args['emergencyContacts'];
    if (rawContacts is List) {
      for (final item in rawContacts) {
        if (item is Map && item['phone'] != null) {
          phones.add(item['phone'].toString());
        }
      }
    }

    return phones.map(_cleanPhone).where((e) => e.isNotEmpty).toSet().toList();
  }

  Future<void> _loadSavedContacts() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('emergency_contacts')
          .get();

      final phones = snapshot.docs
          .map((doc) => (doc.data()['phone'] ?? '').toString())
          .map(_cleanPhone)
          .where((phone) => phone.isNotEmpty)
          .toSet()
          .toList();

      if (!mounted) return;

      setState(() {
        _emergencyPhones = {..._emergencyPhones, ...phones}.toList();
        _data['emergencyPhones'] = _emergencyPhones;
      });
    } catch (e) {
      _showSnack('Failed to load emergency contacts: $e');
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

  Future<void> _fixLocationIfNeeded() async {
    final location = (_data['location'] ?? '').toString();

    if (location.startsWith('http')) return;

    if (location.isEmpty ||
        location == 'Current GPS location' ||
        location == 'Current GPS location shared' ||
        location == 'Location not shared' ||
        location == 'Location unavailable') {
      final realLocation = await _getRealLocation();

      if (!mounted) return;

      setState(() {
        _data['location'] = realLocation;
      });

      if (_reportId != null && _reportId!.isNotEmpty) {
        await FirebaseFirestore.instance
            .collection('emergency_reports')
            .doc(_reportId)
            .set({
              'location': realLocation,
              'updatedAt': FieldValue.serverTimestamp(),
            }, SetOptions(merge: true));
      }
    }
  }

  List<String> _responders() {
    final raw = _data['responders'];

    if (raw is List) {
      return raw.map((e) => e.toString()).toList();
    }

    final type = (_data['emergencyType'] ?? 'Accident')
        .toString()
        .toLowerCase();

    if (type.contains('fire') || type.contains('hazard')) {
      return [_tr('Fire Rescue / Bomba', 'Bomba / Pasukan Penyelamat')];
    }

    if (type.contains('crime') || type.contains('police')) {
      return [_tr('Police', 'Polis')];
    }

    if (type.contains('medical')) {
      return [_tr('Ambulance', 'Ambulans')];
    }

    return [_tr('Ambulance', 'Ambulans'), _tr('Police', 'Polis')];
  }

  String _messageText(AppLocalizations l10n) {
    final emergencyType = (_data['emergencyType'] ?? 'Accident').toString();
    final severity = (_data['severity'] ?? _tr('High', 'Tinggi')).toString();
    final injuredCount = (_data['injuredCount'] ?? '1').toString();
    final condition = (_data['condition'] ?? 'Unknown').toString();
    final dangerPresent = (_data['dangerPresent'] ?? 'Unknown').toString();
    final notes = (_data['notes'] ?? '').toString().trim();
    final location = (_data['location'] ?? 'Location not shared').toString();
    final confidence = _parseConfidence(_data['confidence']);
    final responders = _responders().join(', ');
    final emergencyId = _emergencyId();

    return '''
🚨 SOS EMERGENCY ALERT

Emergency ID: $emergencyId
Emergency Type: $emergencyType
AI Confidence: ${(confidence * 100).toStringAsFixed(0)}%
Severity: $severity

Location:
$location

People Involved: $injuredCount
Condition: $condition
Danger Still Present: $dangerPresent

Recommended Responders:
$responders

${notes.isNotEmpty ? 'Additional Notes:\n$notes\n\n' : ''}Please call 999 if urgent. Please send help immediately.
''';
  }

  Future<void> _updateSosStatus(String channel) async {
    if (_reportId == null || _reportId!.isEmpty) return;

    await FirebaseFirestore.instance
        .collection('emergency_reports')
        .doc(_reportId)
        .set({
          'status': 'active',
          'trackingStage': 'sent',
          'sosSent': true,
          'sosChannel': channel,
          'location': _data['location'] ?? 'Location not shared',
          'emergencyId': _reportId,
          'updatedAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
  }

  Future<void> _call999() async {
    final uri = Uri(scheme: 'tel', path: '999');

    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);

      if (_reportId != null && _reportId!.isNotEmpty) {
        await FirebaseFirestore.instance
            .collection('emergency_reports')
            .doc(_reportId)
            .set({
              'called999': true,
              'called999At': FieldValue.serverTimestamp(),
              'status': 'active',
              'trackingStage': 'confirmed',
              'updatedAt': FieldValue.serverTimestamp(),
            }, SetOptions(merge: true));
      }
    } else {
      _showSnack(
        _tr(
          'Unable to open phone dialer.',
          'Tidak dapat membuka dialer telefon.',
        ),
      );
    }
  }

  Future<void> _sendSms(AppLocalizations l10n) async {
    if (_emergencyPhones.isEmpty) {
      _showSnack(
        _tr(
          'No emergency contact phone number found.',
          'Tiada nombor telefon kenalan kecemasan dijumpai.',
        ),
      );
      return;
    }

    setState(() => _isSending = true);

    final uri = Uri(
      scheme: 'sms',
      path: _emergencyPhones.join(','),
      queryParameters: {'body': _messageText(l10n)},
    );

    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
      await _goToReportStatus('SMS');
    } else {
      _showSnack(
        _tr('Unable to open SMS app.', 'Tidak dapat membuka aplikasi SMS.'),
      );
    }

    if (mounted) setState(() => _isSending = false);
  }

  Future<void> _sendWhatsApp(AppLocalizations l10n) async {
    setState(() => _isSending = true);

    final message = Uri.encodeComponent(_messageText(l10n));

    final Uri uri = _emergencyPhones.isNotEmpty
        ? Uri.parse('https://wa.me/${_emergencyPhones.first}?text=$message')
        : Uri.parse('https://wa.me/?text=$message');

    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
      await _goToReportStatus('WhatsApp');
    } else {
      _showSnack(
        _tr('Unable to open WhatsApp.', 'Tidak dapat membuka WhatsApp.'),
      );
    }

    if (mounted) setState(() => _isSending = false);
  }

  Future<void> _shareLocationOnly(AppLocalizations l10n) async {
    await _fixLocationIfNeeded();

    final location = (_data['location'] ?? 'Location not shared').toString();

    final message = Uri.encodeComponent(
      'My emergency location:\n$location\n\nEmergency ID: ${_emergencyId()}',
    );

    final uri = Uri.parse('https://wa.me/?text=$message');

    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      _showSnack(
        _tr('Unable to share location.', 'Tidak dapat berkongsi lokasi.'),
      );
    }
  }

  Future<void> _goToReportStatus(String channel) async {
    await _updateSosStatus(channel);

    final reportArgs = {
      ..._data,
      'reportId': _reportId,
      'emergencyId': _emergencyId(),
      'responders': _responders(),
      'emergencyPhones': _emergencyPhones,
      'sosChannel': channel,
      'sosSent': true,
      'locationShared': true,
      'contactsReady': true,
      'callReady': true,
      'emergencyDetected': true,
      'guidanceGenerated': true,
      'status': 'active',
      'trackingStage': 'sent',
    };

    if (!mounted) return;

    Navigator.pushNamed(context, AppRoutes.reportStatus, arguments: reportArgs);
  }

  void _showSnack(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  void _cancel() {
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    final emergencyType = (_data['emergencyType'] ?? 'Accident').toString();
    final severity = (_data['severity'] ?? _tr('High', 'Tinggi')).toString();
    final location = (_data['location'] ?? 'Location not shared').toString();
    final confidence = _parseConfidence(_data['confidence']);
    final emergencyId = _emergencyId();

    final isDark = Theme.of(context).brightness == Brightness.dark;

    final bgColor = isDark ? const Color(0xFF0B1220) : const Color(0xFFEAF1FB);

    final cardColor = isDark ? const Color(0xFF162033) : Colors.white;

    final innerCardColor = isDark
        ? const Color(0xFF0F172A)
        : const Color(0xFFF5F8FD);

    final textDark = isDark ? Colors.white : const Color(0xFF0B1B3A);

    final textSoft = isDark ? Colors.white70 : const Color(0xFF71829E);

    final sosIconBg = isDark
        ? const Color(0xFF2A1720)
        : const Color(0xFFFFE8E8);

    const primaryBlue = Color(0xFF2F6FE4);
    const dangerRed = Color(0xFFE12529);
    const successGreen = Color(0xFF22C55E);

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
                      l10n.sosMessagePreview,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        color: textDark,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(26),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(isDark ? 0.18 : 0.04),
                      blurRadius: 18,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Container(
                      height: 82,
                      width: 82,
                      decoration: BoxDecoration(
                        color: sosIconBg,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.sos_outlined,
                        color: dangerRed,
                        size: 42,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      _tr('SOS Message Ready', 'Mesej SOS Sedia'),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w900,
                        color: textDark,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _isVictim
                          ? _tr(
                              'Send your emergency message to trusted contacts with your current location.',
                              'Hantar mesej kecemasan kepada kenalan dipercayai bersama lokasi semasa anda.',
                            )
                          : _tr(
                              'You are reporting for someone else. Call 999 and share the location clearly.',
                              'Anda melaporkan untuk orang lain. Hubungi 999 dan kongsi lokasi dengan jelas.',
                            ),
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
              const SizedBox(height: 16),
              _SectionCard(
                title: _tr('Emergency Summary', 'Ringkasan Kecemasan'),
                child: Column(
                  children: [
                    _SummaryRow(
                      icon: Icons.confirmation_number_outlined,
                      label: _tr('Emergency ID', 'ID Kecemasan'),
                      value: emergencyId,
                    ),
                    const SizedBox(height: 12),
                    _SummaryRow(
                      icon: Icons.warning_amber_rounded,
                      label: _tr('Type', 'Jenis'),
                      value: emergencyType,
                    ),
                    const SizedBox(height: 12),
                    _SummaryRow(
                      icon: Icons.priority_high_rounded,
                      label: _tr('Severity', 'Tahap'),
                      value: severity,
                    ),
                    const SizedBox(height: 12),
                    _SummaryRow(
                      icon: Icons.analytics_outlined,
                      label: _tr('AI Confidence', 'Keyakinan AI'),
                      value: '${(confidence * 100).toStringAsFixed(0)}%',
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              _SectionCard(
                title: _tr('Location Attached', 'Lokasi Dilampirkan'),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _CircleIcon(
                      icon: Icons.location_on_outlined,
                      color: primaryBlue,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        location,
                        style: TextStyle(
                          fontSize: 14.5,
                          height: 1.45,
                          color: textDark,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              _SectionCard(
                title: _tr('Message Preview', 'Pratonton Mesej'),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: innerCardColor,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    _messageText(l10n),
                    style: TextStyle(
                      fontSize: 14.5,
                      height: 1.5,
                      color: textDark,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              _SectionCard(
                title: _tr('Sending To', 'Dihantar Kepada'),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (_emergencyPhones.isEmpty)
                      Text(
                        _tr(
                          'No emergency contact phone number found. Add emergency contacts to enable direct SMS and WhatsApp.',
                          'Tiada nombor telefon kenalan kecemasan dijumpai. Tambah kenalan kecemasan untuk aktifkan SMS dan WhatsApp terus.',
                        ),
                        style: TextStyle(
                          fontSize: 14,
                          height: 1.4,
                          color: textSoft,
                          fontWeight: FontWeight.w600,
                        ),
                      )
                    else
                      Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        children: _emergencyPhones
                            .map(
                              (phone) => _ContactChip(
                                name: phone,
                                icon: Icons.phone_outlined,
                              ),
                            )
                            .toList(),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 22),
              ElevatedButton.icon(
                onPressed: _isSending ? null : _call999,
                icon: const Icon(Icons.call),
                label: Text(
                  _tr('Call 999', 'Hubungi 999'),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: dangerRed,
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: dangerRed.withOpacity(0.55),
                  disabledForegroundColor: Colors.white70,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(
                    vertical: 17,
                    horizontal: 14,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              ElevatedButton.icon(
                onPressed: _isSending ? null : () => _sendSms(l10n),
                icon: _isSending
                    ? const SizedBox(
                        height: 19,
                        width: 19,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.4,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.sms_outlined),
                label: Text(
                  _isSending
                      ? _tr('Opening...', 'Membuka...')
                      : _tr(
                          'Send SMS to Emergency Contacts',
                          'Hantar SMS kepada Kenalan Kecemasan',
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
                  disabledBackgroundColor: primaryBlue.withOpacity(0.55),
                  disabledForegroundColor: Colors.white70,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(
                    vertical: 17,
                    horizontal: 14,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              ElevatedButton.icon(
                onPressed: _isSending ? null : () => _sendWhatsApp(l10n),
                icon: const Icon(Icons.chat_bubble_outline),
                label: Text(
                  _tr('Send WhatsApp', 'Hantar WhatsApp'),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: successGreen,
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: successGreen.withOpacity(0.55),
                  disabledForegroundColor: Colors.white70,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(
                    vertical: 17,
                    horizontal: 14,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: _isSending ? null : () => _shareLocationOnly(l10n),
                icon: const Icon(Icons.share_location_outlined),
                label: Text(
                  _tr('Share Location Only', 'Kongsi Lokasi Sahaja'),
                  style: const TextStyle(
                    fontSize: 15.5,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  foregroundColor: primaryBlue,
                  backgroundColor: cardColor,
                  side: BorderSide.none,
                  disabledForegroundColor: isDark
                      ? Colors.white38
                      : const Color(0xFF71829E),
                  padding: const EdgeInsets.symmetric(vertical: 17),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: _cancel,
                icon: const Icon(Icons.close_rounded),
                label: Text(
                  l10n.cancel,
                  style: const TextStyle(
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
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.title, required this.child, this.trailing});

  final String title;
  final Widget child;
  final Widget? trailing;

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
          Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w900,
                    color: textDark,
                  ),
                ),
              ),
              if (trailing != null) trailing!,
            ],
          ),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({
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

    const primaryBlue = Color(0xFF2F6FE4);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _CircleIcon(icon: icon, color: primaryBlue),
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

class _ContactChip extends StatelessWidget {
  const _ContactChip({required this.name, required this.icon});

  final String name;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final chipBg = isDark ? const Color(0xFF1E2A44) : const Color(0xFFEAF1FF);

    final textDark = isDark ? Colors.white : const Color(0xFF0B1B3A);

    const primaryBlue = Color(0xFF2F6FE4);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 10),
      decoration: BoxDecoration(
        color: chipBg,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 17, color: primaryBlue),
          const SizedBox(width: 7),
          Text(
            name,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w800,
              color: textDark,
            ),
          ),
        ],
      ),
    );
  }
}

class _CircleIcon extends StatelessWidget {
  const _CircleIcon({required this.icon, required this.color});

  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final bgColor = isDark ? color.withOpacity(0.20) : color.withOpacity(0.12);

    return Container(
      height: 42,
      width: 42,
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Icon(icon, color: color, size: 22),
    );
  }
}
