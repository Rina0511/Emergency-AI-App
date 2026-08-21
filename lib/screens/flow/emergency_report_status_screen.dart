import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../l10n/app_localizations.dart';
import '../../routes.dart';

class EmergencyReportStatusScreen extends StatefulWidget {
  const EmergencyReportStatusScreen({super.key});

  @override
  State<EmergencyReportStatusScreen> createState() =>
      _EmergencyReportStatusScreenState();
}

class _EmergencyReportStatusScreenState
    extends State<EmergencyReportStatusScreen> {
  Map<String, dynamic> _data = {};

  bool _isLoadingLocation = false;
  String _location = 'Location not available';

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final args = ModalRoute.of(context)?.settings.arguments;

    if (args is Map<String, dynamic>) {
      _data = Map<String, dynamic>.from(args);
      _location = (_data['location'] ?? 'Location not available').toString();
    }

    _loadLocationIfNeeded();
  }

  Future<void> _loadLocationIfNeeded() async {
    if (_location.startsWith('http')) return;

    setState(() {
      _isLoadingLocation = true;
    });

    final location = await _getRealLocation();

    if (!mounted) return;

    setState(() {
      _location = location;
      _data['location'] = location;
      _isLoadingLocation = false;
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

  String _getEmergencyType(AppLocalizations l10n) {
    return (_data['emergencyType'] ?? _data['type'] ?? l10n.accident)
        .toString();
  }

  String _getSeverity(AppLocalizations l10n) {
    return (_data['severity'] ?? l10n.high).toString();
  }

  String _getResponders() {
    final responders = _data['responders'];

    if (responders is List) {
      return responders.map((e) => e.toString()).join(', ');
    }

    return responders?.toString() ?? 'Ambulance, Police';
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
    if (!_location.startsWith('http')) {
      setState(() {
        _isLoadingLocation = true;
      });

      final location = await _getRealLocation();

      if (!mounted) return;

      setState(() {
        _location = location;
        _data['location'] = location;
        _isLoadingLocation = false;
      });
    }

    if (_location.startsWith('http')) {
      final uri = Uri.parse(_location);

      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        _showSnackBar('Unable to open Google Maps.');
      }
    } else {
      _showSnackBar(_location);
    }
  }

  void _viewLiveTracking() {
    Navigator.pushNamed(
      context,
      AppRoutes.emergencyLiveTracking,
      arguments: {
        ..._data,
        'location': _location,
        'status': 'active',
        'trackingStage': 'sent',
      },
    );
  }

  void _backToApp() {
    Navigator.pushNamedAndRemoveUntil(
      context,
      AppRoutes.mainShell,
      (route) => false,
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
    const successGreen = Color(0xFF34C759);
    const red = Color(0xFFE12529);

    final emergencyType = _getEmergencyType(l10n);
    final severity = _getSeverity(l10n);
    final responders = _getResponders();

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
                      l10n.emergencyReportStatus,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: textDark,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 28),

              Center(
                child: Container(
                  height: 96,
                  width: 96,
                  decoration: const BoxDecoration(
                    color: Color(0xFFEAFBF0),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check_circle,
                    size: 56,
                    color: successGreen,
                  ),
                ),
              ),

              const SizedBox(height: 18),

              const Text(
                'Emergency Report Ready',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                  color: textDark,
                ),
              ),

              const SizedBox(height: 8),

              const Text(
                'Your emergency information is prepared. Please call 999 and keep your location ready.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 15,
                  height: 1.45,
                  color: textSoft,
                  fontWeight: FontWeight.w500,
                ),
              ),

              const SizedBox(height: 24),

              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Column(
                  children: [
                    _EmergencyStatusItem(
                      icon: Icons.warning_amber_rounded,
                      title: 'Emergency Detected',
                      subtitle: 'Emergency information is ready.',
                    ),
                    const SizedBox(height: 16),
                    _EmergencyStatusItem(
                      icon: Icons.location_on_outlined,
                      title: 'Location Ready',
                      subtitle: _isLoadingLocation
                          ? 'Getting current GPS location...'
                          : _location,
                    ),
                    const SizedBox(height: 16),
                    const _EmergencyStatusItem(
                      icon: Icons.call_outlined,
                      title: 'Call Support Ready',
                      subtitle: 'Tap Call 999 to open the phone dialer.',
                    ),
                    const SizedBox(height: 16),
                    const _EmergencyStatusItem(
                      icon: Icons.map_outlined,
                      title: 'Map Ready',
                      subtitle: 'Open Google Maps to view current location.',
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
                    const Text(
                      'Quick Summary',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                        color: textDark,
                      ),
                    ),
                    const SizedBox(height: 14),
                    _EmergencySummaryRow(label: 'Type', value: emergencyType),
                    const SizedBox(height: 12),
                    _EmergencySummaryRow(label: 'Severity', value: severity),
                    const SizedBox(height: 12),
                    _EmergencySummaryRow(label: 'Location', value: _location),
                    const SizedBox(height: 12),
                    _EmergencySummaryRow(
                      label: 'Responders',
                      value: responders,
                    ),
                    const SizedBox(height: 12),
                    const _EmergencySummaryRow(
                      label: 'Tracking Stage',
                      value: 'Sent',
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 22),

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
                onPressed: _isLoadingLocation ? null : _openMap,
                icon: const Icon(Icons.map_outlined),
                label: Text(
                  _isLoadingLocation
                      ? 'Getting Location...'
                      : 'Open Google Maps',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  foregroundColor: primaryBlue,
                  backgroundColor: Colors.white,
                  side: BorderSide.none,
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                ),
              ),

              const SizedBox(height: 12),

              ElevatedButton.icon(
                onPressed: _viewLiveTracking,
                icon: const Icon(Icons.my_location_outlined),
                label: Text(
                  l10n.viewLiveTracking,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ),
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

              const SizedBox(height: 12),

              OutlinedButton.icon(
                onPressed: _backToApp,
                icon: const Icon(Icons.home_outlined),
                label: Text(
                  l10n.backToApp,
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
            ],
          ),
        ),
      ),
    );
  }
}

class _EmergencyStatusItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _EmergencyStatusItem({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    const textDark = Color(0xFF0B1B3A);
    const textSoft = Color(0xFF71829E);
    const successGreen = Color(0xFF34C759);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          height: 42,
          width: 42,
          decoration: BoxDecoration(
            color: const Color(0xFFEAFBF0),
            borderRadius: BorderRadius.circular(999),
          ),
          child: const Icon(Icons.check, color: successGreen),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(icon, size: 18, color: textDark),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      title,
                      style: const TextStyle(
                        fontSize: 15.5,
                        fontWeight: FontWeight.w800,
                        color: textDark,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: const TextStyle(
                  fontSize: 14,
                  color: textSoft,
                  fontWeight: FontWeight.w500,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _EmergencySummaryRow extends StatelessWidget {
  final String label;
  final String value;

  const _EmergencySummaryRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    const textDark = Color(0xFF0B1B3A);
    const textSoft = Color(0xFF71829E);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.right,
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
