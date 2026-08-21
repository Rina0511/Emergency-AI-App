import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../l10n/app_localizations.dart';
import '../../routes.dart';

class EmergencySosPreviewScreen extends StatefulWidget {
  const EmergencySosPreviewScreen({super.key});

  @override
  State<EmergencySosPreviewScreen> createState() =>
      _EmergencySosPreviewScreenState();
}

class _EmergencySosPreviewScreenState extends State<EmergencySosPreviewScreen> {
  Map<String, dynamic> _data = {};

  bool _isLoadingLocation = false;
  bool _isLoadingContacts = true;

  String _location = 'Location not available';
  List<Map<String, dynamic>> _contacts = [];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is Map<String, dynamic>) {
      _data = args;
      _location = (_data['location'] ?? 'Location not available').toString();
    }

    _loadEmergencyContacts();
    _loadCurrentLocation();
  }

  Future<void> _loadEmergencyContacts() async {
    try {
      final user = FirebaseAuth.instance.currentUser;

      if (user == null) {
        setState(() {
          _contacts = [];
          _isLoadingContacts = false;
        });
        return;
      }

      final snapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('emergency_contacts')
          .orderBy('isPrimary', descending: true)
          .get();

      setState(() {
        _contacts = snapshot.docs.map((doc) {
          final data = doc.data();
          return {
            'id': doc.id,
            'name': data['name'] ?? 'Emergency Contact',
            'phone': data['phone'] ?? '',
            'isPrimary': data['isPrimary'] ?? false,
          };
        }).toList();
        _isLoadingContacts = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingContacts = false;
      });
      _showSnackBar('Failed to load contacts.');
    }
  }

  Future<void> _loadCurrentLocation() async {
    setState(() {
      _isLoadingLocation = true;
    });

    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();

      if (!serviceEnabled) {
        setState(() {
          _isLoadingLocation = false;
        });
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();

      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        setState(() {
          _isLoadingLocation = false;
        });
        return;
      }

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      final locationLink =
          'https://maps.google.com/?q=${position.latitude},${position.longitude}';

      setState(() {
        _location = locationLink;
        _data['location'] = locationLink;
        _isLoadingLocation = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingLocation = false;
      });
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

  String _sosMessage(AppLocalizations l10n) {
    final emergencyType =
        (_data['emergencyType'] ?? _data['type'] ?? 'Emergency').toString();
    final severity = (_data['severity'] ?? 'High').toString();
    final confidence = _parseConfidence(_data['confidence']);
    final condition =
        (_data['condition'] ?? _data['summary'] ?? 'Emergency help needed')
            .toString();

    return '''
🚨 SOS EMERGENCY ALERT

Type: $emergencyType
Severity: $severity
AI Confidence: ${(confidence * 100).toStringAsFixed(0)}%

Condition:
$condition

Location:
$_location

Please send help immediately.
Malaysia Emergency Number: 999
''';
  }

  Future<void> _call999() async {
    final uri = Uri(scheme: 'tel', path: '999');

    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      _showSnackBar('Unable to open phone dialer.');
    }
  }

  Future<void> _sendSmsToContact(String phone) async {
    if (phone.trim().isEmpty) {
      _showSnackBar('Contact phone number is empty.');
      return;
    }

    final message = _sosMessage(AppLocalizations.of(context)!);
    final uri = Uri(
      scheme: 'sms',
      path: phone,
      queryParameters: {'body': message},
    );

    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
      _goToReportStatus();
    } else {
      _showSnackBar('Unable to open SMS app.');
    }
  }

  Future<void> _sendWhatsAppToContact(String phone) async {
    if (phone.trim().isEmpty) {
      _showSnackBar('Contact phone number is empty.');
      return;
    }

    String cleanPhone = phone.replaceAll(RegExp(r'[^0-9]'), '');

    if (cleanPhone.startsWith('0')) {
      cleanPhone = '60${cleanPhone.substring(1)}';
    }

    final message = Uri.encodeComponent(
      _sosMessage(AppLocalizations.of(context)!),
    );

    final uri = Uri.parse('https://wa.me/$cleanPhone?text=$message');

    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
      _goToReportStatus();
    } else {
      _showSnackBar('Unable to open WhatsApp.');
    }
  }

  Future<void> _copyMessage() async {
    await Clipboard.setData(
      ClipboardData(text: _sosMessage(AppLocalizations.of(context)!)),
    );
    _showSnackBar('SOS message copied.');
  }

  void _goToReportStatus() {
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
    const green = Color(0xFF22C55E);

    final sosText = _sosMessage(l10n);

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
                  Text(
                    l10n.emergencySosPreview,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: textDark,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              Container(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.sosMessage,
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                        color: textDark,
                      ),
                    ),
                    const SizedBox(height: 14),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF5F8FD),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        sosText,
                        style: const TextStyle(
                          fontSize: 15.2,
                          height: 1.55,
                          color: textDark,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        const Icon(
                          Icons.location_on_outlined,
                          color: primaryBlue,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _isLoadingLocation
                                ? 'Getting current GPS location...'
                                : _location,
                            style: const TextStyle(
                              color: textSoft,
                              fontSize: 13.5,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        IconButton(
                          onPressed: _loadCurrentLocation,
                          icon: const Icon(
                            Icons.refresh_rounded,
                            color: primaryBlue,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 18),

              ElevatedButton.icon(
                onPressed: _call999,
                icon: const Icon(Icons.call),
                label: const Text(
                  'Call 999 Now',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
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
                onPressed: _copyMessage,
                icon: const Icon(Icons.copy_rounded),
                label: const Text(
                  'Copy SOS Message',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
                ),
                style: OutlinedButton.styleFrom(
                  foregroundColor: primaryBlue,
                  side: const BorderSide(color: primaryBlue),
                  padding: const EdgeInsets.symmetric(vertical: 17),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                ),
              ),

              const SizedBox(height: 22),

              const Text(
                'Send SOS To Emergency Contacts',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w900,
                  color: textDark,
                ),
              ),

              const SizedBox(height: 12),

              if (_isLoadingContacts)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(20),
                    child: CircularProgressIndicator(),
                  ),
                )
              else if (_contacts.isEmpty)
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    'No emergency contacts found. Please add contacts first.',
                    style: TextStyle(
                      color: textSoft,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                )
              else
                Column(
                  children: _contacts.map((contact) {
                    final name = contact['name'].toString();
                    final phone = contact['phone'].toString();
                    final isPrimary = contact['isPrimary'] == true;

                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              CircleAvatar(
                                backgroundColor: const Color(0xFFEAF1FF),
                                child: Text(
                                  name.isNotEmpty ? name[0].toUpperCase() : '?',
                                  style: const TextStyle(
                                    color: primaryBlue,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      name,
                                      style: const TextStyle(
                                        color: textDark,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w900,
                                      ),
                                    ),
                                    const SizedBox(height: 3),
                                    Text(
                                      phone,
                                      style: const TextStyle(
                                        color: textSoft,
                                        fontSize: 13.5,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              if (isPrimary)
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFEAF1FF),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: const Text(
                                    'Primary',
                                    style: TextStyle(
                                      color: primaryBlue,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                ),
                            ],
                          ),

                          const SizedBox(height: 14),

                          Row(
                            children: [
                              Expanded(
                                child: ElevatedButton.icon(
                                  onPressed: () => _sendSmsToContact(phone),
                                  icon: const Icon(Icons.sms_outlined),
                                  label: const Text('SMS'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: red,
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(14),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: ElevatedButton.icon(
                                  onPressed: () =>
                                      _sendWhatsAppToContact(phone),
                                  icon: const Icon(
                                    Icons.chat_bubble_outline_rounded,
                                  ),
                                  label: const Text('WhatsApp'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: green,
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(14),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),

              const SizedBox(height: 16),

              ElevatedButton.icon(
                onPressed: _goToReportStatus,
                icon: const Icon(Icons.arrow_forward_rounded),
                label: const Text(
                  'Continue To Report Status',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
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
            ],
          ),
        ),
      ),
    );
  }
}
