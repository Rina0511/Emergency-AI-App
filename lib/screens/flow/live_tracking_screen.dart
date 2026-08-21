import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../routes.dart';
//import '../common/app_bottom_nav.dart';

class LiveTrackingScreen extends StatefulWidget {
  const LiveTrackingScreen({super.key});

  @override
  State<LiveTrackingScreen> createState() => _LiveTrackingScreenState();
}

class _LiveTrackingScreenState extends State<LiveTrackingScreen> {
  static const Color primaryBlue = Color(0xFF2F6FE4);
  static const Color dangerRed = Color(0xFFE53935);
  static const Color successGreen = Color(0xFF34C759);

  String? _reportId;
  bool _loadedArgs = false;
  bool _busy = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (_loadedArgs) return;
    _loadedArgs = true;

    final args = ModalRoute.of(context)?.settings.arguments;

    if (args is Map<String, dynamic>) {
      _reportId =
          args['reportId']?.toString() ?? args['emergencyId']?.toString();
    }

    if (_reportId != null && _reportId!.isNotEmpty) {
      _prepareActiveReport();
    }
  }

  DocumentReference<Map<String, dynamic>> get _reportRef {
    return FirebaseFirestore.instance
        .collection('emergency_reports')
        .doc(_reportId);
  }

  Future<void> _prepareActiveReport() async {
    try {
      if (_reportId == null || _reportId!.isEmpty) return;

      final snap = await _reportRef.get();

      if (!snap.exists) return;

      final data = snap.data() ?? {};

      final status = (data['status'] ?? '').toString().toLowerCase().trim();
      final stage = (data['trackingStage'] ?? '')
          .toString()
          .toLowerCase()
          .trim();

      if (status == 'completed' ||
          status == 'cancelled' ||
          stage == 'completed' ||
          stage == 'cancelled') {
        _reportId = null;
        if (mounted) setState(() {});
        return;
      }

      if (status != 'active') {
        _reportId = null;
        if (mounted) setState(() {});
        return;
      }

      final location = data['location']?.toString() ?? '';

      final updates = <String, dynamic>{
        'updatedAt': FieldValue.serverTimestamp(),
      };

      if ((data['trackingStage'] ?? '').toString().isEmpty) {
        updates['trackingStage'] = 'sent';
      }

      if ((data['emergencyId'] ?? '').toString().isEmpty) {
        updates['emergencyId'] = _reportId;
      }

      if (location.isEmpty ||
          location == 'Current GPS location' ||
          location == 'Location not shared') {
        final realLocation = await _getRealLocation();
        updates['location'] = realLocation;
      }

      await _reportRef.set(updates, SetOptions(merge: true));
    } catch (_) {}
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

  Future<void> _updateStage(String stage) async {
    if (_reportId == null) return;

    await _reportRef.update({
      'status': 'active',
      'trackingStage': stage,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> _call999() async {
    final uri = Uri(scheme: 'tel', path: '999');

    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
      await _reportRef.set({
        'called999': true,
        'called999At': FieldValue.serverTimestamp(),
        'trackingStage': 'confirmed',
        'status': 'active',
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } else {
      _showSnack('Unable to open phone dialer.');
    }
  }

  Future<void> _shareLiveLocation(String location) async {
    String realLocation = location;

    if (realLocation.isEmpty ||
        realLocation == 'Current GPS location' ||
        realLocation == 'Location not shared' ||
        realLocation == 'Location unavailable') {
      realLocation = await _getRealLocation();

      await _reportRef.set({
        'location': realLocation,
        'locationUpdatedAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    }

    if (realLocation.startsWith('http')) {
      final uri = Uri.parse(realLocation);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        _showSnack('Unable to open Google Maps.');
      }
    } else {
      _showSnack(realLocation);
    }
  }

  Future<void> _sendUpdateToContacts(Map<String, dynamic> report) async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      _showSnack('Please login first.');
      return;
    }

    setState(() => _busy = true);

    try {
      final contactsSnap = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('emergency_contacts')
          .get();

      if (contactsSnap.docs.isEmpty) {
        _showSnack('No emergency contacts found.');
        setState(() => _busy = false);
        return;
      }

      final senderDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      final senderName =
          (senderDoc.data()?['name'] ?? user.displayName ?? 'Someone')
              .toString()
              .trim();

      final emergencyType = (report['emergencyType'] ?? 'Emergency').toString();
      final severity = (report['severity'] ?? 'High').toString();
      final location = (report['location'] ?? 'Location not shared').toString();

      int sentCount = 0;

      for (final doc in contactsSnap.docs) {
        final contact = doc.data();

        final contactUserId =
            (contact['contactUserId'] ??
                    contact['appUserId'] ??
                    contact['uid'] ??
                    contact['userId'] ??
                    '')
                .toString()
                .trim();

        if (contactUserId.isEmpty) continue;

        await FirebaseFirestore.instance.collection('notifications').add({
          'userId': contactUserId,
          'toUserId': contactUserId,
          'fromUserId': user.uid,
          'title': 'Emergency Alert',
          'shortMessage':
              '$senderName may be in danger. $emergencyType emergency detected.',
          'message': _statusMessage(report),
          'senderName': senderName,
          'emergencyType': emergencyType,
          'severity': severity,
          'location': location,
          'type': 'emergency_update',
          'isRead': false,
          'reportId': _reportId,
          'emergencyId': _reportId,
          'createdAt': FieldValue.serverTimestamp(),
        });

        sentCount++;
      }

      if (sentCount > 0) {
        await _reportRef.set({
          'lastContactUpdateAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));

        _showSnack('Emergency alert sent to $sentCount contact(s).');
      } else {
        _showSnack('Contact does not have valid App User ID.');
      }
    } catch (e) {
      _showSnack('Failed to send update: $e');
    }

    if (mounted) setState(() => _busy = false);
  }

  Future<void> _finishEmergency({
    required String status,
    required String stage,
  }) async {
    if (_reportId == null || _reportId!.isEmpty) return;

    setState(() => _busy = true);

    try {
      await FirebaseFirestore.instance
          .collection('emergency_reports')
          .doc(_reportId)
          .set({
            'status': status,
            'trackingStage': stage,
            'endedAt': FieldValue.serverTimestamp(),
            'updatedAt': FieldValue.serverTimestamp(),
          }, SetOptions(merge: true));

      if (!mounted) return;

      setState(() {
        _reportId = null;
        _busy = false;
      });

      Navigator.pushNamedAndRemoveUntil(
        context,
        AppRoutes.mainShell,
        (route) => false,
        arguments: 0,
      );
    } catch (e) {
      _showSnack('Failed to update emergency: $e');
      if (mounted) setState(() => _busy = false);
    }
  }

  String _statusMessage(Map<String, dynamic> report) {
    return '''
Emergency Alert

Emergency ID: ${_reportId ?? '-'}
Type: ${report['emergencyType'] ?? 'Emergency'}
Severity: ${report['severity'] ?? '-'}
AI Confidence: ${report['confidence'] ?? '-'}%
Stage: ${report['trackingStage'] ?? 'sent'}

Location:
${report['location'] ?? 'Location not shared'}

Recommended Responders:
${_listText(report['responders'])}
''';
  }

  String _listText(dynamic value) {
    if (value is List) {
      if (value.isEmpty) return '-';
      return value.map((e) => e.toString()).join(', ');
    }
    return value?.toString() ?? '-';
  }

  String _eta(String stage) {
    switch (stage) {
      case 'sent':
        return 'Pending confirmation';
      case 'confirmed':
        return '999 details confirmed';
      case 'dispatched':
        return 'Responder dispatched';
      case 'arriving':
        return 'Responder arriving soon';
      case 'completed':
        return 'Assistance arrived';
      case 'cancelled':
        return 'False alarm cancelled';
      default:
        return 'Pending';
    }
  }

  int _stageIndex(String stage) {
    switch (stage) {
      case 'sent':
        return 0;
      case 'confirmed':
        return 1;
      case 'dispatched':
        return 2;
      case 'arriving':
        return 3;
      case 'completed':
        return 4;
      case 'cancelled':
        return 4;
      default:
        return 0;
    }
  }

  String _stageTitle(String stage) {
    switch (stage) {
      case 'sent':
        return 'SOS Sent';
      case 'confirmed':
        return '999 Details Confirmed';
      case 'dispatched':
        return 'Responder Dispatched';
      case 'arriving':
        return 'Responder Arriving';
      case 'completed':
        return 'Assistance Arrived';
      case 'cancelled':
        return 'False Alarm Cancelled';
      default:
        return 'Tracking Active';
    }
  }

  IconData _responderIcon(String type) {
    final value = type.toLowerCase();

    if (value.contains('fire') || value.contains('bomba')) {
      return Icons.fire_truck_outlined;
    }

    if (value.contains('crime') || value.contains('police')) {
      return Icons.local_police_outlined;
    }

    if (value.contains('accident')) {
      return Icons.car_crash_outlined;
    }

    return Icons.local_hospital_outlined;
  }

  void _showSnack(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  void _goHome() {
    Navigator.pushNamedAndRemoveUntil(
      context,
      AppRoutes.mainShell,
      (route) => false,
      arguments: 0,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final bgColor = isDark ? const Color(0xFF0B1220) : const Color(0xFFEAF1FB);

    if (_reportId == null || _reportId!.isEmpty) {
      return Scaffold(
        backgroundColor: bgColor,
        body: SafeArea(child: _NoEmergencyView(onHome: _goHome)),
      );
    }

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
          stream: _reportRef.snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(color: primaryBlue),
              );
            }

            if (!snapshot.hasData || !snapshot.data!.exists) {
              return _NoEmergencyView(onHome: _goHome);
            }

            final report = snapshot.data!.data() ?? {};
            final status = (report['status'] ?? 'active').toString();
            final stage = (report['trackingStage'] ?? 'sent').toString();
            final emergencyType = (report['emergencyType'] ?? 'Emergency')
                .toString();
            final severity = (report['severity'] ?? '-').toString();
            final confidence = (report['confidence'] ?? '-').toString();
            final location = (report['location'] ?? 'Location not shared')
                .toString();
            final responders = _listText(report['responders']);
            final index = _stageIndex(stage);
            final role = (report['reporterRole'] ?? report['role'] ?? 'victim')
                .toString()
                .toLowerCase()
                .trim();

            final isVictim = role == 'victim';

            final isEnded = status == 'completed' || status == 'cancelled';

            return SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(18, 16, 18, 28),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _Header(onBack: _goHome),
                  const SizedBox(height: 18),
                  _StatusCard(
                    title: _stageTitle(stage),
                    eta: _eta(stage),
                    stage: stage,
                    isEnded: isEnded,
                  ),
                  const SizedBox(height: 16),
                  _InfoGrid(
                    emergencyId: _reportId!,
                    emergencyType: emergencyType,
                    severity: severity,
                    confidence: confidence,
                    responders: responders,
                    responderIcon: _responderIcon(emergencyType),
                    location: location,
                  ),
                  const SizedBox(height: 16),
                  _StageCard(
                    currentIndex: index,
                    cancelled: stage == 'cancelled',
                  ),
                  const SizedBox(height: 18),
                  if (!isEnded) ...[
                    _ActionButton(
                      icon: Icons.call_outlined,
                      label: 'Call 999',
                      color: dangerRed,
                      onPressed: _busy ? null : _call999,
                    ),
                    const SizedBox(height: 12),
                    if (isVictim) ...[
                      _ActionButton(
                        icon: Icons.location_on_outlined,
                        label: 'Share Live Location',
                        color: primaryBlue,
                        onPressed: _busy
                            ? null
                            : () => _shareLiveLocation(location),
                      ),
                      const SizedBox(height: 12),

                      _ActionButton(
                        icon: Icons.notifications_active_outlined,
                        label: _busy
                            ? 'Sending...'
                            : 'Send Update to Emergency Contacts',
                        color: primaryBlue,
                        onPressed: _busy
                            ? null
                            : () => _sendUpdateToContacts(report),
                      ),
                      const SizedBox(height: 12),
                    ],
                    _ActionButton(
                      icon: Icons.local_hospital_outlined,
                      label: 'Assistance Arrived',
                      color: successGreen,
                      onPressed: _busy
                          ? null
                          : () => _finishEmergency(
                              status: 'completed',
                              stage: 'completed',
                            ),
                    ),
                    const SizedBox(height: 12),
                    OutlinedButton.icon(
                      onPressed: _busy
                          ? null
                          : () => _finishEmergency(
                              status: 'cancelled',
                              stage: 'cancelled',
                            ),
                      icon: const Icon(Icons.cancel_outlined),
                      label: const Text(
                        'Cancel False Alarm',
                        style: TextStyle(
                          fontSize: 15.5,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: dangerRed,
                        backgroundColor: isDark
                            ? const Color(0xFF2A1720)
                            : Colors.white,
                        side: BorderSide(
                          color: isDark
                              ? const Color(0xFF7F1D1D)
                              : const Color(0xFFFFCDD2),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: _SmallStageButton(
                            label: 'Confirmed',
                            onTap: () => _updateStage('confirmed'),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _SmallStageButton(
                            label: 'Dispatched',
                            onTap: () => _updateStage('dispatched'),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _SmallStageButton(
                            label: 'Arriving',
                            onTap: () => _updateStage('arriving'),
                          ),
                        ),
                      ],
                    ),
                  ] else
                    _ActionButton(
                      icon: Icons.home_outlined,
                      label: 'Back to Home',
                      color: primaryBlue,
                      onPressed: _goHome,
                    ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.onBack});

  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final cardColor = isDark ? const Color(0xFF162033) : Colors.white;
    final textDark = isDark ? Colors.white : const Color(0xFF0B1B3A);

    return Row(
      children: [
        Container(
          height: 44,
          width: 44,
          decoration: BoxDecoration(color: cardColor, shape: BoxShape.circle),
          child: IconButton(
            onPressed: onBack,
            icon: Icon(
              Icons.arrow_back_ios_new_rounded,
              size: 18,
              color: textDark,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            'Live Emergency Tracking',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w900,
              color: textDark,
            ),
          ),
        ),
      ],
    );
  }
}

class _StatusCard extends StatelessWidget {
  const _StatusCard({
    required this.title,
    required this.eta,
    required this.stage,
    required this.isEnded,
  });

  final String title;
  final String eta;
  final String stage;
  final bool isEnded;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final cardColor = isDark ? const Color(0xFF162033) : Colors.white;
    final textDark = isDark ? Colors.white : const Color(0xFF0B1B3A);
    final textSoft = isDark ? Colors.white70 : const Color(0xFF71829E);
    final iconBg = isDark ? const Color(0xFF1E2A44) : const Color(0xFFEAF1FF);
    final progressBg = isDark
        ? const Color(0xFF334155)
        : const Color(0xFFEAF1FB);

    final progress = switch (stage) {
      'sent' => 0.25,
      'confirmed' => 0.50,
      'dispatched' => 0.75,
      'arriving' => 0.92,
      'completed' => 1.0,
      'cancelled' => 1.0,
      _ => 0.25,
    };

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(26),
      ),
      child: Column(
        children: [
          Container(
            height: 82,
            width: 82,
            decoration: BoxDecoration(color: iconBg, shape: BoxShape.circle),
            child: Icon(
              isEnded
                  ? Icons.check_circle_outline
                  : Icons.emergency_share_outlined,
              color: const Color(0xFF2F6FE4),
              size: 40,
            ),
          ),
          const SizedBox(height: 14),
          Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 21,
              fontWeight: FontWeight.w900,
              color: textDark,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            eta,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14.5,
              color: textSoft,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 9,
              backgroundColor: progressBg,
              valueColor: const AlwaysStoppedAnimation(Color(0xFF2F6FE4)),
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoGrid extends StatelessWidget {
  const _InfoGrid({
    required this.emergencyId,
    required this.emergencyType,
    required this.severity,
    required this.confidence,
    required this.responders,
    required this.responderIcon,
    required this.location,
  });

  final String emergencyId;
  final String emergencyType;
  final String severity;
  final String confidence;
  final String responders;
  final IconData responderIcon;
  final String location;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _InfoTile(
                icon: Icons.confirmation_number_outlined,
                title: 'Emergency ID',
                value: emergencyId,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _InfoTile(
                icon: Icons.warning_amber_rounded,
                title: 'Emergency Type',
                value: emergencyType,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _InfoTile(
                icon: Icons.priority_high_rounded,
                title: 'Severity',
                value: severity,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _InfoTile(
                icon: Icons.analytics_outlined,
                title: 'AI Confidence',
                value: '$confidence%',
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        _WideInfoTile(
          icon: responderIcon,
          title: 'Recommended Responders',
          value: responders,
        ),
        const SizedBox(height: 12),
        _WideInfoTile(
          icon: Icons.location_on_outlined,
          title: 'Real GPS Location',
          value: location,
        ),
      ],
    );
  }
}

class _InfoTile extends StatelessWidget {
  const _InfoTile({
    required this.icon,
    required this.title,
    required this.value,
  });

  final IconData icon;
  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final cardColor = isDark ? const Color(0xFF162033) : Colors.white;
    final textDark = isDark ? Colors.white : const Color(0xFF0B1B3A);
    final textSoft = isDark ? Colors.white70 : const Color(0xFF71829E);

    return Container(
      constraints: const BoxConstraints(minHeight: 118),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.confirmation_number_outlined,
            color: Colors.transparent,
            size: 0,
          ),
          Icon(icon, color: const Color(0xFF2F6FE4), size: 24),
          const SizedBox(height: 10),
          Text(
            title,
            style: TextStyle(
              color: textSoft,
              fontSize: 12.5,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            value,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: textDark,
              fontSize: 14.5,
              fontWeight: FontWeight.w900,
              height: 1.25,
            ),
          ),
        ],
      ),
    );
  }
}

class _WideInfoTile extends StatelessWidget {
  const _WideInfoTile({
    required this.icon,
    required this.title,
    required this.value,
  });

  final IconData icon;
  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final cardColor = isDark ? const Color(0xFF162033) : Colors.white;
    final textDark = isDark ? Colors.white : const Color(0xFF0B1B3A);
    final textSoft = isDark ? Colors.white70 : const Color(0xFF71829E);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: const Color(0xFF2F6FE4), size: 25),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: textSoft,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  value,
                  style: TextStyle(
                    color: textDark,
                    fontSize: 14.5,
                    fontWeight: FontWeight.w800,
                    height: 1.35,
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

class _StageCard extends StatelessWidget {
  const _StageCard({required this.currentIndex, required this.cancelled});

  final int currentIndex;
  final bool cancelled;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final cardColor = isDark ? const Color(0xFF162033) : Colors.white;
    final textDark = isDark ? Colors.white : const Color(0xFF0B1B3A);

    final stages = cancelled
        ? ['SOS Sent', 'Confirmed', 'Dispatched', 'Arriving', 'Cancelled']
        : ['SOS Sent', 'Confirmed', 'Dispatched', 'Arriving', 'Completed'];

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Malaysia 999 Emergency Flow',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w900,
              color: textDark,
            ),
          ),
          const SizedBox(height: 16),
          ...List.generate(stages.length, (index) {
            return _ProgressStep(
              title: stages[index],
              done: currentIndex > index,
              active: currentIndex == index,
              isLast: index == stages.length - 1,
              cancelled: cancelled && index == stages.length - 1,
            );
          }),
        ],
      ),
    );
  }
}

class _ProgressStep extends StatelessWidget {
  const _ProgressStep({
    required this.title,
    required this.done,
    required this.active,
    required this.isLast,
    required this.cancelled,
  });

  final String title;
  final bool done;
  final bool active;
  final bool isLast;
  final bool cancelled;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final textDark = isDark ? Colors.white : const Color(0xFF0B1B3A);
    final textSoft = isDark ? Colors.white70 : const Color(0xFF71829E);
    final lineColor = isDark ? Colors.white24 : const Color(0xFFE2E8F0);

    final color = cancelled
        ? const Color(0xFFE53935)
        : active
        ? const Color(0xFF2F6FE4)
        : done
        ? const Color(0xFF34C759)
        : textSoft;

    return IntrinsicHeight(
      child: Row(
        children: [
          Column(
            children: [
              Icon(
                done || active
                    ? Icons.check_circle
                    : Icons.radio_button_unchecked,
                color: color,
                size: 23,
              ),
              if (!isLast)
                Expanded(
                  child: Container(
                    width: 2,
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    color: done ? color.withOpacity(0.45) : lineColor,
                  ),
                ),
            ],
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: isLast ? 0 : 18),
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 15,
                  height: 1.35,
                  color: done || active ? textDark : textSoft,
                  fontWeight: done || active
                      ? FontWeight.w800
                      : FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onPressed,
  });

  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon),
      label: Text(
        label,
        textAlign: TextAlign.center,
        style: const TextStyle(fontSize: 15.5, fontWeight: FontWeight.w800),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        disabledBackgroundColor: color.withOpacity(0.45),
        disabledForegroundColor: Colors.white70,
        elevation: 0,
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      ),
    );
  }
}

class _SmallStageButton extends StatelessWidget {
  const _SmallStageButton({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final bgColor = isDark ? const Color(0xFF162033) : Colors.white;
    final borderColor = isDark
        ? const Color(0xFF1E2A44)
        : const Color(0xFFD8E5FF);

    return OutlinedButton(
      onPressed: onTap,
      style: OutlinedButton.styleFrom(
        foregroundColor: const Color(0xFF2F6FE4),
        backgroundColor: bgColor,
        side: BorderSide(color: borderColor),
        padding: const EdgeInsets.symmetric(vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      ),
      child: Text(
        label,
        style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w800),
      ),
    );
  }
}

class _NoEmergencyView extends StatelessWidget {
  const _NoEmergencyView({required this.onHome});

  final VoidCallback onHome;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final cardColor = isDark ? const Color(0xFF162033) : Colors.white;
    final textDark = isDark ? Colors.white : const Color(0xFF0B1B3A);
    final textSoft = isDark ? Colors.white70 : const Color(0xFF71829E);

    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 28),
      child: Column(
        children: [
          const Spacer(),
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: cardColor,
              borderRadius: BorderRadius.circular(28),
            ),
            child: Column(
              children: [
                Container(
                  height: 88,
                  width: 88,
                  decoration: BoxDecoration(
                    color: const Color(
                      0xFF2F6FE4,
                    ).withOpacity(isDark ? 0.20 : 0.12),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.track_changes_rounded,
                    color: Color(0xFF2F6FE4),
                    size: 42,
                  ),
                ),
                const SizedBox(height: 18),
                Text(
                  'No active emergency',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 23,
                    fontWeight: FontWeight.w900,
                    color: textDark,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Live tracking will appear after an emergency report is created.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14.5,
                    height: 1.45,
                    color: textSoft,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 22),
                ElevatedButton.icon(
                  onPressed: onHome,
                  icon: const Icon(Icons.home_outlined),
                  label: const Text(
                    'Back to Home',
                    style: TextStyle(
                      fontSize: 15.5,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2F6FE4),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(
                      vertical: 16,
                      horizontal: 18,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Spacer(),
        ],
      ),
    );
  }
}
