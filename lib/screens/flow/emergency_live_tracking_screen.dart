import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../l10n/app_localizations.dart';
import '../../routes.dart';

class EmergencyLiveTrackingScreen extends StatefulWidget {
  const EmergencyLiveTrackingScreen({super.key});

  @override
  State<EmergencyLiveTrackingScreen> createState() =>
      _EmergencyLiveTrackingScreenState();
}

class _EmergencyLiveTrackingScreenState
    extends State<EmergencyLiveTrackingScreen> {
  static const Color bgColor = Color(0xFFEAF1FB);
  static const Color textDark = Color(0xFF0B1B3A);
  static const Color textSoft = Color(0xFF71829E);
  static const Color primaryBlue = Color(0xFF2F6FE4);
  static const Color dangerRed = Color(0xFFE12529);
  static const Color successGreen = Color(0xFF34C759);

  Map<String, dynamic> _data = {};

  String _stage = 'sent';
  String _eta = 'Pending confirmation';
  String _location = 'Location not available';

  bool _busy = false;
  bool _loadedArgs = false;

  @override
  void initState() {
    super.initState();
    _startMockTracking();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (_loadedArgs) return;
    _loadedArgs = true;

    final args = ModalRoute.of(context)?.settings.arguments;

    if (args is Map<String, dynamic>) {
      _data = Map<String, dynamic>.from(args);
      _location = (_data['location'] ?? 'Location not available').toString();
    }

    _loadLocationIfNeeded();
  }

  void _startMockTracking() {
    Future.delayed(const Duration(seconds: 4), () {
      if (!mounted || _stage == 'cancelled' || _stage == 'completed') return;
      setState(() {
        _stage = 'confirmed';
        _eta = '999 details confirmed';
      });
    });

    Future.delayed(const Duration(seconds: 8), () {
      if (!mounted || _stage == 'cancelled' || _stage == 'completed') return;
      setState(() {
        _stage = 'dispatched';
        _eta = 'Responder dispatched';
      });
    });

    Future.delayed(const Duration(seconds: 13), () {
      if (!mounted || _stage == 'cancelled' || _stage == 'completed') return;
      setState(() {
        _stage = 'arriving';
        _eta = 'Responder arriving soon';
      });
    });
  }

  Future<void> _loadLocationIfNeeded() async {
    if (_location.startsWith('http')) return;

    final location = await _getRealLocation();

    if (!mounted) return;

    setState(() {
      _location = location;
      _data['location'] = location;
    });
  }

  Future<String> _getRealLocation() async {
    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();

      if (!serviceEnabled) {
        return 'Location service disabled';
      }

      LocationPermission permission = await Geolocator.checkPermission();

      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.denied) {
        return 'Location permission denied';
      }

      if (permission == LocationPermission.deniedForever) {
        return 'Location permission permanently denied';
      }

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      return 'https://maps.google.com/?q=${position.latitude},${position.longitude}';
    } catch (e) {
      return 'Location unavailable';
    }
  }

  String _emergencyType(AppLocalizations l10n) {
    return (_data['emergencyType'] ?? _data['type'] ?? l10n.accident)
        .toString();
  }

  String _severity(AppLocalizations l10n) {
    return (_data['severity'] ?? l10n.high).toString();
  }

  String _confidence() {
    final value = _data['confidence'];

    if (value is double) {
      return '${(value > 1 ? value : value * 100).toStringAsFixed(0)}%';
    }

    if (value is int) {
      return value > 1 ? '$value%' : '${value * 100}%';
    }

    if (value is String && value.trim().isNotEmpty) {
      final parsed = double.tryParse(value);
      if (parsed != null) {
        return '${(parsed > 1 ? parsed : parsed * 100).toStringAsFixed(0)}%';
      }
      return value;
    }

    return '-';
  }

  String _responders() {
    final responders = _data['responders'];

    if (responders is List) {
      return responders.map((e) => e.toString()).join(', ');
    }

    return responders?.toString() ?? 'Ambulance, Police';
  }

  String _stageTitle() {
    switch (_stage) {
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

  int _stageIndex() {
    switch (_stage) {
      case 'sent':
        return 0;
      case 'confirmed':
        return 1;
      case 'dispatched':
        return 2;
      case 'arriving':
        return 3;
      case 'completed':
      case 'cancelled':
        return 4;
      default:
        return 0;
    }
  }

  double _progressValue() {
    switch (_stage) {
      case 'sent':
        return 0.25;
      case 'confirmed':
        return 0.50;
      case 'dispatched':
        return 0.75;
      case 'arriving':
        return 0.92;
      case 'completed':
      case 'cancelled':
        return 1.0;
      default:
        return 0.25;
    }
  }

  Future<void> _call999() async {
    final uri = Uri(scheme: 'tel', path: '999');

    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);

      if (!mounted) return;

      setState(() {
        _stage = 'confirmed';
        _eta = '999 details confirmed';
      });
    } else {
      _showSnack('Unable to open phone dialer.');
    }
  }

  Future<void> _openMap() async {
    setState(() {
      _busy = true;
    });

    if (!_location.startsWith('http')) {
      final location = await _getRealLocation();

      if (!mounted) return;

      setState(() {
        _location = location;
        _data['location'] = location;
      });
    }

    if (_location.startsWith('http')) {
      final uri = Uri.parse(_location);

      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        _showSnack('Unable to open Google Maps.');
      }
    } else {
      _showSnack(_location);
    }

    if (!mounted) return;

    setState(() {
      _busy = false;
    });
  }

  void _assistanceArrived() {
    setState(() {
      _stage = 'completed';
      _eta = 'Assistance arrived';
    });

    _showSnack('Emergency marked as completed.');

    Future.delayed(const Duration(milliseconds: 700), () {
      if (!mounted) return;
      _goLogin();
    });
  }

  void _cancelEmergency() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Cancel False Alarm?'),
          content: const Text(
            'This will stop this emergency tracking session.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('No'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);

                setState(() {
                  _stage = 'cancelled';
                  _eta = 'False alarm cancelled';
                });

                _showSnack('Emergency cancelled.');

                Future.delayed(const Duration(milliseconds: 700), () {
                  if (!mounted) return;
                  _goLogin();
                });
              },
              child: const Text('Yes, Cancel'),
            ),
          ],
        );
      },
    );
  }

  void _goLogin() {
    Navigator.pushNamedAndRemoveUntil(
      context,
      AppRoutes.login,
      (route) => false,
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
    final l10n = AppLocalizations.of(context)!;
    final ended = _stage == 'completed' || _stage == 'cancelled';

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 10, 20, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _Header(
                title: l10n.emergencyLiveTracking,
                onBack: () => Navigator.pop(context),
              ),

              const SizedBox(height: 24),

              Container(
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Column(
                  children: [
                    Container(
                      height: 94,
                      width: 94,
                      decoration: const BoxDecoration(
                        color: Color(0xFFEAF1FF),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        ended
                            ? Icons.check_circle_outline
                            : Icons.emergency_share_outlined,
                        size: 46,
                        color: primaryBlue,
                      ),
                    ),

                    const SizedBox(height: 16),

                    Text(
                      _stageTitle(),
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 23,
                        fontWeight: FontWeight.w900,
                        color: textDark,
                      ),
                    ),

                    const SizedBox(height: 8),

                    Text(
                      _eta,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 15,
                        height: 1.45,
                        color: textSoft,
                        fontWeight: FontWeight.w600,
                      ),
                    ),

                    const SizedBox(height: 16),

                    ClipRRect(
                      borderRadius: BorderRadius.circular(999),
                      child: LinearProgressIndicator(
                        value: _progressValue(),
                        minHeight: 9,
                        backgroundColor: bgColor,
                        valueColor: const AlwaysStoppedAnimation(primaryBlue),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 18),

              _InfoCard(
                title: 'Emergency Summary',
                children: [
                  _SummaryRow(label: 'Type', value: _emergencyType(l10n)),
                  _SummaryRow(label: 'Severity', value: _severity(l10n)),
                  _SummaryRow(label: 'AI Confidence', value: _confidence()),
                  _SummaryRow(label: 'Responders', value: _responders()),
                ],
              ),

              const SizedBox(height: 18),

              _StageCard(
                currentIndex: _stageIndex(),
                cancelled: _stage == 'cancelled',
              ),

              const SizedBox(height: 18),

              _InfoCard(
                title: 'Current Location',
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(
                        Icons.location_on_outlined,
                        color: primaryBlue,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          _location,
                          style: const TextStyle(
                            fontSize: 14.5,
                            height: 1.45,
                            color: textDark,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: _busy ? null : _openMap,
                        icon: const Icon(
                          Icons.map_outlined,
                          color: primaryBlue,
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 18),

              if (!ended) ...[
                _ActionButton(
                  icon: Icons.call_outlined,
                  label: 'Call 999 Again',
                  color: dangerRed,
                  onPressed: _busy ? null : _call999,
                ),

                const SizedBox(height: 12),

                _ActionButton(
                  icon: Icons.map_outlined,
                  label: _busy ? 'Opening Map...' : 'Open Google Maps',
                  color: primaryBlue,
                  onPressed: _busy ? null : _openMap,
                ),

                const SizedBox(height: 12),

                _ActionButton(
                  icon: Icons.local_hospital_outlined,
                  label: 'Assistance Arrived',
                  color: successGreen,
                  onPressed: _busy ? null : _assistanceArrived,
                ),

                const SizedBox(height: 12),

                OutlinedButton.icon(
                  onPressed: _busy ? null : _cancelEmergency,
                  icon: const Icon(Icons.cancel_outlined),
                  label: const Text(
                    'Cancel False Alarm',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: dangerRed,
                    backgroundColor: Colors.white,
                    side: const BorderSide(color: Color(0xFFFFCDD2)),
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                  ),
                ),
              ] else
                _ActionButton(
                  icon: Icons.login_outlined,
                  label: 'Back To Login',
                  color: primaryBlue,
                  onPressed: _goLogin,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  final String title;
  final VoidCallback onBack;

  const _Header({required this.title, required this.onBack});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          height: 44,
          width: 44,
          decoration: const BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
          ),
          child: IconButton(
            onPressed: onBack,
            icon: const Icon(
              Icons.arrow_back_ios_new_rounded,
              size: 20,
              color: Color(0xFF0B1B3A),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: Color(0xFF0B1B3A),
            ),
          ),
        ),
      ],
    );
  }
}

class _InfoCard extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const _InfoCard({required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 18),
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
              color: Color(0xFF0B1B3A),
            ),
          ),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final String value;

  const _SummaryRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 14.5,
                color: Color(0xFF71829E),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: const TextStyle(
                fontSize: 14.5,
                color: Color(0xFF0B1B3A),
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StageCard extends StatelessWidget {
  final int currentIndex;
  final bool cancelled;

  const _StageCard({required this.currentIndex, required this.cancelled});

  @override
  Widget build(BuildContext context) {
    final stages = cancelled
        ? ['SOS Sent', 'Confirmed', 'Dispatched', 'Arriving', 'Cancelled']
        : ['SOS Sent', 'Confirmed', 'Dispatched', 'Arriving', 'Completed'];

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Emergency Tracking Flow',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w900,
              color: Color(0xFF0B1B3A),
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
  final String title;
  final bool done;
  final bool active;
  final bool isLast;
  final bool cancelled;

  const _ProgressStep({
    required this.title,
    required this.done,
    required this.active,
    required this.isLast,
    required this.cancelled,
  });

  @override
  Widget build(BuildContext context) {
    final color = cancelled
        ? const Color(0xFFE12529)
        : active
        ? const Color(0xFF2F6FE4)
        : done
        ? const Color(0xFF34C759)
        : const Color(0xFF71829E);

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
                    color: done
                        ? color.withOpacity(0.45)
                        : const Color(0xFFE2E8F0),
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
                  color: done || active
                      ? const Color(0xFF0B1B3A)
                      : const Color(0xFF71829E),
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
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback? onPressed;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onPressed,
  });

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
        elevation: 0,
        padding: const EdgeInsets.symmetric(vertical: 17, horizontal: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      ),
    );
  }
}
