import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../routes.dart';
import 'home_screen.dart';
import 'emergency_profile_screen.dart';
import 'assist_screen.dart';
import '../flow/live_tracking_screen.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _index = 0;
  bool _checkingActiveEmergency = false;

  final List<Widget> _tabs = const [
    HomeScreen(),
    SizedBox(),
    LiveTrackingScreen(),
    EmergencyProfileScreen(),
    AssistScreen(),
  ];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final args = ModalRoute.of(context)?.settings.arguments;

    if (args is int && args >= 0 && args <= 4 && _index != args) {
      setState(() => _index = args);
    }
  }

  Future<QueryDocumentSnapshot<Map<String, dynamic>>?>
  _findActiveEmergency() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return null;

    final snapshot = await FirebaseFirestore.instance
        .collection('emergency_reports')
        .where('userId', isEqualTo: user.uid)
        .where('status', isEqualTo: 'active')
        .get();

    final activeDocs = snapshot.docs.where((doc) {
      final data = doc.data();

      final status = (data['status'] ?? '').toString().toLowerCase().trim();
      final stage = (data['trackingStage'] ?? '')
          .toString()
          .toLowerCase()
          .trim();

      return status == 'active' && stage != 'completed' && stage != 'cancelled';
    }).toList();

    if (activeDocs.isEmpty) return null;

    activeDocs.sort((a, b) {
      final aTime = a.data()['updatedAt'] ?? a.data()['createdAt'];
      final bTime = b.data()['updatedAt'] ?? b.data()['createdAt'];

      if (aTime is Timestamp && bTime is Timestamp) {
        return bTime.compareTo(aTime);
      }

      return 0;
    });

    return activeDocs.first;
  }

  Future<void> _handleDetectTab() async {
    if (_checkingActiveEmergency) return;

    setState(() => _checkingActiveEmergency = true);

    try {
      final activeReport = await _findActiveEmergency();

      if (!mounted) return;

      if (activeReport != null) {
        final data = activeReport.data();

        Navigator.pushNamed(
          context,
          AppRoutes.guidance,
          arguments: {
            'reportId': activeReport.id,
            'emergencyId': activeReport.id,
            'role': data['reporterRole'] ?? 'victim',
            'emergencyType': data['emergencyType'] ?? 'Emergency',
            'confidence': data['confidence'] ?? 0,
            'severity': data['severity'] ?? 'High',
            'summary': data['summary'] ?? '',
            'evidence': data['evidence'] ?? [],
            'responders': data['responders'] ?? [],
            'equipment': data['equipment'] ?? [],
            'safetySteps': data['safetySteps'] ?? [],
            'location': data['location'] ?? '',
            'status': data['status'] ?? 'active',
            'trackingStage': data['trackingStage'] ?? 'sent',
          },
        );
      } else {
        Navigator.pushNamed(context, AppRoutes.reportRole);
      }
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to check active emergency: $e')),
      );

      Navigator.pushNamed(context, AppRoutes.reportRole);
    } finally {
      if (mounted) setState(() => _checkingActiveEmergency = false);
    }
  }

  Future<void> _handleTrackingTab() async {
    if (_checkingActiveEmergency) return;

    setState(() => _checkingActiveEmergency = true);

    try {
      final activeReport = await _findActiveEmergency();

      if (!mounted) return;

      if (activeReport != null) {
        Navigator.pushNamed(
          context,
          AppRoutes.liveTracking,
          arguments: {
            'reportId': activeReport.id,
            'emergencyId': activeReport.id,
          },
        );
      } else {
        setState(() => _index = 2);
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _index = 2);
    } finally {
      if (mounted) setState(() => _checkingActiveEmergency = false);
    }
  }

  void _onTabTapped(int value) {
    if (value == 1) {
      _handleDetectTab();
      return;
    }

    if (value == 2) {
      _handleTrackingTab();
      return;
    }

    setState(() => _index = value);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final navColor = isDark ? const Color(0xFF162033) : Colors.white;

    final borderColor = isDark ? Colors.white12 : const Color(0xFFE6ECF5);

    final unselectedColor = isDark ? Colors.white70 : const Color(0xFF71829E);

    final overlayColor = isDark
        ? Colors.black.withOpacity(0.35)
        : Colors.black.withOpacity(0.08);

    const primaryBlue = Color(0xFF2F6FE4);

    return Scaffold(
      body: Stack(
        children: [
          IndexedStack(index: _index, children: _tabs),
          if (_checkingActiveEmergency)
            Container(
              color: overlayColor,
              child: const Center(
                child: CircularProgressIndicator(color: primaryBlue),
              ),
            ),
        ],
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: navColor,
          border: Border(top: BorderSide(color: borderColor)),
        ),
        child: SafeArea(
          top: false,
          child: BottomNavigationBar(
            type: BottomNavigationBarType.fixed,
            currentIndex: _index,
            onTap: _onTabTapped,
            backgroundColor: navColor,
            elevation: 0,
            selectedItemColor: primaryBlue,
            unselectedItemColor: unselectedColor,
            selectedLabelStyle: const TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 12,
            ),
            unselectedLabelStyle: const TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: 12,
            ),
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.home_outlined),
                activeIcon: Icon(Icons.home),
                label: 'Home',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.center_focus_weak_outlined),
                activeIcon: Icon(Icons.center_focus_weak),
                label: 'Detect',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.my_location_outlined),
                activeIcon: Icon(Icons.my_location),
                label: 'Tracking',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.person_outline),
                activeIcon: Icon(Icons.person),
                label: 'Profile',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.health_and_safety_outlined),
                activeIcon: Icon(Icons.health_and_safety),
                label: 'Assist',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
