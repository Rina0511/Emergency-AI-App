import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../routes.dart';

class AppBottomNav extends StatefulWidget {
  final int currentIndex;

  const AppBottomNav({super.key, required this.currentIndex});

  @override
  State<AppBottomNav> createState() => _AppBottomNavState();
}

class _AppBottomNavState extends State<AppBottomNav> {
  bool _checking = false;

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

  Map<String, dynamic> _argsFromReport(
    QueryDocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data();

    return {
      'reportId': doc.id,
      'emergencyId': doc.id,
      'role': data['reporterRole'] ?? 'victim',
      'emergencyType': data['emergencyType'] ?? 'Emergency',
      'confidence': data['confidence'] ?? 0,
      'severity': data['severity'] ?? 'High',
      'summary': data['summary'] ?? '',
      'evidence': data['evidence'] ?? [],
      'responders': data['responders'] ?? [],
      'equipment': data['equipment'] ?? [],
      'safetySteps': data['safetySteps'] ?? [],
      'location': data['location'] ?? 'Location not shared',
      'status': data['status'] ?? 'active',
      'trackingStage': data['trackingStage'] ?? 'sent',
    };
  }

  Future<void> _openDetect(BuildContext context) async {
    setState(() => _checking = true);

    try {
      final activeReport = await _findActiveEmergency();
      if (!mounted) return;

      if (activeReport != null) {
        Navigator.pushNamed(
          context,
          AppRoutes.guidance,
          arguments: _argsFromReport(activeReport),
        );
      } else {
        Navigator.pushNamed(context, AppRoutes.reportRole);
      }
    } finally {
      if (mounted) setState(() => _checking = false);
    }
  }

  Future<void> _openTracking(BuildContext context) async {
    setState(() => _checking = true);

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
        Navigator.pushNamed(context, AppRoutes.liveTracking);
      }
    } finally {
      if (mounted) setState(() => _checking = false);
    }
  }

  void _onTap(BuildContext context, int index) {
    if (_checking) return;

    switch (index) {
      case 0:
        Navigator.pushNamedAndRemoveUntil(
          context,
          AppRoutes.mainShell,
          (route) => false,
          arguments: 0,
        );
        break;
      case 1:
        _openDetect(context);
        break;
      case 2:
        _openTracking(context);
        break;
      case 3:
        Navigator.pushNamedAndRemoveUntil(
          context,
          AppRoutes.mainShell,
          (route) => false,
          arguments: 3,
        );
        break;

      case 4:
        Navigator.pushNamedAndRemoveUntil(
          context,
          AppRoutes.mainShell,
          (route) => false,
          arguments: 4,
        );
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final navColor = isDark ? const Color(0xFF162033) : Colors.white;

    final borderColor = isDark ? Colors.white12 : const Color(0xFFE6ECF5);

    final unselectedColor = isDark ? Colors.white70 : const Color(0xFF71829E);

    const primaryBlue = Color(0xFF2F6FE4);

    return Container(
      decoration: BoxDecoration(
        color: navColor,
        border: Border(top: BorderSide(color: borderColor)),
      ),
      child: SafeArea(
        top: false,
        child: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          currentIndex: widget.currentIndex,
          onTap: (value) => _onTap(context, value),
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
              icon: Icon(Icons.history_outlined),
              activeIcon: Icon(Icons.history),
              label: 'History',
            ),
          ],
        ),
      ),
    );
  }
}
